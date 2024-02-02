import 'package:fema_crm/model/TipologiaInterventoModel.dart';

class CategoriaInterventoSpecificoModel {
  String? id;
  String? descrizione;
  TipologiaInterventoModel? tipologia;

  CategoriaInterventoSpecificoModel(this.id, this.descrizione, this.tipologia);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'tipologia': tipologia
    };
    return map;
  }

  CategoriaInterventoSpecificoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    tipologia = map['tipologia'];
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'descrizione': descrizione, 'tipologia': tipologia};

  factory CategoriaInterventoSpecificoModel.fromJson(
      Map<String, dynamic> json) {
    return CategoriaInterventoSpecificoModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        TipologiaInterventoModel.fromJson(json));
  }
}
