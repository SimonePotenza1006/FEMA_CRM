import 'dart:ffi';

import 'package:fema_crm/model/CategoriaPrezzoListinoModel.dart';
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:fema_crm/model/ProdottoModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';

class PreventivoModel {
  String? id;
  String? descrizione;
  Float? importo;
  ClienteModel? cliente;
  UtenteModel? utente;
  List<CategoriaPrezzoListinoModel>? listini;
  List<ProdottoModel>? prodotti;

  PreventivoModel(this.id, this.descrizione, this.importo, this.cliente,
      this.utente, this.listini, this.prodotti);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'importo': importo,
      'cliente': cliente,
      'utente': utente,
      'listini': listini,
      'prodotti': prodotti
    };
    return map;
  }

  PreventivoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    importo = map['importo'];
    cliente = map['cliente'];
    utente = map['utente'];
    listini = CategoriaPrezzoListinoModel.fromMap(map)
        as List<CategoriaPrezzoListinoModel>;
    prodotti = ProdottoModel.fromMap(map) as List<ProdottoModel>;
  }

  factory PreventivoModel.fromJson(Map<String, dynamic> json) {
    return PreventivoModel(
      json['id']?.toString(),
      json['descrizione']?.toString(),
      json['importo'].float.parse(),
      ClienteModel.fromJson(json),
      UtenteModel.fromJson(json),
      json['listini']
          ?.map((data) => CategoriaPrezzoListinoModel.fromJson(data))
          .toList(),
      json['prodotti']?.map((data) => ProdottoModel.fromJson(data)).toList(),
    );
  }
}
