import 'ClienteModel.dart';
import 'UtenteModel.dart';

class CredenzialiClienteModel {
  String? id;
  String? descrizione;
  String? credenziali;
  ClienteModel? cliente;
  UtenteModel? utente;

  CredenzialiClienteModel(this.id, this.descrizione, this.credenziali, this.cliente, this.utente);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'descrizione': descrizione,
      'credenziali' : credenziali,
      'cliente': cliente,
      'utente': utente,
    };
    return map;
  }

  CredenzialiClienteModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    descrizione = map['descrizione'];
    credenziali = map['credenziali'];
    cliente = ClienteModel.fromJson(map['cliente']);
    utente = UtenteModel.fromJson(map['utente']);
  }


  Map<String, dynamic> toJson() => {
        'id': id,
        'descrizione': descrizione,
        'credenziali' : credenziali,
        'cliente': cliente,
        'utente': utente
      };

  factory CredenzialiClienteModel.fromJson(Map<String, dynamic> json) {
    return CredenzialiClienteModel(
        json['id']?.toString(),
        json['descrizione']?.toString(),
        json['credenziali']?.toString(),
        ClienteModel.fromJson(json['cliente'] as Map<String, dynamic>),
        UtenteModel.fromJson(json['utente'] as Map<String, dynamic>));
  }
}
