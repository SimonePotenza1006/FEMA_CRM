import 'dart:ffi';


import 'package:fema_crm/model/AgenteModel.dart';
import 'package:fema_crm/model/AziendaModel.dart';

import 'CategoriaPrezzoListinoModel.dart';
import 'ClienteModel.dart';
import 'ProdottoModel.dart';
import 'UtenteModel.dart';

class PreventivoModel {
  String? id;
  AziendaModel? azienda;
  String? descrizione;
  double? importo;
  ClienteModel? cliente;
  Bool? accettato;
  Bool? rifiutato;
  Bool? attesa;
  Bool? consegnato;
  double? provvigioni;
  UtenteModel? utente;
  AgenteModel? agente;
  List<ProdottoModel>? prodotti;

  PreventivoModel(
      this.id,
      this.azienda,
      this.descrizione,
      this.importo,
      this.cliente,
      this.accettato,
      this.rifiutato,
      this.attesa,
      this.consegnato,
      this.provvigioni,
      this.utente,
      this.agente,
      this.prodotti
      );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'azienda': azienda,
      'descrizione': descrizione,
      'importo': importo,
      'cliente': cliente,
      'accettato': accettato,
      'rifiutato': rifiutato,
      'attesa': attesa,
      'consegnato': consegnato,
      'provvigioni': provvigioni,
      'utente': utente,
      'agente': agente,
      'prodotti': prodotti
    };
    return map;
  }

  PreventivoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    azienda = map['azienda'] != null ? AziendaModel.fromMap(map['azienda']) : null;
    descrizione = map['descrizione'];
    importo = map['importo'];
    cliente = map['cliente'];
    accettato = map['accettato'];
    rifiutato = map['rifiutato'];
    attesa = map['attesa'];
    consegnato = map['consegnato'];
    provvigioni = map['provvigioni'];
    utente = map['utente'];
    agente = map['agente'] != null ? AgenteModel.fromMap(map['agente']) :null;
    prodotti = ProdottoModel.fromMap(map) as List<ProdottoModel>;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'azienda': azienda,
    'descrizione': descrizione,
    'importo': importo,
    'cliente': cliente,
    'accettato': accettato,
    'rifiutato': rifiutato,
    'attesa': attesa,
    'consegnato': consegnato,
    'provvigioni': provvigioni,
    'utente': utente,
    'agente': agente,
    'prodotti': prodotti,
  };

  factory PreventivoModel.fromJson(Map<String, dynamic> json) {
    return PreventivoModel(
      json['id']?.toString(),
      AziendaModel.fromJson(json),
      json['descrizione']?.toString(),
      json['importo'].toDouble(),
      ClienteModel.fromJson(json),
      json['accettato'],
      json['rifiutato'],
      json['attesa'],
      json['consegnato'],
      json['provvigioni'].toDouble(),
      UtenteModel.fromJson(json),
      AgenteModel.fromJson(json),
      json['prodotti']?.map((data) => ProdottoModel.fromJson(data)).toList(),
    );
  }
}
