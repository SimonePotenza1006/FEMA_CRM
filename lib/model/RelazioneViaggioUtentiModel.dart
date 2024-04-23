import 'package:fema_crm/model/UtenteModel.dart';
import 'package:fema_crm/model/ViaggioModel.dart';

class RelazioneViaggioUtentiModel{
  int? id;
  UtenteModel? utente;
  ViaggioModel? viaggio;

  RelazioneViaggioUtentiModel({
    this.id,
    this.utente,
    this.viaggio,
  });

  Map<String, dynamic> toMap(){
    return{
      'id' : id,
      'utente' : utente?.toMap(),
      'viaggio' : viaggio?.toMap(),
    };
  }

  factory RelazioneViaggioUtentiModel.fromMap(Map<String, dynamic> map) {
    return RelazioneViaggioUtentiModel(
      id : map['id'],
      utente: UtenteModel.fromMap(map['utente']),
      viaggio: ViaggioModel.fromMap(map['viaggio']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'utente' : utente?.toJson(),
    'viaggio' : viaggio?.toJson()
  };

  factory RelazioneViaggioUtentiModel.fromJson(Map<String, dynamic> json){
    return RelazioneViaggioUtentiModel(
      id: json['id'],
      utente: UtenteModel.fromJson(json['utente']),
      viaggio: ViaggioModel.fromJson(json['viaggio'])
    );
  }
}