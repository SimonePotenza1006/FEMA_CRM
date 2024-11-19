class TipoTaskModel{
  String? id;
  String? descrizione;

  TipoTaskModel(
      this.id,
      this.descrizione
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id' : id,
      'descrizione' : descrizione,
    };
    return map;
  }

  factory TipoTaskModel.fromMap(Map<String, dynamic> map){
    return TipoTaskModel(
        map['id']?.toString(),
        map['descrizione']?.toString()
    );
  }

  factory TipoTaskModel.fromJson(Map<String, dynamic> json) {
    return TipoTaskModel(
      json['id']?.toString(),
      json['descrizione']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id?.toString(),
      "descrizione": descrizione,
    };
  }
}