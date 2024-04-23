import 'dart:io';


import 'package:intl/intl.dart';

import 'CategoriaInterventoSpecificoModel.dart';
import 'ClienteModel.dart';
import 'ProdottoModel.dart';
import 'TipologiaInterventoModel.dart';

class SopralluogoModel {
  String? id;
  String? descrizione;
  ClienteModel? cliente;
  DateTime? data;
  String? posizione;
  TipologiaInterventoModel? tipologia;
  CategoriaInterventoSpecificoModel? categoria;

  SopralluogoModel(
      this.id,
      this.descrizione,
      this.cliente,
      this.data,
      this.posizione,
      this.tipologia,
      this.categoria,
      );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'cliente': cliente,
      'data' : data,
      'posizione' : posizione,
      'tipologia': tipologia,
      'categoria': categoria,
    };
    return map;
  }

  SopralluogoModel.fromMap(Map<String, dynamic> map) {
      id = map['id'];
      descrizione = map['descrizione'];
      cliente = map['cliente'] != null ? ClienteModel.fromMap(map['cliente']) : null;
      data = map['data'] !=null ? DateTime.parse(map['data']) : null;
      posizione = map['posizione'];
      tipologia = map['tipologia'] != null ? TipologiaInterventoModel.fromMap(map['tipologia']) : null;
      categoria = map['categoria'] != null ? CategoriaInterventoSpecificoModel.fromMap(map['categoria']) : null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'descrizione': descrizione,
        'cliente': cliente,
        'data': data != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data!) : null,
        'tipologia': tipologia,
        'categoria': categoria,
      };

  factory SopralluogoModel.fromJson(Map<String, dynamic> json) {
    return SopralluogoModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
        json['data'] != null ? DateTime.parse(json['data']) : null,
        json['posizione']?.toString(),
        json['tipologia'] != null ? TipologiaInterventoModel.fromJson(json['tipologia']) : null,
        json['categoria'] != null ? CategoriaInterventoSpecificoModel.fromJson(json['categoria']) : null,
    );
  }
}
