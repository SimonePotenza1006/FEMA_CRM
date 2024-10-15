import 'dart:io';

import 'package:fema_crm/model/AziendaModel.dart';

class ImmagineAziendaModel{
  String? id_immagine;
  File? imageData;
  String? name;
  String? type;
  AziendaModel? azienda;
  bool? timbro;

  ImmagineAziendaModel(
      this.id_immagine,
      this.imageData,
      this.name,
      this.type,
      this.azienda,
      this.timbro
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id_immagine': id_immagine,
      'imageData': imageData,
      'name': name,
      'type': type,
      'azienda': azienda?.toMap(),
      'timbro': timbro,
    };
    return map;
  }

  Map<String, dynamic> toJson() =>{
    'id_imamgine': id_immagine,
    'imageData': imageData,
    'name': name,
    'type': type,
    'azienda': azienda?.toJson(),
    'timbro': timbro,
  };

  factory ImmagineAziendaModel.fromJson(Map<String, dynamic> json){
    return ImmagineAziendaModel(
      json['id_immagine'].toString(),
      json['imageData'],
      json['name'].toString(),
      json['type'].toString(),
      json['azienda'],
      json['timbro'],
    );
  }

}