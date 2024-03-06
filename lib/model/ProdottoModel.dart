import 'dart:io';
import 'CategoriaProdottoModel.dart';
import 'FornitoreModel.dart';
import 'PreventivoModel.dart';
import 'RelazioneDdtProdottiModel.dart';
import 'SopralluogoModel.dart';


class ProdottoModel {
  String? id;
  String? codice_danea;
  String? descrizione;
  String? tipologia;
  String? categoria;
  String? sottocategoria;
  String? unita_misura;
  String? iva;
  String? note;
  String? cod_barre_danea;
  String? produttore;
  String? cod_fornitore;
  String? fornitore;
  String? cod_prod_forn;
  double? prezzo_fornitore;
  String? note_fornitura;
  double? qta_giacenza;
  double? qta_impegnata;
  double? costo_medio_acquisto;
  double? ultimo_costo_acquisto;
  double? prezzo_medio_vendita;
  String? stato_magazzino;
  String? lotto_seriale;
  List<PreventivoModel>? preventivi;
  List<SopralluogoModel>? sopralluoghi;
  List<RelazioneDdtProdottoModel>? relazioni_ddt;

  ProdottoModel(
    this.id,
    this.codice_danea,
    this.descrizione,
    this.tipologia,
    this.categoria,
    this.sottocategoria,
    this.unita_misura,
    this.iva,
    this.note,
    this.cod_barre_danea,
    this.produttore,
    this.cod_fornitore,
    this.fornitore,
    this.cod_prod_forn,
    this.prezzo_fornitore,
    this.note_fornitura,
    this.qta_giacenza,
    this.qta_impegnata,
    this.costo_medio_acquisto,
    this.ultimo_costo_acquisto,
    this.prezzo_medio_vendita,
    this.stato_magazzino,
    this.lotto_seriale,
    this.preventivi,
    this.sopralluoghi,
    this.relazioni_ddt
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'codice_danea': codice_danea,
      'descrizione': descrizione,
      'tipologia' : tipologia,
      'categoria': categoria,
      'sottocategoria' : sottocategoria,
      'unita_misura': unita_misura,
      'iva': iva,
      'note': note,
      'cod_barre_danea': cod_barre_danea,
      'produttore': produttore,
      'cod_fornitore': cod_fornitore,
      'fornitore': fornitore,
      'cod_prod_forn': cod_prod_forn,
      'prezzo_fornitore': prezzo_fornitore,
      'note_fornitura': note_fornitura,
      'qta_giacenza': qta_giacenza,
      'qta_impegnata': qta_impegnata,
      'costo_medio_acquisto': costo_medio_acquisto,
      'ultimo_costo_acquisto': ultimo_costo_acquisto,
      'prezzo_medio_vendita': prezzo_medio_vendita,
      'stato_magazzino' : stato_magazzino,
      'lotto_seriale': lotto_seriale,
      'preventivi': preventivi?.map((e) => e.toMap()).toList(),
      'sopralluoghi': sopralluoghi?.map((e) => e.toMap()).toList(),
      'relazioni_ddt': relazioni_ddt?.map((e) => e.toMap()).toList()
    };
    return map;
  }

  ProdottoModel.fromMap(Map<String, dynamic> map) {
      id = map['id'];
      codice_danea = map['codice_danea'];
      descrizione = map['descrizione'];
      tipologia = map['tipologia'];
      categoria = map['categoria'];
      sottocategoria = map['sottocategoria'];
      unita_misura = map['unita_misura'];
      iva = map['iva'];
      note = map['note'];
      cod_barre_danea = map['cod_barre_danea'];
      produttore = map['produttore'];
      cod_fornitore = map['cod_fornitore'];
      fornitore = map['fornitore'];
      cod_prod_forn = map['cod_prod_forn'];
      prezzo_fornitore = map['prezzo_fornitore'];
      note_fornitura = map['note_fornitura'];
      qta_giacenza = map['qta_giacenza'];
      qta_impegnata = map['qta_giacenza'];
      costo_medio_acquisto = map['costo_medio_acquisto'];
      ultimo_costo_acquisto = map['ultimo_costo_acquisto'];
      prezzo_medio_vendita = map['prezzo_medio_vendita'];
      stato_magazzino = map['stato_magazzino'];
      lotto_seriale = map['lotto_seriale'];
      preventivi = (map['preventivi'] as List<dynamic>?)
          ?.map((e) => PreventivoModel.fromMap(e))
          .toList();
      sopralluoghi = (map['sopralluoghi'] as List<dynamic>?)
          ?.map((e) => SopralluogoModel.fromMap(e))
          .toList();
      relazioni_ddt = (map['relazioni_ddt'] as List<dynamic>?)
          ?.map((e) => RelazioneDdtProdottoModel.fromMap(e))
          .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codice_danea': codice_danea,
      'descrizione': descrizione,
      'tipologia': tipologia,
      'categoria': categoria,
      'sottocategoria': sottocategoria,
      'unita_misura': unita_misura,
      'iva': iva,
      'note': note,
      'cod_barre_danea': cod_barre_danea,
      'produttore': produttore,
      'cod_fornitore': cod_fornitore,
      'fornitore': fornitore,
      'cod_prod_forn': cod_prod_forn,
      'prezzo_fornitore': prezzo_fornitore,
      'note_fornitura': note_fornitura,
      'qta_giacenza': qta_giacenza,
      'qta_impegnata': qta_impegnata,
      'costo_medio_acquisto' : costo_medio_acquisto,
      'ultimo_costo_acquisto': ultimo_costo_acquisto,
      'prezzo_medio_vendita': prezzo_medio_vendita,
      'stato_magazzino': stato_magazzino,
      'lotto_seriale': lotto_seriale,
      'preventivi': preventivi?.map((e) => e.toJson()).toList(),
      'sopralluoghi': sopralluoghi?.map((e) => e.toJson()).toList(),
      'relazioniDdt': relazioni_ddt?.map((e) => e.toJson()).toList(),
    };
  }

  factory ProdottoModel.fromJson(Map<String, dynamic> json) {
    return ProdottoModel(
      json['id'].toString(),
      json['codice_danea'],
      json['descrizione'],
      json['tipologia'],
      json['categoria'],
      json['sottocategoria'],
      json['unita_misura'],
      json['iva'],
      json['note'],
      json['cod_barre_danea'],
      json['produttore'],
      json['cod_fornitore'],
      json['fornitore'],
      json['cod_prod_forn'],
      json['prezzo_fornitore'],
      json['note_fornitura'],
      json['qta_giacenza'],
      json['qta_impegnata'],
      json['costo_medio_acquisto'],
      json['ultimo_costo_acquisto'],
      json['prezzo_medio_vendita'],
      json['stato_magazzino'],
      json['lotto_seriale'],
      json['preventivi'] != null ? (json['preventivi'] as List<dynamic>?)
          ?.map((e) => PreventivoModel.fromJson(e))
          .toList() : null,
      json['sopralluoghi'] != null ? (json['sopralluoghi'] as List<dynamic>?)
          ?.map((e) => SopralluogoModel.fromJson(e))
          .toList() : null,
      json['relazioniDdt'] != null ? (json['relazioniDdt'] as List<dynamic>?)
          ?.map((e) => RelazioneDdtProdottoModel.fromJson(e))
          .toList() : null,
    );
  }
}
