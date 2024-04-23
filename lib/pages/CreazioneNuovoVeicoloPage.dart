import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fema_crm/model/VeicoloModel.dart';

class CreazioneNuovoVeicoloPage extends StatefulWidget {
  const CreazioneNuovoVeicoloPage({Key? key}) : super(key: key);

  @override
  _CreazioneNuovoVeicoloPageState createState() => _CreazioneNuovoVeicoloPageState();
}

class _CreazioneNuovoVeicoloPageState extends State<CreazioneNuovoVeicoloPage> {
  final _formKey = GlobalKey<FormState>();
  final _descrizioneController = TextEditingController();
  final _bolloController = TextEditingController();
  final _polizzaController = TextEditingController();
  final _tagliandoController = TextEditingController();
  final _revisioneController = TextEditingController();
  final _inversioneController = TextEditingController();
  final _sostituzioneController = TextEditingController();

  DateTime? _selectedBolloDate;
  DateTime? _selectedPolizzaDate;
  DateTime? _selectedTagliandoDate;
  DateTime? _selectedRevisioneDate;
  DateTime? _selectedInversioneDate;
  DateTime? _selectedSostituzioneDate;

  String ipaddress = 'http://gestione.femasistemi.it:8090';

  Future<void> _selectDate(BuildContext context, TextEditingController controller, DateTime? selectedDate, void Function(DateTime?) setSelectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        // Formatta la data come giorno/mese/anno
        String formattedDate = DateFormat('dd/MM/yyyy').format(picked);
        controller.text = formattedDate;
        // Salva la data selezionata
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
          _selectedSostituzioneDate == null) {
        throw Exception('Per favore, seleziona tutte le date prima di salvare.');
      }

      final response = await http.post(
        Uri.parse('${ipaddress}/api/veicolo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'descrizione': _descrizioneController.text,
          'data_scadenza_bollo': DateFormat('yyyy-MM-dd').format(_selectedBolloDate!),
          'data_scadenza_polizza': DateFormat('yyyy-MM-dd').format(_selectedPolizzaDate!),
          'data_tagliando': DateFormat('yyyy-MM-dd').format(_selectedTagliandoDate!),
          'data_revisione': DateFormat('yyyy-MM-dd').format(_selectedRevisioneDate!),
          'data_inversione_gomme': DateFormat('yyyy-MM-dd').format(_selectedInversioneDate!),
          'data_sostituzione_gomme': DateFormat('yyyy-MM-dd').format(_selectedSostituzioneDate!),
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
        title: const Text('Creazione nuovo veicolo', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFormField(_descrizioneController, 'Modello', 'Inserisci il modello del veicolo'),
                SizedBox(height: 15),
                _buildDateField(_bolloController, 'Data di scadenza del bollo', _selectedBolloDate, (DateTime? date) {
                  setState(() {
                    _selectedBolloDate = date;
                  });
                }),
                SizedBox(height: 15),
                _buildDateField(_polizzaController, 'Data di scadenza della polizza', _selectedPolizzaDate, (DateTime? date) {
                  setState(() {
                    _selectedPolizzaDate = date;
                  });
                }),
                SizedBox(height: 15),
                _buildDateField(_tagliandoController, 'Data del tagliando', _selectedTagliandoDate, (DateTime? date) {
                  setState(() {
                    _selectedTagliandoDate = date;
                  });
                }),
                SizedBox(height: 15),
                _buildDateField(_revisioneController, 'Data della revisione', _selectedRevisioneDate, (DateTime? date) {
                  setState(() {
                    _selectedRevisioneDate = date;
                  });
                }),
                SizedBox(height: 15),
                _buildDateField(_inversioneController, 'Data dell\'inversione gomme', _selectedInversioneDate, (DateTime? date) {
                  setState(() {
                    _selectedInversioneDate = date;
                  });
                }),
                SizedBox(height: 15),
                _buildDateField(_sostituzioneController, 'Data di sostituzione delle gomme', _selectedSostituzioneDate, (DateTime? date) {
                  setState(() {
                    _selectedSostituzioneDate = date;
                  });
                }),
                SizedBox(height: 60),
                Container(
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
                      'Salva Veicolo',
                      style: TextStyle(fontSize: 20, color: Colors.white),
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
    return TextFormField(
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
          return 'Campo obbligatorio';
        }
        return null;
      },
    );
  }


  Widget _buildDateField(TextEditingController controller, String label, DateTime? selectedDate, void Function(DateTime?) setSelectedDate) {
    return InkWell(
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
              return 'Campo obbligatorio';
            }
            return null;
          },
        ),
      ),
    );
  }
}

