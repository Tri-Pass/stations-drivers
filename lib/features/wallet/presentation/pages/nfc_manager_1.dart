import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcScanScreen extends StatefulWidget {
  const NfcScanScreen({super.key});

  @override
  State<NfcScanScreen> createState() => _NfcScanScreenState();
}

class _NfcScanScreenState extends State<NfcScanScreen> {
  String _tagId = 'Waiting for NFC tag...';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _startNfcListening(); // ← starts automatically when screen opens
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession(); // ← stops when screen closes
    super.dispose();
  }

  Future<void> _startNfcListening() async {
    final availability = await NfcManager.instance.checkAvailability();
    if (availability != NfcAvailability.enabled) {
      setState(() => _tagId = 'NFC is not available on this device');
      return;
    }

    setState(() => _isListening = true);

    NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
      },
      onDiscovered: (NfcTag tag) async {
        // Extract the ID
        String? tagId = _extractTagId(tag);

        setState(() => _tagId = tagId ?? 'Could not read tag ID');

        // ✅ Restart session so it keeps listening for next tap
        await NfcManager.instance.stopSession();
        _startNfcListening();
      },
    );
  }

  String? _extractTagId(NfcTag tag) {
    try {
      // Try getting identifier from all available techs
      final techList = (tag as dynamic).additionalData as Map?;
      if (techList != null) {
        for (final tech in techList.values) {
          if (tech is Map && tech['identifier'] != null) {
            final identifier = tech['identifier'] as List<dynamic>;
            return identifier
                .map((e) => (e as int)
                .toRadixString(16)
                .padLeft(2, '0')
                .toUpperCase())
                .join(':');
          }
        }
      }
    } catch (e) {
      debugPrint('Error reading tag: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // NFC icon
            Icon(
              Icons.nfc,
              size: 100,
              color: _isListening ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              _isListening ? 'Tap your card...' : 'Starting NFC...',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 16),
            // Show the tag ID
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _tagId,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}