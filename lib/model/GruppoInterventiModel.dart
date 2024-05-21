
import 'ClienteModel.dart';

class GruppoInterventiModel{
  String? id;
  String? descrizione;
  String? note;
  double? importo;
  bool? concluso;
  ClienteModel? cliente;

  GruppoInterventiModel(
      this.id,
      this.descrizione,
      this.note,
      this.importo,
      this.concluso,
      this.cliente,
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id' : id,
      'descrizione' : descrizione,
      'note' : note,
      'importo' : importo,
      'concluso' : concluso,
      'cliente': cliente?.toMap(),

    };
    return map;
  }

  GruppoInterventiModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    descrizione = map['descrizione'];
    note = map['note'];
    importo = map['importo'];
    concluso = map['concluso'];
    cliente = map['cliente'] != null ? ClienteModel.fromMap(map['cliente']) : null;;
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'descrizione' : descrizione,
    'note' : note,
    'importo' : importo,
    'concluso' : concluso,
    'cliente': cliente?.toJson(),
  };

  factory GruppoInterventiModel.fromJson(Map<String, dynamic> json){
    return GruppoInterventiModel(
      json['id'].toString(),
      json['descrizione'].toString(),
      json['note'].toString(),
      json['importo'] != null ? double.parse(json['importo'].toString()) : null,
      json['concluso'],
      json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
    );
  }
}