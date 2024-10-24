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
    _descrizioneController = TextEditingController(text: widget.veicolo.descrizione);
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
              SizedBox(
                width: 420,
                child:TextFormField(
                  controller: _descrizioneController,
                  decoration: InputDecoration(
                    labelText: 'Descrizione'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: TextFormField(
                  controller: _proprietarioController,
                  decoration: InputDecoration(
                    labelText: 'Proprietario'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: TextFormField(
                  controller: _targaController,
                  decoration: InputDecoration(
                    labelText: 'TARGA',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: TextFormField(
                  controller: _imeiController,
                  decoration: InputDecoration(
                    labelText: 'IMEI GPS',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: TextFormField(
                  controller: _serialeController,
                  decoration: InputDecoration(
                    labelText: 'SERIALE GPS',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: TextFormField(
                  controller: _chilometraggioController,
                  decoration: InputDecoration(
                    labelText: 'Chilometraggio attuale'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: TextFormField(
                  controller: _chilometraggioTagliandoController,
                  decoration: InputDecoration(
                    labelText: 'Chilometraggio ultimo tagliando'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width:420,
                child: TextFormField(
                  controller: _sogliaTagliandoController,
                  decoration: InputDecoration(
                    labelText: 'Chilometri da effettuare prima del prossimo tagliando'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child:TextFormField(
                  controller: _chilometraggioInversioneController,
                  decoration: InputDecoration(
                    labelText: 'Chilometraggio ultima inversione gomme'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: TextFormField(
                  controller: _sogliaInversioneController,
                  decoration: InputDecoration(
                    labelText: 'Chilometri da effettuare prima della prossima inversione gomme'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: TextFormField(
                  controller: _chilometraggioSostituzioneController,
                  decoration: InputDecoration(
                    labelText: 'Chilometraggio ultima sostituzione gomme'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 420,
                child: TextFormField(
                  controller: _sogliaSostituzioneController,
                  decoration: InputDecoration(
                    labelText: 'Chilometri da effettuare prima della prossima sostituzione gomme'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 20),
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
                      primary: Colors.red,
                      onPrimary: Colors.white,
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