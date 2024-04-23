import 'dart:convert';
import 'package:http/http.dart' as http;



import '../model/RuoloUtenteModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/UtenteModel.dart';
import '../model/ClienteModel.dart';

class DbHelper{

  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddress1 = 'http://localhost:8080';
  String ipaddress3 ='http://79.10.122.110:8084';
  String ipaddress4 = 'http://10.0.2.2.8080';

  Future<List<TipologiaInterventoModel>> getAllTipologieIntervento() async{
    try{
      http.Response response = await http.get(Uri.parse('$ipaddress/api/tipologiaIntervento'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<TipologiaInterventoModel> allTipologieIntervento = [];
        for(var singolaTipologia in responseData){
          List<UtenteModel>? tecniciList;
          if (singolaTipologia['tecnici'] != null) {
            tecniciList = (singolaTipologia['tecnici'] as List<dynamic>)
                .map((data) => UtenteModel.fromJson(data))
                .toList();
          }
          TipologiaInterventoModel tipologiaIntervento = TipologiaInterventoModel(
            singolaTipologia['id'].toString(),
            singolaTipologia['descrizione'].toString(),
          );
          allTipologieIntervento.add(tipologiaIntervento);
        }
        return allTipologieIntervento;
      }
      else{
        throw Exception('Failed to load Tipologie Intervento');
      }
    }
    catch(e){
      print('Errore in get all tipologie $e');
      throw Exception(e);
    }
  }


  Future<List<ClienteModel>> getAllClienti() async{
    try{
      http.Response response = await http.get(Uri.parse('$ipaddress/api/cliente'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<ClienteModel> clienti = [];
        for(var singoloCliente in responseData){
          List<TipologiaInterventoModel>? tipologieIntervento;
          if (singoloCliente['tipologie_interventi'] != null) {
            tipologieIntervento = (singoloCliente['tipologie_interventi'] as List<dynamic>)
                .map((data) => TipologiaInterventoModel.fromJson(data))
                .toList();
          }
          ClienteModel cliente = ClienteModel(
            singoloCliente['id'].toString(),
            singoloCliente['codice_fiscale'].toString(),
            singoloCliente['partita_iva'].toString(),
            singoloCliente['denominazione'].toString(),
            singoloCliente['indirizzo'].toString(),
            singoloCliente['cap'].toString(),
            singoloCliente['citta'].toString(),
            singoloCliente['provincia'].toString(),
            singoloCliente['nazione'].toString(),
            singoloCliente['recapito_fatturazione_elettronica'].toString(),
            singoloCliente['riferimento_amministrativo'].toString(),
            singoloCliente['referente'].toString(),
            singoloCliente['fax'].toString(),
            singoloCliente['telefono'].toString(),
            singoloCliente['cellulare'].toString(),
            singoloCliente['email'].toString(),
            singoloCliente['pec'].toString(),
            singoloCliente['note'].toString(),
            singoloCliente['note_tecnico'].toString(),
            tipologieIntervento,
          );
          clienti.add(cliente);
        }
        return clienti;
      }
      else{
        throw Exception('Failed to load clienti!');
      }
    }
    catch(e){
      print('Errore in get all clientiç $e');
      throw Exception(e);
    }
  }

  void getUser()async {
    http.Response? response;
    try{
      http.Response response = await http.get(
          Uri.parse('$ipaddress/api/utente/1'),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          });
      return print('$response');
    } catch(e){
      throw Exception(e);
    }
  }


  Future<UtenteModel> getLoginUser(String email, String password) async {
    print("PROVA!");
    try {
      print('AIUTO');
      http.Response response = await http.post(
          Uri.parse('$ipaddress/api/utente/ulogin'),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: json.encode({
            'email': email,
            'password': password
          }),
          encoding: Encoding.getByName('utf-8')
      );

      if(response.statusCode == 200){
        print("OK!");
        var responseData = jsonDecode(response.body.toString());
        print('$responseData');
        UtenteModel utente = UtenteModel(
          responseData['id'].toString(),
          responseData['attivo'],
          responseData['nome'].toString(),
          responseData['cognome'].toString(),
          responseData['email'].toString(),
          responseData['password'].toString(),
          responseData['cellulare'].toString(),
          responseData['codice_fiscale'].toString(),
          responseData['iban'].toString(),
          RuoloUtenteModel.fromJson(responseData['ruolo']),
          TipologiaInterventoModel.fromJson(responseData['tipologia_intervento']),

        );
        print('Login done successfully!');
        return utente;
      }else {
        throw Exception('Login Failed ${response.statusCode}');
      }
    } catch(e){
      throw Exception('$e');
    }
  }

  Future<UtenteModel> getUtentebyId(String userId) async {
    final response =
    await http.get(Uri.parse('$ipaddress/api/utente/$userId'));

    if(response.statusCode == 200) {
      var responseData = jsonDecode(response.body.toString());
      print("$responseData");
      UtenteModel utente = UtenteModel(
        responseData["id"].toString(),
        responseData["attivo"],
        responseData["nome"],
        responseData["cognome"],
        responseData["email"],
        responseData["password"],
        responseData["cellulare"],
        responseData["codice_fiscale"],
        responseData["iban"],
        RuoloUtenteModel.fromJson(responseData["ruolo"]),
        TipologiaInterventoModel.fromJson(responseData["tipologia_intervento"]),
      );
      return utente;
    } else {
      throw Exception('Failed to load utente');
    }
  }
}