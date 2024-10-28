import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:http/http.dart' as http;
import '../model/UtenteModel.dart';

class InizioInterventoPage extends StatefulWidget {
  final InterventoModel intervento;
  final UtenteModel utente;

  const InizioInterventoPage({Key? key, required this.intervento, required this.utente})
      : super(key: key);

  @override
  _InizioInterventoPageState createState() => _InizioInterventoPageState();
}

class _InizioInterventoPageState extends State<InizioInterventoPage> {
  late String _gps;
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  TextEditingController _gpsController = TextEditingController();
  TextEditingController _notaClienteController = TextEditingController();
  TextEditingController _notaDestinazioneController = TextEditingController();
  String _indirizzo = 'Ottenendo posizione...';
  TimeOfDay _selectedTime = TimeOfDay(hour: 0, minute: 0); // Orario selezionato, inizializzato a mezzanotte

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      return '${place.street},${place.subThoroughfare} ${place.locality} ${place.postalCode}, ${place.country}';
    } catch (e) {
      print(
          "Errore durante la conversione delle coordinate in indirizzo: $e");
      return "Indirizzo non disponibile";
    }
  }


  Future<void> saveNotaDestinazione() async {
    try{
      final now = DateTime.now().toIso8601String();
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/noteTecnico'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': now,
          'utente': widget.utente.toMap(),
          'nota': _notaDestinazioneController.text,
          'destinazione' : widget.intervento.destinazione!.toMap(),
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nota relativa alla destinazione salvata con successo!'),
            duration: Duration(seconds: 3),
          ),
        );
        _notaDestinazioneController.clear();
      }
    } catch (e) {
      print('Errore durante il salvataggio dell\'orario $e');
    }
  }

  Future<void> saveNotaCliente() async {
    try{
      final now = DateTime.now().toIso8601String();
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/noteTecnico'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': now,
          'utente': widget.utente.toMap(),
          'nota': _notaClienteController.text,
          'cliente' : widget.intervento.cliente?.toMap(),
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nota relativa al cliente salvata con successo!'),
            duration: Duration(seconds: 3),
          ),
        );
        _notaClienteController.clear();
      }
    } catch (e) {
      print('Errore durante il salvataggio dell\'orario $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String indirizzo = await getAddressFromCoordinates(
          position.latitude, position.longitude);
      setState(() {
        _gps = "${position.latitude}, ${position.longitude}";
        _indirizzo = indirizzo.toString();
      });
    } catch (e) {
      print("Errore durante l'ottenimento della posizione: $e");
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((value) => _gpsController.text = _indirizzo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Verifiche iniziali per intervento",
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 12),
                Text(
                  'Informazioni attuali:'.toUpperCase(),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Indirizzo: ${widget.intervento.destinazione?.indirizzo}',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  'Città: ${widget.intervento.destinazione?.citta}',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  'Provincia: ${widget.intervento.destinazione?.provincia}',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  'Cap: ${widget.intervento.destinazione?.cap}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 15),
                Text(
                  "La tua posizione corrente è:".toUpperCase(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('${_indirizzo}'.toUpperCase(), style: TextStyle(fontSize: 22)),
                SizedBox(height: 16),
                // Spazio aggiunto tra il pulsante e il pulsante "Inizia intervento"
                Column(
                  children: [
                    TextFormField(
                      controller: _notaDestinazioneController,
                      maxLines: null, // Allow multiline input
                      decoration: InputDecoration(
                        hintText: 'Inserisci una nota sulla destinazione (opzionale)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16), // Add some space between TextFormField and ElevatedButton
                      ElevatedButton(
                        onPressed: () {
                          saveNotaDestinazione();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Set padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Set border radius
                          ),
                        ),
                        child: Text(
                          'Salva nota destinazione'.toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 30),
                // Spazio aggiunto tra il pulsante e il pulsante "Inizia intervento"
                Column(
                  children: [
                    TextFormField(
                      controller: _notaClienteController,
                      maxLines: null, // Allow multiline input
                      decoration: InputDecoration(
                        hintText: 'Inserisci una nota sul cliente (opzionale)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16), // Add some space between TextFormField and ElevatedButton
                      ElevatedButton(
                        onPressed: () {
                          saveNotaCliente();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14), // Set padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Set border radius
                          ),
                        ),
                        child: Text(
                          'Salva nota cliente'.toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saveIntervento,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        label: Text("Inizia intervento".toUpperCase()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  String timeOfDayToIso8601String(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return dateTime.toIso8601String();
  }

  Future<void> saveIntervento() async {
    try {
      final now = DateTime.now();

      final response = await http.post(
        Uri.parse('$ipaddressProva/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id,
          'attivo' : widget.intervento.attivo,
          'titolo' : widget.intervento.titolo,
          'numerazione_danea' : widget.intervento.numerazione_danea,
          'priorita' : widget.intervento.priorita.toString().split('.').last,
          'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : _indirizzo,
          'orario_inizio': DateTime.now().toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': widget.intervento.descrizione,
          'importo_intervento': widget.intervento.importo_intervento,
          'saldo_tecnico' : widget.intervento.saldo_tecnico,
          'prezzo_ivato' : widget.intervento.prezzo_ivato,
          'iva' : widget.intervento.iva,
          'assegnato': widget.intervento.assegnato,
          'accettato_da_Tecnico' : widget.intervento.accettato_da_tecnico,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
          'note': widget.intervento.note,
          'relazione_tecnico' : widget.intervento.relazione_tecnico,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente_apertura' : widget.intervento.utente_apertura?.toMap(),
          'utente': widget.intervento.utente?.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'merce' : widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap(),
          'gruppo' : widget.intervento.gruppo?.toMap(),
        }),
      );

      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Orario di inizio salvato, buon lavoro!'),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Errore durante il salvataggio dell\'orario $e');
    }
  }

}
