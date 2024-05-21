import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/ProdottoModel.dart';
import 'package:intl/intl.dart';
import 'UtenteModel.dart';

class RelazioneUtentiProdottiModel{
  String? id;
  DateTime? data_creazione;
  ProdottoModel? prodotto;
  double? quantita;
  String? materiale;
  UtenteModel? utente;
  DDTModel? ddt;
  InterventoModel? intervento;
  bool? assegnato;

  RelazioneUtentiProdottiModel(
    this.id,
    this.data_creazione,
    this.prodotto,
    this.quantita,
    this.materiale,
    this.utente,
    this.ddt,
    this.intervento,
    this.assegnato
  );

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'data_creazione': data_creazione,
      'prodotto': prodotto?.toMap(),
      'quantita' : quantita,
      'materiale' : materiale,
      'utente' : utente?.toMap(),
      'ddt' : ddt?.toMap(),
      'intervento' : intervento?.toMap(),
      'assegnato' : assegnato
    };
  }

  RelazioneUtentiProdottiModel.fromMap(Map<String, dynamic> map){
      id = map['id'];
      map['data_creazione'] != null ? DateTime.parse(map['data_creazione']) : null;
      prodotto = map['prodotto'] != null ? ProdottoModel.fromMap(map['prodotto']) : null;
      quantita = map['quantita'];
      materiale = map['materiale'];
      utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
      ddt = map['ddt'] != null ? DDTModel.fromMap(map['ddt']) : null;
      intervento = map['intervento'] != null ? InterventoModel.fromMap(map['intervento']) : null;
      assegnato = map['assegnato'];
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'data_creazione': data_creazione != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data_creazione!) : null,
    'prodotto' : prodotto?.toJson(),
    'quantita' : quantita,
    'materiale' : materiale.toString(),
    'utente' : utente?.toJson(),
    'ddt' : ddt?.toJson(),
    'intervento' : intervento?.toJson(),
    'assegnato' : assegnato,
  };

  factory RelazioneUtentiProdottiModel.fromJson(Map<String, dynamic> json){
    return RelazioneUtentiProdottiModel(
      json['id']?.toString(),
      json['data_creazione'] != null ? DateTime.parse(json['data_creazione']) : null,
      json['prodotto'] != null ? ProdottoModel.fromJson(json['prodotto']) : null,
      json['quantita'] != null ? json['quantita'].toDouble() : null,
      json['materiale']?.toString(),
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['ddt'] != null ? DDTModel.fromJson(json['ddt']) : null,
      json['intervento'] != null ? InterventoModel.fromJson(json['intervento']) : null,
      json['assegnato'],
    );
  }
}