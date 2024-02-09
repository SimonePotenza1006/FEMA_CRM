

import 'TipologiaInterventoModel.dart';

class ClienteModel {
  String? id;
  String? codice_fiscale;
  String? partita_iva;
  String? denominazione;
  String? indirizzo;
  String? cap;
  String? citta;
  String? provincia;
  String? nazione;
  String? recapito_fatturazione_elettronica;
  String? riferimento_amministrativo;
  String? referente;
  String? fax;
  String? telefono;
  String? cellulare;
  String? email;
  String? pec;
  String? note;
  List<TipologiaInterventoModel>? tipologie_interventi;

  ClienteModel(
    this.id,
    this.codice_fiscale,
    this.partita_iva,
    this.denominazione,
    this.indirizzo,
    this.cap,
    this.citta,
    this.provincia,
    this.nazione,
    this.recapito_fatturazione_elettronica,
    this.riferimento_amministrativo,
    this.referente,
    this.fax,
    this.telefono,
    this.cellulare,
    this.email,
    this.pec,
    this.note,
    this.tipologie_interventi,
  );


  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'codice_fiscale': codice_fiscale,
      'partita_iva': partita_iva,
      'denominazione': denominazione,
      'indirizzo': indirizzo,
      'cap': cap,
      'citta': citta,
      'provincia': provincia,
      'nazione': nazione,
      'recapito_fatturazione_elettronica': recapito_fatturazione_elettronica,
      'riferimentoAmministrativo': riferimento_amministrativo,
      'referente': referente,
      'fax': fax,
      'telefono': telefono,
      'cellulare': cellulare,
      'email': email,
      'pec': pec,
      'note': note,
      'tipologie_interventi': tipologie_interventi
    };
    return map;
  }

  ClienteModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    codice_fiscale = map['codice_fiscale'];
    partita_iva = map['partita_iva'];
    denominazione = map['denominazione'];
    indirizzo = map['indirizzo'];
    cap = map['cap'];
    citta = map['citta'];
    provincia = map['provincia'];
    nazione = map['nazione'];
    recapito_fatturazione_elettronica = map['recapito_fatturazione_elettronica'];
    riferimento_amministrativo = map['riferimento_amministrativo'];
    referente = map['referente'];
    fax = map['fax'];
    telefono = map['telefono'];
    cellulare = map['cellulare'];
    email = map['email'];
    pec = map['pec'];
    note = map['note'];
    //tipologieIntervento = map['tipologieIntervento'];
    tipologie_interventi = map['tipologie_interventi'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'codice_fiscale': codice_fiscale,
        'partita_iva': partita_iva,
        'denominazione': denominazione,
        'indirizzo': indirizzo,
        'cap': cap,
        'citta': citta,
        'provincia': provincia,
        'nazione': nazione,
        'recapito_fatturazione_elettronica': recapito_fatturazione_elettronica,
        'riferimento_amministrativo': riferimento_amministrativo,
        'referente': referente,
        'fax': fax,
        'telefono': telefono,
        'cellulare': cellulare,
        'email': email,
        'pec': pec,
        'note': note,
        'tipologie_interventi': tipologie_interventi
      };

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      json['id']?.toString(),
      json['codice_fiscale']?.toString(),
      json['partitaIva']?.toString(),
      json['denominazione']?.toString(),
      json['indirizzo']?.toString(),
      json['cap']?.toString(),
      json['citta']?.toString(),
      json['provincia']?.toString(),
      json['nazione']?.toString(),
      json['recapito_fatturazione_elettronica']?.toString(),
      json['riferimento_amministrativo']?.toString(),
      json['referente']?.toString(),
      json['fax']?.toString(),
      json['telefono']?.toString(),
      json['cellulare']?.toString(),
      json['email']?.toString(),
      json['pec']?.toString(),
      json['note']?.toString(),
      (json['tipologie_interventi'] as List<dynamic>?)
          ?.map((data) => TipologiaInterventoModel.fromJson(data as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
