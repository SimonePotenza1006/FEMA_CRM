class RuoloUtenteModel {
  String? id;
  String? descrizione;
  bool? capogruppo;

  RuoloUtenteModel(this.id, this.descrizione, this.capogruppo);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'descrizione': descrizione, 'capogruppo' : capogruppo};
    return map;
  }

  factory RuoloUtenteModel.fromMap(Map<String, dynamic> map) {
    return RuoloUtenteModel(
        map['id']?.toString(),
        map['descrizione']?.toString(),
        map['capogruppo']
    );
  }

  factory RuoloUtenteModel.fromJson(Map<String, dynamic> json) {
    return RuoloUtenteModel(
      json['id']?.toString(),
      json['descrizione']?.toString(),
      json['capogruppo']
    );
  }


  @override
  String toString() {
    return '{id: $id, descrizione: $descrizione}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'descrizione': descrizione.toString(),
      'capogruppo': capogruppo
    };
  }
}
