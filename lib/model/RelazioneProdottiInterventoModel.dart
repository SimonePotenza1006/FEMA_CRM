import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/ProdottoModel.dart';

class RelazioneProdottiInterventoModel{
  int? id;
  ProdottoModel? prodotto;
  DDTModel? ddt;
  InterventoModel? intervento;
  double? quantita;
  bool? presenza_storico_utente;
  String? seriale;

  RelazioneProdottiInterventoModel(
    this.id,
    this.prodotto,
    this.ddt,
    this.intervento,
    this.quantita,
    this.presenza_storico_utente,
    this.seriale
  );

  Map<String, dynamic> toMap(){
    return{
      'id' : id,
      'prodotto' : prodotto?.toMap(),
      'ddt': ddt?.toMap(),
      'intervento' : intervento?.toMap(),
      'quantita' : quantita,
      'presenza_storico_utente' : presenza_storico_utente,
      'seriale' : seriale
    };
  }

  RelazioneProdottiInterventoModel.fromMap(Map<String, dynamic> map){
      id = map['id'];
      map['prodotto'] != null ? ProdottoModel.fromMap(map['prodotto']) : null;
      map['ddt'] != null ? DDTModel.fromMap(map['ddt']) : null;
      map['intervento'] != null ? InterventoModel.fromMap(map['intervento']) : null;
      quantita = map['quantita'];
      presenza_storico_utente = map['presenza_storico_utente'];
      seriale = map['seriale'];
  }

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'prodotto' : prodotto?.toJson(),
    'ddt' : ddt?.toJson(),
    'intervento' : intervento?.toJson(),
    'quantita' : quantita,
    'presenza_storico_utente' : presenza_storico_utente,
    'seriale' : seriale
  };

  factory RelazioneProdottiInterventoModel.fromJson(Map<String, dynamic> json){
    return RelazioneProdottiInterventoModel(
      json['id'],
      json['prodotto'] != null ? ProdottoModel.fromJson(json['prodotto']) : null,
      json['ddt'] != null ? DDTModel.fromJson(json['ddt']) : null,
      json['intervento'] != null ? InterventoModel.fromJson(json['intervento']) : null,
      json['quantita'] is double ? json['quantita'] : (json['quantita'] != null ? double.tryParse(json['quantita'].toString()) : null),
      json['presenza_storico_utente'],
      json['seriale']
    );
  }
}