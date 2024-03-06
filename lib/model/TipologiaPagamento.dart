class TipologiaPagamentoModel {
  String? id;
  String? descrizione;

  TipologiaPagamentoModel(this.id, this.descrizione);

  factory TipologiaPagamentoModel.fromMap(Map<String, dynamic> map) {
    return TipologiaPagamentoModel(
      map['id'],
      map['descrizione'],
    );
  }

  factory TipologiaPagamentoModel.fromJson(Map<String, dynamic> json) {
    return TipologiaPagamentoModel(
      json['id'].toString(),
      json['descrizione'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descrizione': descrizione,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'descrizione': descrizione.toString(),
    };
  }

  @override
  String toString() {
    return 'TipologiaPagamentoModel{id: $id, descrizione: $descrizione}';
  }
}
