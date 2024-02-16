

import 'ClienteModel.dart';

class DestinazioneModel {
  String? id;
  String? denominazione;
  String? indirizzo;
  String? cap;
  String? citta;
  String? provincia;
  String? codice_fiscale;
  String? partita_iva;
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
      this.codice_fiscale,
      this.partita_iva,
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
      'codiceFiscale': codice_fiscale,
      'partitaIva': partita_iva,
      'telefono': telefono,
      'cellulare': cellulare,
      'cliente': cliente?.toMap() // Converti l'oggetto cliente in una mappa
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
        'codiceFiscale': codice_fiscale,
        'partitaIva': partita_iva,
        'telefono': telefono,
        'cellulare': cellulare,
        'cliente': cliente?.toMap(),
      };

  factory DestinazioneModel.fromMap(Map<String, dynamic> map) {
    return DestinazioneModel(
      map['id'],
      map['denominazione'],
      map['indirizzo'],
      map['cap'],
      map['citta'],
      map['provincia'],
      map['codiceFiscale'],
      map['partitaIva'],
      map['telefono'],
      map['cellulare'],
      map['cliente'] != null ? ClienteModel.fromMap(map['cliente']) : null,
    );
  }


  factory DestinazioneModel.fromJson(Map<String, dynamic> json) {
    return DestinazioneModel(
        json['id']?.toString(),
        json['denominazione']?.toString(),
        json['indirizzo']?.toString(),
        json['cap']?.toString(),
        json['citta']?.toString(),
        json['provincia']?.toString(),
        json['codice_fiscale']?.toString(), // Utilizza 'codice_fiscale' invece di 'codiceFiscale'
        json['partita_iva']?.toString(), // Utilizza 'partita_iva' invece di 'partitaIva'
        json['telefono']?.toString(),
        json['cellulare']?.toString(),
        json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null);
  }

}
