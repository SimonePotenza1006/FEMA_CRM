import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../model/AziendaModel.dart';

class CertificazioniFormPage extends StatefulWidget {
  const CertificazioniFormPage({Key? key}) : super(key:key);

  @override
  _CertificazioniFormPageState createState() => _CertificazioniFormPageState();
}

class _CertificazioniFormPageState extends State<CertificazioniFormPage>{
  List<AziendaModel> allAziende = [];
  AziendaModel? selectedAzienda;
  List<TipologiaInterventoModel> allTipologie = [];
  TipologiaInterventoModel? selectedTipologia;
  List<UtenteModel> allUtenti = [];
  UtenteModel? selectedUtente;
  List<ClienteModel> allClienti = [];
  ClienteModel? selectedCliente;
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  Future<void> getAllClienti() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/cliente'));
      if(response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
        List<ClienteModel> clienti = [];
        for(var item in jsonData){
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          allClienti = clienti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamataa all\'API getAllClienti: $e');
    }
  }

  Future<void> getAllUtenti() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/utente'));
      if(response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for(var item in jsonData){
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamataa all\'API getAllUtenti: $e');
    }
  }

  Future<void> getAllTipologie() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/tipologiaIntervento'));
      if(response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
        List<TipologiaInterventoModel> tipologie = [];
        for(var item in jsonData){
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }
        setState(() {
          allTipologie = tipologie;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamataa all\'API getAllTipologie: $e');
    }
  }

  Future<void> getAllAziende() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/azienda'));
      if(response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
        List<AziendaModel> aziende = [];
        for(var item in jsonData){
          aziende.add(AziendaModel.fromJson(item));
        }
        setState(() {
          allAziende = aziende;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamataa all\'API getAllAziende: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compilazione certificazione', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  DropdownButton<AziendaModel>(
                    value: selectedAzienda,
                    onChanged: (AziendaModel? newValue){
                      setState(() {
                        selectedAzienda = newValue;
                      });
                    },
                    items: allAziende.map((AziendaModel azienda){
                      return DropdownMenuItem<AziendaModel>(
                          value: azienda,
                          child: Text(azienda.nome!)
                      );
                    }).toList(),
                    hint: Text('Azienda'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}