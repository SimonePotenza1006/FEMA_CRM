

import 'TipologiaCarta.dart';
import 'ViaggioModel.dart';

class CartaDiCreditoModel {
  String? id;
  String? descrizione;
  TipologiaCartaModel? tipologiaCarta;
  List<ViaggioModel>? viaggi;

  CartaDiCreditoModel(
      this.id, this.descrizione, this.tipologiaCarta, this.viaggi);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'tipologiaCarta': tipologiaCarta,
      'viaggi': viaggi,
    };
    return map;
  }

  CartaDiCreditoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    tipologiaCarta = map['tipologiaCarta'];
    viaggi = ViaggioModel.fromMap(map) as List<ViaggioModel>;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'descrizione': descrizione,
        'tipologiaCarta': tipologiaCarta,
        'viaggi': viaggi,
      };

  factory CartaDiCreditoModel.fromJson(Map<String, dynamic> json) {
    return CartaDiCreditoModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        TipologiaCartaModel.fromJson(json),
        json['viaggi']?.map((data) => ViaggioModel.fromJson(data)).toList());
  }
}
