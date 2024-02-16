import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/InterventoModel.dart';
import '../model/UtenteModel.dart';
import '../model/RuoloUtenteModel.dart';

class DettaglioInterventoPage extends StatefulWidget {
  final InterventoModel intervento;

  DettaglioInterventoPage({required this.intervento});

  @override
  _DettaglioInterventoPageState createState() =>
      _DettaglioInterventoPageState();
}

class _DettaglioInterventoPageState extends State<DettaglioInterventoPage> {


  void _assegnaUtente(UtenteModel utenteSelezionato) async {
    try {
      // Converti le date in formato stringa
      String? dataString = widget.intervento.data?.toIso8601String();
      String? orarioInizioString = widget.intervento.orario_inizio?.toIso8601String();
      String? orarioFineString = widget.intervento.orario_fine?.toIso8601String();
      // Esegui la chiamata POST al database
      final response = await http.post(
        Uri.parse('http://192.168.1.52:8080/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id?.toString(),
          'data': dataString,
          'orarioInizio': orarioInizioString,
          'orarioFine': orarioFineString,
          'descrizione': widget.intervento.descrizione,
          'foto': widget.intervento.foto,
          'importoIntervento': widget.intervento.importo_intervento,
          'assegnato': true,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'note': widget.intervento.note,
          'firmaCliente': widget.intervento.firma_cliente,
          'utente': utenteSelezionato.toJson(),
          'cliente': widget.intervento.cliente?.toMap(), // Converti il cliente in una mappa
          'veicolo': widget.intervento.veicolo?.toMap(), // Converti il veicolo in una mappa
          'tipologia': widget.intervento.tipologia?.toMap(), // Converti la tipologia in una mappa
          'categoria_intervento_specifico': widget.intervento.categoria_intervento_specifico?.toMap(), // Converti la categoria in una mappa
          'tipologia_pagamento': widget.intervento.tipologiaPagamento?.toMap(), // Converti la tipologia di pagamento in una mappa
          'destinazione': widget.intervento.destinazione?.toMap(), // Converti la destinazione in una mappa
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervento assegnato con successo'),
          ),
        );
      } else {
        print('${widget.intervento.categoria_intervento_specifico?.toMap()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'assegnazione dell\'intervento'),
          ),
        );
      }
    } catch (e) {
      print('${widget.intervento.veicolo.toString()}');
      print('PROVAAAAAAA Errore durante l\'assegnazione dell\'intervento: $e, ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante l\'assegnazione dell\'intervento'),
        ),
      );
    }
  }



  void _showUtentiModal(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.52:8080/api/utente'));
      var responseData = json.decode(response.body.toString());

      if (response.statusCode == 200) {
        List<UtenteModel> utenti = [];

        for (var singoloUtente in responseData) {
          utenti.add(UtenteModel.fromJson(singoloUtente));
        }

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
                    },
                  );
                },
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il recupero degli utenti'),
          ),
        );
      }
    } catch (e) {
      print('Errore durante il recupero degli utenti: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante il recupero degli utenti'),
        ),
      );
    }
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
            child: ListView(
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
                        booleanToString(widget.intervento.assegnato),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 200),
                      ElevatedButton(
                        onPressed: () {
                          _showUtentiModal(context);
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
                    'Concluso',
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    booleanToString(widget.intervento.concluso),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Saldato',
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    booleanToString(widget.intervento.saldato),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Note',
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    widget.intervento.note ?? 'N/A',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
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
