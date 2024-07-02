class CartellaModel {
  String? id;
  String? nome;
  CartellaModel? parent;

  CartellaModel(
      this.id,
      this.nome,
      this.parent,
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id' : id,
      'nome' : nome,
      'parent' : parent?.toMap(),
    };
    return map;
  }

  CartellaModel.fromMap(Map<String, dynamic> map){
      id = map['id'];
      nome = map['nome'];
      parent = map['parent'] != null ? CartellaModel.fromMap(map['parent']) : null;
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'nome' : nome,
    'parent' : parent?.toJson()
  };

  factory CartellaModel.fromJson(Map<String, dynamic> json){
    return CartellaModel(
      json['id'].toString(),
      json['nome'].toString(),
      json['parent'] != null ? CartellaModel.fromJson(json['parent']) : null,
    );
  }
}