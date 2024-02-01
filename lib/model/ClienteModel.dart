import 'package:fema_crm/model/TipologiaInterventoModel.dart';

class ClienteModel {
  String? id;
  String? codiceFiscale;
  String? partitaIva;
  String? denominazione;
  String? indirizzo;
  String? cap;
  String? citta;
  String? provincia;
  String? nazione;
  String? recapitoFatturazioneElettronica;
  String? riferimentoAmministrativo;
  String? referente;
  String? fax;
  String? telefono;
  String? cellulare;
  String? email;
  String? pec;
  String? note;
  List<TipologiaInterventoModel>? tipologieIntervento;

  ClienteModel(
    this.id,
    this.codiceFiscale,
    this.partitaIva,
    this.denominazione,
    this.indirizzo,
    this.cap,
    this.citta,
    this.provincia,
    this.nazione,
    this.recapitoFatturazioneElettronica,
    this.riferimentoAmministrativo,
    this.referente,
    this.fax,
    this.telefono,
    this.cellulare,
    this.email,
    this.pec,
    this.note,
    this.tipologieIntervento,
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'codiceFiscale': codiceFiscale,
      'partitaIva': partitaIva,
      'denominazione': denominazione,
      'indirizzo': indirizzo,
      'cap': cap,
      'citta': citta,
      'provincia': provincia,
      'nazione': nazione,
      'recapitoFatturazioneElettronica': recapitoFatturazioneElettronica,
      'riferimentoAmministrativo': riferimentoAmministrativo,
      'referente': referente,
      'fax': fax,
      'telefono': telefono,
      'cellulare': cellulare,
      'email': email,
      'pec': pec,
      'note': note,
      'tipologieIntervento': tipologieIntervento
    };
    return map;
  }

  ClienteModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    codiceFiscale = map['codiceFiscale'];
    partitaIva = map['partitaIva'];
    denominazione = map['denominazione'];
    indirizzo = map['indirizzo'];
    cap = map['cap'];
    citta = map['citta'];
    provincia = map['provincia'];
    nazione = map['nazione'];
    recapitoFatturazioneElettronica = map['recapitoFatturazioneElettronica'];
    riferimentoAmministrativo = map['riferimentoAmministrativo'];
    referente = map['referente'];
    fax = map['fax'];
    telefono = map['telefono'];
    cellulare = map['cellulare'];
    email = map['email'];
    pec = map['pec'];
    note = map['note'];
    //tipologieIntervento = map['tipologieIntervento'];
    tipologieIntervento = map['tipologieIntervento'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'codiceFiscale': codiceFiscale,
        'partitaIva': partitaIva,
        'denominazione': denominazione,
        'indirizzo': indirizzo,
        'cap': cap,
        'citta': citta,
        'provincia': provincia,
        'nazione': nazione,
        'recapitoFatturazioneElettronica': recapitoFatturazioneElettronica,
        'riferimentoAmministrativo': riferimentoAmministrativo,
        'referente': referente,
        'fax': fax,
        'telefono': telefono,
        'cellulare': cellulare,
        'email': email,
        'pec': pec,
        'note': note,
        'tipologieIntervento': tipologieIntervento
      };

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
        json['id']?.toString(),
        json['codiceFiscale']?.toString(),
        json['partitaIva']?.toString(),
        json['denominazione']?.toString(),
        json['indirizzo']?.toString(),
        json['cap']?.toString(),
        json['citta']?.toString(),
        json['provincia']?.toString(),
        json['nazione']?.toString(),
        json['recapitoFatturazioneElettronica']?.toString(),
        json['riferimentoAmministrativo']?.toString(),
        json['referente']?.toString(),
        json['fax']?.toString(),
        json['telefono']?.toString(),
        json['cellualare']?.toString(),
        json['email']?.toString(),
        json['pec']?.toString(),
        json['note']?.toString(),
        json['tipologieIntervento']
            .map((data) => TipologiaInterventoModel.fromJson(data))
            .toList());
  }
}
