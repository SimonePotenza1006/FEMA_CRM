import 'dart:io';
import 'InterventoModel.dart';

class ImmagineModel{
  String? id;
  File? imageData;
  String? name;
  String? type;
  InterventoModel? intervento;

  ImmagineModel(
      this.id,
      this.imageData,
      this.name,
      this.type,
      this.intervento
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id':id,
      'imageData': imageData,
      'name': name,
      'type': type,
      'intervento': intervento?.toMap()
    };
    return map;
  }

  ImmagineModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    imageData = map['imageData'];
    name = map['name'];
    type = map['type'];
    intervento = map['intervento'] != null ? InterventoModel.fromMap(map['intervento']) : null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageData': imageData,
    'name': name,
    'type': type,
    'intervento': intervento
  };

  factory ImmagineModel.fromJson(Map<String, dynamic> json){
    return ImmagineModel(
      json['id'].toString(),
      json['imageData'],
      json['name'].toString(),
      json['type'].toString(),
      json['intervento'] != null ? InterventoModel.fromJson(json['intervento']) : null
    );
  }
}