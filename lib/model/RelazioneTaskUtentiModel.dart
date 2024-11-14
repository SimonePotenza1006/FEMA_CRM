import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/ProdottoModel.dart';

import 'TaskModel.dart';
import 'UtenteModel.dart';

class RelazioneTaskUtentiModel{
  int? id;
  TaskModel? task;
  UtenteModel? utente;
  bool? accettato;
  DateTime? data_invio;
  DateTime? data_conclusione;

  RelazioneTaskUtentiModel(
    this.id,
    this.task,
    this.utente,
    this.accettato,
    this.data_invio,
    this.data_conclusione
  );

  Map<String, dynamic> toMap(){
    return{
      'id' : id,
      'task' : task?.toMap(),
      'utente': utente?.toMap(),
      'accettato' : accettato,
      'data_invio' : data_invio?.toIso8601String(),
      'data_conclusione' : data_conclusione?.toIso8601String(),
    };
  }

  RelazioneTaskUtentiModel.fromMap(Map<String, dynamic> map){
      id = map['id'];
      map['task'] != null ? TaskModel.fromMap(map['task']) : null;
      map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
      accettato = map['accettato'];
      map['data_invio'] != null ? DateTime.parse(map['data_invio']) : null;
      map['data_conclusione'] != null ? DateTime.parse(map['data_conclusione']) : null;
  }

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'task' : task?.toJson(),
    'utente' : utente?.toJson(),
    'accettato' : accettato,
    'data_invio' : data_invio?.toIso8601String(),
    'data_conclusione' : data_conclusione?.toIso8601String(),

  };

  factory RelazioneTaskUtentiModel.fromJson(Map<String, dynamic> json){
    return RelazioneTaskUtentiModel(
      json['id'],
      json['task'] != null ? TaskModel.fromJson(json['task']) : null,
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['accettato'],
      json['data_invio'] != null ? DateTime.parse(json['data_invio']) : null,
      json['data_conclusione'] != null ? DateTime.parse(json['data_conclusione']) : null,
    );
  }
}