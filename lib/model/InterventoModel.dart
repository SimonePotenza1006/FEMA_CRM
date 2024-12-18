import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'CategoriaInterventoSpecificoModel.dart';
import 'ClienteModel.dart';
import 'DestinazioneModel.dart';
import 'GruppoInterventiModel.dart';
import 'TipologiaInterventoModel.dart';
import 'TipologiaPagamento.dart';
import 'UtenteModel.dart';
import 'VeicoloModel.dart';

class InterventoModel {
  String? id;
  bool? attivo;
  bool? visualizzato;
  String? numerazione_danea;
  Priorita? priorita;
  String? titolo;
  DateTime? data_apertura_intervento;
  DateTime? data;
  DateTime? orario_appuntamento;
  String? posizione_gps;
  DateTime? orario_inizio;
  DateTime? orario_fine;
  String? descrizione;
  String? utente_importo;
  double? importo_intervento;
  double? saldo_tecnico;
  bool? prezzo_ivato;
  int? iva;
  double? acconto;
  bool? assegnato;
  bool? accettato_da_tecnico;
  bool? annullato;
  bool? conclusione_parziale;
  bool? concluso;
  bool? saldato;
  bool? saldato_da_tecnico;
  String? note;
  String? relazione_tecnico;
  String? firma_cliente;
  UtenteModel? utente_apertura;
  UtenteModel? utente;
  ClienteModel? cliente;
  VeicoloModel? veicolo;
  MerceInRiparazioneModel? merce;
  TipologiaInterventoModel? tipologia;
  CategoriaInterventoSpecificoModel? categoria_intervento_specifico;
  TipologiaPagamentoModel? tipologia_pagamento;
  DestinazioneModel? destinazione;
  GruppoInterventiModel? gruppo;

  InterventoModel(
      this.id,
      this.attivo,
      this.visualizzato,
      this.numerazione_danea,
      this.priorita,
      this.titolo,
      this.data_apertura_intervento,
      this.data,
      this.orario_appuntamento,
      this.posizione_gps,
      this.orario_inizio,
      this.orario_fine,
      this.descrizione,
      this.utente_importo,
      this.importo_intervento,
      this.saldo_tecnico,
      this.prezzo_ivato,
      this.iva,
      this.acconto,
      this.assegnato,
      this.accettato_da_tecnico,
      this.annullato,
      this.conclusione_parziale,
      this.concluso,
      this.saldato,
      this.saldato_da_tecnico,
      this.note,
      this.relazione_tecnico,
      this.firma_cliente,
      this.utente_apertura,
      this.utente,
      this.cliente,
      this.veicolo,
      this.merce,
      this.tipologia,
      this.categoria_intervento_specifico,
      this.tipologia_pagamento,
      this.destinazione,
      this.gruppo
      );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'attivo' : attivo,
      'visualizzato' : visualizzato,
      'numerazione_danea' : numerazione_danea,
      'priorita' : priorita.toString().split('.').last,
      'titolo' : titolo,
      'data_apertura_intervento': data_apertura_intervento?.toIso8601String(),
      'data': data?.toIso8601String(),
      'orario_appuntamento' : orario_appuntamento?.toIso8601String(),
      'posizione_gps' : posizione_gps,
      'orario_inizio': orario_inizio?.toIso8601String(),
      'orario_fine': orario_fine?.toIso8601String(),
      'descrizione': descrizione,
      'utente_importo' : utente_importo,
      'importo_intervento': importo_intervento,
      'saldo_tecnico' : saldo_tecnico,
      'prezzo_ivato' : prezzo_ivato,
      'iva' : iva,
      'acconto' : acconto,
      'assegnato': assegnato,
      'accettato_da_tecnico' : accettato_da_tecnico,
      'annullato' : annullato,
      'conclusione_parziale' : conclusione_parziale,
      'concluso': concluso,
      'saldato': saldato,
      'saldato_da_tecnico' : saldato_da_tecnico,
      'note': note,
      'relazione_tecnico' : relazione_tecnico,
      'firma_cliente': firma_cliente,
      'utente_apertura' : utente_apertura?.toMap(),
      'utente': utente?.toMap(),
      'cliente': cliente?.toMap(),
      'veicolo': veicolo?.toMap(),
      'merce' : merce?.toMap(),
      'tipologia': tipologia?.toMap(),
      'categoria_intervento_specifico': categoria_intervento_specifico?.toMap(),
      'tipologia_pagamento': tipologia_pagamento?.toMap(),
      'destinazione': destinazione?.toMap(),
      'gruppo' : gruppo?.toMap(),
    };
    return map;
  }



  InterventoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    attivo = map['attivo'];
    visualizzato = map['visualizzato'];
    numerazione_danea = map['numerazione_danea'];
    priorita = Priorita.values.firstWhere(
            (type) => type.toString() == 'priorita.${map['priorita']}');
    titolo = map['titolo'];
    map['data_apertura_intervento'] != null ? DateTime.parse(map['data_apertura_intervento']) : null;
    map['data'] != null ? DateTime.parse(map['data']) : null;
    map['orario_appuntamento'] != null ? DateTime.parse(map['orario_appuntamento']) : null;
    posizione_gps = map['posizione_gps'];
    map['orario_inizio'] != null ? DateTime.parse(map['orario_inizio']) : null;
    map['orario_fine'] != null ? DateTime.parse(map['orario_fine']) : null;
    descrizione = map['descrizione'];
    utente_importo = map['utente_importo'];
    importo_intervento = map['importo_intervento'];
    saldo_tecnico = map['saldo_tecnico'];
    prezzo_ivato = map['prezzo_ivato'];
    iva = map['iva'];
    acconto = map['acconto'];
    assegnato = map['assegnato'];
    accettato_da_tecnico = map['accettato_da_tecnico'];
    annullato = map['annullato'];
    conclusione_parziale = map['conclusione_parziale'];
    concluso = map['concluso'];
    saldato = map['saldato'];
    saldato_da_tecnico = map['saldato_da_tecnico'];
    note = map['note'];
    relazione_tecnico = map['relazione_tecnico'];
    firma_cliente = map['firma_cliente'];
    utente_apertura = map['utente_apertura'] != null ? UtenteModel.fromMap(map['utente_apertura']) : null;
    utente = map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
    cliente = map['cliente'] != null ? ClienteModel.fromMap(map['cliente']) : null;
    veicolo = map['veicolo'] != null ? VeicoloModel.fromMap(map['veicolo']) : null;
    merce = map['merce'] != null ? MerceInRiparazioneModel.fromMap(map['merce']) : null;
    tipologia = map['tipologia'] != null ? TipologiaInterventoModel.fromMap(map['tipologia']) : null;
    categoria_intervento_specifico = map['categoria_intervento_specifico'] != null ? CategoriaInterventoSpecificoModel.fromMap(map['categoria_intervento_specifico']) : null;
    tipologia_pagamento = map['tipologia_pagamento'] != null ? TipologiaPagamentoModel.fromMap(map['tipologia_pagamento']) : null;
    destinazione = map['destinazione'] != null ? DestinazioneModel.fromMap(map['destinazione']) : null;
    gruppo = map['gruppo'] != null ? GruppoInterventiModel.fromMap(map['gruppo']) : null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'attivo' : attivo,
    'visualizzato' : visualizzato,
    'numerazione_danea' : numerazione_danea,
    'priorita' : priorita.toString().split('.').last,
    'titolo' : titolo,
    'data_apertura_intervento' : data_apertura_intervento?.toIso8601String(),
    'data': data?.toIso8601String(),
    'orario_appuntamento' : orario_appuntamento?.toIso8601String(),
    'posizione_gps' : posizione_gps,
    'orario_inizio': orario_inizio?.toIso8601String(),
    'orario_fine': orario_fine?.toIso8601String(),
    'descrizione': descrizione,
    'utente_importo' : utente_importo,
    'importo_intervento': importo_intervento,
    'saldo_tecnico' : saldo_tecnico,
    'prezzo_ivato' : prezzo_ivato,
    'iva' : iva,
    'acconto' : acconto,
    'assegnato': assegnato,
    'accettato_da_tecnico' : accettato_da_tecnico,
    'annullato' : annullato,
    'conclusione_parziale' : conclusione_parziale,
    'concluso': concluso,
    'saldato': saldato,
    'saldato_da_tecnico' : saldato_da_tecnico,
    'note': note,
    'relazione_tecnico' : relazione_tecnico,
    'firma_cliente': firma_cliente,
    'utente_apertura' : utente_apertura?.toJson(),
    'utente': utente?.toJson(),
    'cliente': cliente?.toJson(),
    'veicolo': veicolo?.toJson(),
    'merce' : merce?.toJson(),
    'tipologia': tipologia?.toJson(),
    'categoria_intervento_specifico': categoria_intervento_specifico?.toJson(),
    'tipologia_pagamento': tipologia_pagamento?.toJson(),
    'destinazione': destinazione?.toJson(),
    'gruppo' : gruppo?.toJson()
  };

  factory InterventoModel.fromJson(Map<String, dynamic> json) {
    return InterventoModel(
      json['id']?.toString(),
      json['attivo'],
      json['visualizzato'],
      json['numerazione_danea']?.toString(),
      _getPrioritaFromString(json['priorita']),
      json['titolo'],
      json['data_apertura_intervento'] != null ? DateTime.parse(json['data_apertura_intervento']) : null,
      json['data'] != null ? DateTime.parse(json['data']) : null,
      json['orario_appuntamento'] != null ? DateTime.parse(json['orario_appuntamento']) : null,
      json['posizione_gps'],
      json['orario_inizio'] != null ? DateTime.parse(json['orario_inizio']) : null,
      json['orario_fine'] != null ? DateTime.parse(json['orario_fine']) : null,
      json['descrizione'],
      json['utente_importo'],
      json['importo_intervento'] != null ? double.parse(json['importo_intervento'].toString()) : null,
      json['saldo_tecnico'] != null ? double.parse(json['saldo_tecnico'].toString()) : null,
      json['prezzo_ivato'],
      json['iva'],
      json['acconto'] != null ? double.parse(json['acconto'].toString()) : null,
      json['assegnato'],
      json['accettato_da_tecnico'],
      json['annullato'],
      json['conclusione_parziale'],
      json['concluso'],
      json['saldato'],
      json['saldato_da_tecnico'],
      json['note']?.toString(),
      json['relazione_tecnico']?.toString(),
      json['firma_cliente'],
      json['utente_apertura'] != null ? UtenteModel.fromJson(json['utente_apertura']) : null,
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
      json['veicolo'] != null ? VeicoloModel.fromJson(json['veicolo']) : null,
      json['merce'] != null ? MerceInRiparazioneModel.fromJson(json['merce']) : null,
      json['tipologia'] != null ? TipologiaInterventoModel.fromJson(json['tipologia']) : null,
      json['categoria_intervento_specifico'] != null ? CategoriaInterventoSpecificoModel.fromJson(json['categoria_intervento_specifico']) : null,
      json['tipologia_pagamento'] != null ? TipologiaPagamentoModel.fromJson(json['tipologia_pagamento']) : null,
      json['destinazione'] != null ? DestinazioneModel.fromJson(json['destinazione']) : null,
      json['gruppo'] != null ? GruppoInterventiModel.fromJson(json['gruppo']) : null,
    );
  }

  static Priorita _getPrioritaFromString(String? priorita){
    if(priorita == "BASSA"){
      return Priorita.BASSA;
    } else if(priorita == "MEDIA"){
      return Priorita.MEDIA;
    } else if(priorita == "ALTA"){
      return Priorita.ALTA;
    } else if(priorita == "URGENTE") {
      return Priorita.URGENTE;
    } else if(priorita == "NULLA"){
      return Priorita.NULLA;
    } else {
      throw Exception('Valore non valido per Priorita: $priorita');
    }
  }

  List<InterventoModel> filtraPerUtente(List<InterventoModel> interventi, UtenteModel utente) {
    return interventi.where((intervento) => intervento.utente?.id == utente.id).toList();
  }

  List<InterventoModel> filtraPerCliente(List<InterventoModel> interventi, ClienteModel cliente) {
    return interventi.where((intervento) => intervento.cliente?.id == cliente.id).toList();
  }

  List<InterventoModel> filtraPerTipologia(List<InterventoModel> interventi, TipologiaInterventoModel tipologia) {
    return interventi.where((intervento) => intervento.tipologia?.id == tipologia.id).toList();
  }

  List<InterventoModel> filtraPerData(List<InterventoModel> interventi, DateTime data) {
    return interventi.where((intervento) => intervento.data?.isAtSameMomentAs(data) ?? false).toList();
  }

  List<InterventoModel> filtraPerUtenteEIntervalloDate(List<InterventoModel> interventi, UtenteModel utente, DateTime startDate, DateTime endDate) {
    return interventi.where((intervento) {
      return intervento.utente?.id == utente.id &&
          intervento.data != null &&
          intervento.data!.isAfter(startDate) &&
          intervento.data!.isBefore(endDate);
    }).toList();
  }

  List<InterventoModel> filtraConclusiPerUtenteEIntervalloDate(List<InterventoModel> interventi, UtenteModel utente, DateTime startDate, DateTime endDate) {
    return interventi.where((intervento) {
      return intervento.utente?.id == utente.id &&
          intervento.data != null &&
          intervento.concluso == true &&
          intervento.data!.isAfter(startDate) &&
          intervento.data!.isBefore(endDate);
    }).toList();
  }

  List<InterventoModel> filtraPerUtenteClienteEIntervalloDate(List<InterventoModel> interventi, UtenteModel utente, ClienteModel cliente, DateTime startDate, DateTime endDate) {
    return interventi.where((intervento) {
      return intervento.utente?.id == utente.id &&
          intervento.cliente?.id == cliente.id &&
          intervento.data != null &&
          intervento.data!.isAfter(startDate) &&
          intervento.data!.isBefore(endDate);
    }).toList();
  }

  List<InterventoModel> filtraPerUtenteClienteTipologiaEIntervalloDate(
      List<InterventoModel> interventi,
      UtenteModel utente,
      ClienteModel cliente,
      TipologiaInterventoModel tipologia,
      DateTime startDate,
      DateTime endDate
      ) {
    return interventi.where((intervento) {
      return intervento.utente?.id == utente.id &&
          intervento.cliente?.id == cliente.id &&
          intervento.tipologia?.id == tipologia.id &&
          intervento.data != null &&
          intervento.data!.isAfter(startDate) &&
          intervento.data!.isBefore(endDate);
    }).toList();
  }
}

enum Priorita{
  NULLA,
  BASSA,
  MEDIA,
  ALTA,
  URGENTE,
}