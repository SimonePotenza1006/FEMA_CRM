import 'InterventoModel.dart';
import 'UtenteModel.dart';

class CommissioneModel{
  String? id;
  DateTime? data_creazione;
  DateTime? data;
  Priorita? priorita;
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
      this.priorita,
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
      'priorita' : priorita.toString().split('.').last,
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
    priorita = Priorita.values.firstWhere(
            (type) => type.toString() == 'priorita.${map['priorita']}');
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
    'priorita' : priorita.toString().split('.').last,
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
      _getPrioritaFromString(json['priorita']),
      json['descrizione']?.toString(),
      json['concluso'],
      json['attivo'],
      json['note'],
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['intervento'] != null ? InterventoModel.fromJson(json['intervento']) : null
    );
  }


  static Priorita _getPrioritaFromString(String? priorita){
    if(priorita == "BASSA"){
      return Priorita.BASSA;
    } else if(priorita == "MEDIA"){
      return Priorita.MEDIA;
    } else if(priorita == "ALTA"){
      return Priorita.ALTA;
    } else if(priorita == "URGENTE") {
      return Priorita.URGENTE;
    } else if(priorita == "NULLA"){
      return Priorita.NULLA;
    } else {
      throw Exception('Valore non valido per Priorita: $priorita');
    }
  }
}