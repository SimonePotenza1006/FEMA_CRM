import 'package:fema_crm/model/FornitoreModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';

class RestituzioneMerceModel{
  String? id;
  String? prodotto;
  DateTime? data_acquisto;
  String? difetto_riscontrato;
  FornitoreModel? fornitore;
  DateTime? data_riconsegna;
  UtenteModel? utenteRiconsegna;
  bool? rimborso;
  bool? cambio;
  DateTime? data_rientro_ufficio;
  UtenteModel? utenteRitiro;
  bool? concluso;

  RestituzioneMerceModel(
      this.id,
      this.prodotto,
      this.data_acquisto,
      this.difetto_riscontrato,
      this.fornitore,
      this.data_riconsegna,
      this.utenteRiconsegna,
      this.rimborso,
      this.cambio,
      this.data_rientro_ufficio,
      this.utenteRitiro,
      this.concluso,
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id':id.toString(),
      'prodotto':prodotto,
      'data_acquisto':data_acquisto?.toIso8601String(),
      'difetto_riscontrato':difetto_riscontrato,
      'fornitore':fornitore?.toMap(),
      'data_riconsegna':data_riconsegna?.toIso8601String(),
      'utenteRiconsegna': utenteRiconsegna?.toMap(),
      'rimborso':rimborso,
      'cambio':cambio,
      'data_rientro_ufficio':data_rientro_ufficio?.toIso8601String(),
      'utenteRitiro':utenteRitiro?.toMap(),
      'concluso':concluso,
    };
    return map;
  }

  RestituzioneMerceModel.fromMap(Map<String, dynamic> map){
    id = map['id'].toString();
    prodotto = map['prodotto'];
    map['data_acquisto'] != null ? DateTime.parse(map['data_acquisto']) : null;
    difetto_riscontrato = map['difetto_riscontrato'];
    fornitore = map['fornitore'] != null ? FornitoreModel.fromMap(map['fornitore']) : null;
    map['data_riconsegna'] != null ? DateTime.parse(map['data_riconsegna']) : null;
    utenteRiconsegna = map['utenteRiconsegna'] != null ? UtenteModel.fromMap(map['utenteRiconsegna']) : null;
    rimborso = map['rimborso'];
    cambio = map['cambio'];
    map['data_rientro_ufficio'] != null ? DateTime.parse(map['data_rientro_ufficio']) : null;
    utenteRitiro = map['utente_ritiro'] != null ? UtenteModel.fromMap(map['utenteRitiro']) : null;
    map['concluso'];
  }

  Map<String, dynamic> toJson() =>{
    'id':int.parse(id.toString()),
    'prodotto': prodotto,
    'data_acquisto': data_acquisto?.toIso8601String(),
    'difetto_riscontrato': difetto_riscontrato,
    'fornitore': fornitore?.toJson(),
    'data_riconsegna': data_riconsegna?.toIso8601String(),
    'utenteRiconsegna': utenteRiconsegna?.toJson(),
    'rimborso': rimborso,
    'cambio': cambio,
    'data_rientro_ufficio': data_rientro_ufficio?.toIso8601String(),
    'utenteRitiro': utenteRitiro?.toJson(),
    'concluso': concluso,
  };

  factory RestituzioneMerceModel.fromJson(Map<String, dynamic> json){
    return RestituzioneMerceModel(
      json['id'].toString(),
      json['prodotto'],
      json['data_acquisto'] != null ? DateTime.parse(json['data_acquisto']) : null,
      json['difetto_riscontrato'],
      json['fornitore'] != null ? FornitoreModel.fromJson(json['fornitore']) : null,
      json['data_riconsegna'] != null ? DateTime.parse(json['data_riconsegna']) : null,
      json['utenteRiconsegna'] != null ? UtenteModel.fromJson(json['utenteRiconsegna']) : null,
      json['rimborso'],
      json['cambio'],
      json['data_rientro_ufficio'] != null ? DateTime.parse(json['data_rientro_ufficio']) : null,
      json['utenteRitiro'] != null ? UtenteModel.fromJson(json['utenteRitiro']) : null,
      json['concluso'],
    );
  }

}