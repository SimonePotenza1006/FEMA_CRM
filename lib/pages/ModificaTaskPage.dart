import 'dart:io';
import 'dart:typed_data';
import 'package:fema_crm/pages/TableTaskPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../model/TipoTaskModel.dart';
import '../model/UtenteModel.dart';
import '../model/TaskModel.dart';
import 'package:intl/intl.dart';

import 'GalleriaFotoInterventoPage.dart';

class ModificaTaskPage extends StatefulWidget {
  final UtenteModel utente;
  final TaskModel task;
  const ModificaTaskPage({Key? key, required this.utente, required this.task}) : super(key: key);
  //const CreazioneTaskPage({Key? key}) : super(key: key);

  @override
  _ModificaTaskPageState createState() =>
      _ModificaTaskPageState();
}

class _ModificaTaskPageState
    extends State<ModificaTaskPage> {
  List<UtenteModel> allUtenti = [];
  // Controller for the text fields
  TextEditingController _descrizioneController = TextEditingController();
  TextEditingController _titoloController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  UtenteModel? selectedUtente;
  List<TipoTaskModel> allTipi = [];
  DateTime _dataOdierna = DateTime.now();
  DateTime? selectedDate = null;
  TipoTaskModel? _selectedTipo;
  bool _condiviso = false;
  bool _concluso = false;
  bool _accettato = false;
  TextEditingController _condivisoController = TextEditingController();
  TextEditingController _accettatoController = TextEditingController();
  TextEditingController _conclusoController = TextEditingController();
  Future<List<Uint8List>>? _futureImages;
  List<XFile> pickedImages =  [];

  @override
  void initState() {
    super.initState();
    _descrizioneController = TextEditingController(text: widget.task.descrizione);
    _titoloController = TextEditingController(text: widget.task.titolo);
    //_selectedTipo = widget.task.tipologia;
    _condiviso = widget.task.condiviso!;
    _concluso = widget.task.concluso!;
    _accettato = widget.task.accettato!;
    getAllUtenti();
    getAllTipi();
    _fetchImages();
  }

  void _fetchImages() {
    setState(() {
      _futureImages = fetchImages();
    });
  }

  Future<List<Uint8List>> fetchImages() async {
    final url = '$ipaddressProva/api/immagine/task/${int.parse(widget.task.id.toString())}/images';
    http.Response? response;
    try {
      response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final images = jsonData.map<Uint8List>((imageData) {
          final base64String = imageData['imageData'];
          final bytes = base64Decode(base64String);
          return bytes.buffer.asUint8List();
        }).toList();
        return images; // no need to wrap with Future
      } else {
        throw Exception('Errore durante la chiamata al server: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata al server: $e');
      if (response!= null) {
        //print('Risposta del server: ${response.body}');
      }
      throw e; // rethrow the exception
    }
  }

  Future<void> getAllTipi() async {
    try {
      var apiUrl = Uri.parse('$ipaddressProva/api/tipoTask');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<TipoTaskModel> tipi = [];
        for (var item in jsonData) {
          tipi.add(TipoTaskModel.fromJson(item));
        }
        setState(() {
          allTipi = tipi;
          // Imposta il valore di default solo dopo aver popolato la lista
          _selectedTipo = allTipi.firstWhere(
                (tipo) => tipo.id == widget.task.tipologia?.id!,
            orElse: () => allTipi[0], // Valore predefinito se non c'è corrispondenza
          );
        });
      } else {
        throw Exception(
            'Failed to load tipi task data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tipi task data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text(
                'Unable to load data from API. Please check your internet connection and try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> takePicture() async {
    final ImagePicker _picker = ImagePicker();

    // Verifica se sei su Android
    //if (Platform.isAndroid) {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        pickedImages.add(pickedFile);
      });
    }
    //}
    // Verifica se sei su Windows
    /*else if (Platform.isWindows) {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          pickedImages.addAll(pickedFiles);
        });
      }
    }*/
  }

  Future<void> pickImagesFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        pickedImages.addAll(pickedFiles);
      });
    }
    print(pickedImages);
  }

  Widget _buildImagePreview() {
    print('hjgfddfg');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('MODIFICA TASK',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
          child: LayoutBuilder(
              builder: (context, constraints){
                return Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        // Description Field
                        buildTFF(controller: _titoloController, label: "Titolo"),
                        SizedBox(height: 20),
                        // Description Field
                        buildTFF(controller: _descrizioneController, label: "Descrizione", maxLines: 6),
                        SizedBox(height: 20),
                        SizedBox(
                          width: 600,
                          child: buildCustomDropdown(
                              selectedValue: _selectedTipo,
                              items: allTipi,
                              label: "Tipologia",
                              itemLabelBuilder: (tipo) => tipo.descrizione!,
                              validator: (value){
                                if (value == null) {
                                  return 'Selezionare una tipologia';
                                }
                                return null;
                              },
                              onChanged: (TipoTaskModel? tipo){
                                setState(() {
                                  _selectedTipo = tipo;
                                });
                              }
                          ),
                        ),
                        SizedBox(height: 20),
                        (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? SizedBox(
                          width: 200,
                          child: CheckboxListTile(
                            title: Text('Condiviso'),
                            value: _condiviso,
                            onChanged: (value) {
                              setState(() {
                                _condiviso = value!;
                                if (_condiviso) {
                                  _condivisoController.clear();
                                }
                              });
                            },
                          ),
                        ) : Container(),
                        SizedBox(height: 20),// Button
                        if(widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti")
                          SizedBox(
                            width: 600,
                            child: buildCustomDropdown(
                                selectedValue: selectedUtente,
                                items: allUtenti,
                                label: "Utente condivisione",
                                itemLabelBuilder: (utente) => utente.nomeCompleto()!,
                                onChanged: (UtenteModel? utente){
                                  setState(() {
                                    selectedUtente = utente;
                                  });
                                }
                            ),
                          ),
                        !(widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? SizedBox(
                          width: 200,
                          child: CheckboxListTile(
                            title: Text('Accettato'),
                            value: _accettato,
                            onChanged: (value) {
                              setState(() {
                                _accettato = value!;
                                if (_accettato) {
                                  _accettatoController.clear();
                                }
                              });
                            },
                          ),
                        ) : Container(),
                        SizedBox(
                          width: 200,
                          child: CheckboxListTile(
                            title: Text('Concluso'),
                            value: _concluso,
                            onChanged: (value) {
                              setState(() {
                                _concluso = value!;
                                if (_concluso) {
                                  _conclusoController.clear();
                                }
                              });
                            },
                          ),
                        ),
                        FutureBuilder<List<Uint8List>>(
                          future: _futureImages,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal, // Imposta lo scroll orizzontale
                                child: Row(
                                  children: snapshot.data!.map((imageData) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PhotoViewPage(
                                              images: snapshot.data!,
                                              initialIndex: snapshot.data!.indexOf(imageData),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 150, // aumenta la larghezza del container
                                        height: 170, // aumenta l'altezza del container
                                        margin: EdgeInsets.symmetric(horizontal: 8.0), // Margine tra le immagini
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 1), // Aggiungi un bordo al container
                                        ),
                                        child: Image.memory(
                                          imageData,
                                          fit: BoxFit.cover, // Copri l'intero spazio del container
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Nessuna foto presente nel database!');
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                        SizedBox(height: 40),
                        Platform.isWindows ? Row(
                          children : [
                            ElevatedButton(
                              onPressed: pickImagesFromGallery,
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                onPrimary: Colors.white,
                              ),
                              child: Text('Allega Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                            )],
                        ) : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: ElevatedButton(
                                onPressed: takePicture,
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  onPrimary: Colors.white,
                                ),
                                child: Text('Scatta Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                              ),
                            ),
                            SizedBox(height: 16,),
                            Center(
                              child: ElevatedButton(
                                onPressed: pickImagesFromGallery,
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  onPrimary: Colors.white,
                                ),
                                child: Text('Allega Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                              ),
                            ),


                          ],),
                        SizedBox(height: 30),
                        if (pickedImages.isNotEmpty)
                          _buildImagePreview(),
                        SizedBox(height: 20),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _selectedTipo != null ? () {
                            savePics();
                          } : null,
                          child: Text('SALVA'),
                          style: ElevatedButton.styleFrom(
                            primary: _selectedTipo != null ? Colors.red : Colors.grey, // Cambia colore quando disabilitato
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );})),
      /*floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: EdgeInsets.all(22.0),
        child: ElevatedButton(
          onPressed: () {
            createTask();
          },
          child: Text('SALVA'),
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
            onPrimary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),*/
    );
  }

  Future<void> salvaTask() async {
    final formatter = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"); // Crea un formatter per il formato desiderato
    //var data = selectedDate != null ? selectedDate?.toIso8601String() : null;
    //final formattedDate = _dataController.text.isNotEmpty ? _dataController  // Formatta la data in base al formatter creato
    try {
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.task.id,
          'data_creazione': widget.task.data_creazione!.toIso8601String(),//DateTime.now().toIso8601String(),//data, // Utilizza la data formattata
          'data_conclusione': widget.task.data_conclusione != null ? widget.task.data_conclusione!.toIso8601String() : null,//null,
          'titolo' : _titoloController.text,
          'descrizione': _descrizioneController.text,
          'concluso': _concluso,
          'condiviso': _condiviso,
          'accettato': _accettato,
          'tipologia': _selectedTipo?.toMap(),
          'utente': _condiviso ? selectedUtente?.toMap() : widget.utente,
        }),
      );
      Navigator.of(context).pop();//Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task salvato con successo!'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio del task $e');
    }
  }

  Future<void> getAllUtenti() async {
    try {
      var apiUrl = Uri.parse('$ipaddressProva/api/utente/attivo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception(
            'Failed to load utenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text(
                'Unable to load data from API. Please check your internet connection and try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> savePics() async {
    if(pickedImages.isNotEmpty){
      try{
        for(var image in pickedImages){
          if(image.path.isNotEmpty){
            var request = http.MultipartRequest(
              'POST',
              Uri.parse('$ipaddressProva/api/immagine/task/${int.parse(widget.task.id!.toString())}'),
            );
            request.files.add(
              await http.MultipartFile.fromPath(
                'task', // Field name
                image.path, // File path
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
              salvaTask();
            } else {
              print('Errore durante l\'invio del file: ${response.statusCode}');
            }
          }
        }
      } catch(e){
        print('Errore durante l\'invio del file: $e');
      }
    } else{
      salvaTask();
    }
  }

  Widget buildCustomDropdown<T>({
    required T? selectedValue,
    required List<T> items,
    required String label,
    required void Function(T?) onChanged,
    String Function(T)? itemLabelBuilder,
    String? Function(T?)? validator,
  }) {
    return SizedBox(
      width: 400,
      child: DropdownButtonFormField<T>(
        value: selectedValue,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<T>>((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabelBuilder != null ? itemLabelBuilder(item) : item.toString(),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
        validator: validator ??
                (value) {
              if (value == null) {
                return 'Selezionare un valore';
              }
              return null;
            },
      ),
    );
  }

  Widget buildTFF({
    required TextEditingController controller,
    required String label,
    int maxLines = 1, // Valore predefinito di 1
  }) {
    return SizedBox(
      width: 600,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          alignLabelWithHint: true,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
      ),
    );
  }
}