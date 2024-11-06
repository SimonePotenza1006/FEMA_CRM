import 'dart:convert';

import 'package:fema_crm/model/InterventoModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../model/ClienteModel.dart';

class CreazioneScadenzaPage extends StatefulWidget{
  final InterventoModel intervento;
  final ClienteModel cliente;

  CreazioneScadenzaPage({Key? key, required this.intervento, required this.cliente}) : super(key : key);

  @override
  _CreazioneScadenzaPageState createState() => _CreazioneScadenzaPageState();
}

class _CreazioneScadenzaPageState extends State<CreazioneScadenzaPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();

  Widget _buildTextFormField(TextEditingController controller, String label, String hintText) {
    return Container(
      width: MediaQuery.of(context).size.width / 2, // half of the screen width
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obbligatorio'.toUpperCase();
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label, DateTime? selectedDate, void Function(DateTime?) setSelectedDate) {
    return Container(
      width: MediaQuery.of(context).size.width / 2, // half of the screen width
      child: InkWell(
        onTap: () async {
          await _selectDate(context, controller, selectedDate, setSelectedDate);
        },
        child: IgnorePointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.red,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obbligatorio'.toUpperCase();
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, DateTime? selectedDate, void Function(DateTime?) setSelectedDate) async {
    // Inizializza l'initialDate con un anno da oggi
    final DateTime initialDate = selectedDate ?? DateTime.now().add(Duration(days: 365));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate, // Imposta un anno da oggi come data di partenza
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        String formattedDate = DateFormat('dd/MM/yyyy').format(picked);
        controller.text = formattedDate;
        setSelectedDate(picked);
      });
    }
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Creazione nuova scadenza'.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 12),
                  SizedBox(
                    width: 400,
                    child: _buildTextFormField(_descrizioneController, "DESCRIZIONE".toUpperCase(), "Inserisci il prodotto di riferimento".toUpperCase()),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: 400,
                    child: _buildDateField(_dataController, "DATA DI SCADENZA", _selectedDate, (DateTime? date){
                      setState(() {
                        _selectedDate = date;
                      });
                    }),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            saveScadenza();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Crea scadenza'.toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveScadenza() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/scadenza'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data' : _selectedDate?.toIso8601String(),
          'descrizione' : _descrizioneController.text,
          'cliente' : widget.cliente.toMap(),
          'intervento' : widget.intervento.toMap()
        })
      );
      if(response.statusCode == 201){
        _descrizioneController.clear();
        _dataController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Scadenza creata con successo!".toUpperCase()),
              duration: Duration(seconds: 3),
            )
        );
      }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }


}