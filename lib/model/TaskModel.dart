import 'dart:io';
import 'ClienteModel.dart';
import 'UtenteModel.dart';

class TaskModel{
  String? id;
  DateTime? data_creazione;
  DateTime? data_accordata;
  DateTime? orario_inizio;
  DateTime? orario_fine;
  String? descrizione;
  bool? concluso;
  double? importo;
  String? note;
  UtenteModel? utente;
  ClienteModel? cliente;

  TaskModel(
      this.id,
      this.data_creazione,
      this.data_accordata,
      this.orario_inizio,
      this.orario_fine,
      this.descrizione,
      this.concluso,
      this.importo,
      this.note,
      this.utente,
      this.cliente
      );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'id': id,
      'data_creazione': data_creazione?.toIso8601String(),
      'data_accordata' : data_accordata?.toIso8601String(),
      'orario_inizio': orario_inizio?.toIso8601String(),
      'orario_fine': orario_fine?.toIso8601String(),
      'descrizione': descrizione,
      'concluso': concluso,
      'importo': importo,
      'note': note,
      'utente': utente?.toMap(),
      'cliente': cliente?.toMap(),
    };
    return map;
  }

  TaskModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    map['data_creazione'] != null ? DateTime.parse(map['data_creazione']) : null;
    map['data_accordata'] != null ? DateTime.parse(map['data_accordata']) : null;
    map['orario_inizio'] != null ? DateTime.parse(map['orario_inizio']) : null;
    map['orario_fine'] != null ? DateTime.parse(map['orario_fine']) : null;
    descrizione = map['descrizione'];
    concluso = map['concluso'];
    importo = map['importo'];
    note = map['note'];
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    cliente = map['cliente'] != null ? ClienteModel.fromMap(map['cliente']) : null;
  }

  Map<String, dynamic> toJson() =>{
    'id': id,
    'data_creazione': data_creazione?.toIso8601String(),
    'data_accordata': data_accordata?.toIso8601String(),
    'orario_inizio': orario_inizio?.toIso8601String(),
    'orario_fine': orario_fine?.toIso8601String(),
    'descrizione': descrizione,
    'concluso': concluso,
    'importo': importo,
    'note': note,
    'utente': utente?.toJson(),
    'cliente': cliente?.toJson(),
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      json['id']?.toString(),
      json['data_creazione'] != null ? DateTime.parse(json['data_creazione']) : null,
      json['data_accordata'] != null ? DateTime.parse(json['data_accordata']) : null,
      json['orario_inizio'] != null ? DateTime.parse(json['orario_inizio']) : null,
      json['orario_fine'] != null ? DateTime.parse(json['orario_fine']) : null,
      json['descrizione']?.toString(),
      json['concluso'],
      json['importo'] != null ? double.parse(json['importo'].toString()) : null,
      json['note']?.toString(),
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
    );
  }
}