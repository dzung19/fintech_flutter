// =============================================================================
// File: lib/core/hardware/nfc_service.dart
// Purpose: Hardware abstraction for NFC capabilities.
// =============================================================================

import 'dart:async';
import 'package:nfc_manager/nfc_manager.dart';
import '../errors/failures.dart';
import '../utils/result.dart';

abstract class NfcService {
  /// Checks if NFC is available on this device.
  Future<bool> isAvailable();

  /// Starts an NFC session and waits for a single tag to be read.
  /// Returns a Map of tag data on success, or a Failure on error.
  Future<Result<Map<String, dynamic>>> readSingleTag({
    String message = 'Hold your device near the tag',
  });
}

class NfcServiceImpl implements NfcService {
  @override
  Future<bool> isAvailable() async {
    return (await NfcManager.instance.checkAvailability()) ==
        NfcAvailability.enabled;
  }

  @override
  Future<Result<Map<String, dynamic>>> readSingleTag({
    String message = 'Hold your device near the tag',
  }) async {
    bool isAvailable =
        (await NfcManager.instance.checkAvailability()) ==
        NfcAvailability.enabled;
    if (!isAvailable) {
      return const Err(
        CacheFailure(
          message: 'NFC is not available or disabled on this device.',
        ),
      );
    }

    try {
      // Create a Completer to wait for the callback
      final completer = Completer<Result<Map<String, dynamic>>>();

      await NfcManager.instance.startSession(
        pollingOptions: const {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (NfcTag tag) async {
          // Stop session immediately after first read
          await NfcManager.instance.stopSession();

          if (!completer.isCompleted) {
            completer.complete(const Success(<String, dynamic>{}));
          }
        },
      );

      return await completer.future;
    } catch (e) {
      await NfcManager.instance.stopSession();
      return Err(CacheFailure(message: 'Failed to read NFC tag: $e'));
    }
  }
}
