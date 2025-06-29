import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../../controllers/memory_controller.dart';
import '../../utils/snackbar_helper.dart';
import 'create_memory_screen.dart';

class NfcScanScreen extends StatefulWidget {
  const NfcScanScreen({Key? key}) : super(key: key);

  @override
  NfcScanScreenState createState() => NfcScanScreenState();
}

class NfcScanScreenState extends State<NfcScanScreen> {
  final MemoryController memoryController = Get.find<MemoryController>();
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  Future<void> _checkNfcAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      SnackbarHelper.showError(
        'NFC Not Available',
        'Your device does not support NFC or it is disabled.',
      );
    }
  }

  Future<void> _startNfcScan() async {
    setState(() => isScanning = true);

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final ndefTag = Ndef.from(tag);
            if (ndefTag == null) {
              throw 'Tag is not NDEF compatible';
            }

            // Read existing URL if available
            String? existingUrl;
            if (ndefTag.cachedMessage != null) {
              final records = ndefTag.cachedMessage!.records;
              if (records.isNotEmpty && records.first.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
                final uriRecord = Uri.tryParse(String.fromCharCodes(records.first.payload.skip(1)));
                if (uriRecord != null) {
                  existingUrl = uriRecord.toString();
                }
              }
            }

            await NfcManager.instance.stopSession();
            setState(() => isScanning = false);
            memoryController.nfcScanResult.value = existingUrl;

            // Navigate to create memory screen with the existing URL if found
            Get.to(() => CreateMemoryScreen(existingNfcUrl: existingUrl));
          } catch (e) {
            await NfcManager.instance.stopSession();
            setState(() => isScanning = false);
            SnackbarHelper.showError('Error', e.toString());
          }
        },
      );
    } catch (e) {
      setState(() => isScanning = false);
      SnackbarHelper.showError('Error', 'Failed to start NFC scan: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan NFC Tag'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.nfc, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              isScanning ? 'Scanning for NFC tag...' : 'Tap to scan NFC tag',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isScanning ? null : _startNfcScan,
              child: const Text('Start Scan'),
            ),
            const SizedBox(height: 24),
            if (memoryController.nfcScanResult.value != null)
              Column(
                children: <Widget>[
                  const Text('NFC Tag Data:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(memoryController.nfcScanResult.value ?? ''),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }
}
