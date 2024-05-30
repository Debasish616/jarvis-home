import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isFlashOn = false;
  bool isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.appYellow,
              borderRadius: 20,
              borderLength: 70,
              borderWidth: 10,
              cutOutSize: 315,
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: IconButton(
                icon: Icon(
                  isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.black,
                  size: 25,
                ),
                onPressed: _toggleFlash,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isDrawerOpen = !isDrawerOpen;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: MediaQuery.of(context).size.width -
                    0, // Set width to cover full screen width
                height:
                    isDrawerOpen ? MediaQuery.of(context).size.height / 4 : 60,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Instructions',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.appYellow),
                        ),
                        const Spacer(),
                        Icon(
                          isDrawerOpen
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          size: 24,
                        ),
                      ],
                    ),
                    if (isDrawerOpen)
                      const Column(
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Your instructions here...',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      if (scanData.code != null) {
        // Decode the JSON data// tap on id// phone connect// itr list// user clicl// connect---

        Map<String, dynamic> bleInfo = jsonDecode(scanData.code!);
        String deviceName = bleInfo['device_name'];
        String serviceUuid = bleInfo['service_uuid'];
        String characteristicUuid = bleInfo['characteristic_uuid'];

        FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
        FlutterBluePlus.scanResults.listen((results) {
          for (ScanResult r in results) {
            if (r.device.platformName == deviceName) {
              FlutterBluePlus.stopScan();
              r.device.connect();
              r.device.discoverServices().then((services) {
                services.forEach((service) {
                  if (service.uuid.toString() == serviceUuid) {
                    service.characteristics.forEach((characteristic) {
                      if (characteristic.uuid.toString() ==
                          characteristicUuid) {
                        // Perform operations on the characteristic
                      }
                    });
                  }
                });
              });
            }
          }
        });
      }
    });
  }

  void _toggleFlash() {
    if (controller != null) {
      controller!.toggleFlash();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
