import 'dart:core';

import 'package:intl/intl.dart';

import 'ClienteModel.dart';
import 'FornitoreModel.dart';
import 'ProdottoModel.dart';
import 'UtenteModel.dart';
import 'InterventoModel.dart';

class OrdinePerInterventoModel{
  String? id;
  String? descrizione;
  InterventoModel? intervento;
  ClienteModel? cliente;
  DateTime? data_creazione;
  DateTime? data_richiesta;
  DateTime? data_disponibilita;
  DateTime? data_ultima;
  UtenteModel? utente;
  UtenteModel? utente_presa_visione;
  UtenteModel? utente_ordine;
  UtenteModel? utente_consegnato;
  ProdottoModel? prodotto;
  FornitoreModel? fornitore;
  String? prodotto_non_presente;
  String? note;
  String? aggiornamento;
  bool? presa_visione;
  bool? ordinato;
  bool? arrivato;
  bool? consegnato;


  OrdinePerInterventoModel(
      this.id,
      this.descrizione,
      this.intervento,
      this.cliente,
      this.data_creazione,
      this.data_richiesta,
      this.data_disponibilita,
      this.data_ultima,
      this.utente,
      this.utente_presa_visione,
      this.utente_ordine,
      this.utente_consegnato,
      this.prodotto,
      this.fornitore,
      this.prodotto_non_presente,
      this.note,
      this.aggiornamento,
      this.presa_visione,
      this.ordinato,
      this.arrivato,
      this.consegnato
      );


  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id' : id,
      'descrizione': descrizione,
      'intervento': intervento?.toMap(),
      'cliente' : cliente?.toMap(),
      'data_creazione': data_creazione != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_creazione!) : null,
      'data_presa_visione': data_richiesta != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_richiesta!) : null,
      'data_disponibilita' : data_disponibilita != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_disponibilita!) : null,
      'data_ultima' : data_ultima != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_ultima!) : null,
      'utente': utente?.toMap(),
      'utente_presa_visione' : utente_presa_visione?.toMap(),
      'utente_ordine' : utente_ordine?.toMap(),
      'utente_consegnato' : utente_consegnato?.toMap(),
      'prodotto' : prodotto?.toMap(),
      'fornitore' : fornitore?.toMap(),
      'prodotto_non_presente' : prodotto_non_presente,
      'note' : note,
      'aggiornamento' : aggiornamento,
      'presa_visione' : presa_visione,
      'ordinato' : ordinato,
      'arrivato' : arrivato,
      'consegnato' : consegnato
    };
    return map;
  }


  OrdinePerInterventoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    intervento = map['intervento'] != null ? InterventoModel.fromMap(map['intervento']) : null;
    cliente = map['cliente'] != null ? ClienteModel.fromMap(map['cliente']) : null;
    data_creazione = map['data_creazione'] != null ? DateTime.parse(map['data_creazione']) : null;
    data_richiesta = map['data_richiesta'] != null ? DateTime.parse(map['data_richiesta']) : null;
    data_disponibilita = map['data_disponibilita'] != null ? DateTime.parse(map['data_disponibilita']) : null;
    data_ultima = map['data_ultima'] != null ? DateTime.parse(map[data_ultima]) : null;
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    utente_presa_visione = map['utente_presa_visione'] != null ? UtenteModel.fromMap(map['utente_presa_visione']) : null;
    utente_ordine = map['utente_ordine'] != null ? UtenteModel.fromMap(map['utente_ordine']) : null;
    utente_consegnato = map['utente_consegnato'] != null ? UtenteModel.fromMap(map['utente_consegnato']) : null;
    prodotto = map['prodotto'] != null ? ProdottoModel.fromMap(map['prodotto']) : null;
    fornitore = map['fornitore'] != null ? FornitoreModel.fromMap(map['fornitore']) : null;
    prodotto_non_presente = map['prodotto_non_presente'];
    note = map['note'];
    aggiornamento = map['aggiornamento'];
    presa_visione = map['presa_visione'];
    ordinato = map['ordinato'];
    arrivato = map['arrivato'];
    consegnato = map['consegnato'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'descrizione' : descrizione,
    'intervento' : intervento?.toJson(),
    'cliente' : cliente?.toJson(),
    'data_creazione': data_creazione != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_creazione!) : null,
    'data_presa_visione': data_richiesta != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_richiesta!) : null,
    'data_disponibilita' : data_disponibilita != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_disponibilita!) : null,
    'data_ultima' : data_ultima != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_ultima!) : null,
    'utente' : utente?.toJson(),
    'utente_presa_visione' : utente_presa_visione?.toJson(),
    'utente_ordine' : utente_ordine?.toJson(),
    'utente_consegnato' : utente_consegnato?.toJson(),
    'prodotto' : prodotto?.toJson(),
    'fornitore' : fornitore?.toJson(),
    'prodotto_non_presente' : prodotto_non_presente,
    'note' : note,
    'aggiornamento' : aggiornamento,
    'presa_visione' : presa_visione,
    'ordinato' : ordinato,
    'arrivato' : arrivato,
    'consegnato' : consegnato
  };

  factory OrdinePerInterventoModel.fromJson(Map<String, dynamic> json) {
    return OrdinePerInterventoModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        json['intervento'] != null ? InterventoModel.fromJson(json['intervento']) : null,
        json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
        json['data_creazione'] != null ? DateTime.parse(json['data_creazione']) : null,
        json['data_richiesta'] != null ? DateTime.parse(json['data_richiesta']) : null,
        json['data_disponibilita'] != null ? DateTime.parse(json['data_disponibilita']) : null,
        json['data_ultima'] != null ? DateTime.parse(json['data_ultima']) : null,
        json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
        json['utente_presa_visione'] != null ? UtenteModel.fromJson(json['utente_presa_visione']) : null,
        json['utente_ordine'] != null ? UtenteModel.fromJson(json['utente_ordine']) : null,
        json['utente_consegnato'] != null ? UtenteModel.fromJson(json['utente_consegnato']) : null,
        json['prodotto'] != null ? ProdottoModel.fromJson(json['prodotto']) : null,
        json['fornitore'] != null ? FornitoreModel.fromJson(json['fornitore']) : null,
        json['prodotto_non_presente']?.toString(),
        json['note']?.toString(),
        json['aggiornamento']?.toString(),
        json['presa_visione'],
        json['ordinato'],
        json['arrivato'],
        json['consegnato']
    );
  }
}
