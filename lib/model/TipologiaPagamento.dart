class TipologiaPagamentoModel {
  String? id;
  String? descrizione;

  TipologiaPagamentoModel(this.id, this.descrizione);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'descrizione': descrizione};
    return map;
  }

  factory TipologiaPagamentoModel.fromMap(Map<String, dynamic> map) {
    return TipologiaPagamentoModel(
      map['id'] ?? '',
      map['descrizione'] ?? '',
    );
  }

  factory TipologiaPagamentoModel.fromJson(Map<String, dynamic> json) {
    return TipologiaPagamentoModel(json['id'], json['descrizione']);
  }

  @override
  String toString() {
    return '{id: $id, descrizione: $descrizione}';
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id ?? '',
      "descrizione": descrizione ?? '',
    };
  }
}
