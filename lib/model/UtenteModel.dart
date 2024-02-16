

import 'RuoloUtenteModel.dart';
import 'TipologiaInterventoModel.dart';

class UtenteModel {
  String? id;
  bool? attivo;
  String? nome;
  String? cognome;
  String? email;
  String? password;
  String? cellulare;
  String? codiceFiscale;
  String? iban;

  RuoloUtenteModel? ruolo;
  TipologiaInterventoModel? tipologiaintervento;

  UtenteModel(
      this.id,
      this.attivo,
      this.nome,
      this.cognome,
      this.email,
      this.password,
      this.cellulare,
      this.codiceFiscale,
      this.iban,
      this.ruolo,
      this.tipologiaintervento);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'attivo': attivo,
      'nome': nome,
      'cognome': cognome,
      'email': email,
      'password': password,
      'cellulare': cellulare,
      'codiceFiscale': codiceFiscale,
      'iban': iban,
      'ruolo': ruolo,
      'tipologiaIntervento': tipologiaintervento,
    };
    return map;
  }

  UtenteModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    attivo = map['attivo'];
    nome = map['nome'];
    cognome = map['cognome'];
    email = map['email'];
    password = map['password'];
    cellulare = map['cellulare'];
    codiceFiscale = map['codiceFiscale'];
    iban = map['iban'];
    ruolo = map['ruolo'] != null ? RuoloUtenteModel.fromMap(map['ruolo']) : null;
    tipologiaintervento = map['tipologiaIntervento'] != null ? TipologiaInterventoModel.fromMap(map['tipologiaIntervento']) : null;

  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'attivo': attivo,
    'nome': nome,
    'cognome': cognome,
    'email': email,
    'password': password,
    'cellulare': cellulare,
    'codiceFiscale': codiceFiscale,
    'iban': iban,
    'ruolo': ruolo,
    'tipologiaIntervento': tipologiaintervento,
  };

  factory UtenteModel.fromJson(Map<String, dynamic> json) {
    return UtenteModel(
      json['id']?.toString(),
      json['attivo'],
      json['nome']?.toString(),
      json['cognome']?.toString(),
      json['email']?.toString(),
      json['password']?.toString(),
      json['cellulare']?.toString(),
      json['codiceFiscale']?.toString(),
      json['iban']?.toString(),
      json['ruolo'] != null ? RuoloUtenteModel.fromJson(json['ruolo']) : null,
      json['tipologiaIntervento'] != null ? TipologiaInterventoModel.fromJson(json['tipologiaIntervento']) : null,
    );
  }
}