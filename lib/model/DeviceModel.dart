class DeviceModel {
  String? id;
  String? descrizione;


  DeviceModel(this.id, this.descrizione);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione
    };
    return map;
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    //id = map['id'];
    //descrizione = map['descrizione'];
    return DeviceModel(
        map['id'],
        map['descrizione']
    );
  }


  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
        json['id'].toString(),
        json['descrizione']
    );
  }

  @override
  String toString() {
    return '{'
        'id: ${id}, '
        'descrizione: ${descrizione}'
        '}';
  }

  Map<String, dynamic> toJson() => {

    "id": id,
    "descrizione": descrizione
  };
}