class TipologiaSpesaModel {
  String? id;
  String? descrizione;

  TipologiaSpesaModel(this.id, this.descrizione);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'descrizione': descrizione};
    return map;
  }

  factory TipologiaSpesaModel.fromMap(Map<String, dynamic> map) {
    return TipologiaSpesaModel(map['id'], map['descrizione']);
  }

  factory TipologiaSpesaModel.fromJson(Map<String, dynamic> json) {
    return TipologiaSpesaModel(json['id'].toString(), json['descrizione']);
  }

  @override
  String toString() {
    return '{id: $id, descrizione: $descrizione}';
  }

  Map<String, dynamic> toJson() => {"id": id, "descrizione": descrizione};
}
