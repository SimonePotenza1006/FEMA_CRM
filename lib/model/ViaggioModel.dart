
import 'AttivitaModel.dart';
import 'AttrezzaturaModel.dart';
import 'CartaDiCreditoModel.dart';
import 'UtenteModel.dart';

class ViaggioModel {
  String? id;
  String? destinazione;
  DateTime? data_arrivo;
  DateTime? data_partenza;
  AttivitaModel? attivita;

  ViaggioModel(this.id, this.destinazione, this.data_arrivo, this.data_partenza,
      this.attivita);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'destinazione': destinazione,
      'data_arrivo': data_arrivo,
      'data_partenza': data_partenza,
      'attivita': attivita,
    };
    return map;
  }

  ViaggioModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    destinazione = map['destinazione'];
    data_arrivo = map['data_arrivo'];
    data_partenza = map['data_partenza'];
    attivita = map['attivita'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'destinazione': destinazione,
        'data_arrivo': data_arrivo,
        'data_partenza': data_partenza,
        'attivita': attivita,
      };

  factory ViaggioModel.fromJson(Map<String, dynamic> json) {
    return ViaggioModel(
      json['id']?.toString(),
      json['destinazione']?.toString(),
      json['data_arrivo'],
      json['data_partenza'],
      AttivitaModel.fromJson(json),
    );
  }
}
