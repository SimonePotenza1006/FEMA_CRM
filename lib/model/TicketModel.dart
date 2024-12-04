import 'package:fema_crm/model/TipologiaInterventoModel.dart';

import 'ClienteModel.dart';
import 'DestinazioneModel.dart';
import 'InterventoModel.dart';
import 'UtenteModel.dart';

class TicketModel {
  String? id;
  DateTime? data_creazione;
  // DateTime? data;
  // DateTime? orario_appuntamento;
  // String? titolo;
  // Priorita? priorita;
  String? descrizione;
  String? note;
  bool? convertito;
  // ClienteModel? cliente;
  // DestinazioneModel? destinazione;
  //TipologiaInterventoModel? tipologia;
  UtenteModel? utente;

  TicketModel(
      this.id,
      this.data_creazione,
      // this.data,
      // this.orario_appuntamento,
      // this.titolo,
      // this.priorita,
      this.descrizione,
      this.note,
      this.convertito,
      // this.cliente,
      // this.destinazione,
      //this.tipologia,
      this.utente
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id' : id,
      'data_creazione' : data_creazione?.toIso8601String(),
      // 'data' : data?.toIso8601String(),
      // 'orario_appuntamento' : orario_appuntamento?.toIso8601String(),
      // 'titolo' : titolo,
      // 'priorita' : priorita.toString().split('.').last,
      'descrizione' : descrizione,
      'note' : note,
      'convertito' : convertito,
      // 'cliente' : cliente?.toMap(),
      // 'destinazione' : destinazione?.toMap(),
      //'tipologia' : tipologia?.toMap(),
      'utente' : utente?.toMap()
    };
    return map;
  }

  TicketModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    map['data_creazione'] != null ? DateTime.parse(map['data_creazione']) : null;
    // map['data'] != null ? DateTime.parse(map['data']) : null;
    // map['orario_appuntamento'] != null ? DateTime.parse(map['orario_appuntamento']) : null;
    // titolo = map['titolo'];
    // priorita = Priorita.values.firstWhere(
    //         (type) => type.toString() == 'priorita.${map['priorita']}');
    descrizione = map['descrizione'];
    note = map['note'];
    convertito = map['convertito'];
    // cliente = map['cliente'] != null ? ClienteModel.fromMap(map['cliente']) : null;
    // destinazione = map['destinazione'] != null ? DestinazioneModel.fromMap(map['destinazione']) : null;
    //tipologia = map['tipologia'] != null ? TipologiaInterventoModel.fromMap(map['tipologia']) : null;
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
  }

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'data_creazione' : data_creazione?.toIso8601String(),
    // 'data' : data?.toIso8601String(),
    // 'orario_appuntamento' : orario_appuntamento?.toIso8601String(),
    // 'titolo' : titolo,
    // 'priorita' : priorita.toString().split('.').last,
    'descrizione' : descrizione,
    'note' : note,
    'convertito' : convertito,
    // 'cliente' : cliente?.toMap(),
    // 'destinazione' : destinazione?.toMap(),
    //'tipologia' : tipologia?.toMap(),
    'utente' : utente?.toMap()
  };

  factory TicketModel.fromJson(Map<String, dynamic> json){
    return TicketModel(
      json['id']?.toString(),
      json['data_creazione'] != null ? DateTime.parse(json['data_creazione']) : null,
      // json['data'] != null ? DateTime.parse(json['data']) : null,
      // json['orario_appuntamento'] != null ? DateTime.parse(json['orario_appuntamento']) : null,
      // json['titolo'],
      // _getPrioritaFromString(json['priorita']),
      json['descrizione'],
      json['note'],
      json['convertito'],
      // json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
      // json['destinazione'] != null ? DestinazioneModel.fromJson(json['destinazione']) : null,
      //json['tipologia'] != null ? TipologiaInterventoModel.fromJson(json['tipologia']) : null,
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
    );
  }
}