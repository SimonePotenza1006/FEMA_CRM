
import 'CategoriaPrezzoListinoModel.dart';
import 'TipologiaInterventoModel.dart';

class CategoriaInterventoSpecificoModel {
  String? id;
  String? descrizione;
  TipologiaInterventoModel? tipologiaIntervento;

  CategoriaInterventoSpecificoModel(
      this.id,
      this.descrizione,
      this.tipologiaIntervento
      ); //, this.listini);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
    };
    if (tipologiaIntervento != null && tipologiaIntervento!.id != null) {
      map['tipologiaIntervento'] = tipologiaIntervento!.toMap();
    }
    return map;
  }


  CategoriaInterventoSpecificoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    tipologiaIntervento = map['tipologiaIntervento'] != null ? TipologiaInterventoModel.fromMap(map['tipologiaIntervento']) : null;
    // listini = (map['listini'] as List<dynamic>?)
    //     ?.map((data) => CategoriaPrezzoListinoModel.fromMap(data as Map<String, dynamic>))
    //     .toList();
  }



  Map<String, dynamic> toJson() =>
      {
        'id': id,
       'descrizione': descrizione,
       'tipologiaIntervento': tipologiaIntervento?.toJson()
      }; //, 'listini': listini};


  factory CategoriaInterventoSpecificoModel.fromJson(Map<String, dynamic> json) {

    return CategoriaInterventoSpecificoModel(
      json['id']?.toString(),
      json['descrizione']?.toString(),
      json['tipologiaIntervento'] != null ? TipologiaInterventoModel.fromJson(json['tipologiaIntervento']) : null,
    );
  }

}
