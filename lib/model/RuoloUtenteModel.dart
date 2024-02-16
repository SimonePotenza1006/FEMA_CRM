class RuoloUtenteModel {
  String? id;
  String? descrizione;

  RuoloUtenteModel(this.id, this.descrizione);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'descrizione': descrizione};
    return map;
  }

  factory RuoloUtenteModel.fromMap(Map<String, dynamic> map) {
    return RuoloUtenteModel(
        map['id']?.toString(),
        map['descrizione']?.toString());
  }

  factory RuoloUtenteModel.fromJson(Map<String, dynamic> json) {
    return RuoloUtenteModel(
      json['id']?.toString(),
      json['descrizione']?.toString(),
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
    };
  }
}
