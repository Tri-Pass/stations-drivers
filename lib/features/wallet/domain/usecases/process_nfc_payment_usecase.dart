// Replaced by RechargeClientUseCase
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';

Future<void> readNfcId() async {
  // Check if NFC is available
  bool isAvailable = await NfcManager.instance.checkAvailability() == NfcAvailability.disabled;

  if (!isAvailable) {
    debugPrint('NFC not available on this device');
    return;
  }

  // Start session
  NfcManager.instance.startSession(
    pollingOptions: {
      NfcPollingOption.iso14443,
      NfcPollingOption.iso15693,
    },
    onDiscovered: (NfcTag tag) async {
      String? tagId;

      // tag.handle is the raw map — loop through to find 'identifier'
      for (final tech in (tag as dynamic).additionalData.values) {
        if (tech is Map && tech['identifier'] != null) {
          final identifier = tech['identifier'] as List<dynamic>;
          tagId = identifier
              .map((e) => (e as int).toRadixString(16).padLeft(2, '0').toUpperCase())
              .join(':');
          break;
        }
      }

      debugPrint('NFC Tag ID: $tagId');
      await NfcManager.instance.stopSession();
    },
  );
}