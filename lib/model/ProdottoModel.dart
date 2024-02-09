import 'dart:core';
import 'dart:ffi';



import 'CategoriaProdottoModel.dart';
import 'DDTModel.dart';
import 'FornitoreModel.dart';
import 'PreventivoModel.dart';
import 'SopralluogoModel.dart';

class ProdottoModel {
  String? id;
  String? codiceBarre;
  String? descrizione;
  int? giacenza;
  String? unitaMisura;
  Float? prezzoFornitore;
  String? codicePerFornitore;
  Float? costoMedio;
  Float? ultimoCosto;
  CategoriaProdottoModel? categoriaProdotto;
  FornitoreModel? fornitore;
  List<DDTModel>? ddt;
  List<PreventivoModel>? preventivi;
  List<SopralluogoModel>? sopralluoghi;

  ProdottoModel(
      this.id,
      this.codiceBarre,
      this.descrizione,
      this.giacenza,
      this.unitaMisura,
      this.prezzoFornitore,
      this.codicePerFornitore,
      this.costoMedio,
      this.ultimoCosto,
      this.categoriaProdotto,
      this.fornitore,
      this.ddt,
      this.preventivi,
      this.sopralluoghi);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'codiceBarre': codiceBarre,
      'descrizione': descrizione,
      'giacenza': giacenza,
      'unitaMisura': unitaMisura,
      'prezzoFornitore': prezzoFornitore,
      'codicePerFornitore': codicePerFornitore,
      'costoMedio': costoMedio,
      'ultimoCosto': ultimoCosto,
      'categoriaProdotto': categoriaProdotto,
      'fornitore': fornitore,
      'ddt': ddt,
      'preventivi': preventivi,
      'sopralluoghi': sopralluoghi
    };
    return map;
  }

  ProdottoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    codiceBarre = map['codiceBarre'];
    descrizione = map['descrizione'];
    giacenza = map['giacenza'];
    unitaMisura = map['unitaMisura'];
    prezzoFornitore = map['prezzoFornitore'];
    codicePerFornitore = map['codicePerFornitore'];
    costoMedio = map['costoMedio'];
    ultimoCosto = map['ultimoCosto'];
    categoriaProdotto = map['categoriaProdotto'];
    fornitore = map['fornitore'];
    ddt = map['ddt'];
    preventivi = map['preventivi'];
    sopralluoghi = map['sopralluoghi'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'codiceBarre': codiceBarre,
        'descrizione': descrizione,
        'giacenza': giacenza,
        'unitaMisura': unitaMisura,
        'prezzoFornitore': prezzoFornitore,
        'codicePerFornitore': codicePerFornitore,
        'costoMedio': costoMedio,
        'ultimoCosto': ultimoCosto,
        'categoriaProdotto': categoriaProdotto,
        'fornitore': fornitore,
        'ddt': ddt,
        'preventivi': preventivi,
        'sopralluoghi': sopralluoghi,
      };

  factory ProdottoModel.fromJson(Map<String, dynamic> json) {
    return ProdottoModel(
        json['id']?.toString(),
        json['codiceBarre']?.toString(),
        json['descrizione']?.toString(),
        json['giacenza'].int.parse(),
        json['unitaMisura']?.toString(),
        json['prezzoFornitore'].float.parse(),
        json['codicePerFornitore']?.toString(),
        json['costoMedio'].float.parse(),
        json['ultimoCosto'].float.parse(),
        CategoriaProdottoModel.fromJson(json),
        FornitoreModel.fromJson(json),
        json['ddt']?.map((data) => DDTModel.fromJson(data)).toList(),
        json['preventivi']
            ?.map((data) => PreventivoModel.fromJson(data))
            .toList(),
        json['sopralluoghi']
            ?.map((data) => SopralluogoModel.fromJson(data))
            .toList());
  }
}
