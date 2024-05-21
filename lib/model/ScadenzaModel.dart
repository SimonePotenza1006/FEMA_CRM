
import 'package:fema_crm/model/ClienteModel.dart';

class ScadenzaModel{
  int? id;
  DateTime? data;
  String? descrizione;
  ClienteModel? cliente;
  
  ScadenzaModel({
    this.id,
    this.data,
    this.descrizione,
    this.cliente
  });
  
  Map<String, dynamic> toMap(){
    return{
      'id' : id,
      'data' : data,
      'descrizione' : descrizione,
      'cliente' : cliente?.toMap(),
    };
  }
  
  factory ScadenzaModel.fromMap(Map<String, dynamic> map){
    return ScadenzaModel(
      id : map['id'],
      data: map['data'],
      descrizione: map['descrizione'],
      cliente: ClienteModel.fromMap(map['cliente']),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id' : id,
    'data' : data,
    'descrizione' : descrizione,
    'cliente' : cliente?.toJson()
  };
  
  factory ScadenzaModel.fromJson(Map<String, dynamic> json) {
    return ScadenzaModel(
      id : json['id'],
      data : json['data'],
      descrizione: json['descrizione'],
      cliente: ClienteModel.fromJson(json['cliente'])
    );
  }
}