

import 'CategoriaPrezzoListinoModel.dart';
import 'TipologiaInterventoModel.dart';

class CategoriaInterventoSpecificoModel {
  String? id;
  String? descrizione;
  TipologiaInterventoModel? tipologia;
  List<CategoriaPrezzoListinoModel>? listini;

  CategoriaInterventoSpecificoModel(this.id, this.descrizione, this.tipologia, this.listini);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'tipologia': tipologia!.toMap(), // Converti l'oggetto TipologiaInterventoModel in una mappa
      'listini': listini,
    };
    return map;
  }


  CategoriaInterventoSpecificoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    tipologia = TipologiaInterventoModel.fromMap(map['tipologia']);
    listini = map['listini'];
  }



  Map<String, dynamic> toJson() =>
      {'id': id, 'descrizione': descrizione, 'tipologia': tipologia, 'listini': listini};

  factory CategoriaInterventoSpecificoModel.fromJson(
      Map<String, dynamic> json) {
    final List<dynamic>? listiniJson = json['listini'];
    return CategoriaInterventoSpecificoModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        TipologiaInterventoModel.fromJson(json),
        listiniJson != null ? listiniJson.map((data) => CategoriaPrezzoListinoModel.fromJson(data)).toList() : null,
    );
  }
}
