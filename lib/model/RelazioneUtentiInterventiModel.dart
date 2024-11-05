import 'UtenteModel.dart';
import 'InterventoModel.dart';

class RelazioneUtentiInterventiModel{
  int? id;
  InterventoModel? intervento;
  UtenteModel? utente;
  bool? visualizzato;

  RelazioneUtentiInterventiModel({
    this.id,
    this.intervento,
    this.utente,
    this.visualizzato
  });

  Map<String, dynamic> toMap(){
    return{
      'id' : id,
      'intervento' : intervento?.toMap(),
      'utente' : utente?.toMap(),
      'visualizzato' : visualizzato,
    };
  }

  factory RelazioneUtentiInterventiModel.fromMap(Map<String, dynamic> map){
    return RelazioneUtentiInterventiModel(
      id: map['id'],
      intervento: InterventoModel.fromMap(map['intervento']),
      utente: UtenteModel.fromMap(map['utente']),
      visualizzato: map['visualizzato']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'intervento': intervento?.toJson(),
    'utente' : utente?.toJson(),
    'visualizzato' : visualizzato,
  };

  factory RelazioneUtentiInterventiModel.fromJson(Map<String, dynamic> json){
    return RelazioneUtentiInterventiModel(
      id: json['id'],
      intervento: InterventoModel.fromJson(json['intervento']),
      utente: UtenteModel.fromJson(json['utente']),
      visualizzato: json['visualizzato']
    );
  }
}