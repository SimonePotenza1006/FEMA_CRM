class LicenzaModel {
  String? id;
  String? descrizione;
  bool? utilizzato;
  String? note;

  LicenzaModel(this.id, this.descrizione, this.utilizzato, this.note);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'utilizzato': utilizzato,
      'note': note,
    };
    return map;
  }

  factory LicenzaModel.fromMap(Map<String, dynamic> map) {
    //id = map['id'];
    //descrizione = map['descrizione'];
    return LicenzaModel(
        map['id'],
        map['descrizione'],
        map['utilizzato'],
        map['note']
    );
  }


  factory LicenzaModel.fromJson(Map<String, dynamic> json) {
    return LicenzaModel(
        json['id'].toString(),
        json['descrizione'],
        json['utilizzato'],
        json['note']
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