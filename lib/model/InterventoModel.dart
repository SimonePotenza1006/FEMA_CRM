import 'dart:ffi';
import 'dart:io';

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
  DateTime? orarioInizio;
  DateTime? orarioFine;
  String? descrizione;
  File? foto;
  Float? importoIntervento;
  Bool? concluso;
  File? firmaCliente;
  UtenteModel? utente;
  ClienteModel? cliente;
  VeicoloModel? veicolo;
  TipologiaInterventoModel? tipologiaIntervento;
  CategoriaInterventoSpecificoModel? categoriaInterventoSpecifico;
  TipologiaPagamentoModel? tipologiaPagamento;
  DestinazioneModel? destinazione;
  List<UtenteModel>? utenti;

  InterventoModel(
      this.id,
      this.data,
      this.orarioInizio,
      this.orarioFine,
      this.descrizione,
      this.foto,
      this.importoIntervento,
      this.concluso,
      this.firmaCliente,
      this.utente,
      this.cliente,
      this.veicolo,
      this.tipologiaIntervento,
      this.categoriaInterventoSpecifico,
      this.tipologiaPagamento,
      this.destinazione,
      this.utenti);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'data': data,
      'orarioInizio': orarioInizio,
      'orarioFine': orarioFine,
      'descrizione': descrizione,
      'foto': foto,
      'importoIntervento': importoIntervento,
      'concluso': concluso,
      'firmaCliente': firmaCliente,
      'utente': utente,
      'cliente': cliente,
      'veicolo': veicolo,
      'tipologiaIntervento': tipologiaIntervento,
      'categoriaInterventoSpecifico': categoriaInterventoSpecifico,
      'tipologiaPagamento': tipologiaPagamento,
      'destinazione': destinazione,
      'utenti': utenti
    };
    return map;
  }

  InterventoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    data = map['data'];
    orarioInizio = map['orarioInizio'];
    orarioFine = map['orarioFine'];
    descrizione = map['descrizione'];
    foto = map['foto'];
    importoIntervento = map['importoIntervento'];
    concluso = map['concluso'];
    firmaCliente = map['firmaCliente'];
    utente = map['utente'];
    cliente = map['cliente'];
    veicolo = map['veicolo'];
    tipologiaIntervento = map['tipologiaIntervento'];
    categoriaInterventoSpecifico = map['categoriaInterventoSpecifico'];
    tipologiaPagamento = map['tipologiaPagamento'];
    destinazione = map['destinazione'];
    utenti = map['utenti'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'orarioInizio': orarioInizio,
        'orarioFine': orarioFine,
        'descrizione': descrizione,
        'foto': foto,
        'importoIntervento': importoIntervento,
        'concluso': concluso,
        'firmaCliente': firmaCliente,
        'utente': utente,
        'cliente': cliente,
        'veicolo': veicolo,
        'tipologiaIntervento': tipologiaIntervento,
        'categoriaInterventoSpecifico': categoriaInterventoSpecifico,
        'tipologiaPagamento': tipologiaPagamento,
        'destinazione': destinazione,
        'utenti': utenti
      };

  factory InterventoModel.fromJson(Map<String, dynamic> json) {
    return InterventoModel(
        json['id']?.toString(),
        json['data'],
        json['orarioInizio'],
        json['orarioFine'],
        json['descrizione'].toString(),
        json['foto'],
        json['importoIntervento'].float.parse(),
        json['concluso'],
        json['firmaCliente'],
        UtenteModel.fromJson(json),
        ClienteModel.fromJson(json),
        VeicoloModel.fromJson(json),
        TipologiaInterventoModel.fromJson(json),
        CategoriaInterventoSpecificoModel.fromJson(json),
        TipologiaPagamentoModel.fromJson(json),
        DestinazioneModel.fromJson(json),
        json['utenti']?.map((data) => UtenteModel.fromJson(data)));
  }
}
