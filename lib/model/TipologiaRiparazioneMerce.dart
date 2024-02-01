class TipologiaRiparazioneMerceModel {
  String? id;
  String? descrizione;

  TipologiaRiparazioneMerceModel(this.id, this.descrizione);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'descrizione': descrizione};
    return map;
  }

  factory TipologiaRiparazioneMerceModel.fromMap(Map<String, dynamic> map) {
    return TipologiaRiparazioneMerceModel(map['id'], map['descrizione']);
  }

  factory TipologiaRiparazioneMerceModel.fromJson(Map<String, dynamic> json) {
    return TipologiaRiparazioneMerceModel(
        json['id'].toString(), json['descrizione']);
  }

  @override
  String toString() {
    return '{id: $id, descrizione: $descrizione}';
  }

  Map<String, dynamic> toJson() => {"id": id, "descrizione": descrizione};
}
