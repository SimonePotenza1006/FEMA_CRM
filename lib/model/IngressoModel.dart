import 'package:fema_crm/model/UtenteModel.dart';
import 'package:intl/intl.dart';

class IngressoModel{
  String? id;
  DateTime? orario;
  UtenteModel? utente;

  IngressoModel(
      this.id,
      this.orario,
      this.utente,
      );

  IngressoModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    orario = map['orario'] != null ? DateTime.parse(map['orario']) : null;
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'id': id,
      'orario': orario != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(orario!) : null,
      'utente': utente?.toMap(),
    };
    return map;
  }

  Map<String, dynamic> toJson() =>{
    'id': id,
    'orario': orario != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(orario!) : null,
    'utente': utente?.toJson(),
  };

  factory IngressoModel.fromJson(Map<String, dynamic> json) {
    return IngressoModel(
      json['id']?.toString(),
      json['orario'] != null ? DateTime.parse(json['orario']) : null,
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
    );
  }


}