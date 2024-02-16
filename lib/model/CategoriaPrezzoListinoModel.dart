import 'package:fema_crm/model/CategoriaInterventoSpecificoModel.dart';
import 'PreventivoModel.dart';

class CategoriaPrezzoListinoModel {
  String? id;
  String? descrizione;
  double? prezzo; // Modificato da Float a double
  CategoriaInterventoSpecificoModel? categoriaInterventoSpecifico;
  //List<PreventivoModel>? preventivi;

  CategoriaPrezzoListinoModel(
      this.id, this.descrizione, this.prezzo, this.categoriaInterventoSpecifico);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'prezzo': prezzo,
      'categoriaInterventoSpecificoId': categoriaInterventoSpecifico?.id, // Invia solo l'ID della categoria
    };
    return map;
  }


  CategoriaPrezzoListinoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    prezzo = map['prezzo'];
    categoriaInterventoSpecifico = map['categoriaInterventoSpecifico'];
    //preventivi = map['preventivi'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'descrizione': descrizione,
    'prezzo': prezzo != null ? double.parse(prezzo!.toStringAsFixed(2)) : null,
    'categoriaInterventoSpecifico': categoriaInterventoSpecifico,
    //'preventivi': preventivi,
  };

  factory CategoriaPrezzoListinoModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? preventiviJson = json['preventivi'];
    return CategoriaPrezzoListinoModel(
      json['id']?.toString(),
      json['descrizione']?.toString(),
      json['prezzo']?.toDouble(), // Converti il valore in double
      CategoriaInterventoSpecificoModel.fromJson(json),
      //preventiviJson != null ? preventiviJson.map((data) => PreventivoModel.fromJson(data)).toList() : null,
    );
  }
}
