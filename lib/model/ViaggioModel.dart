
import 'AttivitaModel.dart';
import 'AttrezzaturaModel.dart';
import 'CartaDiCreditoModel.dart';
import 'UtenteModel.dart';

class ViaggioModel {
  String? id;
  String? destinazione;
  DateTime? dataArrivo;
  DateTime? dataPartenza;
  AttivitaModel? attivita;
  List<CartaDiCreditoModel>? carteDiCredito;
  List<AttrezzaturaModel>? attrezzature;
  List<UtenteModel>? utenti;

  ViaggioModel(this.id, this.destinazione, this.dataArrivo, this.dataPartenza,
      this.attivita, this.carteDiCredito, this.attrezzature, this.utenti);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'destinazione': destinazione,
      'dataArrivo': dataArrivo,
      'dataPartenza': dataPartenza,
      'attivita': attivita,
      'carteDiCredito': carteDiCredito,
      'attrezzature': attrezzature,
      'utenti': utenti,
    };
    return map;
  }

  ViaggioModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    destinazione = map['destinazione'];
    dataArrivo = map['dataArrivo'];
    dataPartenza = map['dataPartenza'];
    attivita = map['attivita'];
    carteDiCredito = map['carteDiCredito'];
    attrezzature = map['attrezzature'];
    utenti = map['utenti'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'destinazione': destinazione,
        'dataArrivo': dataArrivo,
        'dataPartenza': dataArrivo,
        'attivita': attivita,
        'carteDiCredito': carteDiCredito,
        'attrezzature': attrezzature,
        'utenti': utenti,
      };

  factory ViaggioModel.fromJson(Map<String, dynamic> json) {
    return ViaggioModel(
      json['id']?.toString(),
      json['destinazione']?.toString(),
      json['dataArrivo'],
      json['dataPartenza'],
      AttivitaModel.fromJson(json),
      json['carteDiCredito']
          ?.map((data) => CartaDiCreditoModel.fromJson(data))
          .toList(),
      json['attrezzature']
          ?.map((data) => AttrezzaturaModel.fromJson(data))
          .toList(),
      json['utenti']?.map((data) => UtenteModel.fromJson(data)).toList(),
    );
  }
}
