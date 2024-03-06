

class AgenteModel {
  String? id;
  String? nome;
  String? cognome;
  String? email;
  String? cellulare;
  String? codice_fiscale;
  String? iban;
  double? categoria_provvigione;


  AgenteModel(
      this.id,
      this.nome,
      this.cognome,
      this.email,
      this.cellulare,
      this.codice_fiscale,
      this.iban,
      this.categoria_provvigione
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id': id,
      'nome': nome.toString(),
      'cognome': cognome.toString(),
      'email': email.toString(),
      'cellulare': cellulare.toString(),
      'codice_fiscale': codice_fiscale.toString(),
      'iban': iban.toString(),
      'categoria_provvigione': double.parse(categoria_provvigione.toString()),
    };
    return map;
  }

  AgenteModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    nome = map['nome'];
    cognome = map['cognome'];
    email = map['email'];
    cellulare = map['cellulare'];
    codice_fiscale = map['codice_fiscale'];
    iban = map['iban'];
    categoria_provvigione = map['categoria_provvigione'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'cognome': cognome,
    'email': email,
    'cellulare': cellulare,
    'codice_fiscale': codice_fiscale,
    'iban': iban,
    'categoria_provvigione': categoria_provvigione,
  };

  factory AgenteModel.fromJson(Map<String, dynamic> json){
    return AgenteModel(
      json['id']?.toString(),
      json['nome']?.toString(),
      json['cognome']?.toString(),
      json['email']?.toString(),
      json['cellulare']?.toString(),
      json['codice_fiscale']?.toString(),
      json['iban']?.toString(),
      double.parse(json['categoria_provvigione']!.toString())
    );
  }
}