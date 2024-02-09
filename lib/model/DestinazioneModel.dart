

import 'ClienteModel.dart';

class DestinazioneModel {
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

  DestinazioneModel(
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
      this.cliente);

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
      'cliente': cliente
    };
    return map;
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
        'cliente': cliente
      };

  factory DestinazioneModel.fromJson(Map<String, dynamic> json) {
    return DestinazioneModel(
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
        ClienteModel.fromJson(json));
  }
}
