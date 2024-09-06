import 'package:fema_crm/model/InterventoModel.dart';
import 'package:flutter/material.dart';
import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DettaglioMerceInRiparazioneByTecnicoPage extends StatefulWidget {
  final InterventoModel intervento;

  DettaglioMerceInRiparazioneByTecnicoPage({Key? key, required this.intervento}) : super(key: key);

  @override
  _DettaglioMerceInRiparazioneByTecnicoPageState createState() =>
      _DettaglioMerceInRiparazioneByTecnicoPageState();
}

class _DettaglioMerceInRiparazioneByTecnicoPageState
    extends State<DettaglioMerceInRiparazioneByTecnicoPage> {
  final TextEditingController diagnosiController = TextEditingController();
  final TextEditingController risoluzioneController = TextEditingController();
  final TextEditingController prodottiInstallatiController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';


  @override
  void initState() {
    super.initState();
    diagnosiController.text = widget.intervento.merce?.diagnosi ?? '';
    risoluzioneController.text = widget.intervento.merce?.risoluzione ?? '';
    prodottiInstallatiController.text = widget.intervento.merce?.prodotti_installati ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio Merce in Riparazione',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID:', widget.intervento.merce?.id ?? ''),
              _buildDetailRow('Data:', widget.intervento.merce?.data != null ? DateFormat('dd/MM/yyyy').format(widget.intervento.merce!.data!) : ''),
              _buildDetailRow('Articolo:', widget.intervento.merce?.articolo ?? ''),
              _buildDetailRow('Accessori:', widget.intervento.merce?.accessori ?? ''),
              _buildDetailRow('Difetto Riscontrato:', widget.intervento.merce?.difetto_riscontrato ?? ''),
              //_buildDetailRow('Data Presa in Carico:', widget.merce.data_presa_in_carico != null ? DateFormat('dd/MM/yyyy').format(widget.merce.data_presa_in_carico!) : ''),
              _buildDetailRow('Password:', widget.intervento.merce?.password ?? ''),
              _buildDetailRow('Dati:', widget.intervento.merce?.dati ?? ''),
              _buildDetailRow('Preventivo:', widget.intervento.merce?.preventivo != null ? (widget.intervento.merce!.preventivo! ? 'Preventivo richiesto' : 'Preventivo non richiesto') : ''),
              _buildDetailRow('Importo Preventivato:', widget.intervento.merce?.importo_preventivato != null ? widget.intervento.merce!.importo_preventivato.toString() : ''),
              SizedBox(height: 20),
              _buildDetailRow('Diagnosi:', widget.intervento.merce?.diagnosi ?? ''),
              TextFormField(
                controller: diagnosiController,
                decoration: InputDecoration(
                  labelText: 'Diagnosi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                maxLines: null,
              ),
              SizedBox(height: 20,),
              _buildDetailRow('Risoluzione:', widget.intervento.merce?.risoluzione ?? ''),
              TextFormField(
                controller: risoluzioneController,
                decoration: InputDecoration(
                  labelText: 'Risoluzione',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                maxLines: null,
              ),
              SizedBox(height: 20,),
              _buildDetailRow('Prodotti Installati:', widget.intervento.merce?.prodotti_installati ?? ''),
              TextFormField(
                controller: prodottiInstallatiController,
                decoration: InputDecoration(
                  labelText: 'Prodotti Installati',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                maxLines: null,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    concludi();
                    chiudiIntervento();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Riparazione conclusa'),
                ),
              ),
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

  Future<void> chiudiIntervento() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id,
          'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': widget.intervento.descrizione,
          'importo_intervento': null,
          'prezzo_ivato' : widget.intervento.prezzo_ivato,
          'assegnato': true,
          'conclusione_parziale' : widget.intervento.conclusione_parziale,
          'concluso': true,
          'saldato': false,
          'note': widget.intervento.note,
          'relazione_tecnico' : widget.intervento.relazione_tecnico,
          'firma_cliente' : widget.intervento.firma_cliente,
          'utente': widget.intervento.utente?.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'merce' : widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap(),
        })
      );
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Riparazione conclusa!'),
        ),
      );
    } catch(e){
      print('Errore durante il salvataggio: $e');
    }
  }

  Future<void> concludi() async {
    try {
      String? dataConclusione = DateTime.now().toIso8601String();
      String? dataConsegna = widget.intervento.merce?.data_consegna != null ? widget.intervento.merce?.data_consegna!.toIso8601String() : null;
      String? dataPresaInCarico = widget.intervento.merce?.data_presa_in_carico != null ? widget.intervento.merce?.data_presa_in_carico!.toIso8601String() : null;
      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.merce?.id,
          'data': widget.intervento.merce?.data?.toIso8601String(), // Converti data in stringa ISO 8601
          'articolo': widget.intervento.merce?.articolo,
          'accessori': widget.intervento.merce?.accessori,
          'difetto_riscontrato': widget.intervento.merce?.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.intervento.merce?.password,
          'dati': widget.intervento.merce?.dati,
          'preventivo': widget.intervento.merce?.preventivo,
          'importo_preventivato': widget.intervento.merce?.importo_preventivato,
          'diagnosi': diagnosiController.text,
          'risoluzione': risoluzioneController.text,
          'data_conclusione': dataConclusione,
          'prodotti_installati': prodottiInstallatiController.text,
          'data_consegna': dataConsegna,
        }),
      );
    } catch (e) {
      print('Errore $e');
    }
  }

}
