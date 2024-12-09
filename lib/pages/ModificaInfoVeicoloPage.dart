import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/VeicoloModel.dart';

class ModificaInfoVeicoloPage extends StatefulWidget{
  final VeicoloModel veicolo;

  const ModificaInfoVeicoloPage({Key? key, required this.veicolo}) : super(key : key);

  @override
  _ModificaInfoVeicoloPageState createState() => _ModificaInfoVeicoloPageState();
}

class _ModificaInfoVeicoloPageState extends State<ModificaInfoVeicoloPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  late TextEditingController _proprietarioController;
  late TextEditingController _descrizioneController;
  late TextEditingController _chilometraggioController;
  late TextEditingController _chilometraggioTagliandoController;
  late TextEditingController _sogliaTagliandoController;
  late TextEditingController _chilometraggioInversioneController;
  late TextEditingController _sogliaInversioneController;
  late TextEditingController _chilometraggioSostituzioneController;
  late TextEditingController _sogliaSostituzioneController;
  late TextEditingController _targaController;
  late TextEditingController _imeiController;
  late TextEditingController _serialeController;
  late DateTime? _scadenzaGps = widget.veicolo.scadenza_gps;
  late DateTime? _dataScadenzaBollo = widget.veicolo.data_scadenza_bollo;
  late DateTime? _dataScadenzaPolizza = widget.veicolo.data_scadenza_polizza;
  late DateTime? _dataTagliando = widget.veicolo.data_tagliando;
  late DateTime? _dataRevisione = widget.veicolo.data_revisione;
  late DateTime? _dataInversione = widget.veicolo.data_inversione_gomme;
  late DateTime? _dataSostituzione = widget.veicolo.data_sostituzione_gomme;

  @override
  void initState(){
    super.initState();
    _descrizioneController = TextEditingController(text: widget.veicolo.descrizione != null ? widget.veicolo.descrizione : '');
    _chilometraggioController = TextEditingController(text: widget.veicolo.chilometraggio_attuale.toString());
    _chilometraggioTagliandoController = TextEditingController(text: widget.veicolo.chilometraggio_ultimo_tagliando.toString());
    _sogliaTagliandoController = TextEditingController(text: widget.veicolo.soglia_tagliando.toString());
    _chilometraggioInversioneController = TextEditingController(text: widget.veicolo.chilometraggio_ultima_inversione.toString());
    _sogliaInversioneController = TextEditingController(text: widget.veicolo.soglia_inversione.toString());
    _chilometraggioSostituzioneController = TextEditingController(text: widget.veicolo.chilometraggio_ultima_sostituzione.toString());
    _sogliaSostituzioneController = TextEditingController(text: widget.veicolo.soglia_sostituzione.toString());
    _proprietarioController = TextEditingController(text: widget.veicolo.proprietario.toString());
    _targaController = TextEditingController(text: widget.veicolo.targa != null ? widget.veicolo.targa.toString() : '');
    _imeiController= TextEditingController(text: widget.veicolo.imei != null ? widget.veicolo.imei.toString() : '');
    _serialeController = TextEditingController(text: widget.veicolo.seriale != null ? widget.veicolo.seriale.toString() : '');
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('MODIFICA INFO ${widget.veicolo.descrizione}',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildTextFormField(_descrizioneController, 'Descrizione', 'Inserisci la descrizione del veicolo'),
              SizedBox(height: 10),
              _buildTextFormField(_proprietarioController, 'Proprietario', 'Inserisci il proprietario del veicolo'),
              SizedBox(height: 10),
              _buildTextFormField(_targaController, 'Targa', 'Inserisci il numero di targa'),
              SizedBox(height: 10),
              _buildTextFormField(_imeiController, 'Imei Gps', 'Inserisci l\'IMEI gps del veicolo'),
              SizedBox(height: 10),
              _buildTextFormField(_serialeController, 'Seriale', 'Inserisci il seriale del veicolo'),
              SizedBox(height: 10),
              SizedBox(
                width: 420,
                child:GestureDetector(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: _scadenzaGps?? DateTime.now().add(Duration(days:1)),
                      firstDate: DateTime.now().add(Duration(days: 1)),
                      lastDate: DateTime(2100),
                    ).then((date) {
                      setState(() {
                        _scadenzaGps = date;
                      });
                    });
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Data scadenza gps'.toUpperCase(),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _scadenzaGps!= null? DateFormat('dd/MM/yyyy').format(_scadenzaGps!) : ''),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              _buildTextFormField(_chilometraggioController, 'Chilometraggio attuale', 'Inserisci il chilometraggio attuale del veicolo'),
              SizedBox(height: 10),
              _buildTextFormField(_chilometraggioTagliandoController, 'Chilometraggio ultimo tagliando', 'Inserisci il chilometraggio dell\'ultimo tagliando'),
              SizedBox(height: 10),
              _buildTextFormField(_sogliaTagliandoController, 'Soglia tagliando', 'Inserisci i chilometri da effettuare prima del prossimo tagliando'),
              SizedBox(height: 10),
              _buildTextFormField(_chilometraggioInversioneController, 'Chilometraggio ultima inversione gomme', 'Inserisci il chilometraggio all\'ultima inversione gomme'),
              SizedBox(height: 10),
              _buildTextFormField(_sogliaInversioneController, 'Soglia inversione', 'Inserisci i chilometri da effettuare prima della prossima inversione'),
              SizedBox(height: 10),
              _buildTextFormField(_chilometraggioSostituzioneController, 'Chilometraggio ultima sostituzione gomme', 'Inserisci il chilometraggio all\'ultima inversione gomme'),
              SizedBox(height: 10),
              _buildTextFormField(_sogliaSostituzioneController, 'Soglia sostituzione', 'Inserisci i chilometri da effettuare prima della prossima sostituzione'),
              SizedBox(height: 10),
              SizedBox(
                width: 420,
                child:GestureDetector(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: _dataScadenzaBollo?? DateTime.now().add(Duration(days:1)),
                      firstDate: DateTime.now().add(Duration(days: 1)),
                      lastDate: DateTime(2100),
                    ).then((date) {
                      setState(() {
                        _dataScadenzaBollo = date;
                      });
                    });
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Data scadenza bollo'.toUpperCase(),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _dataScadenzaBollo!= null? DateFormat('dd/MM/yyyy').format(_dataScadenzaBollo!) : ''),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width:420,
                child: GestureDetector(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: _dataScadenzaPolizza?? DateTime.now().add(Duration(days:1)),
                      firstDate: DateTime.now().add(Duration(days: 1)),
                      lastDate: DateTime(2100),
                    ).then((date) {
                      setState(() {
                        _dataScadenzaPolizza = date;
                      });
                    });
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Data scadenza polizza'.toUpperCase(),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _dataScadenzaPolizza!= null? DateFormat('dd/MM/yyyy').format(_dataScadenzaPolizza!) : ''),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: GestureDetector(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: _dataTagliando?? DateTime.now().add(Duration(days:1)),
                      firstDate: DateTime.now().add(Duration(days: 1)),
                      lastDate: DateTime(2100),
                    ).then((date) {
                      setState(() {
                        _dataTagliando = date;
                      });
                    });
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Data tagliando'.toUpperCase(),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _dataTagliando!= null? DateFormat('dd/MM/yyyy').format(_dataTagliando!) : ''),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: GestureDetector(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: _dataRevisione?? DateTime.now().add(Duration(days:1)),
                      firstDate: DateTime.now().add(Duration(days: 1)),
                      lastDate: DateTime(2100),
                    ).then((date) {
                      setState(() {
                        _dataRevisione = date;
                      });
                    });
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Data revisione'.toUpperCase(),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _dataRevisione!= null? DateFormat('dd/MM/yyyy').format(_dataRevisione!) : ''),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: GestureDetector(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: _dataInversione?? DateTime.now().add(Duration(days:1)),
                      firstDate: DateTime.now().add(Duration(days: 1)),
                      lastDate: DateTime(2100),
                    ).then((date) {
                      setState(() {
                        _dataInversione = date;
                      });
                    });
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Data inversione gomme'.toUpperCase(),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _dataInversione!= null? DateFormat('dd/MM/yyyy').format(_dataInversione!) : ''),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: GestureDetector(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: _dataSostituzione?? DateTime.now().add(Duration(days:1)),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    ).then((date) {
                      setState(() {
                        _dataSostituzione = date;
                      });
                    });
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Data sostituzione gomme'.toUpperCase(),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _dataSostituzione!= null? DateFormat('dd/MM/yyyy').format(_dataSostituzione!) : ''),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30), // add some space before the button
              Center(
                child: Container(
                  width: 150, // adjust the width as needed
                  height: 50, // adjust the height as needed
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      updateVeicolo();
                    },
                    child: Text('Salva'.toUpperCase(), style: TextStyle(fontSize: 18)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText,
      {String? Function(String?)? validator}) {
    return SizedBox(
      width: 600, // Larghezza modificata
      child: TextFormField(
        controller: controller,
        maxLines: null, // Permette più righe
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200], // Sfondo riempito
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Nessun bordo di default
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.redAccent,
              width: 2.0, // Larghezza bordo focale
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.0, // Larghezza bordo abilitato
            ),
          ),
          contentPadding:
          EdgeInsets.symmetric(vertical: 15, horizontal: 10), // Padding contenuto
        ),
        validator: validator, // Funzione di validazione
      ),
    );
  }

  Future<http.Response> updateVeicolo() async{
    late http.Response response;
    try{
      response = await http.post(
        Uri.parse('$ipaddress/api/veicolo'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'id' : widget.veicolo.id,
          'descrizione' : _descrizioneController.text,
          'proprietario' : _proprietarioController.text,
          'targa' : _targaController.text,
          'imei' : _imeiController.text,
          'seriale' : _serialeController.text,
          'chilometraggio_attuale' : int.parse(_chilometraggioController.text),
          'data_scadenza_bollo' : _dataScadenzaBollo?.toIso8601String(),
          'data_scadenza_polizza' : _dataScadenzaPolizza?.toIso8601String(),
          'data_tagliando' : _dataTagliando?.toIso8601String(),
          'chilometraggio_ultimo_tagliando' : int.parse(_chilometraggioTagliandoController.text),
          'soglia_tagliando' : int.parse(_sogliaTagliandoController.text),
          'data_revisione' : _dataRevisione?.toIso8601String(),
          'data_inversione_gomme' : _dataInversione?.toIso8601String(),
          'chilometraggio_ultima_inversione' : int.parse(_chilometraggioInversioneController.text),
          'soglia_inversione' : int.parse(_sogliaInversioneController.text),
          'data_sostituzione_gomme' : _dataSostituzione?.toIso8601String(),
          'chilometraggio_ultima_sostituzione' : int.parse(_chilometraggioSostituzioneController.text),
          'soglia_sostituzione' : int.parse(_sogliaSostituzioneController.text),
          'scadenza_gps' : _scadenzaGps?.toIso8601String(),
          'flotta' : widget.veicolo.flotta
        }),
      );
      if(response.statusCode == 201){
        print('EVVAIII');
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le informazioni su ${widget.veicolo.descrizione} sono state salvate correttamente!'.toUpperCase()),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
      }
    } catch(e) {
      print('Errore durante la modifica : $e');
    }
    return response;
  }
}