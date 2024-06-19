import 'ProdottoModel.dart';
import 'PreventivoModel.dart';

class RelazionePreventivoProdottiModel {
  int? id;
  ProdottoModel? prodotto;
  PreventivoModel? preventivo;
  double? quantita;
  double? prezzo;

  RelazionePreventivoProdottiModel({
   this.id,
   this.prodotto,
   this.preventivo,
   this.quantita,
    this.prezzo
});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prodotto': prodotto?.toMap(),
      'preventivo': preventivo?.toMap(),
      'quantita' : quantita,
      'prezzo' : prezzo
    };
  }

  factory RelazionePreventivoProdottiModel.fromMap(Map<String, dynamic> map) {
    return RelazionePreventivoProdottiModel(
      id: map['id'],
      prodotto: ProdottoModel.fromMap(map['prodotto']),
      preventivo: PreventivoModel.fromMap(map['preventivo']),
      quantita: map['quantita'],
      prezzo: map['prezzo']
    );
  }

  Map<String, dynamic> toJson() =>{
    'id': id,
    'prodotto': prodotto?.toJson(),
    'preventivo' : preventivo?.toJson(),
    'quantita': quantita,
    'prezzo' : prezzo,
  };

  factory RelazionePreventivoProdottiModel.fromJson(Map<String, dynamic> json) {
    return RelazionePreventivoProdottiModel(
      id: json['id'],
      prodotto: ProdottoModel.fromJson(json['prodotto']),
      preventivo: PreventivoModel.fromJson(json['preventivo']),
      quantita: json['quantita'],
      prezzo: json['prezzo']
    );
  }
}