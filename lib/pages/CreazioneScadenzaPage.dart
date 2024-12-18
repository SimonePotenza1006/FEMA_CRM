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
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();

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

  Widget _buildDatePickerField(
      BuildContext context, TextEditingController controller, String label,
      {DateTime? initialDate,
        DateTime? firstDate,
        DateTime? lastDate,
        void Function(DateTime?)? onDateSelected}) {
    return SizedBox(
      width: 600, // Larghezza modificata
      child: GestureDetector(
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: initialDate ?? DateTime.now(),
            firstDate: firstDate ?? DateTime.now(),
            lastDate: lastDate ?? DateTime(2100),
          ).then((selectedDate) {
            if (selectedDate != null) {
              // Aggiorna il controller con la data selezionata
              controller.text = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
              if (onDateSelected != null) {
                onDateSelected(selectedDate);
              }
            }
          });
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              hintText: 'Seleziona una data', // Testo suggerimento
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
                    child: _buildDatePickerField(context, _dataController, "DATA DI SCADENZA" ),
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
                          backgroundColor: Colors.red,
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
        Uri.parse('$ipaddress/api/scadenza'),
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