import 'dart:convert';

import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:fema_crm/model/RuoloUtenteModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../databaseHandler/DbHelper.dart';

class AssegnazioneInterventoByAmministrazionePage extends StatefulWidget{
  final InterventoModel intervento;

  const AssegnazioneInterventoByAmministrazionePage({Key? key, required this.intervento}) : super(key : key);

  @override
  _AssegnazioneInterventoByAmministrazionePageState createState() => _AssegnazioneInterventoByAmministrazionePageState();
}

class _AssegnazioneInterventoByAmministrazionePageState extends State<AssegnazioneInterventoByAmministrazionePage>{

  DbHelper? dbHelper;

  @override
  void initState() {
    super.initState();
    getAllUtenti();
  }

  @override
  Widget build(BuildContext){
    return Scaffold();
  }

  Future<List<UtenteModel>> getAllUtenti() async {
    try {
      http.Response response = await http.get(Uri.parse('http://192.168.1.52:8080/api/utente'));
      var responseData = json.decode(response.body.toString());

      if (response.statusCode == 200) {
        print(responseData);
        List<UtenteModel> utenti = [];

        for (var singoloUtente in responseData) {
          List<TipologiaInterventoModel>? tipologiaIntervento;

          if (singoloUtente['tipologieIntervento'] != null) {
            tipologiaIntervento = (singoloUtente['tipologieIntervento'] as List)
                .map((data) => TipologiaInterventoModel.fromJson(data))
                .toList();
          }

          RuoloUtenteModel? ruolo = singoloUtente['ruolo'] != null
              ? RuoloUtenteModel.fromJson(singoloUtente['ruolo'])
              : null;

          UtenteModel utente = UtenteModel(
            singoloUtente['id'],
            singoloUtente['attivo'],
            singoloUtente['nome'].toString(),
            singoloUtente['cognome'].toString(),
            singoloUtente['email'].toString(),
            singoloUtente['password'].toString(),
            singoloUtente['cellulare'].toString(),
            singoloUtente['codiceFiscale'].toString(),
            singoloUtente['iban'].toString(),
            ruolo,
            tipologiaIntervento as TipologiaInterventoModel?,
          );
          utenti.add(utente);
          print("Successo");
        }

        return utenti;
      } else {
        throw Exception('Failed to load utenti!');
      }
    } catch (e) {
      print('Errore in get all utenti: $e');
      throw Exception(e);
    }
  }
}