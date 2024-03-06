import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScannerBarCodePage extends StatefulWidget {
  @override
  _ScannerBarCodePageState createState() => _ScannerBarCodePageState();
}

class _ScannerBarCodePageState extends State<ScannerBarCodePage> {
  String barcode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner Barcode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Risultato:',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20.0),
            Text(
              barcode,
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                scanBarcode();
              },
              child: Text('Scansiona'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> scanBarcode() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode('#004297', 'Annulla', true, ScanMode.BARCODE);
      setState(() {
        this.barcode = barcode;
      });
    } catch (e) {
      setState(() {
        this.barcode = 'Errore nella scansione del barcode: $e';
      });
    }
  }
}
