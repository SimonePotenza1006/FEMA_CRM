
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:fema_crm/model/DestinazioneModel.dart';
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:fema_crm/model/SopralluogoModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';

class NotaTecnicoModel{
  String? id;
  UtenteModel? utente;
  DateTime? data;
  String? nota;
  InterventoModel? intervento;
  ClienteModel? cliente;
  DestinazioneModel? destinazione;
  SopralluogoModel? sopralluogo;
  MerceInRiparazioneModel? merce;

  NotaTecnicoModel(
      this.id,
      this.utente,
      this.data,
      this.nota,
      this.intervento,
      this.cliente,
      this.destinazione,
      this.sopralluogo,
      this.merce
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id': id,
      'utente' : utente?.toMap(),
      'data' : data?.toIso8601String(),
      'nota': nota,
      'intervento' : intervento?.toMap(),
      'cliente' : cliente?.toMap(),
      'destinazione' : destinazione?.toMap(),
      'sopralluogo' : sopralluogo?.toMap(),
      'merce' : merce?.toMap()
    };
    return map;
  }

  NotaTecnicoModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    map['data'] != null ? DateTime.parse(map['data']) : null;
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    nota = map['nota'];
    intervento = map['intervento'] != null ? InterventoModel.fromMap(map['intervento']) : null;
    cliente = map['cliente'] != null ? ClienteModel.fromMap(map['cliente']) : null;
    destinazione = map['destinazione'] != null ? DestinazioneModel.fromMap(map['destinazione']) : null;
    sopralluogo = map['sopralluogo'] != null ? SopralluogoModel.fromMap(map['sopralluogo']) : null;
    merce = map['merce'] != null ? MerceInRiparazioneModel.fromMap(map['merce']) : null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data?.toIso8601String(),
    'utente' : utente?.toJson(),
    'nota' : nota,
    'intervento' : intervento?.toJson(),
    'cliente': cliente?.toJson(),
    'destinazione' : destinazione?.toJson(),
    'sopralluogo': sopralluogo?.toJson(),
    'merce' : merce?.toJson(),
  };

  factory NotaTecnicoModel.fromJson(Map<String, dynamic> json) {
    return NotaTecnicoModel(
      json['id']?.toString(),
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['data'] != null ? DateTime.parse(json['data']) : null,
      json['nota']?.toString(),
      json['intervento'] != null ? InterventoModel.fromJson(json['intervento']) : null,
      json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
      json['destinazione'] != null ? DestinazioneModel.fromJson(json['destinazione']) : null,
      json['sopralluogo'] != null ? SopralluogoModel.fromJson(json['sopralluogo']) : null,
      json['merce'] != null ? MerceInRiparazioneModel.fromJson(json['merce']) : null,
    );
  }
}