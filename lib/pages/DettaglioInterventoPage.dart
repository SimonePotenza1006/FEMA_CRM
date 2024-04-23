import 'dart:convert';
import 'package:fema_crm/model/NotaTecnicoModel.dart';
import 'package:fema_crm/model/RelazioneUtentiInterventiModel.dart';
import 'package:flutter/material.dart';
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

  final TextEditingController descrizioneController = TextEditingController();
  final TextEditingController importoController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  @override
  void initState() {
    super.initState();
    getRelazioni();
    getNoteByIntervento();
    _utentiFuture = _fetchUtenti();
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

  Future<List<UtenteModel>> _fetchUtenti() async {
    try {
      final response = await http.get(Uri.parse('${ipaddress}/api/utente'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<UtenteModel> utenti = [];
        for (var singoloUtente in responseData) {
          utenti.add(UtenteModel.fromJson(singoloUtente));
        }
        return utenti;
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
          ? DateFormat('HH:mm').format(widget.intervento.orario_inizio!)
          : 'N/A';
      String? orarioFineString = widget.intervento.orario_fine != null
          ? DateFormat('HH:mm').format(widget.intervento.orario_fine!)
          : 'N/A';
      final response = await http.post(
        Uri.parse('${ipaddress}/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id?.toString(),
          'data': dataString,
          'orarioInizio': orarioInizioString,
          'orarioFine': orarioFineString,
          'descrizione': widget.intervento.descrizione,
          'importoIntervento': widget.intervento.importo_intervento,
          'assegnato': true,
          'conclusione_parziale' : false,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'note': widget.intervento.note,
          'firmaCliente': widget.intervento.firma_cliente,
          'utente': utenteSelezionato.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria_intervento_specifico':
              widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap(),
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Intervento assegnato con successo'),
        ),
      );
    } catch (e) {
      print('${widget.intervento.veicolo.toString()}');
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  buildInfoRow(
                    title: 'Data creazione',
                    value: formatDate(widget.intervento.data_apertura_intervento),
                  ),
                  buildInfoRow(
                    title: 'Data accordata',
                    value: formatDate(widget.intervento.data),
                  ),
                  buildInfoRow(
                    title: 'Orario Inizio',
                    value: formatTime(widget.intervento.orario_inizio),
                  ),
                  buildInfoRow(
                    title: 'Orario Fine',
                    value: formatTime(widget.intervento.orario_fine),
                  ),
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
                      fontSize: 18,
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
                  buildInfoRow(
                    title: 'Assegnato',
                    value: booleanToString(widget.intervento.assegnato ?? false),
                  ),
                  if (widget.intervento.utente == null)
                    ElevatedButton(
                      onPressed: () {
                        //_showUtentiModal(snapshot.data!);
                      },
                      child: Text(
                        'Assegna',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  buildInfoRow(
                    title: 'Utente incaricato',
                    value: '${widget.intervento.utente?.nome.toString()} ${widget.intervento.utente?.cognome.toString()}' ?? "Non assegnato",
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
                          value: '${relazione.utente?.nome} ${relazione.utente?.cognome}',
                        )),
                      ],
                    ),
                  buildInfoRow(
                    title: 'Concluso',
                    value: booleanToString(widget.intervento.concluso ?? false),
                  ),
                  buildInfoRow(
                    title: 'Saldato',
                    value: booleanToString(widget.intervento.saldato ?? false),
                  ),
                  buildInfoRow(
                    title: 'Note',
                    value: widget.intervento.note.toString() ?? 'N/A',
                  ),
                  buildInfoRow(
                    title: 'Metodo di pagamento',
                    value: widget.intervento.tipologia_pagamento != null
                        ? widget.intervento.tipologia_pagamento?.descrizione ?? 'N/A'
                        : 'N/A',
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
                    title: Text('Nota'),
                    subtitle: Text('${nota.utente?.nome} ${nota.utente?.cognome} : ${nota.nota}'),
                  )),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                if (descrizioneController.text.isNotEmpty && importoController.text.isNotEmpty) {
                  saveIntervento();
                }
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
              },
              icon: Icon(Icons.picture_as_pdf, color: Colors.white),
              label: Text('Genera PDF', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Imposta il colore di sfondo a rosso
              ),
            ),
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
    try{
      final response = await http.post(Uri.parse('$ipaddress/api/intervento'),
          headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id,
          'data': widget.intervento.data?.toIso8601String(),
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': descrizioneController.text,
          'importo_intervento': double.parse(importoController.text),
          'assegnato':widget.intervento.assegnato,
          'conclusione_parziale' : widget.intervento.conclusione_parziale,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'note': widget.intervento.note,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente': widget.intervento.utente?.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'merde': widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap()
        })
      );
      if(response.statusCode == 201){
        print('Modifica effettuata');
      }
    } catch(e){
      print('Errore nell\'aggiornamento dell\'intervento');
    }
  }

  Future<void> saveIntervento() async {
    try {
      final response = await http.post(Uri.parse('${ipaddress}/api/intervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': widget.intervento.id,
            'data': widget.intervento.data?.toIso8601String(),
            'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
            'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
            'descrizione': descrizioneController.text,
            'importo_intervento': double.parse(importoController.text),
            'assegnato': true,
            'conclusione_parziale' : false,
            'concluso': true,
            'saldato': false,
            'note': widget.intervento.note,
            'firma_cliente': widget.intervento.firma_cliente,
            'utente': widget.intervento.utente?.toMap(),
            'cliente': widget.intervento.cliente?.toMap(),
            'veicolo': widget.intervento.veicolo?.toMap(),
            'merce': widget.intervento.merce?.toMap(),
            'tipologia': widget.intervento.tipologia?.toMap(),
            'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
            'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
            'destinazione': widget.intervento.destinazione?.toMap()
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
            'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
            'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
            'descrizione': widget.intervento.descrizione,
            'importo_intervento': widget.intervento.importo_intervento,
            'assegnato': widget.intervento.assegnato,
            'conclusione_parziale' : widget.intervento.conclusione_parziale,
            'concluso': widget.intervento.concluso,
            'saldato': true,
            'note': widget.intervento.note,
            'firma_cliente': widget.intervento.firma_cliente,
            'utente': widget.intervento.utente?.toMap(),
            'cliente': widget.intervento.cliente?.toMap(),
            'veicolo': widget.intervento.veicolo?.toMap(),
            'merce' : widget.intervento.merce?.toMap(),
            'tipologia': widget.intervento.tipologia?.toMap(),
            'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
            'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
            'destinazione': widget.intervento.destinazione?.toMap()
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

  Widget buildLightDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],
    );
  }

  // Funzione per creare una riga divisoria grigia scura
  Widget buildDarkDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[600],
    );
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
