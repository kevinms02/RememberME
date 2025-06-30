import 'package:nfc_manager/nfc_manager.dart';
import 'package:get/get.dart';

class NfcService extends GetxService {
  var isNfcAvailable = false.obs;
  var isNfcEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkNfcAvailability();
  }

  Future<void> checkNfcAvailability() async {
    isNfcAvailable.value = await NfcManager.instance.isAvailable();
  }

  Future<String?> readNfcTag() async {
    if (!isNfcAvailable.value) {
      return null;
    }

    String? result;
    
    try {
      await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef != null && ndef.cachedMessage != null) {
          var records = ndef.cachedMessage!.records;
          if (records.isNotEmpty) {
            var payload = records.first.payload;
            var text = String.fromCharCodes(payload.skip(3));
            result = text;
          }
        }
        await NfcManager.instance.stopSession();
      });
    } catch (e) {
      await NfcManager.instance.stopSession(errorMessage: 'Error reading NFC tag');
      throw Exception('Failed to read NFC tag: $e');
    }

    return result;
  }

  Future<bool> writeNfcTag(String url) async {
    if (!isNfcAvailable.value) {
      return false;
    }

    bool success = false;

    try {
      await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef != null && ndef.isWritable) {
          NdefMessage message = NdefMessage([
            NdefRecord.createText(url),
          ]);
          
          await ndef.write(message);
          success = true;
        }
        await NfcManager.instance.stopSession();
      });
    } catch (e) {
      await NfcManager.instance.stopSession(errorMessage: 'Error writing to NFC tag');
      throw Exception('Failed to write to NFC tag: $e');
    }

    return success;
  }

  Future<void> stopSession() async {
    await NfcManager.instance.stopSession();
  }
}