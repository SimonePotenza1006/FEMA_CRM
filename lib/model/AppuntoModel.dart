import 'package:fema_crm/model/TipologiaInterventoModel.dart';

import 'ClienteModel.dart';
import 'DestinazioneModel.dart';
import 'InterventoModel.dart';
import 'UtenteModel.dart';

class AppuntoModel {
  String? id;
  String? descrizione;
  DateTime? data_creazione;
  bool? personale;
  bool? archiviato;
  UtenteModel? utente;
  String? tipologia;


  AppuntoModel(
      this.id,
      this.descrizione,
      this.data_creazione,
      this.personale,
      this.archiviato,
      this.utente,
      this.tipologia
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id' : id,
      'descrizione' : descrizione,
      'data_creazione' : data_creazione?.toIso8601String(),
      'personale' : personale,
      'archiviato' : archiviato,
      'utente' : utente?.toMap(),
      'tipologia' : tipologia,
    };
    return map;
  }

  AppuntoModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    descrizione = map['descrizione'];
    map['data_creazione'] != null ? DateTime.parse(map['data_creazione']) : null;
    personale = map['personale'];
    archiviato = map['archiviato'];
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    tipologia = map['tipologia'];



  }

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'descrizione' : descrizione,
    'data_creazione' : data_creazione?.toIso8601String(),
    'personale' : personale,
    'archiviato' : archiviato,
    'utente' : utente?.toMap(),
    'tipologia' : tipologia,

  };

  factory AppuntoModel.fromJson(Map<String, dynamic> json){
    return AppuntoModel(
      json['id']?.toString(),
      json['descrizione'],
      json['data_creazione'] != null ? DateTime.parse(json['data_creazione']) : null,
      json['personale'],
      json['archiviato'],
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['tipologia'],


    );
  }


}