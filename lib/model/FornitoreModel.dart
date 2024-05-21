class FornitoreModel {
  String? id;
  String? codice;
  String? partita_iva;
  String? denominazione;
  String? indirizzo;
  String? citta;
  String? provincia;
  String? telefono;

  FornitoreModel(
      this.id,
      this.codice,
      this.partita_iva,
      this.denominazione,
      this.indirizzo,
      this.citta,
      this.provincia,
      this.telefono,
);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'codice': codice,
      'partita_iva': partita_iva,
      'denominazione': denominazione,
      'indirizzo': indirizzo,
      'citta': citta,
      'provincia': provincia,
      'telefono': telefono,
    };
    return map;
  }

  FornitoreModel.fromMap(Map<String, dynamic> map){
    id = map['id'].toString();
    codice = map['codice'].toString();
    partita_iva = map['partita_iva'].toString();
    denominazione = map['denominazione'].toString();
    indirizzo = map['indirizzo'].toString();
    citta = map['citta'].toString();
    provincia = map['provincia'].toString();
    telefono = map['telefono'].toString();
  }

  factory FornitoreModel.fromJson(Map<String, dynamic> json) {
    return FornitoreModel(
      json['id']?.toString(),
      json['codice']?.toString(),
      json['partita_iva']?.toString(),
      json['denominazione']?.toString(),
      json['indirizzo']?.toString(),
      json['citta']?.toString(),
      json['provincia']?.toString(),
      json['telefono']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'codice': codice,
        'partita_iva': partita_iva,
        'denominazione': denominazione,
        'indirizzo': indirizzo,
        'citta': citta,
        'provincia': provincia,
        'telefono': telefono,
      };
}
