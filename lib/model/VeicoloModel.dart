class VeicoloModel {
  String? id;
  String? descrizione;
  DateTime? data_scadenza_bollo;
  DateTime? data_scadenza_polizza;
  DateTime? data_tagliando;
  DateTime? data_revisione;
  DateTime? data_inversione_gomme;
  DateTime? data_sostituzione_gomme;

  VeicoloModel(
      this.id,
      this.descrizione,
      this.data_scadenza_bollo,
      this.data_scadenza_polizza,
      this.data_tagliando,
      this.data_revisione,
      this.data_inversione_gomme,
      this.data_sostituzione_gomme
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id != null ? id!.toString() : null,
      'descrizione': descrizione?.toString(),
      'data_scadenza_bollo': data_scadenza_bollo?.toIso8601String(),
      'data_scadenza_polizza': data_scadenza_polizza?.toIso8601String(),
      'data_tagliando': data_tagliando?.toIso8601String(),
      'data_revisione': data_revisione?.toIso8601String(),
      'data_inversione_gomme': data_inversione_gomme?.toIso8601String(),
      'data_sostituzione_gomme': data_sostituzione_gomme?.toIso8601String(),
    };
    return map;
  }


  VeicoloModel.fromMap(Map<String, dynamic> map) {
        id = map['id'];
        descrizione = map['descrizione'];
        map['data_scadenza_bollo'] != null ? DateTime.parse(map['data_scadenza_bollo']) : null;
        map['data_scadenza_polizza'] != null ? DateTime.parse(map['data_scadenza_polizza']) : null;
        map['data_tagliando'] != null ? DateTime.parse(map['data_tagliando']) : null;
        map['data_revisione'] != null ? DateTime.parse(map['data_revisione']) : null;
        map['data_inversione_gomme'] != null ? DateTime.parse(map['data_inversione_gomme']) : null;
        map['data_sostituzione_gomme'] != null ? DateTime.parse(map['data_sostituzione_gomme']) : null;
  }

  factory VeicoloModel.fromJson(Map<String, dynamic> json) {
    return VeicoloModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        json['data_scadenza_bollo']!= null ? DateTime.parse(json['data_scadenza_bollo']) : null,
        json['data_scadenza_polizza']!= null ? DateTime.parse(json['data_scadenza_polizza']) : null,
        json['data_tagliando']!= null ? DateTime.parse(json['data_tagliando']) : null,
        json['data_revisione']!= null ? DateTime.parse(json['data_revisione']) : null,
        json['data_inversione_gomme']!= null ? DateTime.parse(json['data_inversione_gomme']) : null,
        json['data_sostituzione_gomme']!= null ? DateTime.parse(json['data_sostituzione_gomme']) : null,
    );
  }

  @override
  String toString() {
    return '{id: ${id ?? 'N/A'}, descrizione: $descrizione, data scadenza bollo: $data_scadenza_bollo, data scadenza polizza: $data_scadenza_polizza, data tagliando: $data_tagliando, data revisione: $data_revisione, data inversione gomme: $data_inversione_gomme, data sostituzione gomme: $data_sostituzione_gomme}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'descrizione': descrizione,
        'data_scadenza_bollo': data_scadenza_bollo?.toIso8601String(),
        'data_scadenza_polizza': data_scadenza_polizza?.toIso8601String(),
        'data_tagliando': data_tagliando?.toIso8601String(),
        'data_revisione': data_revisione?.toIso8601String(),
        'data_inversione_gomme': data_inversione_gomme?.toIso8601String(),
        'data_sostituzione_gomme': data_sostituzione_gomme?.toIso8601String()
      };
}
