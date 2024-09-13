import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'dart:io' as io;
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as iiimg;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';


import '../model/OrdinePerInterventoModel.dart';
import '../model/RuoloUtenteModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/UtenteModel.dart';
import '../model/ClienteModel.dart';
import '../model/VeicoloModel.dart';

class DbHelper{

  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddress1 = 'http://localhost:8080';
  String ipaddress3 ='http://79.10.122.110:8084';
  String ipaddress4 = 'http://10.0.2.2.8080';

  List<OrdinePerInterventoModel> allOrdini = [];
  List<VeicoloModel> allVeicoli = [];
  List<TipologiaInterventoModel> allTipologie = [];
  List<UtenteModel> allUtenti = [];

  Future<void> uploadPdfNoleggio(String uploadimage, io.File? uploadimageF)  async {//(String uploadimage, String idutente)  async {
    final directory= await getApplicationSupportDirectory();
    String path=directory.path;
    io.File? fileD = uploadimageF;//io.File("$path/$uploadimage");
    print('65nleg5');
    if (fileD!.existsSync()) {


      var postUri = Uri.parse('$ipaddress/api/pdf/noleggio');

      print('9legg8');
      http.MultipartRequest request;
      request = http.MultipartRequest('POST',
          postUri);


      List<int> fileBytes = await fileD.readAsBytes();
      // Crea un oggetto MultipartFile
      http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
        'pdf',
        fileBytes,
        filename: basename(uploadimage),
      );
      print('neggioleeew');

      request.files.add(multipartFile);//await http.MultipartFile.fromPath('pdf', fileD!.path));

      print('056nolg240 ');//+(fileD!.lengthSync()+request.contentLength).toString());

      Map<String, String> headers = {"Content-Type": "multipart/form-data"//, "Content-Length": (fileD.lengthSync()+request.contentLength).toString()//, "Content-Length": request.contentLength.toString()//, "Content-Length": (fileD.lengthSync()+request.contentLength).toString()
      };//bytesData.length.toString()};
      //Map<String, String> headers = {"Content-Type": "multipart/form-data; charset=utf-8", "Content-Length": fileD.lengthSync().toString()};
      request.headers.addAll(headers);
      print('req co le ' + request.contentLength.toString());

      //print(lung);
      print(fileD.length());

      try {
        var res = await request.send().then((value) =>
        //print(value.statusCode),
        (value.statusCode != 200) ?
        uploadPdfNoleggio(uploadimage, uploadimageF)
            : print('ooooklk'));
      }catch(e){
        //alertDialog("Problemi "+e.toString());
        uploadPdfNoleggio(uploadimage, uploadimageF);
        throw Exception(e);
      }
    } else {
      uploadPdfNoleggio(uploadimage, uploadimageF);
    }
  }

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


  // Future<List<ClienteModel>> getAllClienti() async{
  //   try{
  //     http.Response response = await http.get(Uri.parse('$ipaddress/api/cliente'));
  //     var responseData = json.decode(response.body.toString());
  //     if (response.statusCode == 200) {
  //       List<ClienteModel> clienti = [];
  //       for(var singoloCliente in responseData){
  //         List<TipologiaInterventoModel>? tipologieIntervento;
  //         if (singoloCliente['tipologie_interventi'] != null) {
  //           tipologieIntervento = (singoloCliente['tipologie_interventi'] as List<dynamic>)
  //               .map((data) => TipologiaInterventoModel.fromJson(data))
  //               .toList();
  //         }
  //         ClienteModel cliente = ClienteModel(
  //           singoloCliente['id'],
  //           singoloCliente['codice_fiscale'].toString(),
  //           singoloCliente['partita_iva'].toString(),
  //           singoloCliente['denominazione'].toString(),
  //           singoloCliente['indirizzo'].toString(),
  //           singoloCliente['cap'].toString(),
  //           singoloCliente['citta'].toString(),
  //           singoloCliente['provincia'].toString(),
  //           singoloCliente['nazione'].toString(),
  //           singoloCliente['recapito_fatturazione_elettronica'].toString(),
  //           singoloCliente['riferimento_amministrativo'].toString(),
  //           singoloCliente['referente'].toString(),
  //           singoloCliente['fax'].toString(),
  //           singoloCliente['telefono'].toString(),
  //           singoloCliente['cellulare'].toString(),
  //           singoloCliente['email'].toString(),
  //           singoloCliente['pec'].toString(),
  //           singoloCliente['note'].toString(),
  //           singoloCliente['note_tecnico'].toString(),
  //           tipologieIntervento,
  //         );
  //         clienti.add(cliente);
  //       }
  //       return clienti;
  //     }
  //     else{
  //       throw Exception('Failed to load clienti!');
  //     }
  //   }
  //   catch(e){
  //     print('Errore in get all clientiç $e');
  //     throw Exception(e);
  //   }
  // }

  Future<UtenteModel> getLoginUser(String email, String password) async {
    try {
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

extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year && this.month == other.month && this.day == other.day;
  }
}

class DbHelper1 extends StatefulWidget{
  const DbHelper1({Key? key}) : super(key: key);

  @override
  _DbHelper1State createState() => _DbHelper1State();
}

class _DbHelper1State extends State<DbHelper1>{

  String ipaddress = 'http://gestione.femasistemi.it:8090';

  List<OrdinePerInterventoModel> allOrdini = [];
  List<VeicoloModel> allVeicoli = [];
  List<TipologiaInterventoModel> allTipologie = [];
  List<UtenteModel> allUtenti = [];

  @override
  Widget build(BuildContext context){
    return Scaffold();
  }

  // Future<void> getAllVeicoli() async {
  //   try {
  //     var apiUrl = Uri.parse('$ipaddress/api/veicolo');
  //     var response = await http.get(apiUrl);
  //     if (response.statusCode == 200) {
  //       var jsonData = jsonDecode(response.body);
  //       List<VeicoloModel> veicoli = [];
  //       for (var item in jsonData) {
  //         veicoli.add(VeicoloModel.fromJson(item));
  //       }
  //       setState(() {
  //         allVeicoli = veicoli;
  //       });
  //     } else {
  //       throw Exception('Failed to load utenti data from API: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching agenti data from API: $e');
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {s
  //         return AlertDialog(
  //           title: Text('Connection Error'),
  //           content: Text('Unable to load data from API. Please check your internet connection and try again.'),
  //           actions: <Widget>[
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  Future<void> getTipologieIntervento() async {
    print('getTipologieIntervento chiamato');
    try {
      var apiUrl = Uri.parse('$ipaddress/api/tipologiaIntervento');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        print('getTipologieIntervento: chiamata API riuscita');
        var jsonData = jsonDecode(response.body);
        List<TipologiaInterventoModel> tipologie = [];
        for (var item in jsonData) {
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }
        setState(() {
          allTipologie = tipologie;
        });
      } else {
        print('getTipologieIntervento: fallita con status code ${response.statusCode}');
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }


}