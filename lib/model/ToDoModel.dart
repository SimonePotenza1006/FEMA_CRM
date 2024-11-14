import 'package:fema_crm/model/TipologiaInterventoModel.dart';

import 'ClienteModel.dart';
import 'DestinazioneModel.dart';
import 'InterventoModel.dart';
import 'UtenteModel.dart';

class ToDoModel {
  String? id;
  String? descrizione;
  DateTime? data_creazione;
  bool? concluso;
  UtenteModel? utente;
  Tipologia? tipologia;


  ToDoModel(
      this.id,
      this.descrizione,
      this.data_creazione,
      this.concluso,
      this.utente,
      this.tipologia
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id' : id,
      'descrizione' : descrizione,
      'data_creazione' : data_creazione?.toIso8601String(),
      'concluso' : concluso,
      'utente' : utente?.toMap(),
      'tipologia' : tipologia.toString().split('.').last,
    };
    return map;
  }

  ToDoModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    descrizione = map['descrizione'];
    map['data_creazione'] != null ? DateTime.parse(map['data_creazione']) : null;
    concluso = map['concluso'];
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    tipologia = Tipologia.values.firstWhere(
            (type) => type.toString() == 'tipologia.${map['tipologia']}');
  }

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'descrizione' : descrizione,
    'data_creazione' : data_creazione?.toIso8601String(),
    'concluso' : concluso,
    'utente' : utente?.toMap(),
    'tipologia' : tipologia.toString().split('.').last,
  };

  factory ToDoModel.fromJson(Map<String, dynamic> json){
    return ToDoModel(
      json['id']?.toString(),
      json['descrizione'],
      json['data_creazione'] != null ? DateTime.parse(json['data_creazione']) : null,
      json['concluso'],
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      _getTipologiaFromString(json['tipologia']),

    );
  }

  static Tipologia _getTipologiaFromString(String? tipologia){
    if(tipologia == "AZIENDALE"){
      return Tipologia.AZIENDALE;
    } else if(tipologia == "PERSONALE"){
      return Tipologia.PERSONALE;
    } else if(tipologia == "PREVENTIVOFEMASHOP"){
      return Tipologia.PREVENTIVOFEMASHOP;
    } else if(tipologia == "PREVENTIVOSERVIZIELETTRONICA") {
      return Tipologia.PREVENTIVOSERVIZIELETTRONICA;
    } else if(tipologia == "PREVENTIVOIMPIANTO"){
      return Tipologia.PREVENTIVOIMPIANTO;
    } else if(tipologia == "SPESE"){
      return Tipologia.SPESE;
    } else {
      throw Exception('Valore non valido per tipologia: $tipologia');
    }
  }

}

enum Tipologia{
  AZIENDALE,
  PERSONALE,
  PREVENTIVOFEMASHOP,
  PREVENTIVOSERVIZIELETTRONICA,
  PREVENTIVOIMPIANTO,
  SPESE
}