import 'package:fema_crm/model/RuoloUtenteModel.dart';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';

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
  List<TipologiaInterventoModel>? competenze;

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
      this.competenze);

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
      'competenze': competenze
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
    ruolo = map['ruolo'];
    competenze =
        TipologiaInterventoModel.fromMap(map) as List<TipologiaInterventoModel>;
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
        'competenze': competenze,
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
        RuoloUtenteModel.fromJson(json),
        json['competenze']
            ?.map((data) => TipologiaInterventoModel.fromJson(data))
            .toList());
  }
}
