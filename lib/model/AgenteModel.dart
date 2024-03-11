

class AgenteModel {
  String? id;
  String? nome;
  String? cognome;
  String? email;
  String? riferimento_aziendale;
  String? cellulare;
  String? luogo_di_lavoro;
  String? iban;
  double? categoria_provvigione;


  AgenteModel(
      this.id,
      this.nome,
      this.cognome,
      this.email,
      this.riferimento_aziendale,
      this.cellulare,
      this.luogo_di_lavoro,
      this.iban,
      this.categoria_provvigione
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id': id,
      'nome': nome.toString(),
      'cognome': cognome.toString(),
      'email': email.toString(),
      'riferimento_aziendale' : riferimento_aziendale.toString(),
      'cellulare': cellulare.toString(),
      'luogo_di_lavoro': luogo_di_lavoro.toString(),
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
    riferimento_aziendale = map['riferimento_aziendale'];
    cellulare = map['cellulare'];
    luogo_di_lavoro = map['luogo_di_lavoro'];
    iban = map['iban'];
    categoria_provvigione = map['categoria_provvigione'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'cognome': cognome,
    'email': email,
    'riferimento_aziendale': riferimento_aziendale,
    'cellulare': cellulare,
    'luogo_di_lavoro': luogo_di_lavoro,
    'iban': iban,
    'categoria_provvigione': categoria_provvigione,
  };

  factory AgenteModel.fromJson(Map<String, dynamic> json){
    return AgenteModel(
      json['id']?.toString(),
      json['nome']?.toString(),
      json['cognome']?.toString(),
      json['email']?.toString(),
      json['riferimento_aziendale']?.toString(),
      json['cellulare']?.toString(),
      json['luogo_di_lavoro']?.toString(),
      json['iban']?.toString(),
      double.parse(json['categoria_provvigione']!.toString())
    );
  }
}