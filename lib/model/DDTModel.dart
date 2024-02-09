import 'dart:io';


import 'CategoriaDDTModel.dart';
import 'ClienteModel.dart';
import 'DestinazioneModel.dart';
import 'ProdottoModel.dart';
import 'UtenteModel.dart';

class DDTModel {
  String? id;
  DateTime? data;
  DateTime? orario;
  File? firmaUser;
  File? imageData;
  ClienteModel? cliente;
  DestinazioneModel? destinazione;
  CategoriaDDTModel? categoriaDDT;
  UtenteModel? utente;
  List<ProdottoModel>? prodotti;

  DDTModel(
      this.id,
      this.data,
      this.orario,
      this.firmaUser,
      this.imageData,
      this.cliente,
      this.destinazione,
      this.categoriaDDT,
      this.utente,
      this.prodotti);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'data': data,
      'orario': orario,
      'firmaUser': firmaUser,
      'imageData': imageData,
      'cliente': cliente,
      'destinazione': destinazione,
      'categoriaDDt': categoriaDDT,
      'utente': utente,
      'prodotti': prodotti
    };
    return map;
  }

  DDTModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    data = map['data'];
    orario = map['orario'];
    firmaUser = map['firmaUser'];
    imageData = map['imageData'];
    cliente = map['cliente'];
    destinazione = map['destinazione'];
    categoriaDDT = map['catetgoriaDDT'];
    utente = map['utente'];
    prodotti = map['prodotti'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'orario': orario,
        'firmaUser': firmaUser,
        'imageData': imageData,
        'cliente': cliente,
        'destinazione': destinazione,
        'categoriaDDT': categoriaDDT,
        'utente': utente,
        'prodotti': prodotti,
      };

  factory DDTModel.fromJson(Map<String, dynamic> json) {
    return DDTModel(
        json['id']?.toString(),
        json['data'],
        json['orario'],
        json['firmaUser'],
        json['imageData'],
        json['cliente'],
        DestinazioneModel.fromJson(json),
        CategoriaDDTModel.fromJson(json),
        UtenteModel.fromJson(json),
        json['prodotti']?.map((data) => ProdottoModel.fromJson(data)).toList());
  }
}
