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
  bool edit = false;
  bool editu = false;

  MarcaTempoModel(this.id, this.name, this.type, this.gps, this.gpsu, this.data,
      this.datau, this.imageData, this.utente, this.viaggio, this.edit, this.editu);

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
      'viaggio': viaggio,
      'edit': edit,
      'editu': editu
    };
    return map;
  }

  MarcaTempoModel.fromMap(Map<String, dynamic> map){
    id = map['id']?.toString();
    name = map['name']?.toString();
    type = map['type']?.toString();
    gps = map['gps']?.toString();
    gpsu =map['gpsu']?.toString();
    map['data'] != null ? DateTime.parse(map['data']) : null;
    map['datau'] != null? DateTime.parse(map['datau']) : null;
    imageData = map['imageData'];
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    viaggio = map['viaggio'] != null? ViaggioModel.fromMap(map['viaggio']) : null;
    edit = map['edit'] ?? false;
    editu = map['editu'] ?? false;
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'type': type,
        'gps': gps,
        'gpsu': gpsu,
        'data': data,
        'datau': datau,
        'imageData': imageData,
        'utente': utente,
        'viaggio': viaggio,
        'edit': edit,
        'editu': editu,
      };

  factory MarcaTempoModel.fromJson(Map<String, dynamic> json) {
    return MarcaTempoModel(
        json['id']?.toString(),
        json['name'],
        json['type'],
        json['gps'],
        json['gpsu'],
        json['data'] != null ? DateTime.parse(json['data']) : null,
        json['datau'] != null ? DateTime.parse(json['datau']) : null,
        json['imageData'],
        json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
        json['viaggio'] != null ? ViaggioModel.fromJson(json['viaggio']) : null,
        json['edit'],
        json['editu'],
    );
  }
}