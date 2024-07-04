import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
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
  List<TipologiaInterventoModel> allTipologie = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';

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

    );
  }

}