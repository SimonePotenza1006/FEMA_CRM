import 'dart:convert';
import 'package:fema_crm/model/NotaTecnicoModel.dart';
import 'package:fema_crm/model/RelazioneUtentiInterventiModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/InterventoModel.dart';
import '../model/UtenteModel.dart';
import '../model/RuoloUtenteModel.dart';
import 'PDFInterventoPage.dart';

class DettaglioInterventoPage extends StatefulWidget {
  final InterventoModel intervento;

  DettaglioInterventoPage({required this.intervento});

  @override
  _DettaglioInterventoPageState createState() =>
      _DettaglioInterventoPageState();
}

class _DettaglioInterventoPageState extends State<DettaglioInterventoPage> {
  late Future<List<UtenteModel>> _utentiFuture;
  List<RelazioneUtentiInterventiModel> otherUtenti = [];
  List<NotaTecnicoModel> allNote = [];
  List<UtenteModel> allUtenti = [];
  TimeOfDay _selectedTimeAppuntamento = TimeOfDay.now();

  TimeOfDay _selectedTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _selectedTime2 = TimeOfDay(hour: 0, minute: 0);

  final TextEditingController descrizioneController = TextEditingController();
  final TextEditingController importoController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  @override
  void initState() {
    super.initState();

    getRelazioni();
    getNoteByIntervento();
    _fetchUtenti();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        widget.intervento.orario_inizio = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      });
    }
  }

  Future<void> _selectTimeAppuntamento(BuildContext context) async{
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTimeAppuntamento,
    );
    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        widget.intervento.orario_appuntamento = DateTime(widget.intervento.data!.year, widget.intervento.data!.month, widget.intervento.data!.day, pickedTime.hour, pickedTime.minute);
      });
    }
  }

  Future<void> _selectTime2(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime2,
    );
    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        widget.intervento.orario_fine = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      });
    }
  }


  Future<void> getNoteByIntervento() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/noteTecnico/intervento/${widget.intervento.id}'));
      var responseData = json.decode(response.body);
      if(response.statusCode == 200){
        List<NotaTecnicoModel> note =[];
        for(var item in responseData){
          note.add(NotaTecnicoModel.fromJson(item));
        }
        setState(() {
          allNote = note;
        });
      } else {
        throw Exception('Errore durante il recupero delle note');
      }
    } catch(e){
      throw Exception('Errore durante il recupero delle note: $e');
    }
  }

  Future<void> getRelazioni() async{
    try{
      final response = await http.get(Uri.parse('${ipaddress}/api/relazioneUtentiInterventi/intervento/${widget.intervento.id}'));
      var responseData = json.decode(response.body.toString());
      if(response.statusCode == 200){
        List<RelazioneUtentiInterventiModel> relazioni = [];
        for(var relazione in responseData){
          relazioni.add(RelazioneUtentiInterventiModel.fromJson(relazione));
        }
        setState(() {
          otherUtenti = relazioni;
        });
      } else {
        throw Exception('Errore durante il recupero degli utenti');
      }
    } catch (e) {
      throw Exception('Errore durante il recupero degli utenti: $e');
    }
  }

  Future<void> _fetchUtenti() async {
    try {
      final response = await http.get(Uri.parse('${ipaddress}/api/utente'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<UtenteModel> utenti = [];
        for (var singoloUtente in responseData) {
          utenti.add(UtenteModel.fromJson(singoloUtente));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception('Errore durante il recupero degli utenti');
      }
    } catch (e) {
      throw Exception('Errore durante il recupero degli utenti: $e');
    }
  }

  void _assegnaUtente(UtenteModel utenteSelezionato) async {
    try {
      widget.intervento.assegnato = true;
      print(utenteSelezionato.toMap());
      String? dataString = widget.intervento.data?.toIso8601String();
      String? orarioInizioString = widget.intervento.orario_inizio != null
          ? widget.intervento.orario_inizio?.toIso8601String()
          : null;
      String? orarioFineString = widget.intervento.orario_fine != null
          ? widget.intervento.orario_fine?.toIso8601String()
          : null;
      final response = await http.post(
        Uri.parse('${ipaddress}/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id?.toString(),
          'data': dataString,
          'orario_appuntamento' : null,
          'orario_inizio': orarioInizioString,
          'orario_fine': orarioFineString,
          'descrizione': widget.intervento.descrizione,
          'importo_intervento': widget.intervento.importo_intervento,
          'acconto' : widget.intervento.acconto,
          'assegnato': true,
          'conclusione_parziale' : widget.intervento.conclusione_parziale,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'note': widget.intervento.note,
          'relazione_tecnico' : widget.intervento.relazione_tecnico,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente': utenteSelezionato.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'merce' :widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria_intervento_specifico':
              widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap(),
          'gruppo' : widget.intervento.gruppo?.toMap()
        }),
      );
      if(response.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervento assegnato con successo'),
          ),
        );
      }
    } catch (e) {
      print('${widget.intervento.utente.toString()}');
      print('${utenteSelezionato.nomeCompleto()}');
      print('Errore durante l\'assegnazione dell\'intervento: $e, ');
    }
  }

  void _showUtentiModal(List<UtenteModel> utenti) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: ListView.builder(
            itemCount: utenti.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                  '${utenti[index].nome ?? 'N/A'} ${utenti[index].cognome ?? 'N/A'}',
                ),
                subtitle: Text(utenti[index].ruolo?.descrizione ?? 'N/A'),
                onTap: () {
                  _assegnaUtente(utenti[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Dettaglio Intervento',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informazioni di base',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  buildInfoRow(
                    title: 'ID intervento',
                    value: widget.intervento.id!,
                  ),
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Data creazione',
                    value: formatDate(widget.intervento.data_apertura_intervento),
                  ),
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Data accordata',
                    value: formatDate(widget.intervento.data),
                  ),
                  SizedBox(height: 15),
                  buildInfoRow(
                      title: 'Orario appuntamento',
                      value: formatTime(widget.intervento.orario_appuntamento),
                  ),
                  SizedBox(height: 15),
                  if(widget.intervento.orario_appuntamento == null)
                    Container(
                      decoration: BoxDecoration(

                      ),
                      width: 170,
                      child: FloatingActionButton(
                        onPressed: () {
                          _selectTimeAppuntamento(context);
                        },
                        child: Text(
                          'Inserisci orario appuntamento',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: Colors.red,

                      ),
                    ),
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Orario Inizio',
                    value: formatTime(widget.intervento.orario_inizio),
                  ),
                  if(widget.intervento.orario_inizio == null)
                    Center(
                      child: InkWell(
                        onTap: () => _selectTime(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time),
                            SizedBox(width: 8),
                            Text(
                              _selectedTime.format(context),
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Orario Fine',
                    value: formatTime(widget.intervento.orario_fine),
                  ),
                  if(widget.intervento.orario_fine == null)
                    Center(
                      child: InkWell(
                        onTap: () => _selectTime2(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time),
                            SizedBox(width: 8),
                            Text(
                              _selectedTime2.format(context),
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 15),
                  buildInfoRow(
                      title: 'Cliente',
                      value: widget.intervento.cliente?.denominazione ?? 'N/A'),
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Descrizione',
                    value: widget.intervento.descrizione ?? 'N/A',
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: descrizioneController,
                    decoration: InputDecoration(
                      labelText: 'Descrizione',
                      hintText: 'Aggiungi una descrizione',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height : 15),
                  buildInfoRow(
                    title: 'Indirizzo destinazione',
                    value: widget.intervento.destinazione?.indirizzo ?? 'N/A',
                  ),
                  SizedBox(height : 15),
                  buildInfoRow(
                    title: 'Cellulare destinazione',
                    value: widget.intervento.destinazione?.cellulare ?? 'N/A',
                  ),
                  SizedBox(height : 15),
                  buildInfoRow(
                    title: 'Telefono destinazione',
                    value: widget.intervento.destinazione?.telefono ?? 'N/A',
                  ),
                  SizedBox(height : 15),
                  buildInfoRow(
                    title: 'Indirizzo cliente',
                    value: widget.intervento.cliente?.indirizzo ?? 'N/A',
                  ),
                  SizedBox(height : 15),
                  buildInfoRow(
                    title: 'Telefono cliente',
                    value: widget.intervento.cliente?.telefono ?? 'N/A',
                  ),
                  SizedBox(height : 15),
                  buildInfoRow(
                    title: 'Cellulare cliente',
                    value: widget.intervento.cliente?.cellulare ?? 'N/A',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informazioni sull\'intervento',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  buildInfoRow(
                    title: 'Importo Intervento',
                    value: widget.intervento.importo_intervento?.toString() ?? 'N/A',
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: importoController,
                    decoration: InputDecoration(
                      labelText: 'Importo',
                      hintText: 'Inserisci l\'importo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  buildInfoRow(
                    title: 'Assegnato',
                    value: booleanToString(widget.intervento.assegnato ?? false),
                  ),
                  SizedBox(height: 15),
                  if (widget.intervento.utente == null)
                    FloatingActionButton(
                      onPressed: () {
                        _showUtentiModal(allUtenti);
                      },
                      child: Text(
                        '  Assegna  ',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: Colors.red,

                    ),
                  SizedBox(height: 12),
                  buildInfoRow(
                    title: 'Utente incaricato',
                    value: '${widget.intervento.utente?.nomeCompleto() ?? 'Non assegnato'}',
                  ),
                  if (otherUtenti.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Altri utenti:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ...otherUtenti.map((relazione) => buildInfoRow(
                          title: 'Utente',
                          value: '${relazione.utente?.nomeCompleto() ?? 'N/A'}',
                        )),
                      ],
                    ),
                  SizedBox(height: 15),
                  buildInfoRow(
                      title: 'Relazione Tecnico',
                      value: widget.intervento.relazione_tecnico ?? 'N/A',
                  ),
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Concluso',
                    value: booleanToString(widget.intervento.concluso ?? false),
                  ),
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Saldato',
                    value: booleanToString(widget.intervento.saldato ?? false),
                  ),
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Note',
                    value: widget.intervento.note ?? 'N/A',
                  ),
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Metodo di pagamento',
                    value: widget.intervento.tipologia_pagamento != null
                        ? widget.intervento.tipologia_pagamento?.descrizione ?? 'N/A'
                        : 'N/A',
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),


            if(widget.intervento.merce != null)
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informazioni sulla merce in riparazione',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    buildInfoRow(
                      title: 'Articolo',
                      value: widget.intervento.merce?.articolo ?? 'N/A',
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Accessori',
                      value: widget.intervento.merce?.accessori ?? 'N/A',
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Difetto riscontrato',
                      value: widget.intervento.merce?.difetto_riscontrato ?? 'N/A',
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Diagnosi',
                      value: widget.intervento.merce?.diagnosi ?? 'N/A',
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Richiesta di preventivo',
                      value: booleanToString(widget.intervento.merce?.preventivo ?? false),
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Importo preventivato',
                      value: widget.intervento.merce?.importo_preventivato.toString() ?? 'N/A',
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Password',
                      value: widget.intervento.merce?.password ?? 'N/A',
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Dati',
                      value: widget.intervento.merce?.dati ?? 'N/A',
                    ),
                  ],
                ),
              ),
            if (allNote.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note dei tecnici:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...allNote.map((nota) => ListTile(
                    title: Text('${nota.utente?.nome} ${nota.utente?.cognome}'),
                    subtitle: Text('${nota.nota}'),
                  )),
                ],
              ),
            SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      saveModifiche();
                    },
                    child: Text(
                      'Salva modifiche',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Imposta il colore di sfondo a rosso
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (descrizioneController.text.isNotEmpty && importoController.text.isNotEmpty) {
                        saveIntervento();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFInterventoPage(
                              intervento: widget.intervento,
                              descrizione: descrizioneController.text,
                              importo: importoController.text,
                            ),
                          ),
                        );
                      } else {
                        saveIntervento();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFInterventoPage(
                              intervento: widget.intervento,
                              descrizione: widget.intervento.relazione_tecnico.toString(),
                              importo: widget.intervento.importo_intervento.toString()
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: Text('Genera PDF', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Imposta il colore di sfondo a rosso
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      saldato();
                    },
                    child: Text(
                      'Intervento saldato',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Imposta il colore di sfondo a rosso
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String timeOfDayToIso8601String(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return dateTime.toIso8601String();
  }

  Future<void> saveModifiche() async {
    DateTime? orario = _selectedTimeAppuntamento != null ? convertTimeOfDayToDateTime(_selectedTimeAppuntamento) : widget.intervento.orario_appuntamento;
    double? importo = importoController.text.isNotEmpty ? double.tryParse(importoController.text) : widget.intervento.importo_intervento;
    String? descrizione = descrizioneController.text.isNotEmpty ? descrizioneController.text : widget.intervento.descrizione;
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id,
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento': orario?.toIso8601String(),
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': descrizione,
          'importo_intervento': importo,
          'acconto': widget.intervento.acconto,
          'assegnato': widget.intervento.assegnato,
          'conclusione_parziale': widget.intervento.conclusione_parziale,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'note': widget.intervento.note,
          'relazione_tecnico': widget.intervento.relazione_tecnico,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente': widget.intervento.utente?.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'merce': widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap(),
          'gruppo': widget.intervento.gruppo?.toMap(),
        }),
      );

      if (response.statusCode == 201) {
        print('Modifica effettuata');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervento modificato con successo!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      print('Errore nell\'aggiornamento dell\'intervento: $e');
    }
  }

  DateTime convertTimeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }


  Future<void> saveIntervento() async {
    try {
      final response = await http.post(Uri.parse('${ipaddress}/api/intervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': widget.intervento.id,
            'data': widget.intervento.data?.toIso8601String(),
            'orario_appuntamento' : null,
            'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
            'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
            'descrizione': descrizioneController.text,
            'importo_intervento': double.parse(importoController.text),
            'acconto' : widget.intervento.acconto,
            'assegnato': true,
            'conclusione_parziale' : widget.intervento.conclusione_parziale,
            'concluso': true,
            'saldato': false,
            'note': widget.intervento.note,
            'relazione_intervento' : widget.intervento.relazione_tecnico,
            'firma_cliente': widget.intervento.firma_cliente,
            'utente': widget.intervento.utente?.toMap(),
            'cliente': widget.intervento.cliente?.toMap(),
            'veicolo': widget.intervento.veicolo?.toMap(),
            'merce': widget.intervento.merce?.toMap(),
            'tipologia': widget.intervento.tipologia?.toMap(),
            'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
            'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
            'destinazione': widget.intervento.destinazione?.toMap(),
            'gruppo': widget.intervento.gruppo?.toMap()
          }));
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
      }
    } catch (e) {
      print('Errore durante il salvataggio del preventivo: $e');
    }
  }

  Future<void> saldato() async {
    try {
      final response = await http.post(Uri.parse('${ipaddress}/api/intervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': widget.intervento.id,
            'data': widget.intervento.data?.toIso8601String(),
            'orario_appuntamento' : widget.intervento.orario_appuntamento,
            'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
            'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
            'descrizione': widget.intervento.descrizione,
            'importo_intervento': widget.intervento.importo_intervento,
            'acconto' : widget.intervento.acconto,
            'assegnato': widget.intervento.assegnato,
            'conclusione_parziale' : widget.intervento.conclusione_parziale,
            'concluso': widget.intervento.concluso,
            'saldato': true,
            'note': widget.intervento.note,
            'relazione_tecnico' : widget.intervento.relazione_tecnico,
            'firma_cliente': widget.intervento.firma_cliente,
            'utente': widget.intervento.utente?.toMap(),
            'cliente': widget.intervento.cliente?.toMap(),
            'veicolo': widget.intervento.veicolo?.toMap(),
            'merce' : widget.intervento.merce?.toMap(),
            'tipologia': widget.intervento.tipologia?.toMap(),
            'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
            'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
            'destinazione': widget.intervento.destinazione?.toMap(),
            'gruppo': widget.intervento.gruppo?.toMap()
          }));
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervento saldato!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      } else {}
    } catch (e) {
      print('Errore durante il salvataggio del preventivo: $e');
    }
  }

  String formatDate(DateTime? date) {
    return date != null ? dateFormatter.format(date) : 'N/A';
  }

  String formatTime(DateTime? time) {
    return time != null ? timeFormatter.format(time) : 'N/A';
  }

  String booleanToString(bool? value) {
    return value != null ? (value ? 'SI' : 'NO') : 'N/A';
  }

  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
  final DateFormat timeFormatter = DateFormat('HH:mm');
}
