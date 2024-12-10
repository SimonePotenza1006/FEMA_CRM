import 'UtenteModel.dart';

class TipoTaskModel{
  String? id;
  String? descrizione;
  UtenteModel? utente;
  UtenteModel? utentecreate;

  TipoTaskModel(
      this.id,
      this.descrizione,
      this.utente,
      this.utentecreate
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id' : id,
      'descrizione' : descrizione,
      'utente' : utente?.toMap(),
      'utentecreate' : utentecreate?.toMap()
    };
    return map;
  }

  factory TipoTaskModel.fromMap(Map<String, dynamic> map){
    return TipoTaskModel(
        map['id']?.toString(),
        map['descrizione']?.toString(),
        map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null,
        map['utentecreate'] != null ? UtenteModel.fromMap(map['utentecreate']) : null
    );
  }

  factory TipoTaskModel.fromJson(Map<String, dynamic> json) {
    return TipoTaskModel(
      json['id']?.toString(),
      json['descrizione']?.toString(),
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['utentecreate'] != null ? UtenteModel.fromJson(json['utentecreate']) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id?.toString(),
      "descrizione": descrizione,
      'utente' : utente?.toMap(),
      'utentecreate' : utentecreate?.toMap()
    };
  }
}