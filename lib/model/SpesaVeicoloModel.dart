import 'package:fema_crm/model/TipologiaSpesaVeicoloModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:fema_crm/model/VeicoloModel.dart';

class SpesaVeicoloModel {
  String? idSpesaVeicolo;
  DateTime? data;
  String? km;
  String? importo;
  String? fornitore_carburante;
  TipologiaSpesaVeicoloModel? tipologia_spesa;
  VeicoloModel? veicolo;
  UtenteModel? utente;
  String? note_tipologia_spesa;
  String? note_fornitore;

  SpesaVeicoloModel(
      this.idSpesaVeicolo,
      this.data,
      this.km,
      this.importo,
      this.fornitore_carburante,
      this.tipologia_spesa,
      this.veicolo,
      this.utente,
      this.note_tipologia_spesa,
      this.note_fornitore
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'idSpesaVeicolo' : idSpesaVeicolo,
      'data' : data,
      'km' : km,
      'importo' : importo,
      'fornitore_carburante' : fornitore_carburante,
      'tipologia_spesa': tipologia_spesa?.toMap(),
      'veicolo' : veicolo?.toMap(),
      'utente' : utente?.toMap(),
      'note_tipologia_spesa' : note_tipologia_spesa,
      'note_fornitore' : note_fornitore,
    };
    return map;
  }

  SpesaVeicoloModel.fromMap(Map<String, dynamic> map) {
    idSpesaVeicolo = map['idSpesaVeicolo'];
    map['data'] != null? DateTime.parse(map['data']) : null;
    km = map['km'];
    importo = map['importo'];
    fornitore_carburante = map['fornitore_carburante'];
    tipologia_spesa = map['tipologia_spesa'] != null ? TipologiaSpesaVeicoloModel.fromMap(map['tipologia_spesa']) : null;
    veicolo = map['veicolo'] != null ? VeicoloModel.fromMap(map['veicolo']) : null;
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    note_tipologia_spesa = map['note_tipologia_spesa'];
    note_fornitore = map['note_fornitore'];
  }

  Map<String, dynamic> toJson() => {
    'idSpesaVeicolo': idSpesaVeicolo,
    'data': data?.toIso8601String(),
    'km' : km,
    'importo' : importo,
    'fornitore_carburante' : fornitore_carburante,
    'tipologia_spesa' : tipologia_spesa?.toJson(),
    'veicolo': veicolo?.toJson(),
    'utente': utente?.toJson(),
    'note_tipologia_spesa' : note_tipologia_spesa,
    'note_fornitore' : note_fornitore
  };

  factory SpesaVeicoloModel.fromJson(Map<String, dynamic> json){
    return SpesaVeicoloModel(
      json['idSpesaVeicolo'].toString(),
      json['data'] != null ? DateTime.parse(json['data']) : null,
      json['km'].toString(),
      json['importo'].toString(),
      json['fornitore_carburante'],
      json['tipologia_spesa'] != null ? TipologiaSpesaVeicoloModel.fromJson(json['tipologia_spesa']) : null,
      json['veicolo'] != null ? VeicoloModel.fromJson(json['veicolo']) : null,
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['note_tipologia_spesa'],
      json['note_fornitore'],
    );
  }
}