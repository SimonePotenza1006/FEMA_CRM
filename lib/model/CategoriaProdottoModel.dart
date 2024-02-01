class CategoriaProdottoModel {
  String? id;
  String? descrizione;

  CategoriaProdottoModel(this.id, this.descrizione);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'descrizione': descrizione};
    return map;
  }

  factory CategoriaProdottoModel.fromMap(Map<String, dynamic> map) {
    return CategoriaProdottoModel(map['id'], map['descrizione']);
  }

  factory CategoriaProdottoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaProdottoModel(json['id'].toString(), json['descrizione']);
  }

  String toString() {
    return '{id: $id, descrizione: $descrizione}';
  }

  Map<String, dynamic> toJson() => {"id": id, "descrizione": descrizione};
}
