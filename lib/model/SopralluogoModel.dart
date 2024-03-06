import 'dart:io';


import 'CategoriaInterventoSpecificoModel.dart';
import 'ClienteModel.dart';
import 'ProdottoModel.dart';
import 'TipologiaInterventoModel.dart';

class SopralluogoModel {
  String? id;
  String? descrizione;
  File? foto;
  ClienteModel? cliente;
  TipologiaInterventoModel? tipologiaIntervento;
  CategoriaInterventoSpecificoModel? categoriaInterventoSpecifico;
  List<ProdottoModel>? prodotti;

  SopralluogoModel(
      this.id,
      this.descrizione,
      this.foto,
      this.cliente,
      this.tipologiaIntervento,
      this.categoriaInterventoSpecifico,
      this.prodotti);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'foto': foto,
      'cliente': cliente,
      'tipologiaIntervento': tipologiaIntervento,
      'categoriaInterventoSpecifico': categoriaInterventoSpecifico,
      'prodotti': prodotti,
    };
    return map;
  }

  factory SopralluogoModel.fromMap(Map<String, dynamic> map) {
    return SopralluogoModel(
      map['id'],
      map['descrizione'],
      map['foto'],
      ClienteModel.fromMap(map['cliente']),
      TipologiaInterventoModel.fromMap(map['tipologiaIntervento']),
      CategoriaInterventoSpecificoModel.fromMap(map['categoriaInterventoSpecifico']),
      (map['prodotti'] as List<dynamic>?)
          ?.map((e) => ProdottoModel.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'descrizione': descrizione,
        'foto': foto,
        'cliente': cliente,
        'tipologiaIntervento': tipologiaIntervento,
        'categoriaInterventoSpecifico': categoriaInterventoSpecifico,
        'prodotti': prodotti,
      };

  factory SopralluogoModel.fromJson(Map<String, dynamic> json) {
    return SopralluogoModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        json['foto'],
        ClienteModel.fromJson(json),
        TipologiaInterventoModel.fromJson(json),
        CategoriaInterventoSpecificoModel.fromJson(json),
        json['prodotti']?.map((data) => ProdottoModel.fromJson(data)).toList());
  }
}
