import 'package:fema_crm/model/MerceInRiparazioneModel.dart';

import 'CategoriaInterventoSpecificoModel.dart';
import 'ClienteModel.dart';
import 'DestinazioneModel.dart';
import 'TipologiaInterventoModel.dart';
import 'TipologiaPagamento.dart';
import 'UtenteModel.dart';
import 'VeicoloModel.dart';

class InterventoModel {
  String? id;
  DateTime? data_apertura_intervento;
  DateTime? data;
  DateTime? orario_inizio;
  DateTime? orario_fine;
  String? descrizione;
  double? importo_intervento;
  bool? assegnato;
  bool? conclusione_parziale;
  bool? concluso;
  bool? saldato;
  String? note;
  String? relazione_tecnico;
  String? firma_cliente;
  UtenteModel? utente;
  ClienteModel? cliente;
  VeicoloModel? veicolo;
  MerceInRiparazioneModel? merce;
  TipologiaInterventoModel? tipologia;
  CategoriaInterventoSpecificoModel? categoria_intervento_specifico;
  TipologiaPagamentoModel? tipologia_pagamento;
  DestinazioneModel? destinazione;

  InterventoModel(
      this.id,
      this.data_apertura_intervento,
      this.data,
      this.orario_inizio,
      this.orario_fine,
      this.descrizione,
      this.importo_intervento,
      this.assegnato,
      this.conclusione_parziale,
      this.concluso,
      this.saldato,
      this.note,
      this.relazione_tecnico,
      this.firma_cliente,
      this.utente,
      this.cliente,
      this.veicolo,
      this.merce,
      this.tipologia,
      this.categoria_intervento_specifico,
      this.tipologia_pagamento,
      this.destinazione,
      );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'data_apertura_intervento': data_apertura_intervento?.toIso8601String(),
      'data': data?.toIso8601String(),
      'orario_inizio': orario_inizio?.toIso8601String(),
      'orario_fine': orario_fine?.toIso8601String(),
      'descrizione': descrizione,
      'importo_intervento': importo_intervento,
      'assegnato': assegnato,
      'conclusione_parziale' : conclusione_parziale,
      'concluso': concluso,
      'saldato': saldato,
      'note': note,
      'relazione_tecnico' : relazione_tecnico,
      'firma_cliente': firma_cliente,
      'utente': utente?.toMap(),
      'cliente': cliente?.toMap(),
      'veicolo': veicolo?.toMap(),
      'merce' : merce?.toMap(),
      'tipologia': tipologia?.toMap(),
      'categoria_intervento_specifico': categoria_intervento_specifico?.toMap(),
      'tipologia_pagamento': tipologia_pagamento?.toMap(),
      'destinazione': destinazione?.toMap(),
    };
    return map;
  }



  InterventoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    map['data_apertura_intervento'] != null ? DateTime.parse(map['data_apertura_intervento']) : null;
    map['data'] != null ? DateTime.parse(map['data']) : null;
    map['orario_inizio'] != null ? DateTime.parse(map['orario_inizio']) : null;
    map['orario_fine'] != null ? DateTime.parse(map['orario_fine']) : null;
    descrizione = map['descrizione'];
    importo_intervento = map['importo_intervento'];
    assegnato = map['assegnato'];
    conclusione_parziale = map['conclusione_parziale'];
    concluso = map['concluso'];
    saldato = map['saldato'];
    note = map['note'];
    relazione_tecnico = map['relazione_tecnico'];
    firma_cliente = map['firma_cliente'];
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    cliente = map['cliente'] != null ? ClienteModel.fromMap(map['cliente']) : null;
    veicolo = map['veicolo'] != null ? VeicoloModel.fromMap(map['veicolo']) : null;
    merce = map['merce'] != null ? MerceInRiparazioneModel.fromMap(map['merce']) : null;
    tipologia = map['tipologia'] != null ? TipologiaInterventoModel.fromMap(map['tipologia']) : null;
    categoria_intervento_specifico = map['categoria_intervento_specifico'] != null ? CategoriaInterventoSpecificoModel.fromMap(map['categoria_intervento_specifico']) : null;
    tipologia_pagamento = map['tipologia_pagamento'] != null ? TipologiaPagamentoModel.fromMap(map['tipologia_pagamento']) : null;
    destinazione = map['destinazione'] != null ? DestinazioneModel.fromMap(map['destinazione']) : null;
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'data_apertura_intervento' : data_apertura_intervento?.toIso8601String(),
    'data': data?.toIso8601String(),
    'orario_inizio': orario_inizio?.toIso8601String(),
    'orario_fine': orario_fine?.toIso8601String(),
    'descrizione': descrizione,
    'importo_intervento': importo_intervento,
    'assegnato': assegnato,
    'conclusione_parziale' : conclusione_parziale,
    'concluso': concluso,
    'saldato': saldato,
    'note': note,
    'relazione_tecnico' : relazione_tecnico,
    'firma_cliente': firma_cliente,
    'utente': utente?.toJson(),
    'cliente': cliente?.toJson(),
    'veicolo': veicolo?.toJson(),
    'merce' : merce?.toJson(),
    'tipologia': tipologia?.toJson(),
    'categoria_intervento_specifico': categoria_intervento_specifico?.toJson(),
    'tipologia_pagamento': tipologia_pagamento?.toJson(),
    'destinazione': destinazione?.toJson(),
  };


  factory InterventoModel.fromJson(Map<String, dynamic> json) {
    return InterventoModel(
      json['id']?.toString(),
      json['data_apertura_intervento'] != null ? DateTime.parse(json['data_apertura_intervento']) : null,
      json['data'] != null ? DateTime.parse(json['data']) : null,
      json['orario_inizio'] != null ? DateTime.parse(json['orario_inizio']) : null,
      json['orario_fine'] != null ? DateTime.parse(json['orario_fine']) : null,
      json['descrizione']?.toString(),
      json['importo_intervento'] != null ? double.parse(json['importo_intervento'].toString()) : null,
      json['assegnato'],
      json['conclusione_parziale'],
      json['concluso'],
      json['saldato'],
      json['note']?.toString(),
      json['relazione_tecnico']?.toString(),
      json['firma_cliente'],
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
      json['veicolo'] != null ? VeicoloModel.fromJson(json['veicolo']) : null,
      json['merce'] != null ? MerceInRiparazioneModel.fromJson(json['merce']) : null,
      json['tipologia'] != null ? TipologiaInterventoModel.fromJson(json['tipologia']) : null,
      json['categoria_intervento_specifico'] != null ? CategoriaInterventoSpecificoModel.fromJson(json['categoria_intervento_specifico']) : null,
      json['tipologia_pagamento'] != null ? TipologiaPagamentoModel.fromJson(json['tipologia_pagamento']) : null,
      json['destinazione'] != null ? DestinazioneModel.fromJson(json['destinazione']) : null,
    );
  }
}