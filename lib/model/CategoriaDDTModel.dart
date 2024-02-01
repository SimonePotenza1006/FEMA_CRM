class CategoriaDDTModel {
  String? id;
  String? descrizione;

  CategoriaDDTModel(this.id, this.descrizione);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'descrizione': descrizione};
    return map;
  }

  factory CategoriaDDTModel.fromMap(Map<String, dynamic> map) {
    return CategoriaDDTModel(map['id'], map['descrizione']);
  }

  factory CategoriaDDTModel.fromJson(Map<String, dynamic> json) {
    return CategoriaDDTModel(json['id'].toString(), json['descrizione']);
  }

  @override
  String toString() {
    return '{id: $id, descrizione: $descrizione}';
  }

  Map<String, dynamic> toJson() => {"id": id, "descrizione": descrizione};
}
