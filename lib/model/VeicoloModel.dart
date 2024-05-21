class VeicoloModel {
  String? id;
  String? descrizione;
  String? proprietario;
  int? chilometraggio_attuale;
  DateTime? data_scadenza_bollo;
  DateTime? data_scadenza_polizza;
  DateTime? data_tagliando;
  int? chilometraggio_ultimo_tagliando;
  int? soglia_tagliando;
  DateTime? data_revisione;
  DateTime? data_inversione_gomme;
  int? chilometraggio_ultima_inversione;
  int? soglia_inversione;
  DateTime? data_sostituzione_gomme;
  int? chilometraggio_ultima_sostituzione;
  int? soglia_sostituzione;

  VeicoloModel(
      this.id,
      this.descrizione,
      this.proprietario,
      this.chilometraggio_attuale,
      this.data_scadenza_bollo,
      this.data_scadenza_polizza,
      this.data_tagliando,
      this.chilometraggio_ultimo_tagliando,
      this.soglia_tagliando,
      this.data_revisione,
      this.data_inversione_gomme,
      this.chilometraggio_ultima_inversione,
      this.soglia_inversione,
      this.data_sostituzione_gomme,
      this.chilometraggio_ultima_sostituzione,
      this.soglia_sostituzione
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id != null ? id!.toString() : null,
      'descrizione': descrizione?.toString(),
      'proprietario' : proprietario?.toString(),
      'chilometraggio_attuale' : chilometraggio_attuale,
      'data_scadenza_bollo': data_scadenza_bollo?.toIso8601String(),
      'data_scadenza_polizza': data_scadenza_polizza?.toIso8601String(),
      'data_tagliando': data_tagliando?.toIso8601String(),
      'chilometraggio_ultimo_tagliando' : chilometraggio_ultimo_tagliando,
      'soglia_tagliando' : soglia_tagliando,
      'data_revisione': data_revisione?.toIso8601String(),
      'data_inversione_gomme': data_inversione_gomme?.toIso8601String(),
      'chilometraggio_ultima_inversione' : chilometraggio_ultima_inversione,
      'soglia_inversione' : soglia_inversione,
      'data_sostituzione_gomme': data_sostituzione_gomme?.toIso8601String(),
      'chilometraggio_ultima_sostituzione' : chilometraggio_ultima_sostituzione,
      'soglia_sostituzione' : soglia_sostituzione
    };
    return map;
  }


  VeicoloModel.fromMap(Map<String, dynamic> map) {
        id = map['id'];
        descrizione = map['descrizione'];
        proprietario = map['proprietario'];
        chilometraggio_attuale = map['chilometraggio_attuale'];
        map['data_scadenza_bollo'] != null ? DateTime.parse(map['data_scadenza_bollo']) : null;
        map['data_scadenza_polizza'] != null ? DateTime.parse(map['data_scadenza_polizza']) : null;
        map['data_tagliando'] != null ? DateTime.parse(map['data_tagliando']) : null;
        chilometraggio_ultimo_tagliando = map['chilometraggio_ultimo_tagliando'];
        soglia_tagliando = map['soglia_tagliando'];
        map['data_revisione'] != null ? DateTime.parse(map['data_revisione']) : null;
        map['data_inversione_gomme'] != null ? DateTime.parse(map['data_inversione_gomme']) : null;
        chilometraggio_ultima_inversione = map['chilometraggio_ultima_inversione'];
        soglia_inversione = map['soglia_inversione'];
        map['data_sostituzione_gomme'] != null ? DateTime.parse(map['data_sostituzione_gomme']) : null;
        chilometraggio_ultima_sostituzione = map['chilometraggio_ultima_sostituzione'];
        soglia_sostituzione = map['soglia_sostituzione'];
  }

  factory VeicoloModel.fromJson(Map<String, dynamic> json) {
    return VeicoloModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        json['proprietario']?.toString(),
        json['chilometraggio_attuale'],
        json['data_scadenza_bollo']!= null ? DateTime.parse(json['data_scadenza_bollo']) : null,
        json['data_scadenza_polizza']!= null ? DateTime.parse(json['data_scadenza_polizza']) : null,
        json['data_tagliando']!= null ? DateTime.parse(json['data_tagliando']) : null,
        json['chilometraggio_ultimo_tagliando'],
        json['soglia_tagliando'],
        json['data_revisione']!= null ? DateTime.parse(json['data_revisione']) : null,
        json['data_inversione_gomme']!= null ? DateTime.parse(json['data_inversione_gomme']) : null,
        json['chilometraggio_ultima_inversione'],
        json['soglia_inversione'],
        json['data_sostituzione_gomme']!= null ? DateTime.parse(json['data_sostituzione_gomme']) : null,
        json['chilometraggio_ultima_sostituzione'],
        json['soglia_sostituzione']
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'descrizione': descrizione,
        'proprietario' : proprietario,
        'chilometraggio_attuale' : chilometraggio_attuale,
        'data_scadenza_bollo': data_scadenza_bollo?.toIso8601String(),
        'data_scadenza_polizza': data_scadenza_polizza?.toIso8601String(),
        'data_tagliando': data_tagliando?.toIso8601String(),
        'chilometraggio_ultimo_tagliando': chilometraggio_ultimo_tagliando,
        'soglia_tagliando': soglia_tagliando,
        'data_revisione': data_revisione?.toIso8601String(),
        'data_inversione_gomme': data_inversione_gomme?.toIso8601String(),
        'chilometraggio_ultima_inversione' : chilometraggio_ultima_inversione,
        'soglia_inversione' : soglia_inversione,
        'data_sostituzione_gomme': data_sostituzione_gomme?.toIso8601String(),
        'chilometraggio_ultima_sostituzione' : chilometraggio_ultima_sostituzione,
        'soglia_sostituzione': soglia_sostituzione,
  };
}
