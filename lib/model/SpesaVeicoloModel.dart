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

  SpesaVeicoloModel(
      this.idSpesaVeicolo,
      this.data,
      this.km,
      this.importo,
      this.fornitore_carburante,
      this.tipologia_spesa,
      this.veicolo,
      this.utente
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
      'utente' : utente?.toMap()
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
  };

  factory SpesaVeicoloModel.fromJson(Map<String, dynamic> json){
    return SpesaVeicoloModel(
      json['idSpesaVeicolo'].toString(),
      json['data'] != null ? DateTime.parse(json['data']) : null,
      json['km'].toString(),
      json['importo'].toString(),
      json['fornitore_carburante'].toString(),
      json['tipologia_spesa'] != null ? TipologiaSpesaVeicoloModel.fromJson(json['tipologia_spesa']) : null,
      json['veicolo'] != null ? VeicoloModel.fromJson(json['veicolo']) : null,
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
    );
  }
}