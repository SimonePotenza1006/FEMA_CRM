import 'dart:convert';
import 'package:fema_crm/model/NotaTecnicoModel.dart';
import 'package:fema_crm/model/RelazioneUtentiInterventiModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:fema_crm/pages/DettaglioMerceInRiparazioneByTecnicoPage.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../model/InterventoModel.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'AggiuntaManualeProdottiDDTPage.dart';
import 'AggiuntaNotaByTecnicoPage.dart';
import 'CompilazionePreventivoMerceInRiparazionePage.dart';
import 'InizioInterventoPage.dart';
import 'ScannerBarCodePage.dart';
import 'ScannerQrCodePage.dart';
import 'CompilazioneRapportinoPage.dart'; // Importa il pacchetto per il formato delle date
import 'package:fema_crm/model/RelazioneDdtProdottiModel.dart';

import 'ScannerQrCodeTecnicoPage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';


class DettaglioInterventoByTecnicoPage extends StatefulWidget {
  final UtenteModel? utente;
  final InterventoModel intervento;

  DettaglioInterventoByTecnicoPage({Key? key,required this.utente, required this.intervento}) : super(key: key);

  @override
  _DettaglioInterventoByTecnicoPageState createState() => _DettaglioInterventoByTecnicoPageState();
}

class _DettaglioInterventoByTecnicoPageState extends State<DettaglioInterventoByTecnicoPage> {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy'); // Formato della data
  final DateFormat timeFormat = DateFormat('HH:mm');
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<NotaTecnicoModel> allNote = [];
  List<RelazioneDdtProdottoModel> prodotti = [];
  List<RelazioneUtentiInterventiModel> allRelazioni = [];

  @override
  void initState() {
    super.initState();
    getAllNoteByIntervento();
    getAllRelazioniByIntervento();
  }

  Future<void> getAllRelazioniByIntervento() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/relazioneUtentiInterventi/intervento/${widget.intervento.id}');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<RelazioneUtentiInterventiModel> relazioni = [];
        for(var item in jsonData){
          relazioni.add(RelazioneUtentiInterventiModel.fromJson(item));
        }
        setState(() {
          allRelazioni = relazioni;
        });
      }else {
        throw Exception('Failed to load ingressi data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingressi data from API $e');
    }
  }

  Future<void> getAllNoteByIntervento() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/noteTecnico/intervento/${widget.intervento.id}');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<NotaTecnicoModel> note = [];
        for(var item in jsonData) {
          note.add(NotaTecnicoModel.fromJson(item));
        }
        setState(() {
          allNote = note;
        });
      }else {
        throw Exception('Failed to load ingressi data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingressi data from API $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio Intervento',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Data, Orario inizio, Orario fine
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailRow('Data', dateFormat.format(widget.intervento.data ?? DateTime.now())),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Orario Inizio', widget.intervento.orario_inizio != null ? timeFormat.format(widget.intervento.orario_inizio!) : 'N/A'),
                      _buildDetailRow('Orario Fine', widget.intervento.orario_fine != null ? timeFormat.format(widget.intervento.orario_fine!) : 'N/A'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40),
              // Responsabile intervento, Altri utenti assegnati, Informazioni Cliente
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Responsabile intervento e Altri utenti assegnati
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Responsabile intervento:', widget.intervento.utente?.cognome ?? 'N/A'),
                      if(allRelazioni.isNotEmpty)
                        Text(
                          'Altri utenti assegnati:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: allRelazioni.map((relazione){
                          return Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 5),
                            child: Text(
                              '-${relazione.utente?.nomeCompleto()}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  // Informazioni Cliente
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informazioni Cliente',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      _buildDetailRow('Denominazione cliente', widget.intervento.cliente?.denominazione ?? 'N/A'),
                      _buildDetailRow('Telefono', widget.intervento.cliente?.telefono ?? 'N/A'),
                      _buildDetailRow('Cellulare', widget.intervento.cliente?.cellulare ?? 'N/A'),
                      _buildDetailRow('Indirizzo cliente', widget.intervento.cliente?.indirizzo ?? 'N/A'),
                      _buildDetailRow('Indirizzo destinazione', widget.intervento.destinazione?.indirizzo ?? 'N/A'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Titolo "Dettagli Intervento"
              Text(
                'Dettagli Intervento',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              // Descrizione intervento, Note
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Descrizione', widget.intervento.descrizione ?? 'N/A'),
                  SizedBox(height: 5),
                  if(widget.intervento.merce != null)
                    _buildDetailRow('Articolo', widget.intervento.merce?.articolo ?? 'N/A'),
                    _buildDetailRow('Accessori', widget.intervento.merce?.accessori ?? 'N/A'),
                    _buildDetailRow('Difetto dichiarato', widget.intervento.merce?.difetto_riscontrato ?? 'N/A'),
                    _buildDetailRow('Preventivo:', widget.intervento.merce?.preventivo != null ? (widget.intervento.merce!.preventivo! ? 'Preventivo richiesto' : 'Preventivo non richiesto') : ''),
                    _buildDetailRow('Importo Preventivato:', widget.intervento.merce?.importo_preventivato != null ? widget.intervento.merce!.importo_preventivato.toString() : ''),
                  SizedBox(height: 10),
                  Text(
                    'Note:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 5),
                  if (allNote.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: allNote.map((note) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            '- ${note.nota}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  if (allNote.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Nessuna nota disponibile',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 40),
              // Pulsanti
              if(widget.intervento.merce == null)
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ScannerQrCodeTecnicoPage(intervento: widget.intervento)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          textStyle: TextStyle(fontSize: 20),
                          primary: Colors.red,
                        ),
                        child: Text(
                          'Scannerizza QrCode',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AggiuntaManualeProdottiDDTPage(intervento: widget.intervento)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          textStyle: TextStyle(fontSize: 20),
                          primary: Colors.red,
                        ),
                        child: Text(
                          'Aggiungi prodotti manualmente',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AggiuntaNotaByTecnicoPage(intervento: widget.intervento, utente: widget.utente!)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          textStyle: TextStyle(fontSize: 20),
                          primary: Colors.red,
                        ),
                        child: Text(
                          'Lascia una nota',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 12),
                      if(widget.intervento.utente?.id == widget.utente?.id)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => InizioInterventoPage(intervento: widget.intervento, utente: widget.utente!)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            textStyle: TextStyle(fontSize: 20),
                            primary: Colors.red,
                          ),
                          child: Text(
                            'Inizia intervento',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      SizedBox(height: 12),
                      if(widget.intervento.utente?.id == widget.utente?.id)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CompilazioneRapportinoPage(intervento: widget.intervento)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            textStyle: TextStyle(fontSize: 20),
                            primary: Colors.red,
                          ),
                          child: Text(
                            'Compila rapportino',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              if(widget.intervento.merce != null)
                if(widget.intervento.merce?.preventivo == true)

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CompilazionePreventivoMerceInRiparazionePage(merce: widget.intervento.merce!)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        textStyle: TextStyle(fontSize: 20),
                        primary: Colors.red,
                      ),
                      child: Text(
                        'Compila preventivo',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                Center(
                  child:
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AggiuntaNotaByTecnicoPage(intervento: widget.intervento, utente: widget.utente!)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        textStyle: TextStyle(fontSize: 20),
                        primary: Colors.red,
                      ),
                      child: Text(
                        'Lascia una nota',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DettaglioMerceInRiparazioneByTecnicoPage(intervento: widget.intervento)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      textStyle: TextStyle(fontSize: 20),
                      primary: Colors.red,
                    ),
                    child: Text(
                      'Compilazione rapportino merce in riparazione',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildDetailRow(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
