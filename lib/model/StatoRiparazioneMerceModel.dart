class StatoRiparazioneMerceModel {
  String? id;
  String? descrizione;

  StatoRiparazioneMerceModel(this.id, this.descrizione);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'descrizione': descrizione};
    return map;
  }

  factory StatoRiparazioneMerceModel.fromMap(Map<String, dynamic> map) {
    return StatoRiparazioneMerceModel(map['id'], map['descrizione']);
  }

  factory StatoRiparazioneMerceModel.fromJson(Map<String, dynamic> json) {
    return StatoRiparazioneMerceModel(
        json['id'].toString(), json['descrizione']);
  }

  @override
  String toString() {
    return '{id: $id, descrizione: $descrizione}';
  }

  Map<String, dynamic> toJson() => {"id": id, "descrizione": descrizione};
}
