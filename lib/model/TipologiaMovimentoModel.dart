class TipologiaMovimentoModel{
  String? id;
  String? descrizione;

  TipologiaMovimentoModel(
      this.id,
      this.descrizione,
      );

  Map<String,dynamic> toMap(){
    var map = <String, dynamic>{
      'id' : id,
      'descrizione' : descrizione
    };
    return map;
  }

   TipologiaMovimentoModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    descrizione = map['descrizione'];
   }

   Map<String, dynamic> toJson() =>{
    'id' : id,
    'descrizione' : descrizione
   };

  factory TipologiaMovimentoModel.fromJson(Map<String, dynamic> json){
    return TipologiaMovimentoModel(
      json['id']?.toString(),
      json['descrizione']?.toString()
    );
  }
}