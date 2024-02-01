class AttivitaModel {
  String? id;
  String? descrizione;

  AttivitaModel(this.id, this.descrizione);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'descrizione': descrizione};
    return map;
  }

  factory AttivitaModel.fromMap(Map<String, dynamic> map) {
    return AttivitaModel(map['id'], map['descrizione']);
  }

  factory AttivitaModel.fromJson(Map<String, dynamic> json) {
    return AttivitaModel(
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
