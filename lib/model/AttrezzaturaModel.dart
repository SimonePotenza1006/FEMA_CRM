

import 'UtenteModel.dart';

class AttrezzaturaModel {
  String? id;
  String? descrizione;
  List<UtenteModel>? utenti;

  AttrezzaturaModel(this.id, this.descrizione, this.utenti);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'utenti': utenti
    };
    return map;
  }

  AttrezzaturaModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    utenti = map['utenti'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'descrizione': descrizione,
        'utenti': utenti,
      };

  factory AttrezzaturaModel.fromJson(Map<String, dynamic> json) {
    return AttrezzaturaModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        json['utenti']?.map((data) => UtenteModel.fromJson(data)).toList());
  }
}
