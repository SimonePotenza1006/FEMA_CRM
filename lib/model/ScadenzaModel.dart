import 'ClienteModel.dart';
import 'InterventoModel.dart';

class ScadenzaModel{
  String? id;
  DateTime? data;
  String? descrizione;
  ClienteModel? cliente;
  InterventoModel? intervento;

  ScadenzaModel(
      this.id,
      this.data,
      this.descrizione,
      this.cliente,
      this.intervento
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id' : id,
      'data' : data?.toIso8601String(),
      'descrizione' : descrizione,
      'cliente' : cliente?.toMap(),
      'intervento' : intervento?.toMap()
    };
    return map;
  }

  ScadenzaModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    map['data'] != null ? DateTime.parse(map['data']) : null;
    descrizione = map['descrizione'];
    cliente = map['cliente'] != null ? ClienteModel.fromMap(map['cliente']) : null;
    intervento = map['intervento'] != null ? InterventoModel.fromMap(map['intervento']) : null;
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'data' : data?.toIso8601String(),
    'descrizione' : descrizione,
    'cliente' : cliente?.toJson(),
    'intervento' : intervento?.toJson()
  };

  factory ScadenzaModel.fromJson(Map<String, dynamic> json){
    return ScadenzaModel(
        json['id'],
        json['data'] != null ? DateTime.parse(json['data']) : null,
        json['descrizione'],
        json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
        json['intervento'] != null ? InterventoModel.fromJson(json['intervento']) : null,
    );
  }
}