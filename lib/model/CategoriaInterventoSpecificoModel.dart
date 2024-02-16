

import 'CategoriaPrezzoListinoModel.dart';
import 'TipologiaInterventoModel.dart';

class CategoriaInterventoSpecificoModel {
  String? id;
  String? descrizione;
  TipologiaInterventoModel? tipologia;
  //List<CategoriaPrezzoListinoModel>? listini;

  CategoriaInterventoSpecificoModel(this.id, this.descrizione, this.tipologia); //, this.listini);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
    };
    if (tipologia != null) {
      map['tipologia'] = tipologia!.toMap();
    }
    // if (listini != null) {
    //   map['listini'] = listini!.map((listino) => listino.toMap()).toList();
    // }
    return map;
  }


  CategoriaInterventoSpecificoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'].toString();
    descrizione = map['descrizione'];
    tipologia = map['tipologia'] != null ? TipologiaInterventoModel.fromMap(map['tipologia']) : null;
    // listini = (map['listini'] as List<dynamic>?)
    //     ?.map((data) => CategoriaPrezzoListinoModel.fromMap(data as Map<String, dynamic>))
    //     .toList();
  }



  Map<String, dynamic> toJson() =>
      {'id': id, 'descrizione': descrizione, 'tipologia': tipologia?.toMap()}; //, 'listini': listini};

  factory CategoriaInterventoSpecificoModel.fromJson(Map<String, dynamic> json) {
    //final List<dynamic>? listiniJson = json['listini'];
    final tipologiaJson = json['tipologia'];

    return CategoriaInterventoSpecificoModel(
      json['id'].toString(),
      json['descrizione']?.toString(),
      tipologiaJson != null ? TipologiaInterventoModel.fromJson(tipologiaJson) : null,
      //listiniJson != null ? listiniJson.map((data) => CategoriaPrezzoListinoModel.fromJson(data)).toList() : null,
    );
  }

}
