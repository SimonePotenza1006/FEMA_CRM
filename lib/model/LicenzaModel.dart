class LicenzaModel {
  String? id;
  String? descrizione;
  bool? utilizzato;

  LicenzaModel(this.id, this.descrizione, this.utilizzato);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'utilizzato': utilizzato
    };
    return map;
  }

  factory LicenzaModel.fromMap(Map<String, dynamic> map) {
    //id = map['id'];
    //descrizione = map['descrizione'];
    return LicenzaModel(
        map['id'],
        map['descrizione'],
        map['utilizzato']
    );
  }


  factory LicenzaModel.fromJson(Map<String, dynamic> json) {
    return LicenzaModel(
        json['id'].toString(),
        json['descrizione'],
        json['utilizzato']
    );
  }

  @override
  String toString() {
    return '{'
        'id: ${id}, '
        'descrizione: ${descrizione}, '
        'utilizzato: ${utilizzato}'
        '}';
  }

  Map<String, dynamic> toJson() => {

    "id": id,
    "descrizione": descrizione,
    'utilizzato': utilizzato
  };
}