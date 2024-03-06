import 'dart:convert';

import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/pages/ScannerQrCodePage.dart';
import 'package:flutter/material.dart';
import '../model/InterventoModel.dart';
import '../model/DDTModel.dart';
import 'package:http/http.dart' as http;

class CompilazioneDDTByTecnicoPage extends StatefulWidget {
  final InterventoModel intervento;

  const CompilazioneDDTByTecnicoPage({Key? key, required this.intervento}) : super(key: key);

  @override
  _CompilazioneDDTByTecnicoPageState createState() => _CompilazioneDDTByTecnicoPageState();
}

class _CompilazioneDDTByTecnicoPageState extends State<CompilazioneDDTByTecnicoPage> {
  DDTModel? ddt;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDdtByIntervento();
  }

  Future<void> getDdtByIntervento() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.52:8080/api/ddt/intervento/${widget.intervento.id}'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          ddt = DDTModel.fromJson(responseData);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load DDT per cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Compilazione Documento di trasporto',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (ddt != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Numero DDT: ${ddt!.id}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Data: ${_formatDate(ddt!.data!)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Orario: ${_formatTime(ddt!.orario!)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Concluso: ${ddt!.concluso}',
                    style: TextStyle(fontSize: 16),
                  ),
                  // Aggiungi altri dettagli del DDT secondo la tua struttura di dati
                ],
              )
            else
              Text(
                'Si è verificato un errore durante il recupero del DDT',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => ScannerQrCodePage(DDT: ddt!)));
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Scansiona QRCODE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
