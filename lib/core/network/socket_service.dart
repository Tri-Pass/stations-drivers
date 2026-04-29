import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:pro.stations.wetaxi.ma/core/env.dart';

// ─── Connection state machine ─────────────────────────────────────────────────

enum SocketConnectionStatus { idle, connecting, connected, reconnecting, dead }

// ─── Channel event ────────────────────────────────────────────────────────────

class SocketEvent {
  final String channel;
  final dynamic data;
  const SocketEvent({required this.channel, required this.data});
}

// ─── Channel subscription ─────────────────────────────────────────────────────

class SocketChannel {
  final String channel;
  final String? owner;
  const SocketChannel({required this.channel, this.owner});
}

// ─────────────────────────────────────────────────────────────────────────────

class SocketService with WidgetsBindingObserver {
  static const _wsUrl = Env.socketCluster;

  // Timing constants (mirror RN values)
  static const _pingIntervalMs = 60000; // 1 min keepalive
  static const _heartbeatTimeoutMs = 660000; // 11 min watchdog
  static const _handshakeTimeoutMs = 10000; // 10 s handshake timeout
  static const _reconnectBaseMs = 3000; // base backoff
  static const _reconnectMaxMs = 30000; // backoff cap
  static const _reconnectMaxAttempts = 20;

  // ── Core ───────────────────────────────────────────────────────────────────
  WebSocketChannel? _ws;
  String? _authToken;
  int _cid = 0;
  int _pendingHandshakeCid = -1;

  // ── State machine ──────────────────────────────────────────────────────────
  SocketConnectionStatus _status = SocketConnectionStatus.idle;
  final _statusController =
      StreamController<SocketConnectionStatus>.broadcast();
  Stream<SocketConnectionStatus> get statusStream => _statusController.stream;
  SocketConnectionStatus get status => _status;

  // ── Events broadcast (consumed by BLoCs) ───────────────────────────────────
  final _eventsController = StreamController<SocketEvent>.broadcast();
  Stream<SocketEvent> get events => _eventsController.stream;

  // ── Channel registry ───────────────────────────────────────────────────────
  final _channels = <String, SocketChannel>{};
  final _activeChannels = <String>{};

  // ── Reconnect ──────────────────────────────────────────────────────────────
  int _attempts = 0;
  bool _destroyed = false;
  Timer? _reconnectTimer;

  // ── Timers ─────────────────────────────────────────────────────────────────
  Timer? _pingTimer;
  Timer? _heartbeatTimer;
  Timer? _handshakeTimer;

  // ── Outgoing queue (while disconnected) ────────────────────────────────────
  final _queue = <Map<String, dynamic>>[];

  // ── App lifecycle ──────────────────────────────────────────────────────────
  bool _inBackground = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC API
  // ═══════════════════════════════════════════════════════════════════════════

  bool get isConnected => _status == SocketConnectionStatus.connected;

  /// Connect (or reconnect) with a new auth token.
  void connect(String authToken) {
    _authToken = authToken;
    _destroyed = false;
    _attempts = 0;
    WidgetsBinding.instance.addObserver(this);
    _openSocket();
  }

  /// Update token without reconnecting (e.g. after token refresh).
  void updateToken(String token) => _authToken = token;

  /// Subscribe to a channel. Auto-sends #subscribe if already connected.
  void subscribe(SocketChannel config) {
    _channels[config.channel] = config;
    if (_status == SocketConnectionStatus.connected &&
        !_activeChannels.contains(config.channel)) {
      _sendSubscribe(config.channel);
    }
  }

  /// Unsubscribe from a specific channel.
  void unsubscribe(String channel) {
    _channels.remove(channel);
    _activeChannels.remove(channel);
    if (_status == SocketConnectionStatus.connected) {
      _sendUnsubscribe(channel);
    }
  }

  /// Remove all channels belonging to an owner (e.g. on screen unmount).
  void unsubscribeByOwner(String owner) {
    final toRemove = _channels.entries
        .where((e) => e.value.owner == owner)
        .map((e) => e.key)
        .toList();
    for (final ch in toRemove) {
      unsubscribe(ch);
    }
  }

  /// Graceful disconnect — preserves channel config for reconnect.
  void disconnect() {
    _destroyed = true;
    _clearAllTimers();
    WidgetsBinding.instance.removeObserver(this);
    _activeChannels.clear();
    _ws?.sink.close();
    _ws = null;
    _setStatus(SocketConnectionStatus.idle);
  }

  /// Full teardown — call on logout.
  void destroy() {
    disconnect();
    _channels.clear();
    _queue.clear();
    _cid = 0;
    _attempts = 0;
  }

  /// Emit a custom event to the server (queued if disconnected).
  void emit(String event, dynamic data) {
    final msg = <String, dynamic>{'event': event, 'data': data, 'cid': ++_cid};
    if (_status == SocketConnectionStatus.connected) {
      _rawSend(msg);
    } else {
      _queue.add(msg);
    }
  }

  /// Manual retry after reaching DEAD state.
  void forceReconnect() {
    if (_status == SocketConnectionStatus.dead ||
        _status == SocketConnectionStatus.idle) {
      _destroyed = false;
      _attempts = 0;
      _openSocket();
    }
  }

  void dispose() {
    destroy();
    _statusController.close();
    _eventsController.close();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // APP LIFECYCLE  (mirrors RN AppState listener)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Going to background — pause everything to save battery
      _inBackground = true;
      _clearReconnectTimer();
      _clearHeartbeat();
      _stopPing();
    } else if (state == AppLifecycleState.resumed) {
      // Came to foreground
      _inBackground = false;
      if (_status == SocketConnectionStatus.connected) {
        _startPing();
      } else if (!_destroyed) {
        _attempts = 0;
        _clearReconnectTimer();
        _openSocket();
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SOCKET LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  void _openSocket() {
    // Tear down any previous socket cleanly
    if (_ws != null) {
      _stopPing();
      _ws!.sink.close();
      _ws = null;
    }

    if (_status != SocketConnectionStatus.reconnecting) {
      _setStatus(SocketConnectionStatus.connecting);
    }

    try {
      _ws = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _ws!.stream.listen(
        _onMessage,
        onDone: _onDone,
        onError: (_) {},
        cancelOnError: false,
      );

      // Send handshake immediately — store cid to match the response
      _pendingHandshakeCid = ++_cid;
      _rawSend({
        'event': '#handshake',
        'data': {'authToken': _authToken},
        'cid': _pendingHandshakeCid,
      });

      _resetHeartbeat();

      // Handshake timeout (10 s) — force-close if server never responds
      _handshakeTimer?.cancel();
      _handshakeTimer = Timer(
        const Duration(milliseconds: _handshakeTimeoutMs),
        () {
          if (_status != SocketConnectionStatus.connected) _ws?.sink.close();
        },
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MESSAGE PARSER  (mirrors RN _onMessage exactly)
  // ═══════════════════════════════════════════════════════════════════════════

  void _onMessage(dynamic raw) {
    // Legacy SC raw ping "#1" or empty keepalive frame
    if (raw == '#1' || raw == null || (raw as String).isEmpty) {
      _resetHeartbeat();
      _ws?.sink.add('#2');
      return;
    }

    Map<String, dynamic> frame;
    try {
      frame = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final event = frame['event'] as String?;
    final data = frame['data'];
    final rid = frame['rid'] as int?;
    final cid = frame['cid'] as int?;
    final action = frame['action'] as String?;

    // Custom action-based publish (server → client alternative protocol)
    if (action == 'publish') {
      final channel = frame['channel'] as String?;
      if (channel != null) _dispatchChannel(channel, data);
      return;
    }

    // Handshake ACK — match by stored cid, not hardcoded 1
    if (event == null && rid != null && rid == _pendingHandshakeCid) {
      _handshakeTimer?.cancel();
      _pendingHandshakeCid = -1;
      _attempts = 0;
      _setStatus(SocketConnectionStatus.connected);
      _startPing();
      _resubscribeAll();
      _flushQueue();
      return;
    }

    // ACK for any other outgoing message
    if (event == null && rid != null) {
      _resetHeartbeat();
      return;
    }

    switch (event) {
      case '#ping':
        // Server ping → respond with pong
        _ws?.sink.add(jsonEncode({'event': '#pong', 'data': {}, 'rid': cid}));
        _resetHeartbeat();
        break;

      case '#publish':
        final pub = data as Map<String, dynamic>?;
        final channel = pub?['channel'] as String?;
        if (channel != null) _dispatchChannel(channel, pub?['data']);
        break;

      case '#removeAuthToken':
        _authToken = null;
        break;

      case '#setAuthToken':
        final t = data as Map<String, dynamic>?;
        _authToken = t?['token'] as String?;
        break;

      default:
        if (event != null) {
          _dispatchChannel(event, data);
          if (cid != null) _sendAck(cid);
        }
    }
  }

  void _onDone() {
    _stopPing();
    _clearHeartbeat();
    _activeChannels.clear();
    if (!_destroyed) {
      _setStatus(SocketConnectionStatus.reconnecting);
      _scheduleReconnect();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DISPATCH
  // ═══════════════════════════════════════════════════════════════════════════

  void _dispatchChannel(String channel, dynamic data) {
    if (!_eventsController.isClosed) {
      _eventsController.add(SocketEvent(channel: channel, data: data));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUBSCRIPTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  void _resubscribeAll() {
    for (final ch in _channels.keys) {
      if (!_activeChannels.contains(ch)) _sendSubscribe(ch);
    }
  }

  void _sendSubscribe(String channel) {
    _rawSend({
      'event': '#subscribe',
      'data': {'channel': channel},
      'cid': ++_cid,
    });
    _activeChannels.add(channel);
  }

  void _sendUnsubscribe(String channel) {
    _rawSend({'event': '#unsubscribe', 'data': channel, 'cid': ++_cid});
  }

  void _sendAck(int cid) {
    _ws?.sink.add(jsonEncode({'rid': cid, 'error': null, 'data': null}));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OUTGOING QUEUE
  // ═══════════════════════════════════════════════════════════════════════════

  void _flushQueue() {
    final q = List<Map<String, dynamic>>.from(_queue);
    _queue.clear();
    for (final msg in q) {
      _rawSend(msg);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RECONNECT — exponential backoff + ±20% jitter  (mirrors RN exactly)
  // ═══════════════════════════════════════════════════════════════════════════

  void _scheduleReconnect() {
    if (_destroyed || _inBackground) return;

    if (_attempts >= _reconnectMaxAttempts) {
      _setStatus(SocketConnectionStatus.dead);
      return;
    }

    final base = _reconnectBaseMs * pow(1.5, _attempts);
    final jitter = base * 0.2 * (Random().nextDouble() - 0.5);
    final delay = min(base + jitter, _reconnectMaxMs.toDouble()).toInt();

    _attempts++;
    _clearReconnectTimer();
    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      if (!_destroyed && !_inBackground) _openSocket();
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLIENT KEEPALIVE PING  (every 1 min, mirrors RN)
  // ═══════════════════════════════════════════════════════════════════════════

  void _startPing() {
    _stopPing();
    _pingTimer = Timer.periodic(
      const Duration(milliseconds: _pingIntervalMs),
      (_) => _rawSend({
        'event': '#ping',
        'data': {'timestamp': DateTime.now().millisecondsSinceEpoch},
        'cid': ++_cid,
      }),
    );
  }

  void _stopPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEARTBEAT WATCHDOG  (11-min timeout, mirrors RN)
  // ═══════════════════════════════════════════════════════════════════════════

  void _resetHeartbeat() {
    _clearHeartbeat();
    _heartbeatTimer = Timer(
      const Duration(milliseconds: _heartbeatTimeoutMs),
      () => _ws?.sink.close(),
    );
  }

  void _clearHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _clearReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _clearAllTimers() {
    _stopPing();
    _clearHeartbeat();
    _clearReconnectTimer();
    _handshakeTimer?.cancel();
    _handshakeTimer = null;
  }

  void _rawSend(Map<String, dynamic> msg) {
    try {
      _ws?.sink.add(jsonEncode(msg));
    } catch (_) {}
  }

  void _setStatus(SocketConnectionStatus next) {
    if (_status == next) return;
    _status = next;
    if (!_statusController.isClosed) _statusController.add(next);
  }
}
