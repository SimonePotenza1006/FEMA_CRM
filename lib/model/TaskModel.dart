import 'package:fema_crm/model/TipologiaInterventoModel.dart';

import 'ClienteModel.dart';
import 'DestinazioneModel.dart';
import 'InterventoModel.dart';
import 'UtenteModel.dart';

class TaskModel {
  String? id;
  String? titolo;
  String? descrizione;
  DateTime? data_creazione;
  DateTime? data_conclusione;
  bool? concluso;
  UtenteModel? utente;
  Tipologia? tipologia;
  bool? condiviso;
  bool? accettato;

  TaskModel(
      this.id,
      this.titolo,
      this.descrizione,
      this.data_creazione,
      this.data_conclusione,
      this.concluso,
      this.utente,
      this.tipologia,
      this.condiviso,
      this.accettato
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id' : id,
      'titolo' : titolo,
      'descrizione' : descrizione,
      'data_creazione' : data_creazione?.toIso8601String(),
      'data_conclusione' : data_conclusione?.toIso8601String(),
      'concluso' : concluso,
      'utente' : utente?.toMap(),
      'tipologia' : tipologia.toString().split('.').last,
      'condiviso' : condiviso,
      'accettato' : accettato,
    };
    return map;
  }

  TaskModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    titolo = map['titolo'];
    descrizione = map['descrizione'];
    map['data_creazione'] != null ? DateTime.parse(map['data_creazione']) : null;
    map['data_conclusione'] != null ? DateTime.parse(map['data_conclusione']) : null;
    concluso = map['concluso'];
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    tipologia = Tipologia.values.firstWhere(
            (type) => type.toString() == 'tipologia.${map['tipologia']}');
    condiviso = map['condiviso'];
    accettato = map['accettato'];
  }

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'titolo' : titolo,
    'descrizione' : descrizione,
    'data_creazione' : data_creazione?.toIso8601String(),
    'data_conclusione' : data_conclusione?.toIso8601String(),
    'concluso' : concluso,
    'utente' : utente?.toMap(),
    'tipologia' : tipologia.toString().split('.').last,
    'condiviso' : condiviso,
    'accettato' : accettato,
  };

  factory TaskModel.fromJson(Map<String, dynamic> json){
    return TaskModel(
      json['id']?.toString(),
      json['titolo'],
      json['descrizione'],
      json['data_creazione'] != null ? DateTime.parse(json['data_creazione']) : null,
      json['data_conclusione'] != null ? DateTime.parse(json['data_conclusione']) : null,
      json['concluso'],
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      _getTipologiaFromString(json['tipologia']),
      json['condiviso'],
      json['accettato'],
    );
  }

  static Tipologia _getTipologiaFromString(String? tipologia){
    if(tipologia == "AZIENDALE"){
      return Tipologia.AZIENDALE;
    } else if(tipologia == "PERSONALE"){
      return Tipologia.PERSONALE;
    } else if(tipologia == "PREVENTIVO FEMA SHOP"){
      return Tipologia.PREVENTIVO_FEMA_SHOP;
    } else if(tipologia == "PREVENTIVO SERVIZI ELETTRONICA") {
      return Tipologia.PREVENTIVO_SERVIZI_ELETTRONICA;
    } else if(tipologia == "PREVENTIVO IMPIANTO"){
      return Tipologia.PREVENTIVO_IMPIANTO;
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
  PREVENTIVO_FEMA_SHOP,
  PREVENTIVO_SERVIZI_ELETTRONICA,
  PREVENTIVO_IMPIANTO,
  SPESE
}