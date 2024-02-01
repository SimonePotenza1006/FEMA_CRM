import 'package:fema_crm/model/UtenteModel.dart';

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
    return TipologiaInterventoModel(
        map['id'], map['descrizione'], map['tecnici']);
  }

  factory TipologiaInterventoModel.fromJson(Map<String, dynamic> json) {
    return TipologiaInterventoModel(
        json['id'].toString(), json['descrizione'], json['tecnici']);
  }

  @override
  String toString() {
    return '{id: $id, descrizione: $descrizione, tecnici: $tecnici}';
  }

  Map<String, dynamic> toJson() =>
      {"id": id, "descrizione": descrizione, "tecnici": tecnici};
}
