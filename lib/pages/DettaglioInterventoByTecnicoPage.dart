import 'dart:convert';
import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/model/NotaTecnicoModel.dart';
import 'package:fema_crm/model/RelazioneUtentiInterventiModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:fema_crm/pages/CreazioneScadenzaPage.dart';
import 'package:fema_crm/pages/DettaglioMerceInRiparazioneByTecnicoPage.dart';
import 'package:fema_crm/pages/HomeFormTecnicoNewPage.dart';
import 'package:fema_crm/pages/SalvataggioCredenzialiClientePage.dart';
import 'package:fema_crm/pages/SceltaRapportinoPage.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../model/InterventoModel.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'AggiuntaFotoPage.dart';
import 'AggiuntaManualeProdottiDDTPage.dart';
import 'AggiuntaNotaByTecnicoPage.dart';
import 'CompilazionePreventivoMerceInRiparazionePage.dart';
import 'InizioInterventoPage.dart';
import 'ModificaRelazioneRapportinoPage.dart';
import 'PDFInterventoPage.dart';
import 'ScannerBarCodePage.dart';
import 'ScannerQrCodePage.dart';
import 'CompilazioneRapportinoPage.dart'; // Importa il pacchetto per il formato delle date
import 'package:fema_crm/model/RelazioneDdtProdottiModel.dart';

import 'ScannerQrCodeTecnicoPage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'VerificaMaterialeNewPage.dart';


class DettaglioInterventoByTecnicoPage extends StatefulWidget {
  final UtenteModel utente;
  final InterventoModel intervento;

  DettaglioInterventoByTecnicoPage({Key? key,required this.utente, required this.intervento}) : super(key: key);

  @override
  _DettaglioInterventoByTecnicoPageState createState() => _DettaglioInterventoByTecnicoPageState();
}

class _DettaglioInterventoByTecnicoPageState extends State<DettaglioInterventoByTecnicoPage> {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy'); // Formato della data
  final DateFormat timeFormat = DateFormat('HH:mm');
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<NotaTecnicoModel> allNote = [];
  List<RelazioneDdtProdottoModel> prodotti = [];
  List<RelazioneUtentiInterventiModel> otherUtenti = [];
  DDTModel? finalDdt;
  String _indirizzo = "";

  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      //List<Placemark> placemarks =
      return placemarkFromCoordinates(latitude, longitude).then((value) {

        return value.isNotEmpty ? '${value[0].street}, ${value[0].subThoroughfare} ${value[0].locality}, ${value[0].administrativeArea} ${value[0].postalCode}'
            : '';
      });
      //Placemark place = placemarks[0];
      //return '${place.street},${place.subThoroughfare} ${place.locality}, ${place.administrativeArea} ${place.postalCode}';//, ${place.country}';
    } catch (e) {
      print("Errore durante la conversione delle coordinate in indirizzo: $e");
      return "Indirizzo non disponibile";
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) =>
          getAddressFromCoordinates(value.latitude, value.longitude).then((value2) {
            setState(() {
              //_gps = "${position.latitude}, ${position.longitude}";
              _indirizzo = value2.toString();
            });
          })
      );
      /*String indirizzo = await getAddressFromCoordinates(position.latitude, position.longitude);
      setState(() {
        _gps = "${position.latitude}, ${position.longitude}";
        _indirizzo = indirizzo.toString();
      });*/
    } catch (e) {
      print("Errore durante l'ottenimento della posizione: $e");
    }
  }


  @override
  void initState() {
    super.initState();
    getAllNoteByIntervento();
    getRelazioni();
    getProdotti();
    _getCurrentLocation();
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
      final response = await http.get(Uri.parse('$ipaddress/api/relazioneUtentiInterventi/intervento/${widget.intervento.id}'));
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

  void modificaOrarioFine() async{
    // try{
    //   final response = await http.post(
    //     Uri.parse('$ipaddress/api/intervento'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode({
    //       'id': widget.intervento.id?.toString(),
    //       'numerazione_danea' : widget.intervento.numerazione_danea,
    //       'priorita' : widget.intervento.priorita.toString().split('.').last,
    //       'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
    //       'data': widget.intervento.data?.toIso8601String(),
    //       'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
    //       'posizione_gps' : widget.intervento.posizione_gps,
    //       'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
    //       'orario_fine': DateTime.now().toIso8601String(),//widget.intervento.orario_fine?.toIso8601String(),
    //       'descrizione': widget.intervento.descrizione,
    //       'importo_intervento': widget.intervento.importo_intervento,
    //       'prezzo_ivato' : widget.intervento.prezzo_ivato,
    //       'iva' : widget.intervento.iva,
    //       'acconto' : widget.intervento.acconto,
    //       'assegnato': widget.intervento.assegnato,
    //       'accettato_da_tecnico' : widget.intervento.accettato_da_tecnico,
    //       'conclusione_parziale' : widget.intervento.conclusione_parziale,
    //       'concluso': true,
    //       'saldato': widget.intervento.saldato,
    //       'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
    //       'note': widget.intervento.note,
    //       'relazione_tecnico' : widget.intervento.relazione_tecnico,
    //       'firma_cliente': widget.intervento.firma_cliente,
    //       'utente': widget.intervento.utente?.toMap(),
    //       'cliente': widget.intervento.cliente?.toMap(),
    //       'veicolo': widget.intervento.veicolo?.toMap(),
    //       'merce' :widget.intervento.merce?.toMap(),
    //       'tipologia': widget.intervento.tipologia?.toMap(),
    //       'categoria_intervento_specifico':
    //       widget.intervento.categoria_intervento_specifico?.toMap(),
    //       'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
    //       'destinazione': widget.intervento.destinazione?.toMap(),
    //       'gruppo' : widget.intervento.gruppo?.toMap()
    //     }),
    //   );
    //   if(response.statusCode == 201){
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Orario di fine intervento salvato con successo!'),
    //       ),
    //     );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SceltaRapportinoPage(utente: widget.utente, intervento: widget.intervento,)),
        );
    //   }
    // } catch(e){
    //   print('Qualcosa non va: $e');
    // }
  }

  void modificaOrarioInizio() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id?.toString(),
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
          'acconto' : widget.intervento.acconto,
          'assegnato': widget.intervento.assegnato,
          'accettato_da_tecnico' : widget.intervento.accettato_da_tecnico,
          'conclusione_parziale' : widget.intervento.conclusione_parziale,
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
          'merce' :widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria_intervento_specifico':
          widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap(),
          'gruppo' : widget.intervento.gruppo?.toMap()
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Orario di inizio intervento salvato con successo!'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeFormTecnicoNewPage(userData: widget.utente)),
        );
      }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Dettaglio Intervento'.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DettaglioInterventoByTecnicoPage(
                    intervento: widget.intervento,
                    utente: widget.utente,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              children : [
                if (widget.intervento.utente?.id == widget.utente.id)
                  if (widget.intervento.orario_inizio == null  && (widget.utente.id == "9" || widget.utente.id == "4" || widget.intervento.id == "5"))
                    SpeedDialChild(
                      child: Icon(Icons.lock_clock_outlined, color: Colors.white),
                      backgroundColor: Colors.red,
                      label: 'Inizia intervento'.toUpperCase(),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InizioInterventoPage(intervento: widget.intervento, utente: widget.utente),
                        ),
                      ),
                    ),
                if(widget.intervento.concluso == false && widget.intervento.orario_inizio != null &&  widget.intervento.utente?.id == widget.utente.id && widget.intervento.merce == null && (widget.utente.id == "9" || widget.utente.id == "4" || widget.intervento.id == "5"))
                  SpeedDialChild(
                    child: Icon(Icons.cases_outlined, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: 'Compila Rapportino'.toUpperCase(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompilazioneRapportinoPage(intervento: widget.intervento),
                      ),
                    ),
                  ),
                SpeedDialChild(
                  child: Icon(Icons.edit_outlined, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Lascia una nota'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AggiuntaNotaByTecnicoPage(intervento: widget.intervento, utente: widget.utente!),
                    ),
                  ),
                ),
                // SpeedDialChild(
                //   child: Icon(Icons.camera_alt_outlined, color: Colors.white),
                //   backgroundColor: Colors.red,
                //   label: 'ALLEGA RAPPORTINO'.toUpperCase(),
                //   onTap: () => Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => AggiuntaFotoPage(intervento: widget.intervento, utente: widget.utente),
                //     ),
                //   ),
                // ),
                SpeedDialChild(
                  child: Icon(Icons.camera_alt_outlined, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Aggiungi foto'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AggiuntaFotoPage(intervento: widget.intervento, utente: widget.utente),
                    ),
                  ),
                ),
                SpeedDialChild(
                  child: Icon(Icons.lock_clock_outlined, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Crea scadenza'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreazioneScadenzaPage(intervento: widget.intervento, cliente: widget.intervento.cliente!,),
                    ),
                  ),
                ),
                SpeedDialChild(
                  child: Icon(Icons.password, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Salva credenziali'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalvataggioCredenzialiClientePage(cliente: widget.intervento.cliente!, utente: widget.utente!),
                    ),
                  ),
                ),
                SpeedDialChild(
                  child: Icon(Icons.checklist_outlined, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Materiale utilizzato'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerificaMaterialeNewPage(intervento: widget.intervento, utente: widget.utente!),
                    ),
                  ),
                ),
                SpeedDialChild(
                  child: Icon(Icons.qr_code_outlined, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Scannerizza qrcode'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScannerQrCodeTecnicoPage(intervento: widget.intervento),
                    ),
                  ),
                ),
              ]
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 500),
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
                    SizedBox(height: 20),
                    buildInfoRow(
                      title: 'Intervento nr',
                      value: widget.intervento.id!,
                      context: context,
                    ),
                    SizedBox(height: 15),
                    buildTileRow(
                      title: 'Cliente',
                      value: widget.intervento.cliente?.denominazione?? 'N/A',
                      context: context,
                    ),
                    /*SizedBox(height : 15),
                    buildInfoRow(
                      title: 'Destinazione',
                      value: widget.intervento.destinazione?.indirizzo?? 'N/A',
                      context: context,
                    ),*/

                    /*SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Data creazione',
                      value: formatDate(widget.intervento.data_apertura_intervento),
                      context: context,
                    ),*/
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Data appuntamento',
                      value: formatDate(widget.intervento.data),
                      context: context,
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Orario appuntamento',
                      value: formatTime(widget.intervento.orario_appuntamento),
                      context: context,
                    ),
                   /* SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Orario Inizio',
                      value: formatTime(widget.intervento.orario_inizio),
                      context: context,
                    ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Orario Fine',
                      value: formatTime(widget.intervento.orario_fine),
                      context: context,
                    ),*/

                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Descrizione',
                      value: widget.intervento.descrizione?? 'N/A',
                      context: context,
                    ),
                    /*SizedBox(height : 15),
                    buildInfoRow(
                      title: 'Indirizzo cliente',
                      value: widget.intervento.cliente?.indirizzo?? 'N/A',
                      context: context,
                    ),
                    SizedBox(height : 15),
                    buildInfoRow(
                      title: 'Telefono cliente',
                      value: widget.intervento.cliente?.telefono?? 'N/A',
                      context: context,
                    ),
                    SizedBox(height : 15),
                    buildInfoRow(
                      title: 'Cellulare cliente',
                      value: widget.intervento.cliente?.cellulare?? 'N/A',
                      context: context,
                    ),*/
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
                      context: context,
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
                            context: context,
                          )),
                        ],
                      ),
                    SizedBox(height: 15),
                    buildInfoRow(
                      title: 'Note',
                      value: widget.intervento.note?? 'N/A',
                      context: context,
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
                        context: context,
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Accessori',
                        value: widget.intervento.merce?.accessori?? 'N/A',
                        context: context,
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Difetto riscontrato',
                        value: widget.intervento.merce?.difetto_riscontrato?? 'N/A',
                        context: context,
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Diagnosi',
                        value: widget.intervento.merce?.diagnosi?? 'N/A',
                        context: context,
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Richiesta di preventivo',
                        value: booleanToString(widget.intervento.merce?.preventivo?? false),
                        context: context,
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Importo preventivato',
                        value: widget.intervento.merce?.importo_preventivato.toString()?? 'N/A',
                        context: context,
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Password',
                        value: widget.intervento.merce?.password?? 'N/A',
                        context: context,
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Dati',
                        value: widget.intervento.merce?.dati?? 'N/A',
                        context: context,
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
              SizedBox(height: 25),
              if (widget.intervento.orario_inizio == null) ElevatedButton(
                onPressed: () {
                  modificaOrarioInizio();
                },
                style: ElevatedButton.styleFrom(minimumSize: Size(450, 35),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: TextStyle(fontSize: 20),
                  primary: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  'INIZIA INTERVENTO',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),

              if (widget.intervento.orario_inizio != null && widget.intervento.orario_fine == null) ElevatedButton(
                onPressed: () {
                  modificaOrarioFine();
                },
                style: ElevatedButton.styleFrom(minimumSize: Size(450, 35),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: TextStyle(fontSize: 20),
                  primary: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  'TERMINA INTERVENTO',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              if(widget.utente.id!.toString() == "9" || widget.utente.id!.toString() == "4" || widget.utente.id!.toString() == "5")
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFInterventoPage(
                          intervento: widget.intervento,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow({required String title, required String value, BuildContext? context}) {
    bool isValueTooLong = value.length > 15;
    String displayedValue = isValueTooLong ? value.substring(0, 10) + "..." : value;
    return SizedBox(
      width: 450,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4, // Linea di accento colorata
                      height: 24,
                      color: Colors.redAccent, // Colore di accento per un tocco di vivacità
                    ),
                    SizedBox(width: 10),
                    Text(
                      title.toUpperCase() + ": ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Colore contrastante per il testo
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        displayedValue.toUpperCase(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold, // Un colore secondario per differenziare il valore
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isValueTooLong && context != null)
                        IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("${title.toUpperCase()}"),
                                  content: Text(value),
                                  actions: [
                                    TextButton(
                                      child: Text("Chiudi"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Divider( // Linea di separazione tra i widget
              color: Colors.grey[400],
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTileRow({required String title, required String value, BuildContext? context}) {
    // Verifica se il valore supera i 25 caratteri
    bool isValueTooLong = value.length > 15;
    String displayedValue = isValueTooLong ? value.substring(0, 10) + "..." : value;
    return
      ExpansionTile(
          children: [
            buildInfoRow(
              title: 'Destinazione',
              value: widget.intervento.destinazione?.indirizzo ?? 'N/A',
              context: context,
            ),
            buildInfoRow(
              title: 'Indirizzo cliente',
              value: widget.intervento.cliente?.indirizzo ?? 'N/A',
              context: context,
            ),
            buildInfoRow(
              title: 'Telefono cliente',
              value: widget.intervento.cliente?.telefono ?? 'N/A',
              context: context,
            ),
            buildInfoRow(
              title: 'Cellulare cliente',
              value: widget.intervento.cliente?.cellulare ?? 'N/A',
              context: context,
            ),
          ],
      title:
      SizedBox(
      width: 450,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4, // Linea di accento colorata
                      height: 24,
                      color: Colors.redAccent, // Colore di accento per un tocco di vivacità
                    ),
                    SizedBox(width: 10),
                    Text(
                      title.toUpperCase() + ": ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Colore contrastante per il testo
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      Text(
                        displayedValue.toUpperCase(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold, // Un colore secondario per differenziare il valore
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isValueTooLong && context != null)
                        IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("${title.toUpperCase()}"),
                                  content: Text(value),
                                  actions: [
                                    TextButton(
                                      child: Text("Chiudi"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Divider( // Linea di separazione tra i widget
              color: Colors.grey[400],
              thickness: 1,
            ),
          ],
        ),
      ),
    )
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

