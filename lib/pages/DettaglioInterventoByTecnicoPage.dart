import 'dart:convert';
import 'package:fema_crm/model/DDTModel.dart';
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
import 'ModificaRelazioneRapportinoPage.dart';
import 'ScannerBarCodePage.dart';
import 'ScannerQrCodePage.dart';
import 'CompilazioneRapportinoPage.dart'; // Importa il pacchetto per il formato delle date
import 'package:fema_crm/model/RelazioneDdtProdottiModel.dart';

import 'ScannerQrCodeTecnicoPage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'VerificaMaterialeNewPage.dart';


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
  List<RelazioneUtentiInterventiModel> otherUtenti = [];
  DDTModel? finalDdt;

  @override
  void initState() {
    super.initState();
    getAllNoteByIntervento();
    getRelazioni();
    getProdotti();
  }

  Future<http.Response?> getDdtByIntervento() async{
    late http.Response response;
    try{
      response = await http.get(
        Uri.parse('$ipaddress/api/ddt/intervento/${widget.intervento.id}'));
        if(response.statusCode == 200){
          var jsonData = jsonDecode(response.body);
          DDTModel ddt = DDTModel.fromJson(jsonData);
          setState(() {
            finalDdt = ddt;
          });
          return response;
        };
    } catch(e){
      print('Errore durante il recupero del ddt: $e');
      return null;
    }
    return null;
  }

  Widget buildProdottoItem(int index){
    final prodotto = prodotti[index];
    final double? costo = prodotti[index].prodotto!.prezzo_fornitore! * double.parse(prodotti[index].quantita.toString());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(
                prodotto.prodotto?.descrizione ?? '',
                style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            'Quantità :${prodotto.quantita.toString()}',
          ),
          SizedBox(height: 12),
          Text(
            'Costo del materiale: $costo'
          ),
        ],
      ),
    );
  }

  Future<void> getProdotti() async{
    final data = await getDdtByIntervento();
    try{
      if(data == null){
        throw Exception('Dati del ddt non disponibili.');
      }
      final ddt = DDTModel.fromJson(jsonDecode(data.body));
      try{
        var apiUrl = Uri.parse('$ipaddress/api/relazioneDDTProdotto/ddt/${ddt.id}');
        var response = await http.get(apiUrl);
        if(response.statusCode == 200){
          var jsonData = jsonDecode(response.body);
          List<RelazioneDdtProdottoModel> relazioni = [];
          for(var item in jsonData){
            relazioni.add(RelazioneDdtProdottoModel.fromJson(item));
          }
          setState(() {
            prodotti = relazioni;
          });
        } else {
          throw Exception('Failed to load data from API: ${response.statusCode}');
        }
      } catch(e){
        print('Errore durante la chiamata all\'APIiiiii: $e');
      }
    } catch(e){
      print('Errore durante la chiamata all\'API: $e');
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
                      value: formatTime(widget.intervento.orario_appuntamento)
                  ),
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Orario Inizio',
                    value: formatTime(widget.intervento.orario_inizio),
                  ),
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Orario Fine',
                    value: formatTime(widget.intervento.orario_fine),
                  ),
                  SizedBox(height: 15),
                  buildInfoRow(
                      title: 'Cliente',
                      value: widget.intervento.cliente?.denominazione?? 'N/A'),
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Descrizione',
                    value: widget.intervento.descrizione?? 'N/A',
                  ),
                  SizedBox(height : 15),
                  buildInfoRow(
                    title: 'Indirizzo destinazione',
                    value: widget.intervento.destinazione?.indirizzo?? 'N/A',
                  ),
                  SizedBox(height : 15),
                  buildInfoRow(
                    title: 'Cellulare destinazione',
                    value: widget.intervento.destinazione?.cellulare?? 'N/A',
                  ),
                  SizedBox(height : 15),
                  buildInfoRow(
                    title: 'Telefono destinazione',
                    value: widget.intervento.destinazione?.telefono?? 'N/A',
                  ),
                  SizedBox(height : 15),
                  buildInfoRow(
                    title: 'Indirizzo cliente',
                    value: widget.intervento.cliente?.indirizzo?? 'N/A',
                  ),
                  SizedBox(height : 15),
                  buildInfoRow(
                    title: 'Telefono cliente',
                    value: widget.intervento.cliente?.telefono?? 'N/A',
                  ),
                  SizedBox(height : 15),
                  buildInfoRow(
                    title: 'Cellulare cliente',
                    value: widget.intervento.cliente?.cellulare?? 'N/A',
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
                  SizedBox(height: 15),
                  if (widget.intervento.utente == null)
                    ElevatedButton(
                      onPressed: () {
                        //_showUtentiModal(snapshot.data!);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        textStyle: TextStyle(fontSize: 20),
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Assegna',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  buildInfoRow(
                    title: 'Utente incaricato',
                    value: '${widget.intervento.utente?.nome.toString()} ${widget.intervento.utente?.cognome.toString()}'?? "Non assegnato",
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
                  SizedBox(height: 15),
                  buildInfoRow(
                    title: 'Note',
                    value: widget.intervento.note?? 'N/A',
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            if(widget.intervento.merce!= null)
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
                      value: widget.intervento.merce?.articolo?? 'N/A',
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Accessori',
                      value: widget.intervento.merce?.accessori?? 'N/A',
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Difetto riscontrato',
                      value: widget.intervento.merce?.difetto_riscontrato?? 'N/A',
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Diagnosi',
                      value: widget.intervento.merce?.diagnosi?? 'N/A',
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Richiesta di preventivo',
                      value: booleanToString(widget.intervento.merce?.preventivo?? false),
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Importo preventivato',
                      value: widget.intervento.merce?.importo_preventivato.toString()?? 'N/A',
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Password',
                      value: widget.intervento.merce?.password?? 'N/A',
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Dati',
                      value: widget.intervento.merce?.dati?? 'N/A',
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
            SizedBox(height: 40),
            Center(
              child: Wrap(
                spacing: 25,
                runSpacing: 16,
                children: [
                  if (widget.intervento.merce == null)
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Scannerizza QrCode',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (widget.intervento.merce == null)
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Lascia una nota',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (widget.intervento.utente?.id == widget.utente?.id)
                    if (widget.intervento.orario_inizio == null)
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'Inizia intervento',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  if(widget.intervento.concluso == false && widget.intervento.orario_inizio != null)
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Compila rapportino',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (widget.intervento.concluso == true &&
                      DateTime.now().difference(widget.intervento.orario_fine!).inHours < 24)
                    ElevatedButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ModificaRelazioneRapportinoPage(intervento: widget.intervento)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        textStyle: TextStyle(fontSize: 20),
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Modifica Rapportino',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => VerificaMaterialeNewPage(intervento: widget.intervento, utente: widget.utente! )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        textStyle: TextStyle(fontSize: 20),
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Materiale utilizzato',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if(widget.intervento.merce!= null)
                    if(widget.intervento.merce?.preventivo == true)
                      ElevatedButton(
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'Compila preventivo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  if(widget.intervento.merce!= null)
                    ElevatedButton(
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Compilazione rapportino merce in riparazione',
                        style: TextStyle(color: Colors.white),
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

