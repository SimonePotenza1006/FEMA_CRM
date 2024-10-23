import 'package:fema_crm/model/UtenteModel.dart';

class MerceInRiparazioneModel{
  String? id;
  DateTime? data;
  String? articolo;
  String? accessori;
  String? difetto_riscontrato;
  String? password;
  String? dati;
  bool? presenza_magazzino;
  bool? preventivo;
  double? importo_preventivato;
  bool? preventivo_accettato;
  String? diagnosi;
  String? risoluzione;
  DateTime? data_conclusione;
  DateTime? data_consegna;

  MerceInRiparazioneModel(
      this.id,
      this.data,
      this.articolo,
      this.accessori,
      this.difetto_riscontrato,
      this.password,
      this.dati,
      this.presenza_magazzino,
      this.preventivo,
      this.importo_preventivato,
      this.preventivo_accettato,
      this.diagnosi,
      this.risoluzione,
      this.data_conclusione,
      this.data_consegna,
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id': id,
      'data' : data?.toIso8601String(),
      'articolo' : articolo,
      'accessori' : accessori,
      'difetto_riscontrato' : difetto_riscontrato,
      'password' : password,
      'dati': dati,
      'presenza_magazzino' : presenza_magazzino,
      'preventivo': preventivo,
      'importo_preventivato' : importo_preventivato,
      'preventivo_accettato' : preventivo_accettato,
      'diagnosi' : diagnosi,
      'risoluzione' : risoluzione,
      'data_conclusione': data_conclusione?.toIso8601String(),
      'data_consegna' : data_consegna?.toIso8601String(),
    };
    return map;
  }

  MerceInRiparazioneModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    data = map['data'] != null ? DateTime.parse(map['data']) : null;
    articolo = map['articolo'];
    accessori = map['accessori'];
    difetto_riscontrato = map['difetto_riscontrato'];
    password = map['password'];
    dati = map['dati'];
    presenza_magazzino = map['presenza_magazzino'];
    preventivo = map['preventivo'];
    importo_preventivato = map['importo_preventivato'];
    preventivo_accettato = map['preventivo_accettato'];
    diagnosi = map['diagnosi'];
    risoluzione = map['risoluzione'];
    data_conclusione = map['data_conclusione'] != null ? DateTime.parse(map['data_conclusione']) : null;
    data_consegna = map['data_consegna'] != null ? DateTime.parse(map['data_consegna']) : null;
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data?.toIso8601String(),
    'articolo': articolo,
    'accessori' : accessori,
    'difetto_riscontrato' : difetto_riscontrato,
    'password': password,
    'dati' : dati,
    'presenza_magazzino' : presenza_magazzino,
    'preventivo' : preventivo,
    'importo_preventivato' : importo_preventivato,
    'preventivo_accettato' : preventivo_accettato,
    'diagnosi' : diagnosi,
    'risoluzione' : risoluzione,
    'data_conclusione' : data_conclusione?.toIso8601String(),
    'data_consegna' : data_consegna?.toIso8601String(),
  };

  factory MerceInRiparazioneModel.fromJson(Map<String, dynamic> json){
    return MerceInRiparazioneModel(
      json['id']?.toString(),
      json['data'] != null ? DateTime.parse(json['data']) : null,
      json['articolo']?.toString(),
      json['accessori']?.toString(),
      json['difetto_riscontrato']?.toString(),
      json['password']?.toString(),
      json['dati']?.toString(),
      json['presenza_magazzino'],
      json['preventivo'],
      json['importo_preventivato']!= null ? double.parse(json['importo_preventivato'].toString()) : null,
      json['preventivo_accettato'] != null ? json['preventivo_accettato'] : null,
      json['diagnosi']?.toString(),
      json['risoluzione']?.toString(),
      json['data_conclusione'] != null ? DateTime.parse(json['data_conclusione']) : null,
      json['data_consegna'] != null ? DateTime.parse(json['data_consegna']) : null
    );
  }
}