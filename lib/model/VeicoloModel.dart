class VeicoloModel {
  String? id;
  String? descrizione;
  DateTime? dataScadenzaBollo;
  DateTime? dataScadenzaPolizza;
  DateTime? dataTagliando;
  DateTime? dataRevisione;
  DateTime? dataInversioneGomme;
  DateTime? dataSostituzioneGomme;

  VeicoloModel(
      this.id,
      this.descrizione,
      this.dataScadenzaBollo,
      this.dataScadenzaPolizza,
      this.dataTagliando,
      this.dataRevisione,
      this.dataInversioneGomme,
      this.dataSostituzioneGomme);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'dataScadenzaBollo': dataScadenzaBollo,
      'dataScadenzaPolizza': dataScadenzaPolizza,
      'dataTagliando': dataTagliando,
      'dataRevisione': dataRevisione,
      'dataInversioneGomme': dataInversioneGomme,
      'dataSostituzioneGomme': dataSostituzioneGomme,
    };
    return map;
  }

  factory VeicoloModel.fromMap(Map<String, dynamic> map) {
    return VeicoloModel(
        map['id'],
        map['descrizione'],
        map['dataScadenzaBollo'],
        map['dataScadenzaPolizza'],
        map['dataTagliando'],
        map['dataRevisione'],
        map['dataInversioneGomme'],
        map['dataSostituzioneGomme']);
  }

  factory VeicoloModel.fromJson(Map<String, dynamic> json) {
    return VeicoloModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        json['dataScadenzaBollo'],
        json['dataScadenzaPolizza'],
        json['dataTagliando'],
        json['dataRevisione'],
        json['dataInversioneGomme'],
        json['dataSostituzioneGomme']);
  }

  @override
  String toString() {
    return '{id: $id, descrizione: $descrizione, data scadenza bollo: $dataScadenzaBollo, data scadenza polizza: $dataScadenzaPolizza, data tagliando: $dataTagliando, data revisione: $dataRevisione, data inversione gomme: $dataInversioneGomme, data sostituzione gomme: $dataSostituzioneGomme}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'descrizione': descrizione,
        'dataScadenzaBollo': dataScadenzaBollo,
        'dataScadenzaPolizza': dataScadenzaPolizza,
        'dataTagliando': dataTagliando,
        'dataRevisione': dataRevisione,
        'dataInversioneGomme': dataInversioneGomme,
        'dataSostituzioneGomme': dataSostituzioneGomme
      };
}
