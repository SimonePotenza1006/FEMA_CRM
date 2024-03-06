import 'CategoriaDDTModel.dart';
import 'ClienteModel.dart';
import 'DestinazioneModel.dart';
import 'InterventoModel.dart';
import 'RelazioneDdtProdottiModel.dart';
import 'UtenteModel.dart';

class DDTModel {
  int? id;
  DateTime? data;
  DateTime? orario;
  bool? concluso;
  String? firmaUser;
  String? imageData;
  ClienteModel? cliente;
  DestinazioneModel? destinazione;
  CategoriaDDTModel? categoriaDdt;
  UtenteModel? utente;
  InterventoModel? intervento;
  List<RelazioneDdtProdottoModel>? relazioni_prodotti;

  DDTModel({
    this.id,
    this.data,
    this.orario,
    this.concluso,
    this.firmaUser,
    this.imageData,
    this.cliente,
    this.destinazione,
    this.categoriaDdt,
    this.utente,
    this.intervento,
    this.relazioni_prodotti,
  });

  factory DDTModel.fromMap(Map<String, dynamic> map) {
    return DDTModel(
      id: map['id'],
      data: DateTime.parse(map['data']),
      orario: DateTime.parse(map['orario']),
      concluso: map['concluso'],
      firmaUser: map['firmaUser'],
      imageData: map['imageData'],
      cliente: ClienteModel.fromMap(map['cliente']),
      destinazione: DestinazioneModel.fromMap(map['destinazione']),
      categoriaDdt: CategoriaDDTModel.fromMap(map['categoriaDdt']),
      utente: UtenteModel.fromMap(map['utente']),
      intervento: InterventoModel.fromMap(map['intervento']),
      relazioni_prodotti: (map['relazioni_prodotti'] as List<dynamic>?)
          ?.map((e) => RelazioneDdtProdottoModel.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data?.toIso8601String(),
      'orario': orario?.toIso8601String(),
      'concluso': concluso,
      'firmaUser': firmaUser,
      'imageData': imageData,
      'cliente': cliente?.toMap(),
      'destinazione': destinazione?.toMap(),
      'categoriaDdt': categoriaDdt?.toMap(),
      'utente': utente?.toMap(),
      'intervento': intervento?.toMap(),
      'relazioni_prodotti': relazioni_prodotti?.map((e) => e.toMap()).toList(),
    };
  }

  factory DDTModel.fromJson(Map<String, dynamic> json) {
    return DDTModel(
      id: json['id'],
      data: DateTime.parse(json['data']),
      orario: DateTime.parse(json['orario']),
      concluso: json['concluso'],
      firmaUser: json['firmaUser'],
      imageData: json['imageData'],
      cliente: ClienteModel.fromJson(json['cliente']),
      destinazione: DestinazioneModel.fromJson(json['destinazione']),
      categoriaDdt: CategoriaDDTModel.fromJson(json['categoriaDdt']),
      utente: UtenteModel.fromJson(json['utente']),
      intervento: InterventoModel.fromJson(json['intervento']),
      relazioni_prodotti: (json['relazioni_prodotti'] as List<dynamic>?)
          ?.map((e) => RelazioneDdtProdottoModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data?.toIso8601String(),
      'orario': orario?.toIso8601String(),
      'concluso': concluso,
      'firmaUser': firmaUser,
      'imageData': imageData,
      'cliente': cliente?.toJson(),
      'destinazione': destinazione?.toJson(),
      'categoriaDdt': categoriaDdt?.toJson(),
      'utente': utente?.toJson(),
      'intervento': intervento?.toJson(),
      'relazioni_prodotti': relazioni_prodotti?.map((e) => e.toJson()).toList(),
    };
  }
}
