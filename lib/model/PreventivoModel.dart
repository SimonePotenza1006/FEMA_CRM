import 'dart:ffi';


import 'package:fema_crm/model/AgenteModel.dart';
import 'package:fema_crm/model/AziendaModel.dart';
import 'package:intl/intl.dart';

import 'CategoriaPrezzoListinoModel.dart';
import 'ClienteModel.dart';
import 'DestinazioneModel.dart';
import 'ProdottoModel.dart';
import 'UtenteModel.dart';

class PreventivoModel {
  String? id;
  DateTime? data_creazione;
  AziendaModel? azienda;
  String? categoria_merceologica;
  String? listino;
  String? descrizione;
  double? importo;
  ClienteModel? cliente;
  DestinazioneModel? destinazione;
  bool? accettato;
  bool? rifiutato;
  bool? attesa;
  bool? pendente;
  bool? consegnato;
  double? provvigioni;
  DateTime? data_consegna;
  DateTime? data_accettazione;
  UtenteModel? utente;
  AgenteModel? agente;

  PreventivoModel(
      this.id,
      this.data_creazione,
      this.azienda,
      this.categoria_merceologica,
      this.listino,
      this.descrizione,
      this.importo,
      this.cliente,
      this.destinazione,
      this.accettato,
      this.rifiutato,
      this.attesa,
      this.pendente,
      this.consegnato,
      this.provvigioni,
      this.data_consegna,
      this.data_accettazione,
      this.utente,
      this.agente,
      );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'data_creazione' : data_creazione,
      'azienda': azienda,
      'categoria_merceologica' : categoria_merceologica,
      'listino': listino,
      'descrizione': descrizione,
      'importo': importo,
      'cliente': cliente,
      'destinazione' : destinazione,
      'accettato': accettato,
      'rifiutato': rifiutato,
      'attesa': attesa,
      'pendente' : pendente,
      'consegnato': consegnato,
      'provvigioni': provvigioni,
      'data_consegna': data_consegna,
      'data_accettazione': data_accettazione,
      'utente': utente,
      'agente': agente,
    };
    return map;
  }

  PreventivoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    data_creazione = map['data_creazione'] != null ? DateTime.parse(map['data_creazione']) : null;
    azienda = map['azienda'] != null ? AziendaModel.fromMap(map['azienda']) : null;
    categoria_merceologica = map['categoria_merceologica'];
    listino = map['listino'].toString();
    descrizione = map['descrizione'];
    importo = map['importo'];
    cliente = map['cliente'];
    destinazione = map['destinazione'];
    accettato = map['accettato'];
    rifiutato = map['rifiutato'];
    attesa = map['attesa'];
    pendente = map['pendente'];
    consegnato = map['consegnato'];
    provvigioni = map['provvigioni'] != null ? map['provvigioni'].toDouble() : null;
    data_consegna = map['data_consegna'] != null ? DateTime.parse(map['data_consegna']) : null;
    data_accettazione = map['data_accettazione'] != null ? DateTime.parse(map['data_accettazione']) : null;
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    agente = map['agente'] != null ? AgenteModel.fromMap(map['agente']) :null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'data_creazione': data_creazione != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_creazione!) : null,
    'azienda': azienda,
    'categoria_merceologica': categoria_merceologica,
    'listino': listino,
    'descrizione': descrizione,
    'importo': importo,
    'cliente': cliente,
    'destinazione' : destinazione,
    'accettato': accettato,
    'rifiutato': rifiutato,
    'attesa': attesa,
    'pendente': pendente,
    'consegnato': consegnato,
    'provvigioni': provvigioni,
    'data_consegna': data_consegna != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_consegna!) : null,
    'data_accettazione' : data_accettazione != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_accettazione!) : null,
    'utente': utente,
    'agente': agente,
  };

  factory PreventivoModel.fromJson(Map<String, dynamic> json) {
    return PreventivoModel(
      json['id']?.toString(),
      json['data_creazione'] != null ? DateTime.parse(json['data_creazione']) : null,
      json['azienda'] != null ? AziendaModel.fromJson(json['azienda']) : null,
      json['categoria_merceologica']?.toString(),
      json['listino']?.toString(),
      json['descrizione']?.toString(),
      json['importo'] != null ? json['importo'].toDouble() : null,
      json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
      json['destinazione'] != null ? DestinazioneModel.fromJson(json['destinazione']) : null,
      json['accettato'],
      json['rifiutato'],
      json['attesa'],
      json['pendente'],
      json['consegnato'],
      json['provvigioni'] != null ? json['provvigioni'].toDouble() : null,
      json['data_consegna'] != null ? DateTime.parse(json['data_consegna']) : null,
      json['data_accettazione'] != null? DateTime.parse(json['data_accettazione']) : null,
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['agente'] != null ? AgenteModel.fromJson(json['agente']) : null,
    );
  }
}
