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
  bool? preventivo;
  double? importo_preventivato;
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
      this.preventivo,
      this.importo_preventivato,
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
      'preventivo': preventivo,
      'importo_preventivato' : importo_preventivato,
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
    preventivo = map['preventivo'];
    importo_preventivato = map['importo_preventivato'];
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
    'preventivo' : preventivo,
    'importo_preventivato' : importo_preventivato,
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
      json['preventivo'],
      json['importo_preventivato']!= null ? double.parse(json['importo_preventivato'].toString()) : null,
      json['diagnosi']?.toString(),
      json['risoluzione']?.toString(),
      json['data_conclusione'] != null ? DateTime.parse(json['data_conclusione']) : null,
      json['prodotti_installati']?.toString(),
      json['data_consegna'] != null ? DateTime.parse(json['data_consegna']) : null
    );
  }
}