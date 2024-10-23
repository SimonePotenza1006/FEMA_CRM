import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:io/ansi.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

import '../model/ClienteModel.dart';
import '../model/UtenteModel.dart';
import '../model/UtenteModel.dart';

class RegistrazioneMerceRiparazionePage extends StatefulWidget{
  final UtenteModel utente;

  const RegistrazioneMerceRiparazionePage ({Key? key, required this.utente}) : super(key:key);

  @override
  _RegistrazioneMerceRiparazionePageState createState() => _RegistrazioneMerceRiparazionePageState();
}

class _RegistrazioneMerceRiparazionePageState extends State<RegistrazioneMerceRiparazionePage>{

  final _formKey = GlobalKey<FormState>();
  final _articoloController = TextEditingController();
  final _accessoriController = TextEditingController();
  final _difettoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _datiController = TextEditingController();
  bool _preventivoRichiesto = false;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<XFile> pickedImages =  [];
  List<UtenteModel> allUtenti =[];
  List<ClienteModel> clientiList = [];
  List<ClienteModel> filteredClientiList = [];
  UtenteModel? responsabile;

  @override
  void initState() {
    super.initState();
    getAllUtenti();
    getAllClienti();
  }

  Future<void> getAllClienti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/cliente'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<ClienteModel> clienti = [];
        for (var item in jsonData) {
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          clientiList = clienti;
          filteredClientiList = clienti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }


  Future<void> getAllUtenti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/utente'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata Api: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Nuova merce in riparazione',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15,),
                  SizedBox(
                    width: 400,
                    child: _buildTextFormField(
                        _articoloController, "Articolo", "Inserisci una descrizione dell'articolo"),
                  ),
                  SizedBox(height: 15,),

                  _buildTextFormField(
                      _accessoriController, "Accessori", "Inserisci gli accessori se presenti"),
                  SizedBox(height: 15,),
                  _buildTextFormField(
                      _difettoController, "Difetto", "Inserisci il difetto riscontrato"),
                  SizedBox(height: 15,),
                  _buildTextFormField(
                      _passwordController, "Password", "Inserisci le password, se presenti"),
                  SizedBox(height: 15,),
                  _buildTextFormField(
                      _datiController, "Dati", "Inserisci i dati da salvaguardare"),
                  SizedBox(height: 15,),
                  Row(
                    children: [
                      Checkbox(
                        value: _preventivoRichiesto,
                        onChanged: (value) {
                          setState(() {
                            _preventivoRichiesto = value!;
                          });
                        },
                      ),
                      Text("è richiesto un preventivo?"),
                    ],
                  ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        responsabile = null;
                      });
                      _showSingleUtenteDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Bordo squadrato
                      ),
                    ),
                    child: Text(
                      'Seleziona tecnico',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 15,),
                ],
              ),
                  ElevatedButton(
                    onPressed: () async {
                      await createMerce();
                      Navigator.pop(context);
                    },
                    child: Text('Salva'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                    ),
                  ),
              ]
            ),
          ),
        )
      )
    );
  }

  void _showSingleUtenteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona un Utente', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lista degli utenti recuperati tramite la chiamata API
                  Column(
                    children: allUtenti.map((utente) {
                      return ListTile(
                        title: Text('${utente.nome} ${utente.cognome}'),
                        onTap: () {
                          // Imposta l'utente selezionato come _selectedUtente
                          setState(() {
                            responsabile = utente;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> createMerce() async{
    final url = Uri.parse('$ipaddress/api/merceInRiparazione');
    final body = jsonEncode({
      'data' : DateTime.now().toIso8601String(),
      'articolo' : _articoloController.text,
      'accessori': _accessoriController.text,
      'difetto_riscontrato': _difettoController.text,
      'password' : _passwordController.text,
      'dati' : _datiController.text,
      'preventivo' : _preventivoRichiesto,
    });
    try{
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        print('Merce creata con successo!');
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Qualcosa è andato storto!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        throw Exception('Errore durante il salvataggio del cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  // Future<void> takePicture() async {
  //   final ImagePicker _picker = ImagePicker();
  //   final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
  //
  //   if (pickedFile != null) {
  //     setState(() {
  //       pickedImages.add(pickedFile);
  //     });
  //   }
  // }
  //
  // Widget _buildImagePreview() {
  //   return SizedBox(
  //     height: 200,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: pickedImages.length,
  //       itemBuilder: (context, index) {
  //         return Padding(
  //           padding: EdgeInsets.all(8.0),
  //           child: Stack(
  //             alignment: Alignment.topRight,
  //             children: [
  //               Image.file(File(pickedImages[index].path)),
  //               IconButton(
  //                 icon: Icon(Icons.remove_circle),
  //                 onPressed: () {
  //                   setState(() {
  //                     pickedImages.removeAt(index);
  //                   });
  //                 },
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // Future<void> saveImagesMerce() async {
  //   try {
  //     for (var image in pickedImages) {
  //       // Verifica se il percorso del file è valido
  //       if (image.path != null && image.path.isNotEmpty) {
  //         print('Percorso del file: ${image.path}');
  //         var request = http.MultipartRequest(
  //           'POST',
  //           Uri.parse('$ipaddress/api/immagine/merce'),
  //         );
  //         // Provide field name and file path to fromPath constructor
  //         request.files.add(
  //           await http.MultipartFile.fromPath(
  //             filename: "Prova.jpg",
  //             'merce', // Field name
  //             image.path, // File path
  //             contentType: MediaType('image', 'jpeg'),
  //           ),
  //         );
  //         var response = await request.send();
  //         if (response.statusCode == 200) {
  //           print('File inviato con successo');
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Foto salvata!!'),
  //               duration: Duration(seconds: 1), // Durata dello Snackbar
  //             ),
  //           );
  //         } else {
  //           print('Errore durante l\'invio del file: ${response.statusCode}');
  //         }
  //       } else {
  //         // Gestisci il caso in cui il percorso del file non è valido
  //         print('Errore: Il percorso del file non è valido');
  //       }
  //     }
  //     Navigator.pop(context);
  //   } catch (e) {
  //     print('Errore durante l\'invio del file: $e');
  //   }
  // }


  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    );
  }
}