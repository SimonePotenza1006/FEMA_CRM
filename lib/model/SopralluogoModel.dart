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
