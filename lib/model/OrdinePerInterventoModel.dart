import 'dart:core';

import 'UtenteModel.dart';
import 'InterventoModel.dart';

class OrdinePerInterventoModel{
  String? id;
  String? descrizione;
  InterventoModel? intervento;
  DateTime? dataCreazione;
  DateTime? dataPresaVisione;
  UtenteModel? utente;



  OrdinePerInterventoModel(
      this.id,
      this.descrizione,
      this.intervento,
      this.dataCreazione,
      this.dataPresaVisione,
      this.utente,
      );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id' : id,
      'descrizione': descrizione,
      'intervento': intervento,
      'dataCreazione': dataCreazione,
      'dataPresaVisione': dataPresaVisione,
      'utente': utente,
    };
    return map;
  }

  OrdinePerInterventoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    intervento = map['intervento'];
    dataCreazione = map['dataCreazione'];
    dataPresaVisione = map['dataPresaVisione'];
    utente = map['utente'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'descrizione' : descrizione,
    'intervento' : intervento,
    'dataCreazione' : dataCreazione,
    'dataPresaVisione' : dataPresaVisione,
    'utente' : utente,
  };

  factory OrdinePerInterventoModel.fromJson(Map<String, dynamic> json) {
    return OrdinePerInterventoModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        InterventoModel.fromJson(json),
        json['dataCreazione'],
        json['dataPresaVisione'],
        UtenteModel.fromJson(json)
    );
  }
}
