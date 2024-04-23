class TipologiaSpesaVeicoloModel{
  String? id;
  String? descrizione;

  TipologiaSpesaVeicoloModel(this.id, this.descrizione);

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{'id': id, 'descrizione': descrizione};
    return map;
  }

  factory TipologiaSpesaVeicoloModel.fromMap(Map<String, dynamic> map){
    return TipologiaSpesaVeicoloModel(map['id'], map['descrizione']);
  }

  factory TipologiaSpesaVeicoloModel.fromJson(Map<String, dynamic> json){
    return TipologiaSpesaVeicoloModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'descrizione': descrizione};
}