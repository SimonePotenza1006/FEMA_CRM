class TipologiaCartaModel {
  String? id;
  String? descrizione;

  TipologiaCartaModel(this.id, this.descrizione);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'descrizione': descrizione};
    return map;
  }

  factory TipologiaCartaModel.fromMap(Map<String, dynamic> map) {
    return TipologiaCartaModel(map['id'], map['descrizione']);
  }

  factory TipologiaCartaModel.fromJson(Map<String, dynamic> json) {
    return TipologiaCartaModel(
      json['id']?.toString(),
      json['descrizione']?.toString(),
    );
  }

  @override
  String toString() {
    return '{id:$id, descrizione:$descrizione}';
  }

  Map<String, dynamic> toJson() => {'id': id, 'descrizione': descrizione};
}
