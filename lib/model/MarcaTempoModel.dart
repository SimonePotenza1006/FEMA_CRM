import 'dart:io';

import 'UtenteModel.dart';
import 'ViaggioModel.dart';

class MarcaTempoModel {
  String? id;
  String? name;
  String? type;
  String? gps;
  String? gpsu;
  DateTime? data;
  DateTime? datau;
  File? imageData;
  UtenteModel? utente;
  ViaggioModel? viaggio;

  MarcaTempoModel(this.id, this.name, this.type, this.gps, this.gpsu, this.data,
      this.datau, this.imageData, this.utente, this.viaggio);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'type': type,
      'gps': gps,
      'gpsu': gpsu,
      'data': data,
      'datau': datau,
      'imageData': imageData,
      'utente': utente,
      'viaggio': viaggio
    };
    return map;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'gps': gps,
        'gpsu': gpsu,
        'data': data,
        'datau': datau,
        'imageData': imageData,
        'utente': utente,
        'viaggio': viaggio
      };

  factory MarcaTempoModel.fromJson(Map<String, dynamic> json) {
    return MarcaTempoModel(
        json['id']?.toString(),
        json['name'],
        json['type'],
        json['gps'],
        json['gpsu'],
        json['data'],
        json['datau'],
        json['imageData'],
        UtenteModel.fromJson(json),
        ViaggioModel.fromJson(json));
  }
}
