

import 'TipologiaCarta.dart';
import 'ViaggioModel.dart';

class CartaDiCreditoModel {
  String? id;
  String? descrizione;
  TipologiaCartaModel? tipologia_carta;

  CartaDiCreditoModel(
      this.id, this.descrizione, this.tipologia_carta);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'tipologia_carta': tipologia_carta,
    };
    return map;
  }

  CartaDiCreditoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    tipologia_carta = map['tipologia_carta'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'descrizione': descrizione,
        'tipologia_carta': tipologia_carta,
      };

  factory CartaDiCreditoModel.fromJson(Map<String, dynamic> json) {
    return CartaDiCreditoModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        TipologiaCartaModel.fromJson(json),
        );
  }
}
