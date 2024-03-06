import 'DDTModel.dart';
import 'ProdottoModel.dart';

class RelazioneDdtProdottoModel {
  int? id;
  ProdottoModel? prodotto;
  DDTModel? ddt;
  int? quantita;
  bool? assegnato;
  bool? scaricato;
  bool? pendente;

  RelazioneDdtProdottoModel({
    this.id,
    this.prodotto,
    this.ddt,
    this.quantita,
    this.assegnato,
    this.scaricato,
    this.pendente,
  });

  Map<String, dynamic> toMap() {
    return {
      'idrelazione_ddt_prodotti': id,
      'prodotto': prodotto?.toMap(),
      'ddt': ddt?.toMap(),
      'quantita': quantita,
      'assegnato': assegnato,
      'scaricato': scaricato,
      'pendente': pendente,
    };
  }

  factory RelazioneDdtProdottoModel.fromMap(Map<String, dynamic> map) {
    return RelazioneDdtProdottoModel(
      id: map['idrelazione_ddt_prodotti'],
      prodotto: ProdottoModel.fromMap(map['prodotto']),
      ddt: DDTModel.fromMap(map['ddt']),
      quantita: map['quantita'],
      assegnato: map['assegnato'],
      scaricato: map['scaricato'],
      pendente: map['pendente'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idrelazione_ddt_prodotti': id,
    'prodotto': prodotto?.toJson(),
    'ddt': ddt?.toJson(),
    'quantita': quantita,
    'assegnato': assegnato,
    'scaricato': scaricato,
    'pendente': pendente,
  };

  factory RelazioneDdtProdottoModel.fromJson(Map<String, dynamic> json) {
    return RelazioneDdtProdottoModel(
      id: json['idrelazione_ddt_prodotti'],
      prodotto: ProdottoModel.fromJson(json['prodotto']),
      ddt: DDTModel.fromJson(json['ddt']),
      quantita: json['quantita'],
      assegnato: json['assegnato'],
      scaricato: json['scaricato'],
      pendente: json['pendente'],
    );
  }
}
