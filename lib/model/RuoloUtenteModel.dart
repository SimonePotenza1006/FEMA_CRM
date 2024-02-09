class RuoloUtenteModel {
  String? id;
  String? descrizione;

  RuoloUtenteModel(this.id, this.descrizione);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'descrizione': descrizione};
    return map;
  }

  factory RuoloUtenteModel.fromMap(Map<String, dynamic> map) {
    return RuoloUtenteModel(map['id'], map['descrizione']);
  }

  factory RuoloUtenteModel.fromJson(Map<String, dynamic> json) {
    return RuoloUtenteModel(json['id']?.toString(), json['descrizione']);
  }

  @override
  String toString() {
    return '{id: $id, descrizione: $descrizione}';
  }

  Map<String, dynamic> toJson() => {"id": id, "descrizione": descrizione};
}
