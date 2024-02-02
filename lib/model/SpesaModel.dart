import 'dart:ffi';

import 'package:fema_crm/model/TipologiaPagamento.dart';
import 'package:fema_crm/model/TipologiaSpesaModel.dart';
import 'package:fema_crm/model/ViaggioModel.dart';

class SpesaModel {
  String? id;
  DateTime? data;
  Bool? fattura;
  Float? importo;
  String? luogo;
  TipologiaPagamentoModel? tipologiaPagamento;
  TipologiaSpesaModel? tipologiaSpesa;
  ViaggioModel? viaggio;

  SpesaModel(this.id, this.data, this.fattura, this.importo, this.luogo,
      this.tipologiaPagamento, this.tipologiaSpesa, this.viaggio);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'data': data,
      'fattura': fattura,
      'importo': importo,
      'luogo': luogo,
      'tipologiaPagamento': tipologiaPagamento,
      'tipologiaSpesa': tipologiaSpesa,
      'viaggio': viaggio
    };
    return map;
  }

  SpesaModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    data = map['data'];
    fattura = map['fattura'];
    importo = map['importo'];
    luogo = map['luogo'];
    tipologiaPagamento = map['tipologiaPagamento'];
    tipologiaSpesa = map['tipologiaSpesa'];
    viaggio = map['viaggio'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'fattura': fattura,
        'importo': importo,
        'luogo': luogo,
        'tipologiaPagamento': tipologiaPagamento,
        'tipologiaSpesa': tipologiaSpesa,
        'viaggio': viaggio
      };

  factory SpesaModel.fromJson(Map<String, dynamic> json) {
    return SpesaModel(
        json['id']?.toString(),
        json['data'],
        json['fattura'],
        json['importo'].float.parse(),
        json['luogo']?.toString(),
        TipologiaPagamentoModel.fromJson(json),
        TipologiaSpesaModel.fromJson(json),
        ViaggioModel.fromJson(json));
  }
}
