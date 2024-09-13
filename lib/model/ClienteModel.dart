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
  String? note_tecnico;
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
      this.note_tecnico,
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
      'note_tecnico' : note_tecnico,
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
    note_tecnico = map['note_tecnico'];
    //tipologieIntervento = map['tipologieIntervento'];
    tipologie_interventi = (map['tipologie_interventi'] as List<dynamic>?)
        ?.map((data) => TipologiaInterventoModel.fromJson(data as Map<String, dynamic>))
        .toList() ?? [];
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
    'note_tecnico' : note_tecnico,
    'tipologie_interventi': tipologie_interventi
  };

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      json['id'].toString(),
      json['codice_fiscale'],
      json['partita_iva'],
      json['denominazione'],
      json['indirizzo'],
      json['cap'],
      json['citta'],
      json['provincia'],
      json['nazione'],
      json['recapito_fatturazione_elettronica'],
      json['riferimento_amministrativo'],
      json['referente'],
      json['fax'],
      json['telefono'],
      json['cellulare'],
      json['email'],
      json['pec'],
      json['note'],
      json['note_tecnico'],
      (json['tipologie_interventi'] as List<dynamic>?)
          ?.map((data) => TipologiaInterventoModel.fromJson(data as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  List<ClienteModel> filtraTramiteQuery(List<ClienteModel> clienti, String query){
    return clienti.where((cliente) {
      return cliente.denominazione!.toLowerCase().contains(query.toLowerCase()) ||
          cliente.telefono!.toLowerCase().contains(query.toLowerCase()) ||
          cliente.citta!.toLowerCase().contains(query.toLowerCase()) ||
          cliente.indirizzo!.toLowerCase().contains(query.toLowerCase()) ||
          cliente.email!.toLowerCase().contains(query.toLowerCase()) ||
          cliente.cellulare!.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

}
