import 'dart:core';


import 'ClienteModel.dart';
import 'UtenteModel.dart';

class CantiereModel {
  String? id;
  String? denominazione;
  String? indirizzo;
  String? cap;
  String? citta;
  String? provincia;
  String? codiceFiscale;
  String? partitaIva;
  String? telefono;
  String? cellulare;
  ClienteModel? cliente;
  List<UtenteModel>? utenti;

  CantiereModel(
      this.id,
      this.denominazione,
      this.indirizzo,
      this.cap,
      this.citta,
      this.provincia,
      this.codiceFiscale,
      this.partitaIva,
      this.telefono,
      this.cellulare,
      this.cliente,
      this.utenti);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'denominazione': denominazione,
      'indirizzo': indirizzo,
      'cap': cap,
      'citta': citta,
      'provincia': provincia,
      'codiceFiscale': codiceFiscale,
      'partitaIva': partitaIva,
      'telefono': telefono,
      'cellulare': cellulare,
      'cliente': cliente,
      'utenti': utenti
    };
    return map;
  }

  CantiereModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    denominazione = map['denominazione'];
    indirizzo = map['indirizzo'];
    cap = map['cap'];
    citta = map['citta'];
    provincia = map['provincia'];
    codiceFiscale = map['codiceFiscale'];
    partitaIva = map['partitaIva'];
    telefono = map['telefono'];
    cellulare = map['cellulare'];
    cliente = map['cliente'];
    utenti = map['utenti'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'denominazione': denominazione,
        'indirizzo': indirizzo,
        'cap': cap,
        'citta': citta,
        'provincia': provincia,
        'codiceFiscale': codiceFiscale,
        'partitaIva': partitaIva,
        'telefono': telefono,
        'cellulare': cellulare,
        'cliente': cliente,
        'utenti': utenti
      };

  factory CantiereModel.fromJson(Map<String, dynamic> json) {
    return CantiereModel(
        json['id']?.toString(),
        json['denominazione']?.toString(),
        json['indirizzo']?.toString(),
        json['cap']?.toString(),
        json['citta']?.toString(),
        json['provincia']?.toString(),
        json['codiceFiscale']?.toString(),
        json['partitaIva']?.toString(),
        json['telefono']?.toString(),
        json['cellulare']?.toString(),
        ClienteModel.fromJson(json),
        json['utenti']?.map((data) => UtenteModel.fromJson(data)));
  }
}
