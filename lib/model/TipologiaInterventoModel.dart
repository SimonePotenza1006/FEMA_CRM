

import 'UtenteModel.dart';

class TipologiaInterventoModel {
  String? id;
  String? descrizione;

  TipologiaInterventoModel(
      this.id,
      this.descrizione
      );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
    };
    return map;
  }

  factory TipologiaInterventoModel.fromMap(Map<String, dynamic> map) {
    final List<dynamic>? tecniciJson = map['tecnici'];
    return TipologiaInterventoModel(
      map['id']?.toString(),
      map['descrizione']?.toString(),
    );
  }

  factory TipologiaInterventoModel.fromJson(Map<String, dynamic> json) {
        return TipologiaInterventoModel(
      json['id']?.toString(),
      json['descrizione']?.toString(),
        );
  }


  @override
  String toString() {
    return '{id: $id, descrizione: $descrizione}';
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id?.toString(),
      "descrizione": descrizione,
    };
  }

}
