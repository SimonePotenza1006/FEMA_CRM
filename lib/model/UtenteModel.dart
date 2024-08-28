

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
  String? codice_fiscale;
  String? iban;
  RuoloUtenteModel? ruolo;
  TipologiaInterventoModel? tipologia_intervento;

  UtenteModel(
      this.id,
      this.attivo,
      this.nome,
      this.cognome,
      this.email,
      this.password,
      this.cellulare,
      this.codice_fiscale,
      this.iban,
      this.ruolo,
      this.tipologia_intervento
      );

  String? nomeCompleto(){
    if (nome != null && cognome != null) {
      return '$nome $cognome';
    } else {
      return null; // or some default value, e.g. 'Unknown'
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'attivo': attivo,
      'nome': nome.toString(),
      'cognome': cognome.toString(),
      'email': email.toString(),
      'password': password.toString(),
      'cellulare': cellulare.toString(),
      'codice_fiscale': codice_fiscale.toString(),
      'iban': iban.toString(),
      'ruolo': ruolo,
      'tipologia_intervento': tipologia_intervento,
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
    codice_fiscale = map['codice_fiscale'];
    iban = map['iban'];
    ruolo = map['ruolo'] != null ? RuoloUtenteModel.fromMap(map['ruolo']) : null;
        tipologia_intervento = map['tipologia_intervento'] != null ? TipologiaInterventoModel.fromMap(map['tipologia_itervento']) : null;

  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'attivo': attivo,
    'nome': nome,
    'cognome': cognome,
    'email': email,
    'password': password,
    'cellulare': cellulare,
    'codice_fiscale': codice_fiscale,
    'iban': iban,
    'ruolo': ruolo,
    'tipologia_intervento': tipologia_intervento,
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
      json['codice_fiscale']?.toString(),
      json['iban']?.toString(),
      json['ruolo'] != null ? RuoloUtenteModel.fromJson(json['ruolo']) : null,
      json['tipologia_intervento'] != null ? TipologiaInterventoModel.fromJson(json['tipologia_intervento']) : null,
    );
  }
}