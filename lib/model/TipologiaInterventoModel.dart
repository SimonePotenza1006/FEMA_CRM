

import 'UtenteModel.dart';

class TipologiaInterventoModel {
  String? id;
  String? descrizione;

  List<UtenteModel>? tecnici;

  TipologiaInterventoModel(this.id, this.descrizione, this.tecnici);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'tecnici': tecnici
    };
    return map;
  }

  factory TipologiaInterventoModel.fromMap(Map<String, dynamic> map) {
    final List<dynamic>? tecniciJson = map['tecnici'];
    return TipologiaInterventoModel(
        map['id'], map['descrizione'],
        tecniciJson != null ? tecniciJson.map((data) => UtenteModel.fromMap(data)).toList() : null
    );
  }

  factory TipologiaInterventoModel.fromJson(Map<String, dynamic> json) {
    // Controlla se il campo tecnici nel JSON è una lista
    final List<dynamic>? tecniciJson = json['tecnici'];

    return TipologiaInterventoModel(
      json['id'].toString(),
      json['descrizione'],
      // Converti ogni oggetto JSON in un UtenteModel
      tecniciJson != null ? tecniciJson.map((data) => UtenteModel.fromJson(data)).toList() : null,
    );
  }


  @override
  String toString() {
    return '{id: $id, descrizione: $descrizione, tecnici: $tecnici}';
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "descrizione": descrizione,
      "tecnici": tecnici != null ? tecnici!.map((tecnico) => tecnico.toJson()).toList() : null,
    };
  }

}
