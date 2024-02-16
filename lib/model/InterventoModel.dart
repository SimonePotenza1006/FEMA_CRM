import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'CategoriaInterventoSpecificoModel.dart';
import 'ClienteModel.dart';
import 'DestinazioneModel.dart';
import 'TipologiaInterventoModel.dart';
import 'TipologiaPagamento.dart';
import 'UtenteModel.dart';
import 'VeicoloModel.dart';

class InterventoModel {
  String? id;
  DateTime? data;
  DateTime? orario_inizio;
  DateTime? orario_fine;
  String? descrizione;
  File? foto;
  double? importo_intervento;
  bool? assegnato;
  bool? concluso;
  bool? saldato;
  String? note;
  File? firma_cliente;
  UtenteModel? utente;
  ClienteModel? cliente;
  VeicoloModel? veicolo;
  TipologiaInterventoModel? tipologia;
  CategoriaInterventoSpecificoModel? categoria_intervento_specifico;
  TipologiaPagamentoModel? tipologiaPagamento;
  DestinazioneModel? destinazione;
  //List<UtenteModel>? utenti;

  InterventoModel(
      this.id,
      this.data,
      this.orario_inizio,
      this.orario_fine,
      this.descrizione,
      this.foto,
      this.importo_intervento,
      this.assegnato,
      this.concluso,
      this.saldato,
      this.note,
      this.firma_cliente,
      this.utente,
      this.cliente,
      this.veicolo,
      this.tipologia,
      this.categoria_intervento_specifico,
      this.tipologiaPagamento,
      this.destinazione,
      //this.utenti);
      );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'data': data,
      'orarioInizio': orario_inizio,
      'orarioFine': orario_fine,
      'descrizione': descrizione,
      'foto': foto,
      'importoIntervento': importo_intervento,
      'assegnato': assegnato,
      'concluso': concluso,
      'saldato' : saldato,
      'note' : note,
      'firmaCliente': firma_cliente,
      'utente': utente?.toMap(),
      'cliente': cliente?.toMap(),
      'veicolo': veicolo?.toMap(),
      'tipologia': tipologia?.toMap(),
      'categoria_intervento_specifico': categoria_intervento_specifico?.toMap(),
      'tipologiaPagamento': tipologiaPagamento?.toMap(),
      'destinazione': destinazione?.toMap(),
      //'utenti': utenti
  };
    return map;
  }

  InterventoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    data = map['data'];
    orario_inizio = map['orarioInizio'];
    orario_fine = map['orarioFine'];
    descrizione = map['descrizione'];
    foto = map['foto'];
    importo_intervento = map['importoIntervento'];
    assegnato = map['assegnato'];
    concluso = map['concluso'];
    saldato = map['saldato'];
    note = map['note'];
    firma_cliente = map['firmaCliente'];
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    cliente = map['cliente'] != null ? ClienteModel.fromMap(map['cliente']) : null;
    veicolo = map['veicolo'] != null ? VeicoloModel.fromMap(map['veicolo']) : null;
    tipologia = map['tipologia'] != null ? TipologiaInterventoModel.fromMap(map['tipologia']) : null;
    categoria_intervento_specifico = map['categoria_intervento_specifico'] != null ? CategoriaInterventoSpecificoModel.fromMap(map['categoria_intervento_specifico']) : null;
    tipologiaPagamento = map['tipologiaPagamento'] != null ? TipologiaPagamentoModel.fromMap(map['tipologiaPagamento']) : null;
    destinazione = map['destinazione'] != null ? DestinazioneModel.fromMap(map['destinazione']) : null;
    //utenti = (map['utenti'] as List<Map<String, dynamic>>?)?.map((data) => UtenteModel.fromMap(data)).toList();
  }


  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'orarioInizio': orario_inizio,
        'orarioFine': orario_fine,
        'descrizione': descrizione,
        'foto': foto,
        'importoIntervento': importo_intervento,
        'assegnato' : assegnato,
        'concluso': concluso,
        'saldato': saldato,
        'note': note,
        'firmaCliente': firma_cliente,
        'utente': utente,
        'cliente': cliente,
        'veicolo': veicolo,
        'tipologia': tipologia,
        'categoria_intervento_specifico': categoria_intervento_specifico,
        'tipologiaPagamento': tipologiaPagamento,
        'destinazione': destinazione,
        //'utenti': utenti
      };

  factory InterventoModel.fromJson(Map<String, dynamic> json){
    return InterventoModel(
      json['id'].toString(),
      json['data'] != null ? DateTime.parse(json['data']) : null,
      json['orario_inizio'] != null ? DateTime.parse(json['orarioInizio']) : null,
      json['orario_fine'] != null ? DateTime.parse(json['orarioFine']) : null,
      json['descrizione'].toString(),
      json['foto'],
      json['importo_intervento'] != null ? double.parse(json['importoIntervento'].toString()) : null,
      json['assegnato'],
      json['concluso'],
      json['saldato'],
      json['note'] != null ? json['note'].toString() : null,
      json['firma_cliente'],
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
      json['veicolo'] != null ? VeicoloModel.fromJson(json['veicolo']) : null,
      json['tipologia'] != null ? TipologiaInterventoModel.fromJson(json['tipologia']) : null,
      json['categoriaInterventoSpecifico'] != null ? CategoriaInterventoSpecificoModel.fromJson(json['categoriaInterventoSpecifico']) : null,
      json['tipologiaPagamento'] != null ? TipologiaPagamentoModel.fromJson(json['tipologiaPagamento']) : null,
      json['destinazione'] != null ? DestinazioneModel.fromJson(json['destinazione']) : null,
      //(json['utenti'] as List<dynamic>?)?.map((data) => UtenteModel.fromJson(data)).toList(),
    );
  }


}
