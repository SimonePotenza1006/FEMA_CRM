
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:fema_crm/model/ProdottoModel.dart';
import 'package:intl/intl.dart';

class RelazioneClientiProdottiModel{
  int? id;
  ProdottoModel? prodotto;
  ClienteModel? cliente;
  double? prezzo;
  DateTime? data;

  RelazioneClientiProdottiModel({
   this.id,
   this.prodotto,
   this.cliente,
   this.prezzo,
   this.data
  });

  Map<String, dynamic> toMap(){
    return{
      'id' : id,
      'prodotto' : prodotto?.toMap(),
      'cliente' : cliente?.toMap(),
      'prezzo' : prezzo,
      'data' : data
    };
  }

  factory RelazioneClientiProdottiModel.fromMap(Map<String, dynamic> map){
    return RelazioneClientiProdottiModel(
      id: map['id'],
      prodotto: ProdottoModel.fromMap(map['prodotto']),
      cliente: ClienteModel.fromMap(map['cliente']),
      prezzo: map['prezzo'],
      data: map['data']
    );
  }

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'prodotto' : prodotto?.toJson(),
    'cliente' : cliente?.toJson(),
    'prezzo' : prezzo,
    'data' : data != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data!) : null,
  };

  factory RelazioneClientiProdottiModel.fromJson(Map<String, dynamic> json) {
    return RelazioneClientiProdottiModel(
      id: json['id'],
      prodotto: json['prodotto'] != null
          ? ProdottoModel.fromJson(json['prodotto'])
          : null,
      cliente: json['cliente'] != null
          ? ClienteModel.fromJson(json['cliente'])
          : null,
      prezzo: (json['prezzo'] != null)
          ? json['prezzo'].toDouble()
          : null,
      data: json['data'] != null
          ? DateFormat("yyyy-MM-ddTHH:mm:ss").parse(json['data'])
          : null,
    );
  }
}
