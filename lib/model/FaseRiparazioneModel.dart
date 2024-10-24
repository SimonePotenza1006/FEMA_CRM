import 'package:fema_crm/model/MerceInRiparazioneModel.dart';

import 'UtenteModel.dart';

class FaseRiparazioneModel{
  String? id;
  DateTime? data;
  String? descrizione;
  bool? conclusione;
  UtenteModel? utente;
  MerceInRiparazioneModel? merce;

  FaseRiparazioneModel(
      this.id,
      this.data,
      this.descrizione,
      this.conclusione,
      this.utente,
      this.merce
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id' : id,
      'data' : data?.toIso8601String(),
      'descrizione' : descrizione,
      'conclusione' : conclusione,
      'utente' : utente?.toMap(),
      'merce' : merce?.toMap()
    };
    return map;
  }

  FaseRiparazioneModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    map['data'] != null ? DateTime.parse(map['data']) : null;
    descrizione = map['descrizione'];
    conclusione = map['conclusione'];
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    merce = map['merce'] != null ? MerceInRiparazioneModel.fromMap(map['merce']) : null;
  }

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'data' : data?.toIso8601String(),
    'descrizione' : descrizione,
    'conclusione' : conclusione,
    'utente' : utente?.toJson(),
    'merce' : merce?.toJson()
  };

  factory FaseRiparazioneModel.fromJson(Map<String, dynamic> json){
    return FaseRiparazioneModel(
      json['id']?.toString(),
      json['data'] != null ? DateTime.parse(json['data']) : null,
      json['descrizione'].toString(),
      json['conclusione'],
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['merce'] != null ? MerceInRiparazioneModel.fromJson(json['merce']) : null
    );
  }
}