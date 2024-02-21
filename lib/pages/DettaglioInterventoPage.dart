import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _utentiFuture = _fetchUtenti();
  }

  Future<List<UtenteModel>> _fetchUtenti() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.52:8080/api/utente'));
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
        Uri.parse('http://192.168.1.52:8080/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id?.toString(),
          'data': dataString,
          'orarioInizio': orarioInizioString,
          'orarioFine': orarioFineString,
          'descrizione': widget.intervento.descrizione,
          'importoIntervento': widget.intervento.importo_intervento,
          'assegnato': true,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'note': widget.intervento.note,
          'firmaCliente': widget.intervento.firma_cliente,
          'utente': utenteSelezionato.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria_intervento_specifico': widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologiaPagamento?.toMap(),
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<UtenteModel>>(
              future: _utentiFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Errore durante il recupero degli utenti'));
                } else {
                  return ListView(
                    padding: EdgeInsets.all(16.0),
                    children: [
                      ListTile(
                        title: Text(
                          'Data',
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          formatDate(widget.intervento.data),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Orario Inizio',
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          formatTime(widget.intervento.orario_inizio),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Orario Fine',
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          formatTime(widget.intervento.orario_fine),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Descrizione',
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          widget.intervento.descrizione ?? 'N/A',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Importo Intervento',
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          widget.intervento.importo_intervento?.toString() ?? 'N/A',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Assegnato',
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              booleanToString(widget.intervento.assegnato ?? false),
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(width: 200),
                            ElevatedButton(
                              onPressed: () {
                                _showUtentiModal(snapshot.data!);
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(12.0),
                                ),
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.red,
                                ),
                              ),
                              child: Text(
                                'Assegna',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Utente incaricato',
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          '${widget.intervento.utente?.nome.toString()} ${widget.intervento.utente?.cognome.toString()}'  ?? "Non assegnato",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Concluso',
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          booleanToString(widget.intervento.concluso ?? false),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Saldato',
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          booleanToString(widget.intervento.saldato ?? false),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Note',
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          widget.intervento.note.toString() ?? 'N/A',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PDFInterventoPage(intervento: widget.intervento)),
            );
          },
          icon: Icon(Icons.picture_as_pdf, color: Colors.white),
          label: Text('Genera PDF', style: TextStyle(color: Colors.white)),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          ),
        ),
      ),
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
