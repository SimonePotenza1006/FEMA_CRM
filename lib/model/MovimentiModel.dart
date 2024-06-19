import 'dart:io';

import 'package:fema_crm/model/UtenteModel.dart';
import 'package:intl/intl.dart';

class MovimentiModel {
  String? id;
  DateTime? data;
  DateTime? dataCreazione;
  String? descrizione;
  TipoMovimentazione? tipo_movimentazione;
  double? importo;
  UtenteModel? utente;

  MovimentiModel(
    this.id,
    this.data,
    this.dataCreazione,
    this.descrizione,
    this.tipo_movimentazione,
    this.importo,
    this.utente,
  );

  MovimentiModel.fromMap(Map<String, dynamic> map) {
    id = map['id'].toString();
    data = map['data'] != null ? DateTime.parse(map['data']) : null;
    dataCreazione = map['dataCreazione'] != null ? DateTime.parse(map['dataCreazione']) : null;
    descrizione = map['descrizione'].toString();
    tipo_movimentazione = TipoMovimentazione.values.firstWhere(
            (type) => type.toString() == 'tipo_movimentazione.${map['tipo_movimentazione']}');
    importo = map['importo'];
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'id': id,
      'data': data != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data!) : null,
      'dataCreazione': dataCreazione != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(dataCreazione!) : null,
      'descrizione': descrizione.toString(),
      'tipo_movimentazione': tipo_movimentazione.toString(),
      'importo': importo,
      'utente': utente?.toMap(),
    };
    return map;
  }

  Map<String, dynamic> toJson() => {
      'id': id,
      'data': data != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(data!) : null,
      'dataCreazione' : dataCreazione != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(dataCreazione!) : null,
      'descrizione': descrizione.toString(),
      'tipo_movimentazione': tipo_movimentazione.toString().split('.').last, // Convert enum to string
      'importo': importo,
      'utente': utente?.toJson(),
  };



  factory MovimentiModel.fromJson(Map<String, dynamic> json) {
    return MovimentiModel(
      json['id']?.toString(),
      json['data'] != null ? DateTime.parse(json['data']) : null,
      json['dataCreazione'] != null ? DateTime.parse(json['dataCreazione']) : null,
      json['descrizione']?.toString(),
        _getTipoMovimentazioneFromString(json['tipo_movimentazione']),
      json['importo'] != null ? double.parse(json['importo'].toString()) : null,
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
    );
  }

  static TipoMovimentazione _getTipoMovimentazioneFromString(String? tipoMovimentazione) {
    print(tipoMovimentazione);
    if (tipoMovimentazione == 'Entrata') {
      return TipoMovimentazione.Entrata;
    } else if (tipoMovimentazione == 'Uscita') {
      return TipoMovimentazione.Uscita;
    } else if (tipoMovimentazione == 'Pagamento') {
      return TipoMovimentazione.Pagamento;
    } else if (tipoMovimentazione == 'Acconto') {
      return TipoMovimentazione.Acconto;
    } else if (tipoMovimentazione == 'Prelievo'){
      return TipoMovimentazione.Prelievo;
    } else {
      throw Exception('Valore non valido per TipoMovimentazione: $tipoMovimentazione');
    }
  }

}


enum TipoMovimentazione {
  Entrata,
  Uscita,
  Acconto,
  Pagamento,
  Prelievo
}
