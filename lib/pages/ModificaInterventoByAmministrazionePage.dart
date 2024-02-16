import 'package:fema_crm/model/InterventoModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../databaseHandler/DbHelper.dart';

class ModificaInterventoByAmministrazionePage extends StatefulWidget{
  final InterventoModel intervento;

  const ModificaInterventoByAmministrazionePage({Key? key, required this.intervento}): super(key:key);

  @override
  _ModificaInterventoByAmministrazionePageState createState() => _ModificaInterventoByAmministrazionePageState();
}

class _ModificaInterventoByAmministrazionePageState extends State<ModificaInterventoByAmministrazionePage> {



  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}