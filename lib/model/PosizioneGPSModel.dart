import 'package:fema_crm/model/ClienteModel.dart';

class PosizioneGPSModel{
  String? id;
  DateTime? dataCreazione;
  ClienteModel? cliente;
  String? indirizzo;

  PosizioneGPSModel(
      this.id,
      this.dataCreazione,
      this.cliente,
      this.indirizzo
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id' : id,
      'dataCreazione' : dataCreazione?.toIso8601String(),
      'cliente' : cliente?.toMap(),
      'indirizzo' : indirizzo,
    };
    return map;
  }

  PosizioneGPSModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    dataCreazione = DateTime.parse(map['dataCreazione']);
    cliente = map['cliente'] != null ? ClienteModel.fromMap(map['cliente']) : null;
    indirizzo = map['indirizzo'];
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'dataCreazione' : dataCreazione?.toIso8601String(),
    'cliente' : cliente?.toMap(),
    'indirizzo' : indirizzo
  };

  factory PosizioneGPSModel.fromJson(Map<String, dynamic> json){
    return PosizioneGPSModel(
      json['id']?.toString(),
      json['dataCreazione'] != null ? DateTime.parse(json['dataCreazione']) : null,
      json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
      json['indirizzo']?.toString(),
    );
  }
}