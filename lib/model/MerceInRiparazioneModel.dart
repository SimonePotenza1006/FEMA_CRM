import 'package:fema_crm/model/UtenteModel.dart';

class MerceInRiparazioneModel{
  String? id;
  DateTime? data;
  String? articolo;
  String? accessori;
  String? difetto_riscontrato;
  DateTime? data_presa_in_carico;
  String? password;
  String? dati;
  bool? presenza_magazzino;
  bool? preventivo;
  double? importo_preventivato;
  DateTime? data_comunica_preventivo;
  bool? preventivo_accettato;
  DateTime? data_accettazione_preventivo;
  String? diagnosi;
  String? risoluzione;
  DateTime? data_conclusione;
  String? prodotti_installati;
  DateTime? data_consegna;

  MerceInRiparazioneModel(
      this.id,
      this.data,
      this.articolo,
      this.accessori,
      this.difetto_riscontrato,
      this.data_presa_in_carico,
      this.password,
      this.dati,
      this.presenza_magazzino,
      this.preventivo,
      this.importo_preventivato,
      this.data_comunica_preventivo,
      this.preventivo_accettato,
      this.data_accettazione_preventivo,
      this.diagnosi,
      this.risoluzione,
      this.data_conclusione,
      this.prodotti_installati,
      this.data_consegna,
      );

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id': id,
      'data' : data?.toIso8601String(),
      'articolo' : articolo,
      'accessori' : accessori,
      'difetto_riscontrato' : difetto_riscontrato,
      'data_presa_in_carico' : data_presa_in_carico?.toIso8601String(),
      'password' : password,
      'dati': dati,
      'presenza_magazzino' : presenza_magazzino,
      'preventivo': preventivo,
      'importo_preventivato' : importo_preventivato,
      'data_comunica_preventivo' : data_comunica_preventivo?.toIso8601String(),
      'preventivo_accettato' : preventivo_accettato,
      'data_accettazione_preventivo' : data_accettazione_preventivo?.toIso8601String(),
      'diagnosi' : diagnosi,
      'risoluzione' : risoluzione,
      'data_conclusione': data_conclusione?.toIso8601String(),
      'prodotti_installati' : prodotti_installati,
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
    data_presa_in_carico = map['data_presa_in_carico'] != null ? DateTime.parse(map['data_presa_in_carico']) : null;
    password = map['password'];
    dati = map['dati'];
    presenza_magazzino = map['presenza_magazzino'];
    preventivo = map['preventivo'];
    importo_preventivato = map['importo_preventivato'];
    data_comunica_preventivo = map['data_comunica_preventivo'] != null ? DateTime.parse(map['data_comunica_preventvo']) : null;
    preventivo_accettato = map['preventivo_accettato'];
    data_accettazione_preventivo = map['data_accettazione_preventivo'] != null ? DateTime.parse(map['data_accettazione_preventivo']) : null;
    diagnosi = map['diagnosi'];
    risoluzione = map['risoluzione'];
    data_conclusione = map['data_conclusione'] != null ? DateTime.parse(map['data_conclusione']) : null;
    prodotti_installati = map['prodotti_installati'];
    data_consegna = map['data_consegna'] != null ? DateTime.parse(map['data_consegna']) : null;
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data?.toIso8601String(),
    'articolo': articolo,
    'accessori' : accessori,
    'difetto_riscontrato' : difetto_riscontrato,
    'data_presa_in_carico' : data_presa_in_carico?.toIso8601String(),
    'password': password,
    'dati' : dati,
    'presenza_magazzino' : presenza_magazzino,
    'preventivo' : preventivo,
    'importo_preventivato' : importo_preventivato,
    'data_comunica_preventivo' : data_comunica_preventivo?.toIso8601String(),
    'preventivo_accettato' : preventivo_accettato,
    'data_accettazione_preventivo' : data_accettazione_preventivo?.toIso8601String(),
    'diagnosi' : diagnosi,
    'risoluzione' : risoluzione,
    'data_conclusione' : data_conclusione?.toIso8601String(),
    'prodotti_installati' : prodotti_installati,
    'data_consegna' : data_consegna?.toIso8601String(),
  };

  factory MerceInRiparazioneModel.fromJson(Map<String, dynamic> json){
    return MerceInRiparazioneModel(
      json['id']?.toString(),
      json['data'] != null ? DateTime.parse(json['data']) : null,
      json['articolo']?.toString(),
      json['accessori']?.toString(),
      json['difetto_riscontrato']?.toString(),
      json['data_presa_in_carico'] != null ? DateTime.parse(json['data_presa_in_carico']) : null,
      json['password']?.toString(),
      json['dati']?.toString(),
      json['presenza_magazzino'],
      json['preventivo'],
      json['importo_preventivato']!= null ? double.parse(json['importo_preventivato'].toString()) : null,
      json['data_comunica_preventivo'] != null ? DateTime.parse(json['data_comunica_preventivo']) : null,
      json['preventivo_accettato'] != null ? json['preventivo_accettato'] : null,
      json['data_accettazione_preventivo'] != null ? DateTime.parse(json['data_accettazione_preventivo']) : null,
      json['diagnosi']?.toString(),
      json['risoluzione']?.toString(),
      json['data_conclusione'] != null ? DateTime.parse(json['data_conclusione']) : null,
      json['prodotti_installati']?.toString(),
      json['data_consegna'] != null ? DateTime.parse(json['data_consegna']) : null
    );
  }
}