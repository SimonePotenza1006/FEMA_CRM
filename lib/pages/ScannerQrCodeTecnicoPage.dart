import 'dart:convert';
import 'dart:developer';

import 'package:fema_crm/model/DDTModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_qr/native_qr.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import '../model/InterventoModel.dart';
import '../model/ProdottoModel.dart';
import 'CompilazioneDDTByTecnicoPage.dart';

class ScannerQrCodeTecnicoPage extends StatefulWidget {
  final InterventoModel intervento;

  ScannerQrCodeTecnicoPage({
    Key? key,
    required this.intervento,
  }) : super(key: key);

  @override
  _ScannerQrCodeTecnicoPageState createState() => _ScannerQrCodeTecnicoPageState();
}

class _ScannerQrCodeTecnicoPageState extends State<ScannerQrCodeTecnicoPage> {
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool qrRead = false;
  String qrData = "";
  List<ProdottoModel> prodottiDaAggiungere = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  void initState() {
    super.initState();
    savePrimeDDT();
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
                  _callApiAndPrintResult(qrCode);
                },
                child: Text(
                  'Allega prodotto al DDT',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CompilazioneDDTByTecnicoPage(
                            intervento: widget.intervento,
                            prodotti: prodottiDaAggiungere)),
                  );
                },
                child: Text(
                  'Conferma',
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

  Future<void> _callApiAndPrintResult(String qrCode) async {
    // Estrai i parametri dal QR code
    List<String> qrDataParts = qrCode.split(',');
    // Rimuovi l'ultima virgola da ogni parte
    qrDataParts = qrDataParts.map((part) => part.trim()).toList();
    // Estrai i parametri
    String codiceDanea = qrDataParts[0].substring(14);
    String lottoSeriale = qrDataParts[1].substring(15);

    print(lottoSeriale);
    print(codiceDanea);

    // Effettua la chiamata API con un timeout di 10 secondi
    String apiUrl = '$ipaddressProva/api/prodotto/DDT/$codiceDanea/$lottoSeriale';
    final response =
    await http.get(Uri.parse(apiUrl)).timeout(Duration(seconds: 10));

    // Controlla lo stato della risposta
    if (response.statusCode == 200) {
      print('Chiamata API riuscita. Risposta:');
      print(json.decode(response.body));

      var responseData = json.decode(response.body);
      ProdottoModel prodotto = ProdottoModel.fromJson(responseData);
      prodottiDaAggiungere.add(prodotto);
      print(prodottiDaAggiungere.toList());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prodotto aggiunto con successo'),
          duration: Duration(seconds: 3), // Durata dello Snackbar
        ),
      );
    } else {
      print('Errore durante la chiamata API: ${response.statusCode}');
    }
  }

  Future<void> savePrimeDDT() async {
    try {
      Map<String, dynamic> body = {
        'data': widget.intervento.data?.toIso8601String(),
        'orario': DateTime.now().toIso8601String(),
        'concluso': false,
        'firmaUser': null,
        'imageData': null,
        'cliente': widget.intervento.cliente?.toMap(),
        'destinazione': widget.intervento.destinazione?.toMap(),
        'categoriaDdt': {'id': 1, 'descrizione': "DDT Intervento"},
        'utente': widget.intervento.utente?.toMap(),
        'intervento': widget.intervento.toMap(),
        'relazioni_prodotti': null,
      };

      debugPrint('Body della richiesta: $body', wrapWidth: 1024);

      final response = await http.post(
        Uri.parse('$ipaddressProva/api/ddt'),
        body: jsonEncode(body),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Risposta: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        print('DDT inizializzato, daje');
      } else {
        print('Qualcosa non va');
      }
    } catch (e) {
      print('Errore: $e');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
