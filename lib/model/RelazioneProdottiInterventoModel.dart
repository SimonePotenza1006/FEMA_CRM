import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/ProdottoModel.dart';

class RelazioneProdottiInterventoModel{
  int? id;
  ProdottoModel? prodotto;
  DDTModel? ddt;
  InterventoModel? intervento;
  double? quantita;

  RelazioneProdottiInterventoModel({
    this.id,
    this.prodotto,
    this.ddt,
    this.intervento,
    this.quantita
  });

  Map<String, dynamic> toMap(){
    return{
      'id' : id,
      'prodotto' : prodotto?.toMap(),
      'ddt': ddt?.toMap(),
      'intervento' : intervento?.toMap(),
      'quantita' : quantita
    };
  }

  factory RelazioneProdottiInterventoModel.fromMap(Map<String, dynamic> map){
    return RelazioneProdottiInterventoModel(
      id: map['id'],
      prodotto: ProdottoModel.fromMap(map['prodotto']),
      ddt: DDTModel.fromMap(map['ddt']),
      intervento: InterventoModel.fromMap(map['intervento']),
      quantita: map['quantita'],
    );
  }

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'prodotto' : prodotto?.toJson(),
    'ddt' : ddt?.toJson(),
    'intervento' : intervento?.toJson(),
    'quantita' : quantita
  };

  factory RelazioneProdottiInterventoModel.fromJson(Map<String, dynamic> json){
    return RelazioneProdottiInterventoModel(
      id : json['id'],
      prodotto: ProdottoModel.fromJson(json['prodotto']),
      ddt : DDTModel.fromJson(json['ddt']),
      intervento: InterventoModel.fromJson(json['intervento']),
      quantita: json['quantita']
    );
  }
}