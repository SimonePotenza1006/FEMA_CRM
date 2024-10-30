import 'InterventoModel.dart';
import 'UtenteModel.dart';

class CommissioneModel{
  String? id;
  DateTime? data_creazione;
  DateTime? data;
  String? descrizione;
  bool? concluso;
  bool? attivo;
  String? note;
  UtenteModel? utente;
  InterventoModel? intervento;

  CommissioneModel(
      this.id,
      this.data_creazione,
      this.data,
      this.descrizione,
      this.concluso,
      this.attivo,
      this.note,
      this.utente,
      this.intervento
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'id': id,
      'data_creazione': data_creazione?.toIso8601String(),
      'data' : data?.toIso8601String(),
      'descrizione': descrizione,
      'concluso': concluso,
      'attivo' : attivo,
      'note': note,
      'utente': utente?.toMap(),
      'intervento' : intervento?.toMap(),
    };
    return map;
  }

  CommissioneModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    map['data_creazione'] != null ? DateTime.parse(map['data_creazione']) : null;
    map['data'] != null ? DateTime.parse(map['data']) : null;
    descrizione = map['descrizione'];
    concluso = map['concluso'];
    attivo = map['attivo'];
    note = map['note'];
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    intervento = map['intervento'] != null ? InterventoModel.fromMap(map['intervento']) : null;
  }

  Map<String, dynamic> toJson() =>{
    'id': id,
    'data_creazione': data_creazione?.toIso8601String(),
    'data': data?.toIso8601String(),
    'descrizione': descrizione,
    'concluso': concluso,
    'attivo' : attivo,
    'note': note,
    'utente': utente?.toJson(),
    'intervento' : intervento?.toJson()
  };

  factory CommissioneModel.fromJson(Map<String, dynamic> json) {
    return CommissioneModel(
      json['id']?.toString(),
      json['data_creazione'] != null ? DateTime.parse(json['data_creazione']) : null,
      json['data'] != null ? DateTime.parse(json['data']) : null,
      json['descrizione']?.toString(),
      json['concluso'],
      json['attivo'],
      json['note'],
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['intervento'] != null ? InterventoModel.fromJson(json['intervento']) : null
    );
  }
}