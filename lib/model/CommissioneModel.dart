import 'UtenteModel.dart';

class CommissioneModel{
  String? id;
  DateTime? data_creazione;
  DateTime? data;
  String? descrizione;
  bool? concluso;
  String? note;
  UtenteModel? utente;


  CommissioneModel(
      this.id,
      this.data_creazione,
      this.data,
      this.descrizione,
      this.concluso,
      this.note,
      this.utente,
      );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'id': id,
      'data_creazione': data_creazione?.toIso8601String(),
      'data' : data?.toIso8601String(),
      'descrizione': descrizione,
      'concluso': concluso,
      'note': note,
      'utente': utente?.toMap(),
    };
    return map;
  }

  CommissioneModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    map['data_creazione'] != null ? DateTime.parse(map['data_creazione']) : null;
    map['data'] != null ? DateTime.parse(map['data']) : null;
    descrizione = map['descrizione'];
    concluso = map['concluso'];
    note = map['note'];
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
  }

  Map<String, dynamic> toJson() =>{
    'id': id,
    'data_creazione': data_creazione?.toIso8601String(),
    'data': data?.toIso8601String(),
    'descrizione': descrizione,
    'concluso': concluso,
    'note': note,
    'utente': utente?.toJson(),
  };

  factory CommissioneModel.fromJson(Map<String, dynamic> json) {
    return CommissioneModel(
      json['id']?.toString(),
      json['data_creazione'] != null ? DateTime.parse(json['data_creazione']) : null,
      json['data'] != null ? DateTime.parse(json['data']) : null,
      json['descrizione']?.toString(),
      json['concluso'],
      json['note']?.toString(),
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
    );
  }
}