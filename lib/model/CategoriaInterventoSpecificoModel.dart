
import 'CategoriaPrezzoListinoModel.dart';
import 'TipologiaInterventoModel.dart';

class CategoriaInterventoSpecificoModel {
  String? id;
  String? descrizione;
  TipologiaInterventoModel? tipologia;

  CategoriaInterventoSpecificoModel(
      this.id,
      this.descrizione,
      this.tipologia
      ); //, this.listini);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
    };
    if (tipologia != null && tipologia!.id != null) {
      map['tipologia'] = tipologia!.toMap();
    }
    return map;
  }


  CategoriaInterventoSpecificoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    tipologia = map['tipologia'] != null ? TipologiaInterventoModel.fromMap(map['tipologia']) : null;
    // listini = (map['listini'] as List<dynamic>?)
    //     ?.map((data) => CategoriaPrezzoListinoModel.fromMap(data as Map<String, dynamic>))
    //     .toList();
  }



  Map<String, dynamic> toJson() =>
      {
        'id': id,
       'descrizione': descrizione,
       'tipologia': tipologia?.toJson()
      }; //, 'listini': listini};


  factory CategoriaInterventoSpecificoModel.fromJson(Map<String, dynamic> json) {

    return CategoriaInterventoSpecificoModel(
      json['id']?.toString(),
      json['descrizione']?.toString(),
      json['tipologia'] != null ? TipologiaInterventoModel.fromJson(json['tipologia']) : null,
    );
  }

}
