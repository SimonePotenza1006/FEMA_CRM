import 'dart:core';

import 'package:intl/intl.dart';

import 'FornitoreModel.dart';
import 'ProdottoModel.dart';
import 'UtenteModel.dart';
import 'InterventoModel.dart';

class OrdinePerInterventoModel{
  String? id;
  String? descrizione;
  InterventoModel? intervento;
  DateTime? data_creazione;
  DateTime? data_presa_visione;
  UtenteModel? utente;
  ProdottoModel? prodotto;
  FornitoreModel? fornitore;



  OrdinePerInterventoModel(
      this.id,
      this.descrizione,
      this.intervento,
      this.data_creazione,
      this.data_presa_visione,
      this.utente,
      this.prodotto,
      this.fornitore
      );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id' : id,
      'descrizione': descrizione,
      'intervento': intervento?.toMap(),
      'data_creazione': data_creazione != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_creazione!) : null,
      'data_presa_visione': data_presa_visione != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_presa_visione!) : null,
      'utente': utente?.toMap(),
      'prodotto' : prodotto?.toMap(),
      'fornitore' : fornitore?.toMap()
    };
    return map;
  }

  OrdinePerInterventoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    intervento = map['intervento'] != null ? InterventoModel.fromMap(map['intervento']) : null;
    data_creazione = map['data_creazione'] != null ? DateTime.parse(map['data_creazione']) : null;
    data_presa_visione = map['data_presa_visione'] != null ? DateTime.parse(map['data_presa_visione']) : null;
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    prodotto = map['prodotto'] != null ? ProdottoModel.fromMap(map['prodotto']) : null;
    fornitore = map['fornitore'] != null ? FornitoreModel.fromMap(map['fornitore']) : null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'descrizione' : descrizione,
    'intervento' : intervento?.toJson(),
    'data_creazione': data_creazione != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_creazione!) : null,
    'data_presa_visione': data_presa_visione != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_presa_visione!) : null,
    'utente' : utente?.toJson(),
    'prodotto' : prodotto?.toJson(),
    'fornitore' : fornitore?.toJson()
  };

  factory OrdinePerInterventoModel.fromJson(Map<String, dynamic> json) {
    return OrdinePerInterventoModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        json['intervento'] != null ? InterventoModel.fromJson(json['intervento']) : null,
        json['data_creazione'] != null ? DateTime.parse(json['data_creazione']) : null,
        json['data_presa_visione'] != null ? DateTime.parse(json['data_presa_visione']) : null,
        json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
        json['prodotto'] != null ? ProdottoModel.fromJson(json['prodotto']) : null,
        json['fornitore'] != null ? FornitoreModel.fromJson(json['fornitore']) : null,
    );
  }
}
