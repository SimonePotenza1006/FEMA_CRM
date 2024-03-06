import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fema_crm/pages/HomeFormAmministrazione.dart';
import 'package:fema_crm/pages/HomeFormTecnico.dart';
import 'package:fema_crm/pages/RegistroCassaPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:http/http.dart' as http;
import '../model/MovimentiModel.dart';
import '../model/UtenteModel.dart';

class AggiungiMovimentoPage extends StatefulWidget {

  final UtenteModel userData; // Aggiungi questo campo

  const AggiungiMovimentoPage({Key? key, required this.userData}) : super(key: key); // Aggiorna il costruttore
  
  
  @override
  _AggiungiMovimentoPageState createState() => _AggiungiMovimentoPageState();
}

class _AggiungiMovimentoPageState extends State<AggiungiMovimentoPage> {
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _importoController = TextEditingController();
  late DateTime selectedDate;
  TipoMovimentazione? _selectedTipoMovimentazione;
  Uint8List? _signatureBytes;
  GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey<SfSignaturePadState>();

  @override
  void initState() {
    super.initState();
    _signaturePadKey = GlobalKey<SfSignaturePadState>();
    selectedDate = DateTime.now(); // Inizializza la data selezionata con la data corrente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiungi Movimento', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _descrizioneController,
                decoration: InputDecoration(
                  labelText: 'Descrizione',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci una descrizione';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _importoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Importo',
                ),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Inserisci un importo valido';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<TipoMovimentazione>(
                value: _selectedTipoMovimentazione,
                onChanged: (TipoMovimentazione? newValue) {
                  setState(() {
                    _selectedTipoMovimentazione = newValue;
                  });
                },
                items: TipoMovimentazione.values.map<DropdownMenuItem<TipoMovimentazione>>((TipoMovimentazione value) {
                  return DropdownMenuItem<TipoMovimentazione>(
                    value: value,
                    child: Text(value == TipoMovimentazione.Entrata ? 'Entrata' : 'Uscita'),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Tipo Movimentazione',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Seleziona il tipo di movimentazione';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text(
                    'Seleziona Data',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Data selezionata: ${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year.toString().substring(2)}',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_validateInputs()) {
                      addMovimento();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeFormAmministrazione(userData: widget.userData)));
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text(
                    'Conferma Inserimento',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectSignature(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: 700,
            height: 250,
            child: SfSignaturePad(
              key: _signaturePadKey,
              backgroundColor: Colors.white,
              strokeColor: Colors.black,
              minimumStrokeWidth: 2.0,
              maximumStrokeWidth: 4.0,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Chiudi'),
            ),
            ElevatedButton(
              onPressed: () async {
                final signatureImage = await _signaturePadKey.currentState!.toImage(pixelRatio: 3.0);
                final data = await signatureImage.toByteData(format: ui.ImageByteFormat.png);
                setState(() {
                  _signatureBytes = data!.buffer.asUint8List();
                });
                Navigator.of(context).pop();
              },
              child: Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  bool _validateInputs() {
    if (_selectedTipoMovimentazione == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seleziona il tipo di movimentazione'),
        ),
      );
      return false;
    }
    if (_descrizioneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci una descrizione'),
        ),
      );
      return false;
    }
    if (_importoController.text.isEmpty || double.tryParse(_importoController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci un importo valido'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> addMovimento() async {

    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(selectedDate.toUtc());
    String tipoMovimentazioneString = _selectedTipoMovimentazione.toString().split('.').last; // Otteniamo solo il nome dell'opzione
    Map<String, dynamic> body = {
      'id': null,
      'data': DateTime.now().toIso8601String(),
      'descrizione': _descrizioneController.text,
      'tipo_movimentazione': tipoMovimentazioneString,
      'importo': double.parse(_importoController.text.toString()),
      'utente': widget.userData.toMap(),
    };

    try {
      debugPrint("Body della richiesta: ${body.toString()}");
      final response = await http.post(
        Uri.parse('http://192.168.1.52:8080/api/movimenti'),
        body: jsonEncode(body),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 201) {
        print('Movimentazione salvata con successo');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Movimentazione salvata con successo'),
          ),
        );
      } else {
        print('Errore durante il salvataggio della movimentazione: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il salvataggio della movimentazione'),
          ),
        );
      }
    } catch (e) {
      print('Errore durante la chiamata HTTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante la chiamata HTTP'),
        ),
      );
    }
  }

}
