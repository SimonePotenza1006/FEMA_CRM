import 'dart:developer';

import 'package:fema_crm/model/DDTModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_qr/native_qr.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../model/InterventoModel.dart';

class ScannerQrCodePage extends StatefulWidget {
  final DDTModel DDT;

  ScannerQrCodePage({Key? key, required this.DDT}) : super(key: key);

  @override
  _ScannerQrCodePageState createState() => _ScannerQrCodePageState();
}

class _ScannerQrCodePageState extends State<ScannerQrCodePage> {
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool qrRead = false;
  String qrData = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Compilazione Documento di trasporto',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: _buildQrView(context),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (!qrRead) {
        qrRead = true;
        setState(() {
          qrData = scanData.code!;
        });
        _handleQRData();
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  void _initializeCamera() {
    controller?.resumeCamera();
  }

  void _handleQRData() {
    List<String> qrDataParts = qrData.split(',');
    // Rimuovi le ultime tre proprietà
    qrDataParts.removeRange(qrDataParts.length - 3, qrDataParts.length);
    qrData = qrDataParts.join(',');
    _showQRModal(qrData);
    controller.stopCamera();
  }

  void _showQRModal(String qrCode) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Informazioni prodotto',
                style: TextStyle(fontSize: 30, color: Colors.black),
              ),
              SizedBox(height: 20),
              Text(
                qrCode,
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Allega al DDT',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
    qrRead = false;
    controller.resumeCamera();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
