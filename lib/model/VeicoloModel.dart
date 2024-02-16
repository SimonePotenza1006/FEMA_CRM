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
      this.dataSostituzioneGomme
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id != null ? id!.toString() : null,
      'descrizione': descrizione?.toString(),
      'dataScadenzaBollo': dataScadenzaBollo?.toIso8601String(),
      'dataScadenzaPolizza': dataScadenzaPolizza?.toIso8601String(),
      'dataTagliando': dataTagliando?.toIso8601String(),
      'dataRevisione': dataRevisione?.toIso8601String(),
      'dataInversioneGomme': dataInversioneGomme?.toIso8601String(),
      'dataSostituzioneGomme': dataSostituzioneGomme?.toIso8601String(),
    };
    return map;
  }


  factory VeicoloModel.fromMap(Map<String, dynamic> map) {
    return VeicoloModel(
        map['id'],
        map['descrizione'],
        map['dataScadenzaBollo']?.toIso8601String(),
        map['dataScadenzaPolizza']?.toIso8601String(),
        map['dataTagliando']?.toIso8601String(),
        map['dataRevisione']?.toIso8601String(),
        map['dataInversioneGomme']?.toIso8601String(),
        map['dataSostituzioneGomme']?.toIso8601String()
    );
  }

  factory VeicoloModel.fromJson(Map<String, dynamic> json) {
    return VeicoloModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        json['dataScadenzaBollo']?.toIso8601String(),
        json['dataScadenzaPolizza']?.toIso8601String(),
        json['dataTagliando']?.toIso8601String(),
        json['dataRevisione']?.toIso8601String(),
        json['dataInversioneGomme']?.toIso8601String(),
        json['dataSostituzioneGomme']?.toIso8601String()
    );
  }

  @override
  String toString() {
    return '{id: ${id ?? 'N/A'}, descrizione: $descrizione, data scadenza bollo: $dataScadenzaBollo, data scadenza polizza: $dataScadenzaPolizza, data tagliando: $dataTagliando, data revisione: $dataRevisione, data inversione gomme: $dataInversioneGomme, data sostituzione gomme: $dataSostituzioneGomme}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'descrizione': descrizione,
        'dataScadenzaBollo': dataScadenzaBollo?.toIso8601String(),
        'dataScadenzaPolizza': dataScadenzaPolizza?.toIso8601String(),
        'dataTagliando': dataTagliando?.toIso8601String(),
        'dataRevisione': dataRevisione?.toIso8601String(),
        'dataInversioneGomme': dataInversioneGomme?.toIso8601String(),
        'dataSostituzioneGomme': dataSostituzioneGomme?.toIso8601String()
      };
}
