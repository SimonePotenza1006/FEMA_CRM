import 'dart:convert';
import 'dart:ui';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';
import '../model/ClienteModel.dart';
import '../model/DestinazioneModel.dart';
import '../model/InterventoModel.dart';
import '../model/TicketModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/UtenteModel.dart';

class CreazioneTicketTecnicoPage extends StatefulWidget{
  final UtenteModel utente;

  const CreazioneTicketTecnicoPage({Key? key, required this.utente}) : super(key : key);

  @override
  _CreazioneTicketTecnicoPageState createState() => _CreazioneTicketTecnicoPageState();
}

class _CreazioneTicketTecnicoPageState extends State<CreazioneTicketTecnicoPage>{

  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  TextEditingController _descrizioneController = TextEditingController();
  TextEditingController _notaController = TextEditingController();
  TextEditingController _titoloController = TextEditingController();
  List<TipologiaInterventoModel> allTipologie = [];
  TipologiaInterventoModel? _selectedTipologia;
  List<XFile> pickedImages =  [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getAllTipologie();
  }

  Future<void> pickImagesFromGallery() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        pickedImages.addAll(pickedFiles);
      });
    }
  }


  Future<void> getAllTipologie() async {
    try {
      final response = await http.get(Uri.parse('$ipaddressProva/api/tipologiaIntervento'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<TipologiaInterventoModel> tipologie = [];
        for (var item in jsonData) {
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }
        setState(() {
          allTipologie = tipologie;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog(e.toString());
    }
  }

  Future<void> takePicture() async {
    final ImagePicker _picker = ImagePicker();
    // Verifica se sei su Android
    if (Platform.isAndroid) {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          pickedImages.add(pickedFile);
        });
      }
    }
    // Verifica se sei su Windows
    else if (Platform.isWindows) {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          pickedImages.addAll(pickedFiles);
        });
      }
    }
  }

  Widget _buildImagePreview() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pickedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(File(pickedImages[index].path)),
                IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      pickedImages.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SfGlobalLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('it'),
      ],
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CREAZIONE TICKET', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.red,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 16,
              right: 16,
              child: SpeedDial(
                animatedIcon: AnimatedIcons.menu_close,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                children:[
                  SpeedDialChild(
                      child: Icon(Icons.attach_file, color: Colors.white),
                      backgroundColor: Colors.red,
                      label: 'Allega da galleria'.toUpperCase(),
                      onTap: (){
                        pickImagesFromGallery();
                      }
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.camera_alt_outlined, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: 'Scatta foto'.toUpperCase(),
                    onTap: (){
                      takePicture();
                    }
                  ),
                  SpeedDialChild(
                      child: Icon(Icons.save, color: Colors.white),
                      backgroundColor: Colors.red,
                      label: 'Salva ticket'.toUpperCase(),
                      onTap: (){
                        savePics();
                      }
                  ),
                ]
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
            child: LayoutBuilder(
                builder: (context, constraints){
                  if(constraints.maxWidth >= 800){
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20.0),
                                  SizedBox(
                                    width: 600,
                                    child: TextFormField(
                                      controller: _descrizioneController,
                                      maxLines: 6, // Imposta l'altezza in termini di righe di testo
                                      decoration: InputDecoration(
                                        labelText: 'Descrizione'.toUpperCase(),
                                        alignLabelWithHint: true, // Allinea il label in alto quando ci sono più righe
                                        filled: true,
                                        fillColor: Colors.grey[200], // Sfondo grigio chiaro
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12), // Bordi leggermente arrotondati
                                          borderSide: BorderSide(
                                            color: Colors.grey, // Colore del bordo
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey, // Colore del bordo per lo stato attivo
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.blue, // Colore del bordo quando il campo è attivo
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 600,
                                    child: TextFormField(
                                      controller: _notaController,
                                      maxLines: 6, // Imposta l'altezza in termini di righe di testo
                                      decoration: InputDecoration(
                                        labelText: 'Nota'.toUpperCase(),
                                        alignLabelWithHint: true, // Allinea il label in alto quando ci sono più righe
                                        filled: true,
                                        fillColor: Colors.grey[100], // Sfondo grigio chiaro
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12), // Bordi leggermente arrotondati
                                          borderSide: BorderSide(
                                            color: Colors.grey, // Colore del bordo
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey, // Colore del bordo per lo stato attivo
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.red, // Colore del bordo quando il campo è attivo
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 316,
                                    child: DropdownButton<TipologiaInterventoModel>(
                                      value: _selectedTipologia,
                                      hint:  Text('Tipologia di intervento'.toUpperCase()),
                                      onChanged: (TipologiaInterventoModel? newValue) {
                                        setState(() {
                                          _selectedTipologia = newValue;
                                        });
                                      },
                                      items: allTipologie
                                          .map<DropdownMenuItem<TipologiaInterventoModel>>(
                                            (TipologiaInterventoModel value) => DropdownMenuItem<TipologiaInterventoModel>(
                                          value: value,
                                          child: Text(value.descrizione!),
                                        ),
                                      ).toList(),
                                    ),
                                  ),
                                  _buildImagePreview(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else{
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20.0),
                                  SizedBox(
                                    width: 600,
                                    child: TextFormField(
                                      controller: _descrizioneController,
                                      maxLines: 6, // Imposta l'altezza in termini di righe di testo
                                      decoration: InputDecoration(
                                        labelText: 'Descrizione'.toUpperCase(),
                                        alignLabelWithHint: true, // Allinea il label in alto quando ci sono più righe
                                        filled: true,
                                        fillColor: Colors.grey[100], // Sfondo grigio chiaro
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12), // Bordi leggermente arrotondati
                                          borderSide: BorderSide(
                                            color: Colors.grey, // Colore del bordo
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey, // Colore del bordo per lo stato attivo
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.red, // Colore del bordo quando il campo è attivo
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 600,
                                    child: TextFormField(
                                      controller: _notaController,
                                      maxLines: 6, // Imposta l'altezza in termini di righe di testo
                                      decoration: InputDecoration(
                                        labelText: 'Nota'.toUpperCase(),
                                        alignLabelWithHint: true, // Allinea il label in alto quando ci sono più righe
                                        filled: true,
                                        fillColor: Colors.grey[100], // Sfondo grigio chiaro
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12), // Bordi leggermente arrotondati
                                          borderSide: BorderSide(
                                            color: Colors.grey, // Colore del bordo
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey, // Colore del bordo per lo stato attivo
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.red, // Colore del bordo quando il campo è attivo
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                    Center(
                                      child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Form(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        width: 316,
                                                        child: DropdownButton<TipologiaInterventoModel>(
                                                          value: _selectedTipologia,
                                                          hint:  Text('Tipologia di intervento'.toUpperCase()),
                                                          onChanged: (TipologiaInterventoModel? newValue) {
                                                            setState(() {
                                                              _selectedTipologia = newValue;
                                                            });
                                                          },
                                                          items: allTipologie
                                                              .map<DropdownMenuItem<TipologiaInterventoModel>>(
                                                                (TipologiaInterventoModel value) => DropdownMenuItem<TipologiaInterventoModel>(
                                                              value: value,
                                                              child: Text(value.descrizione!),
                                                            ),
                                                          ).toList(),
                                                        ),
                                                      ),
                                                      SizedBox(height: 15,),
                                                      _buildImagePreview(),
                                                    ]
                                                ),
                                              ),
                                            )
                                          ]
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
            )
        ),
      ),
    );
  }

  Future<http.Response?> saveTicket() async{
    late http.Response response;
    var note = _notaController.text.isNotEmpty ? _notaController.text : null;
    var titolo = _titoloController.text.isNotEmpty ? _titoloController.text : null;
    var descrizione = _descrizioneController.text.isNotEmpty ? _descrizioneController.text : null;
    try{
      response = await http.post(
        Uri.parse('$ipaddressProva/api/ticket'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titolo' : titolo,
          'descrizione' : descrizione,
          'note' : note,
          'convertito' : false,
          'tipologia' : _selectedTipologia?.toMap(),
          'utente' : widget.utente.toMap(),
        }),
      );
      print('Ticket salvato!');
      return response;
    } catch(e){
      print('Errore durante il salvataggio del ticket: $e');
    }
    return null;
  }

  Future<void> savePics() async {
    // Mostra il dialog con il CircularProgressIndicator
    showDialog(
      context: context,
      barrierDismissible: false, // Impedisce di chiudere il dialog premendo fuori
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Attendere...',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );

    // Inizia il salvataggio
    try {
      final data = await saveTicket();
      if (data == null) {
        print('Errore: Dati del ticket non disponibili.');
        Navigator.pop(context); // Chiude il dialog
        Navigator.pop(context); // Torna indietro nella navigazione
        return;
      }
      final ticket = TicketModel.fromJson(jsonDecode(data.body));
      for (var image in pickedImages) {
        if (image.path.isNotEmpty) {
          print('Percorso del file: ${image.path}');
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('$ipaddressProva/api/immagine/ticket/${int.parse(ticket.id.toString())}'),
          );
          request.files.add(
            await http.MultipartFile.fromPath(
              'ticket',
              image.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
          var response = await request.send();
          if (response.statusCode == 200) {
            print('File inviato con successo');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Foto salvata!'),
              ),
            );
          } else {
            print('Errore durante l\'invio del file: ${response.statusCode}');
          }
        } else {
          print('Errore: Il percorso del file non è valido');
        }
      }
    } catch (e) {
      print('Errore durante l\'invio del file: $e');
    } finally {
      // Chiude il dialog e torna indietro nella navigazione
      Navigator.pop(context); // Chiude il dialog
      Navigator.pop(context); // Torna indietro nella navigazione
    }
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText) {
    return SizedBox(
      width: 300,
      child: TextFormField(
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
      ),
    );
  }

  void _showErrorDialog(String? exception) {
    if(mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Errore di connessione'),
            content: Text(
              'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.\nException: '+exception!,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
