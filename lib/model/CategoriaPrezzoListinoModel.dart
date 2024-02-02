import 'dart:ffi';

import 'package:fema_crm/model/PreventivoModel.dart';

class CategoriaPrezzoListinoModel {
  String? id;
  String? descrizione;
  Float? prezzo;
  List<PreventivoModel>? preventivi;

  CategoriaPrezzoListinoModel(
      this.id, this.descrizione, this.prezzo, this.preventivi);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'prezzo': prezzo,
      'preventivi': preventivi
    };
    return map;
  }

  CategoriaPrezzoListinoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    prezzo = map['prezzo'];
    preventivi = map['preventivi'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'descrizione': descrizione,
        'prezzo': prezzo,
        'preventivi': preventivi,
      };

  factory CategoriaPrezzoListinoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaPrezzoListinoModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        json['prezzo'].float.parse(),
        json['preventivi']
            ?.map((data) => PreventivoModel.fromJson(data))
            .toList());
  }
}
