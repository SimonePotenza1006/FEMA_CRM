import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../model/CategoriaPrezzoListinoModel.dart';
import '../model/VeicoloModel.dart';
import '../model/CategoriaInterventoSpecificoModel.dart';
import '../model/InterventoModel.dart';
import '../model/ImmagineModel.dart';
import 'dart:ui' as ui;


class CompilazioneRapportinoPage extends StatefulWidget {
  final InterventoModel intervento;

  CompilazioneRapportinoPage({Key? key, required this.intervento}) : super(key: key);


  @override
  _CompilazioneRapportinoPageState createState() => _CompilazioneRapportinoPageState();
}

class _CompilazioneRapportinoPageState extends State<CompilazioneRapportinoPage> {

  String? selectedListino;
  List<CategoriaPrezzoListinoModel> listini = [];
  late DateTime selectedDate;
  late TimeOfDay selectedStartTime;
  String rapportinoText = '';
  GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey<SfSignaturePadState>();
  Uint8List? signatureBytes;
  String? selectedVeicolo;
  String? selectedInterventoSpecifico;
  List<CategoriaInterventoSpecificoModel> categorie =[];
  XFile? pickedImage;
  bool showListinoDropdown = false;

  String timeOfDayToIso8601String(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return dateTime.toIso8601String();
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.intervento.data ?? DateTime.now();
    selectedStartTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Compilazione Rapportino',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dettagli Intervento:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Orario Inizio: ${selectedStartTime.format(context)}'),
                  IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedStartTime,
                      );
                      if (picked != null && picked != selectedStartTime)
                        setState(() {
                          selectedStartTime = picked;
                        });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              FutureBuilder<List<VeicoloModel>>(
                future: getAllVeicoli(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Errore durante il recupero dei veicoli: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    List<VeicoloModel> veicoli = snapshot.data!;
                    return DropdownButton<String>(
                      value: selectedVeicolo,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedVeicolo = newValue!;
                          showListinoDropdown = true;
                        });
                      },
                      isExpanded: true,
                      hint: Text('Seleziona un veicolo'),
                      items: veicoli.map<DropdownMenuItem<String>>((veicolo) {
                        return DropdownMenuItem<String>(
                          value: veicolo.id,
                          child: Text(veicolo.descrizione.toString()),
                        );
                      }).toList(),
                    );
                  } else {
                    return Text('Nessun dato disponibile');
                  }
                },
              ),
              if (showListinoDropdown)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Seleziona Categoria Intervento Specifico:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    FutureBuilder<List<CategoriaInterventoSpecificoModel>>(
                      future: getCategoriaByTipologia(widget.intervento.tipologia!.id.toString()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Errore durante il recupero dei dati: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          List<CategoriaInterventoSpecificoModel> categorie = snapshot.data!;
                          return DropdownButton<String>(
                            value: selectedInterventoSpecifico,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedInterventoSpecifico = newValue!;
                                selectedListino = null;
                              });
                            },
                            isExpanded: true,
                            hint: Text('Seleziona la categoria dell\'intervento'),
                            items: categorie.map<DropdownMenuItem<String>>((categoria) {
                              return DropdownMenuItem<String>(
                                value: categoria.id,
                                child: Text(categoria.descrizione.toString()),
                              );
                            }).toList(),
                          );
                        } else {
                          return Text('Nessun dato disponibile');
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Seleziona il Listino associato:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    FutureBuilder<List<CategoriaPrezzoListinoModel>>(
                      future: getListiniByCategoria(selectedInterventoSpecifico ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Errore durante il recupero dei dati: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          List<CategoriaPrezzoListinoModel> listini = snapshot.data!;
                          return DropdownButton<String>(
                            value: selectedListino,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedListino = newValue!;
                              });
                            },
                            isExpanded: true,
                            hint: Text('Seleziona il listino associato'),
                            items: listini.map<DropdownMenuItem<String>>((listino) {
                              return DropdownMenuItem<String>(
                                value: listino.id,
                                child: Text(listino.descrizione.toString()),
                              );
                            }).toList(),
                          );
                        } else {
                          return Text('Nessun dato disponibile');
                        }
                      },
                    ),
                  ],
                ),
              SizedBox(height: 20),
              Text(
                'Compila il rapportino:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                maxLines: null,
                onChanged: (value) {
                  setState(() {
                    rapportinoText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Inserisci qui il rapportino...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Inserisci la tua firma:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          width: 700,
                          height: 250,
                          child: SfSignaturePad(
                            key: _signaturePadKey,
                            backgroundColor: Colors.white,
                            strokeColor: Colors.black,
                            minimumStrokeWidth: 2.0,
                            maximumStrokeWidth: 4.0,
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Chiudi'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final signatureImage = await _signaturePadKey.currentState!.toImage(pixelRatio: 3.0);
                              final data = await signatureImage.toByteData(format: ui.ImageByteFormat.png);
                              setState(() {
                                signatureBytes = data!.buffer.asUint8List();
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text('Salva'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: signatureBytes != null
                        ? Image.memory(signatureBytes!)
                        : Text(
                      'Tocca per aggiungere la firma',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Scatta una foto:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () {
                      takePicture();
                    },
                  ),
                  if (pickedImage != null)
                    Container(
                      width: 50,
                      height: 50,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                child: Image.file(
                                  File(pickedImage!.path),
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          );
                        },
                        child: Image.file(File(pickedImage!.path)),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        saveIntervento();
                        print('Rapportino salvato');
                        //Navigator.pop(context); // Torna alla pagina precedente
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        onPrimary: Colors.white,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: Text('Salva Rapportino'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (pickedImage != null) {
                          saveImageIntervento(File(pickedImage!.path));
                        }
                        print('Immagine Salvata');
                        //Navigator.pop(context); // Torna alla pagina precedente
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        onPrimary: Colors.white,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: Text('Salva Foto'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<VeicoloModel>> getAllVeicoli() async {
    try {
      http.Response response = await http.get(Uri.parse('http://192.168.1.52:8080/api/veicolo'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<VeicoloModel> allVeicoli = [];
        for (var veicoloJson in responseData) {
          VeicoloModel veicolo = VeicoloModel.fromJson(veicoloJson);
          allVeicoli.add(veicolo);
        }
        return allVeicoli;
      } else {
        return [];
      }
    } catch (e) {
      print('Errore durante il fetch dei veicoli: $e');
      return [];
    }
  }

  Future<List<CategoriaInterventoSpecificoModel>> getCategoriaByTipologia(String tipologiaId) async {
    try {
      http.Response response = await http.get(Uri.parse('http://192.168.1.52:8080/api/categorieIntervento/tipologia/$tipologiaId'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<CategoriaInterventoSpecificoModel> allCategorieByTipologia = [];
        for (var categoriaJson in responseData) {
          CategoriaInterventoSpecificoModel categoria = CategoriaInterventoSpecificoModel.fromJson(categoriaJson);
          allCategorieByTipologia.add(categoria);
        }
        return allCategorieByTipologia;
      } else {
        return [];
      }
    } catch (e) {
      print('Errore durante il fetch delle categorie: $e');
      return [];
    }
  }

  Future<List<CategoriaPrezzoListinoModel>> getListiniByCategoria(String categoriaId) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.52:8080/api/listino/categoria/$categoriaId'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<CategoriaPrezzoListinoModel> listini = responseData.map((data) => CategoriaPrezzoListinoModel.fromJson(data)).toList();
        return listini;
      } else {
        throw Exception('Failed to load listini');
      }
    } catch (e) {
      print('Error fetching listini: $e');
      throw Exception('Failed to load listini');
    }
  }

  Future<void> takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        pickedImage = pickedFile;
      });
    }
  }

  Future<void> saveIntervento() async {
    Map<String, dynamic> body = {};
    final CategoriaPrezzoListinoModel listinoSelezionato = listini.firstWhere(
          (listino) => listino.id == selectedListino,
      orElse: () => CategoriaPrezzoListinoModel(null, null, null, null),
    );
    final CategoriaInterventoSpecificoModel categoriaSelezionata = categorie.firstWhere(
          (categoria) => categoria.id == selectedInterventoSpecifico,
      orElse: () => CategoriaInterventoSpecificoModel(null, null, null),
    );
    if (listinoSelezionato != null) {
      body['listino'] = listinoSelezionato.toJson();
    } else {
      print('Errore: Listino non trovato');
      return;
    }
    if (categoriaSelezionata != null) {
      body['categoria_intervento_specifico'] = categoriaSelezionata.toJson();
    } else {
      print('Errore: Categoria intervento specifico non trovata');
      return;
    }
    body.addAll({
      'id': widget.intervento.id,
      'data': selectedDate.toIso8601String(),
      'orario_inizio': timeOfDayToIso8601String(selectedStartTime),
      'orario_fine': DateTime.now().toIso8601String(),
      'descrizione': widget.intervento.descrizione,
      'importo_intervento': listinoSelezionato.prezzo,
      'assegnato': true,
      'concluso': true,
      'saldato': true,
      'note': rapportinoText.toString(),
      'firma_cliente': signatureBytes,
      'utente': widget.intervento.utente?.toMap(),
      'cliente': widget.intervento.cliente?.toMap(),
      'veicolo': widget.intervento.veicolo?.toMap(),
      'tipologia': widget.intervento.tipologia?.toMap(),
      'categoria_intervento_specifico': categoriaSelezionata.toMap(),
      'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
      'destinazione': widget.intervento.destinazione?.toMap(),
    });
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.52:8080/api/intervento'),
        body: jsonEncode(body),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 201) {
        print('Intervento salvato con successo');
      } else {
        print('Errore durante il salvataggio dell\'intervento: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata HTTP: $e');
    }
  }

  Future<void> saveImageIntervento(File imageFile) async {
    try {
      final CategoriaPrezzoListinoModel listinoSelezionato = listini.firstWhere(
            (listino) => listino.id == selectedListino,
        orElse: () => CategoriaPrezzoListinoModel(null, null, null, null),
      );
      final CategoriaInterventoSpecificoModel categoriaSelezionata = categorie.firstWhere(
            (categoria) => categoria.id == selectedInterventoSpecifico,
        orElse: () => CategoriaInterventoSpecificoModel(null, null, null),
      );
      String interventoId = widget.intervento.id.toString();

      // Creazione della richiesta multipart
      var request = http.MultipartRequest('POST', Uri.parse('http://192.168.1.52:8080/api/immagine/$interventoId'));

      // Aggiunta del file come parte della richiesta multipart
      request.files.add(
        await http.MultipartFile.fromPath(
          'intervento', // Nome del campo nel backend
          imageFile.path,
        ),
      );

      // Aggiunta dei dati relativi all'intervento come parte della richiesta
      request.fields['name'] = 'immagine_intervento${widget.intervento.id.toString()}.jpg';
      request.fields['type'] = 'jpg';
      request.fields['intervento'] = jsonEncode({
        'id': widget.intervento.id,
        'data': selectedDate.toIso8601String(),
        'orario_inizio': timeOfDayToIso8601String(selectedStartTime),
        'orario_fine': DateTime.now().toIso8601String(),
        'descrizione': widget.intervento.descrizione,
        'importo_intervento': listinoSelezionato.prezzo,
        'assegnato': true,
        'concluso': true,
        'saldato': true,
        'note': rapportinoText.toString(),
        'firma_cliente': signatureBytes,
        'utente': widget.intervento.utente?.toMap(),
        'cliente': widget.intervento.cliente?.toMap(),
        'veicolo': widget.intervento.veicolo?.toMap(),
        'tipologia': widget.intervento.tipologia?.toMap(),
        'categoria_intervento_specifico': categoriaSelezionata.toMap(),
        'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
        'destinazione': widget.intervento.destinazione?.toMap(),
      });

      // Invio della richiesta multipart
      var response = await request.send();

      // Controllo dello stato della risposta
      if (response.statusCode == 200) {
        print('Immagine salvata con successo');
      } else {
        print('Errore durante il salvataggio dell\'immagine: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata HTTP: $e');
    }
  }



}
