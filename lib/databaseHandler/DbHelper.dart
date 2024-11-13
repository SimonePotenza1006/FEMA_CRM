import 'dart:convert';

import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/RestituzioneMerceModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
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


import '../model/AziendaModel.dart';
import '../model/DestinazioneModel.dart';
import '../model/DeviceModel.dart';
import '../model/FaseRiparazioneModel.dart';
import '../model/LicenzaModel.dart';
import '../model/OrdinePerInterventoModel.dart';
import '../model/RuoloUtenteModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/UtenteModel.dart';
import '../model/ClienteModel.dart';
import '../model/VeicoloModel.dart';

class DbHelper{

  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';


  List<OrdinePerInterventoModel> allOrdini = [];
  List<VeicoloModel> allVeicoli = [];
  List<TipologiaInterventoModel> allTipologie = [];
  List<UtenteModel> allUtenti = [];


  Future<void> uploadCertificazioneImpianto(
      String uploadImage,
      io.File? uploadImageF,
      String clienteNome
      ) async {
    final directory = await getApplicationSupportDirectory();
    String path = directory.path;
    io.File? fileD = uploadImageF;

    if (!fileD!.existsSync()) {
      throw Exception("File does not exist");
    }

    int retryCount = 0;
    int maxRetry = 3;

    // Ciclo di retry per tentare l'upload
    while (retryCount < maxRetry) {
      try {
        // Ricrea un nuovo MultipartRequest ad ogni tentativo
        var postUri = Uri.parse('$ipaddressProva/pdfu/certificazioni/clienti'); // Endpoint corretto
        http.MultipartRequest request = http.MultipartRequest('POST', postUri);

        // Leggi il file come bytes
        List<int> fileBytes = await fileD.readAsBytes();
        http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
          'pdf',
          fileBytes,
          filename: basename(uploadImage),
        );
        request.files.add(multipartFile);

        // Formatta il nome del cliente e invialo come campo del form
        String formattedNomeCliente = clienteNome.replaceAll(' ', '').toUpperCase();
        request.fields['cliente'] = formattedNomeCliente; // Nome campo corretto

        Map<String, String> headers = {
          "Content-Type": "multipart/form-data"
        };
        request.headers.addAll(headers);

        // Invia la richiesta
        var res = await request.send();

        // Controlla se l'upload è andato a buon fine
        if (res.statusCode == 200) {
          print('Upload completato con successo');
          break;
        } else {
          retryCount++;
          if (retryCount == maxRetry) {
            throw Exception('Errore: Impossibile caricare il file dopo $retryCount tentativi.');
          }
        }
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetry) {
          throw Exception("Upload fallito dopo $maxRetry tentativi: $e");
        }
      }
    }
  }



  Future<List<String>> getAllDevice() async {
    print("gelalldevice");
    try{
      http.Response response =
      await http
          .get(Uri.parse('$ipaddressProva/api/device'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        print(responseData.toString());
        //Creating a list to store input data;
        List<String> ruoli = [];

        print(ruoli.toString());
        for (var singleRuolo in responseData) {
          //responseData.forEach((singleRuolo) {
          DeviceModel ruolo = DeviceModel(

              singleRuolo['id'].toString(),
              singleRuolo['descrizione']
          );
          //print("ooooruoaldiookkppp");//singleRuolo["descrizione"]);
          //Adding interv to the list.
          ruoli.add(ruolo.descrizione!);
        };

        return ruoli;
      }
      else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load ruoli');
      }} catch(e){throw Exception(e);}
  }

  Future<http.Response> saveLicenzaNo(String user) async {
    late http.Response response;
    print('ppppppeetrr6sssasadppppppp');
    try {
      response = await http.post(

          Uri.parse('$ipaddressProva/api/licenza',),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: user

          ,
          encoding: Encoding.getByName('utf-8')
      );
      print(response.toString());

    } catch (e) {
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> saveDevice(DeviceModel user) async {
    late http.Response response;
    print('ppppppdevicpppppp');
    try {
      response = await http.post(

          Uri.parse('$ipaddressProva/api/device',),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: json.encode({
            'id': user.id,
            'descrizione': user.descrizione
          }),
          encoding: Encoding.getByName('utf-8')
      );
      print(response.toString());
      /*if(response.statusCode == 200){

        var data = jsonDecode(response.body.toString());
        //print(data['token']);
        print('Login successfully');

      }else {
        print('faileddd'+response.statusCode.toString());
      }*/
    } catch (e) {
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> saveLicenza(LicenzaModel user) async {
    late http.Response response;
    print('ppppppdevicpppppp');
    try {
      response = await http.post(

          Uri.parse('$ipaddressProva/api/licenza'),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: json.encode({
            'id': user.id,
            'descrizione': user.descrizione,
            'utilizzato': true,
          }),
          encoding: Encoding.getByName('utf-8')
      );
      print(response.toString());
      /*if(response.statusCode == 200){

        var data = jsonDecode(response.body.toString());
        //print(data['token']);
        print('Login successfully');

      }else {
        print('faileddd'+response.statusCode.toString());
      }*/
    } catch (e) {
      print(e.toString());
    }
    return response;
  }



  Future<List<String>> getAllLicenze() async {
    try{
      http.Response response =
      await http
          .get(Uri.parse('$ipaddressProva/api/licenza'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        print("gf45tr54");
        print(responseData.toString());
        //Creating a list to store input data;
        List<String> ruoli = [];
        //ruoli = List<RuoloModel>.from(responseData['data'].map( (x) => RuoloModel.fromJson(x)));
        print(ruoli.toString());
        for (var singleRuolo in responseData) {
          //responseData.forEach((singleRuolo) {
          LicenzaModel ruolo = LicenzaModel(

              singleRuolo['id'].toString(),
              singleRuolo['descrizione'],
              singleRuolo['utilizzato'],
              singleRuolo['note']
          );
          //print("ooooruoaldiookkppp");//singleRuolo["descrizione"]);
          //Adding interv to the list.
          ruoli.add(ruolo.descrizione!);
        };
        print(ruoli.toString());
        print("blicea1");
        return ruoli;
      }
      else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load lice');
      }} catch(e){throw Exception(e);}
  }

  Future<Uint8List> getPdfNoleggio(String filename)  async {
    final response =
    await http.get(Uri.parse('$ipaddressProva/api/pdf/preventiviServizi/$filename'));
    http.MultipartRequest request;
    return response.bodyBytes;
  }

  Future<List<ClienteModel>> getAllClienti() async{
    try{
      final response = await http.get(Uri.parse('$ipaddressProva/api/cliente'));
      if(response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
        List<ClienteModel> clienti = [];
        for(var item in jsonData){
          clienti.add(ClienteModel.fromJson(item));
        }
        return clienti;
      }
      return [];
    } catch(e){
      print("Errore fetching clienti:$e");
      return [];
    }
  }

  Future<List<FaseRiparazioneModel>> getFasiByMerce(InterventoModel intervento) async{
    int? merceId = intervento.merce != null ? int.parse(intervento.merce!.id!) : null;
    try{
      final response = await http.get(Uri.parse('$ipaddressProva/api/fasi/merce/$merceId'));
      if(response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
        List<FaseRiparazioneModel> fasi = [];
        for(var item in jsonData){
          fasi.add(FaseRiparazioneModel.fromJson(item));
        }
        return fasi;
      }
      return [];
    } catch(e){
      print('Errore fetching FASI: $e');
      return [];
    }
  }

  Future<List<DestinazioneModel>> getDestinazioneByCliente(ClienteModel cliente) async{
    int clienteId = int.parse(cliente.id!);
    try{
      final response = await http.get(Uri.parse('$ipaddressProva/api/destinazione/cliente/${clienteId}'));
      if(response.statusCode == 200){
         final jsonData = jsonDecode(response.body);
         List<DestinazioneModel> destinazioni = [];
         for(var item in jsonData){
           destinazioni.add(DestinazioneModel.fromJson(item));
        }
         return destinazioni;
      }
      return [];
    } catch(e){
      print('Errore fetching Destinazione By Cliente : $e');
      return [];
    }
  }

  Future<List<String>> getFilesnameNoleggio() async {
    try {
      final response = await http.get(Uri.parse('$ipaddressProva/api/pdf/preventiviServizi'));

      // Aggiungi questa riga per vedere il corpo della risposta.
      print('Risposta del server: ${response.body}');

      if (response.statusCode == 200) {
        List<String> ruoli = [];
        var responseData = json.decode(response.body.toString());

        for (var singleRuolo in responseData) {
          ruoli.add(singleRuolo);
        }

        return ruoli;
      } else {
        throw Exception('Failed to load ruoli');
      }
    } catch (e) {
      print('Errore: $e');
      throw Exception(e);
    }
  }


  Future<void> uploadPdfPreventivoServizi(String uploadimage, io.File? uploadimageF) async {
    // Controlla se il file passato è null
    if (uploadimageF == null) {
      print('Errore: il file passato è nullo');
      return;
    }

    final directory = await getApplicationSupportDirectory();
    String path = directory.path;

    // Costruisce il percorso del file usando il pacchetto 'path'
    String fullPath = p.join(path, uploadimage);
    io.File fileD = io.File(fullPath); // Usa il percorso costruito correttamente
    print('Controllo se il file esiste al percorso: $fullPath');

    // Verifica che il file esista
    if (fileD.existsSync()) {
      print('Il file esiste: ${fileD.path}');

      // Creazione dell'URI per la richiesta
      var postUri = Uri.parse('$ipaddressProva/api/pdf/preventivoServizi');
      print('URI creato: $postUri');

      // Creazione della richiesta
      http.MultipartRequest request = http.MultipartRequest('POST', postUri);

      // Legge il contenuto del file
      List<int> fileBytes = await fileD.readAsBytes();

      // Crea un oggetto MultipartFile da inviare
      http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
        'pdf',
        fileBytes,
        filename: basename(uploadimage), // Imposta il nome del file
      );

      // Aggiunge il file alla richiesta
      request.files.add(multipartFile);
      print('File aggiunto alla richiesta');

      // Aggiunge gli header necessari alla richiesta
      Map<String, String> headers = {
        "Content-Type": "multipart/form-data",
      };
      request.headers.addAll(headers);

      print('Headers aggiunti alla richiesta: ${request.headers}');
      print('Lunghezza richiesta: ${request.contentLength} byte');

      try {
        // Esegue l'invio della richiesta
        var res = await request.send();

        // Controlla il risultato della richiesta
        if (res.statusCode != 200) {
          print('Errore durante l\'invio del file: codice ${res.statusCode}');
          return; // Esce dalla funzione in caso di errore
        } else {
          print('File inviato con successo');
        }
      } catch (e) {
        // Gestisce eventuali errori durante l'invio della richiesta
        print('Errore durante l\'invio del file: $e');
        return; // Esce dalla funzione in caso di eccezione
      }
    } else {
      // Gestisce il caso in cui il file non esiste
      print('Errore: il file non esiste o non è accessibile: ${fileD.path}');
      return;
    }
  }

  Future<List<AziendaModel>> getAllAziende() async{
    try{
      http.Response response = await http.get(Uri.parse('$ipaddressProva/api/azienda'));
      var responseData = json.decode(response.body);
      if(response.statusCode == 200){
        List<AziendaModel> allAziende = [];
        for(var azieda in responseData){
          allAziende.add(AziendaModel.fromJson(azieda));
        }
        return allAziende;
      }
      return [];
    } catch(e){
      print('Errore nel buttare giù le aziende: $e');
      return [];
    }
  }

  Future<List<TipologiaInterventoModel>> getAllTipologieIntervento() async{
    try{
      http.Response response = await http.get(Uri.parse('$ipaddressProva/api/tipologiaIntervento'));
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


  Future<UtenteModel> getLoginUser(String email, String password) async {
    try {
      http.Response response = await http.post(
          Uri.parse('$ipaddressProva/api/utente/ulogin'),
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
    await http.get(Uri.parse('$ipaddressProva/api/utente/$userId'));

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
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';

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
  //     var apiUrl = Uri.parse('$ipaddressProva/api/veicolo');
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
      var apiUrl = Uri.parse('$ipaddressProva/api/tipologiaIntervento');
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