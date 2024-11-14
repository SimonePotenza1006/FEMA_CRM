import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/ProdottoModel.dart';
import 'package:fema_crm/model/ToDoModel.dart';

import 'UtenteModel.dart';

class RelazioneUtentiToDoModel{
  int? id;
  ToDoModel? todo;
  UtenteModel? utente;
  bool? accettato;


  RelazioneUtentiToDoModel(
    this.id,
    this.todo,
    this.utente,
    this.accettato,
  );

  Map<String, dynamic> toMap(){
    return{
      'id' : id,
      'todo' : todo?.toMap(),
      'utente': utente?.toMap(),
      'accettato' : accettato,

    };
  }

  RelazioneUtentiToDoModel.fromMap(Map<String, dynamic> map){
      id = map['id'];
      map['todo'] != null ? ToDoModel.fromMap(map['todo']) : null;
      map['utente'] != null ? UtenteModel.fromMap(map['utente']) : null;
      accettato = map['accettato'];
  }

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'todo' : todo?.toJson(),
    'utente' : utente?.toJson(),
    'accettato' : accettato,
  };

  factory RelazioneUtentiToDoModel.fromJson(Map<String, dynamic> json){
    return RelazioneUtentiToDoModel(
      json['id'],
      json['todo'] != null ? ToDoModel.fromJson(json['todo']) : null,
      json['utente'] != null ? UtenteModel.fromJson(json['utente']) : null,
      json['accettato'],
    );
  }
}