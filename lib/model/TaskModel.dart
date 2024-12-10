import 'package:fema_crm/model/TipologiaInterventoModel.dart';

import 'ClienteModel.dart';
import 'DestinazioneModel.dart';
import 'InterventoModel.dart';
import 'TipoTaskModel.dart';
import 'UtenteModel.dart';

class TaskModel {
  String? id;
  String? titolo;
  String? descrizione;
  DateTime? data_creazione;
  DateTime? data_conclusione;
  bool? concluso;
  UtenteModel? utente;
  UtenteModel? utentecreate;
  TipoTaskModel? tipologia;
  bool? condiviso;
  bool? accettato;
  DateTime? data_accettazione;

  TaskModel(
      this.id,
      this.titolo,
      this.descrizione,
      this.data_creazione,
      this.data_conclusione,
      this.concluso,
      this.utente,
      this.utentecreate,
      this.tipologia,
      this.condiviso,
      this.accettato,
      this.data_accettazione
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
      'utentecreate' : utentecreate?.toMap(),
      'tipologia' : tipologia?.toMap(),
      'condiviso' : condiviso,
      'accettato' : accettato,
      'data_accettazione' : data_accettazione?.toIso8601String()
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
    utentecreate = map['utentecreate'] != null ? UtenteModel.fromMap(map['utentecreate']) : null;
    tipologia = map['tipologia'] != null ? TipoTaskModel.fromMap(map['tipologia']) : null;
    condiviso = map['condiviso'];
    accettato = map['accettato'];
    map['dat_accettazione'] != null ? DateTime.parse(map['data_accettazioni']) : null;
  }

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'titolo' : titolo,
    'descrizione' : descrizione,
    'data_creazione' : data_creazione?.toIso8601String(),
    'data_conclusione' : data_conclusione?.toIso8601String(),
    'concluso' : concluso,
    'utente' : utente?.toMap(),
    'utentecreate' : utentecreate?.toMap(),
    'tipologia' : tipologia?.toJson(),
    'condiviso' : condiviso,
    'accettato' : accettato,
    'data_accettazione' : data_accettazione?.toIso8601String()
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
      json['utentecreate'] != null ? UtenteModel.fromJson(json['utentecreate']) : null,
      json['tipologia'] != null ? TipoTaskModel.fromJson(json['tipologia']) : null,
      json['condiviso'],
      json['accettato'],
      json['data_accettazione'] != null ? DateTime.parse(json['data_accettazione']) : null
    );
  }
}
