import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fema_crm/model/VeicoloModel.dart';

class CreazioneNuovoVeicoloPage extends StatefulWidget {
  const  CreazioneNuovoVeicoloPage({Key? key}) : super(key: key);

  @override
  _CreazioneNuovoVeicoloPageState createState() => _CreazioneNuovoVeicoloPageState();
}

class _CreazioneNuovoVeicoloPageState extends State<CreazioneNuovoVeicoloPage> {

  final _formKey = GlobalKey<FormState>();
  final _descrizioneController = TextEditingController();
  final _proprietarioController = TextEditingController();
  final _targaController = TextEditingController();
  final _imeiController = TextEditingController();
  final _serialeController = TextEditingController();
  final _chilometraggioController = TextEditingController();
  final _bolloController = TextEditingController();
  final _polizzaController = TextEditingController();
  final _tagliandoController = TextEditingController();
  final _gpsController = TextEditingController();
  final _chilometraggioTagliandoController = TextEditingController();
  final _sogliaTagliandoController = TextEditingController();
  final _revisioneController = TextEditingController();
  final _inversioneController = TextEditingController();
  final _chilometraggioInversioneController = TextEditingController();
  final _sogliaInversioneController = TextEditingController();
  final _sostituzioneController = TextEditingController();
  final _chilometraggioSostituzioneController = TextEditingController();
  final _sogliaSostituzioneController = TextEditingController();

  DateTime? _selectedBolloDate;
  DateTime? _selectedPolizzaDate;
  DateTime? _selectedTagliandoDate;
  DateTime? _selectedRevisioneDate;
  DateTime? _selectedInversioneDate;
  DateTime? _selectedSostituzioneDate;
  DateTime? _selectedGpsDate;

  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';

  Future<void> _selectDate(BuildContext context, TextEditingController controller, DateTime? selectedDate, void Function(DateTime?) setSelectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate?? DateTime.now(),
      firstDate: DateTime(1900), // allow dates from 1900 onwards
      lastDate: DateTime(2101),
    );
    if (picked!= null) {
      setState(() {
        // Format the date as day/month/year
        String formattedDate = DateFormat('dd/MM/yyyy').format(picked);
        controller.text = formattedDate;
        // Save the selected date
        setSelectedDate(picked);
      });
    }
  }

  Future<void> saveVeicolo() async {
    try {
      // Controllo di validità delle date
      if (_selectedBolloDate == null ||
          _selectedPolizzaDate == null ||
          _selectedTagliandoDate == null ||
          _selectedRevisioneDate == null ||
          _selectedInversioneDate == null ||
          _selectedGpsDate == null ||
          _selectedSostituzioneDate == null) {
        throw Exception('Per favore, seleziona tutte le date prima di salvare.');
      }

      final response = await http.post(
        Uri.parse('$ipaddress/api/veicolo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'descrizione': _descrizioneController.text,
          'proprietario' : _proprietarioController.text,
          'targa' : _targaController.text,
          'imei' : _imeiController.text,
          'seriale' : _serialeController.text,
          'chilometraggio_attuale': _chilometraggioController.text,
          'data_scadenza_bollo': DateFormat('yyyy-MM-dd').format(_selectedBolloDate!),
          'data_scadenza_polizza': DateFormat('yyyy-MM-dd').format(_selectedPolizzaDate!),
          'data_tagliando': DateFormat('yyyy-MM-dd').format(_selectedTagliandoDate!),
          'chilometraggio_ultimo_tagliando': _chilometraggioTagliandoController.text,
          'soglia_tagliando': _sogliaTagliandoController.text,
          'data_revisione': DateFormat('yyyy-MM-dd').format(_selectedRevisioneDate!),
          'data_inversione_gomme': DateFormat('yyyy-MM-dd').format(_selectedInversioneDate!),
          'chilometraggio_ultima_inversione': _chilometraggioInversioneController.text,
          'soglia_inversione': _sogliaInversioneController.text,
          'data_sostituzione_gomme': DateFormat('yyyy-MM-dd').format(_selectedSostituzioneDate!),
          'chilometraggio_ultima_sostituzione': _chilometraggioSostituzioneController.text,
          'soglia_sostituzione': _sogliaSostituzioneController.text,
          'scadenza_gps' : DateFormat('yyyy-MM-dd').format(_selectedGpsDate!)
        }),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veicolo registrato con successo!'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio del veicolo: $e');
      // Gestione degli errori...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('Creazione nuovo veicolo'.toUpperCase(), style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Add this
              children: [
                Center( // Wrap each field with Center widget
                  child: _buildTextFormField(_descrizioneController, 'Modello'.toUpperCase(), 'Inserisci il modello del veicolo'.toUpperCase()),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildTextFormField(_targaController, 'Targa'.toUpperCase(), 'Inserisci la targa del veicolo'.toUpperCase()),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildTextFormField(_imeiController, 'Imei gps'.toUpperCase(), 'Inserisci l\'imei del veicolo'.toUpperCase()),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildTextFormField(_proprietarioController, 'proprietario'.toUpperCase(), 'Inserisci il proprietario del veicolo'.toUpperCase()),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildTextFormField(_chilometraggioController, 'Chilometraggio attuale'.toUpperCase(), 'Inserisci il chilometraggio attuale del veicolo'.toUpperCase()),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildDateField(_bolloController, 'Data di scadenza del bollo'.toUpperCase(), _selectedBolloDate, (DateTime? date) {
                    setState(() {
                      _selectedBolloDate = date;
                    });
                  }),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildDateField(_polizzaController, 'Data di scadenza della polizza'.toUpperCase(), _selectedPolizzaDate, (DateTime? date) {
                    setState(() {
                      _selectedPolizzaDate = date;
                    });
                  }),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildDateField(_tagliandoController, 'Data del tagliando'.toUpperCase(), _selectedTagliandoDate, (DateTime? date) {
                    setState(() {
                      _selectedTagliandoDate = date;
                    });
                  }),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildDateField(_gpsController, 'Data di scadenza gps'.toUpperCase(), _selectedGpsDate, (DateTime? date) {
                    setState(() {
                      _selectedPolizzaDate = date;
                    });
                  }),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildTextFormField(_chilometraggioTagliandoController, 'Chilometraggio ultimo tagliando'.toUpperCase(), 'Inserisci il chilometraggio dell\'ultimo tagliando'.toUpperCase()),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildTextFormField(_sogliaTagliandoController, 'Chilometri prima del prossimo tagliando'.toUpperCase(), 'Inserisci i chilometri da percorrere prima del prossimo tagliando'.toUpperCase()),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildDateField(_revisioneController, 'Data della revisione'.toUpperCase(), _selectedRevisioneDate, (DateTime? date) {
                    setState(() {
                      _selectedRevisioneDate = date;
                    });
                  }),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildDateField(_inversioneController, 'Data dell\'inversione gomme'.toUpperCase(), _selectedInversioneDate, (DateTime? date) {
                    setState(() {
                      _selectedInversioneDate = date;
                    });
                  }),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildTextFormField(_chilometraggioInversioneController, 'Chilometraggio ultima inversione gomme'.toUpperCase(), 'Inserisci il chilometraggio dell\'ultima inversione delle gomme'.toUpperCase()),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildTextFormField(_sogliaInversioneController, 'Chilometri prima della prossima inversione'.toUpperCase(), 'Inserisci i chilometri da percorrere prima della prossima inversione'.toUpperCase()),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildDateField(_sostituzioneController, 'Data di sostituzione delle gomme'.toUpperCase(), _selectedSostituzioneDate, (DateTime? date) {
                    setState(() {
                      _selectedSostituzioneDate = date;
                    });
                  }),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildTextFormField(_chilometraggioSostituzioneController, 'Chilometraggio ultima sostituzione gomme'.toUpperCase(), 'Inserisci il chilometraggio dell\'ultima sostituzione delle gomme'.toUpperCase()),
                ),
                SizedBox(height: 14),
                Center(
                  child: _buildTextFormField(_sogliaSostituzioneController, 'Chilometri prima della prossima sostituzione'.toUpperCase(), 'Inserisci i chilometri da percorrere prima della prossima sostituzione'.toUpperCase()),
                ),
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        saveVeicolo();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        ),
                      ),
                      child: Text(
                        'Salva Veicolo'.toUpperCase(),
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
}