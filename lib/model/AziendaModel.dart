class AziendaModel {
  String? id;
  String? nome;
  String? luogo_di_lavoro;
  String? sede_legale;
  String? partita_iva;
  String? pec;
  String? recapito_fatturazione_elettronica;
  String? email;
  String? telefono;
  String? sito;
  String? citta_albo;
  String? citta_rea;
  String? numero_albo;
  String? numero_rea;

  AziendaModel(
      this.id,
      this.nome,
      this.luogo_di_lavoro,
      this.sede_legale,
      this.partita_iva,
      this.pec,
      this.recapito_fatturazione_elettronica,
      this.email,
      this.telefono,
      this.sito,
      this.citta_albo,
      this.citta_rea,
      this.numero_albo,
      this.numero_rea,
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id': id,
      'nome': nome.toString(),
      'luogo_di_lavoro': luogo_di_lavoro,
      'sede_legale' : sede_legale,
      'partita_iva': partita_iva,
      'pec': pec,
      'recapito_fatturazione_elettronica': recapito_fatturazione_elettronica,
      'email': email,
      'telefono' : telefono,
      'sito': sito,
      'citta_albo': citta_albo,
      'citta_rea': citta_rea,
      'numero_albo':numero_albo,
      'numero_rea':numero_rea,
    };
    return map;
  }

  AziendaModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    nome = map['nome'].toString();
    luogo_di_lavoro = map['luogo_di_lavoro'];
    sede_legale = map['sede_legale'];
    partita_iva = map['partita_iva'];
    pec = map['pec'];
    recapito_fatturazione_elettronica = map['recapito_fatturazione_elettronica'];
    email = map['email'];
    telefono = map['telefono'];
    sito = map['sito'];
    citta_albo = map['citta_albo'];
    citta_rea = map['citta_rea'];
    numero_albo = map['numero_albo'];
    numero_rea = map['numero_rea'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'luogo_di_lavoro' : luogo_di_lavoro,
    'sede_legale' : sede_legale,
    'partita_iva': partita_iva,
    'pec': pec,
    'recapito_fatturazione_elettronica': recapito_fatturazione_elettronica,
    'email': email,
    'telefono' : telefono,
    'sito' : sito,
    'citta_albo' : citta_albo,
    'citta_rea' : citta_rea,
    'numero_albo' : numero_albo,
    'numero_rea' : numero_rea,
  };

  factory AziendaModel.fromJson(Map<String, dynamic> json){
    return AziendaModel(
      json['id']?.toString(),
      json['nome']?.toString(),
      json['luogo_di_lavoro']?.toString(),
      json['sede_legale']?.toString(),
      json['partita_iva']?.toString(),
      json['pec']?.toString(),
      json['recapito_fatturazione_elettronica']?.toString(),
      json['email']?.toString(),
      json['telefono']?.toString(),
      json['sito']?.toString(),
      json['citta_albo']?.toString(),
      json['citta_rea']?.toString(),
      json['numero_albo']?.toString(),
      json['numero_rea']?.toString(),
    );
  }
}