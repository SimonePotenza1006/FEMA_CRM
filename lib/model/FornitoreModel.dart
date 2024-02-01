class FornitoreModel {
  String? id;
  String? codiceFiscale;
  String? partitaIva;
  String? denominazione;
  String? indirizzo;
  String? cap;
  String? citta;
  String? provincia;
  String? nazione;
  String? referente;
  String? fax;
  String? telefono;
  String? cellulare;
  String? email;
  String? pec;
  String? note;

  FornitoreModel(
      this.id,
      this.codiceFiscale,
      this.partitaIva,
      this.denominazione,
      this.indirizzo,
      this.cap,
      this.citta,
      this.provincia,
      this.nazione,
      this.referente,
      this.fax,
      this.telefono,
      this.cellulare,
      this.email,
      this.pec,
      this.note);

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
      'referente': referente,
      'fax': fax,
      'telefono': telefono,
      'cellulare': cellulare,
      'email': email,
      'pec': pec,
      'note': note,
    };
    return map;
  }

  factory FornitoreModel.fromMap(Map<String, dynamic> map) {
    return FornitoreModel(
      map['id'],
      map['codiceFiscale'],
      map['partitaIva'],
      map['denominazione'],
      map['indirizzo'],
      map['cap'],
      map['citta'],
      map['provincia'],
      map['nazione'],
      map['referente'],
      map['fax'],
      map['telefono'],
      map['cellulare'],
      map['email'],
      map['pec'],
      map['note'],
    );
  }

  factory FornitoreModel.fromJson(Map<String, dynamic> json) {
    return FornitoreModel(
      json['id']?.toString(),
      json['codiceFiscale']?.toString(),
      json['partitaIva']?.toString(),
      json['denominazione']?.toString(),
      json['indirizzo']?.toString(),
      json['cap']?.toString(),
      json['citta']?.toString(),
      json['provincia']?.toString(),
      json['nazione']?.toString(),
      json['referente']?.toString(),
      json['fax']?.toString(),
      json['telefono']?.toString(),
      json['cellulare']?.toString(),
      json['email']?.toString(),
      json['pec']?.toString(),
      json['note']?.toString(),
    );
  }

  @override
  String toString() {
    return '{id:$id, codice fiscale:$codiceFiscale, partita IVA:$partitaIva, denominazione:$denominazione, indirizzo:$indirizzo, cap:$cap, città:$citta, proivincia:$provincia, nazione:$nazione, referente:$referente, fax:$fax, telefono:$telefono, cellulare:$cellulare, email:$email, pec:$pec, note:$note}';
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
        'referente': referente,
        'fax': fax,
        'telefono': telefono,
        'cellulare': cellulare,
        'email': email,
        'pec': pec,
        'note': note,
      };
}
