import 'dart:io';
import 'package:fema_crm/pages/TableTaskPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../model/TipoTaskModel.dart';
import '../model/UtenteModel.dart';
import '../model/TaskModel.dart';
import 'package:intl/intl.dart';

class CreazioneTaskPage extends StatefulWidget {
  final UtenteModel utente;
  const CreazioneTaskPage({Key? key, required this.utente}) : super(key: key);
  //const CreazioneTaskPage({Key? key}) : super(key: key);

  @override
  _CreazioneTaskPageState createState() =>
      _CreazioneTaskPageState();
}

class _CreazioneTaskPageState
    extends State<CreazioneTaskPage> {
  List<UtenteModel> allUtenti = [];
  List<TipoTaskModel> allTipi = [];
  // Controller for the text fields
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _titoloController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  UtenteModel? selectedUtente;
  DateTime _dataOdierna = DateTime.now();
  DateTime? selectedDate = null;
  TipoTaskModel? _selectedTipo;
  bool _condiviso = false;
  final TextEditingController _condivisoController = TextEditingController();
  List<XFile> pickedImages =  [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getAllUtenti();
    getAllTipi();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _selezionaData() async {
    final DateTime? dataSelezionata = await showDatePicker(
      locale: const Locale('it', 'IT'),
      context: context,
      initialDate: _dataOdierna,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataSelezionata != null && dataSelezionata != _dataOdierna) {
      setState(() {
        selectedDate = dataSelezionata;
      });
    }
  }

  Future<void> takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        pickedImages.add(pickedFile);
      });
    }
  }

  Future<void> pickImagesFromGallery() async {
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
      width: 200,
      height: 150,
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
        title: const Text('CREAZIONE TASK',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: LayoutBuilder(
      builder: (context, constraints){

      return Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // Description Field
                SizedBox(
                  width: 600,
                  child: buildTFF(controller: _titoloController, label: "Titolo"),
                ),
                SizedBox(height: 20),
                // Description Field
                SizedBox(
                  width: 600,
                  child: buildTFF(controller: _descrizioneController, label: "Descrizione", maxLines: 6),
                ),
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
                SizedBox(
                  width: 200,
                  child: buildCustomCheckbox(
                    value: _condiviso,
                    label: 'Condiviso',
                    onChanged: (value) {
                      setState(() {
                        _condiviso = value!;
                        if (_condiviso) {
                          _condivisoController.clear();
                        }
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),// Button
                if (_condiviso) SizedBox(
                  width: 600,
                  child:  buildCustomDropdown(
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
                SizedBox(height: 40),
                Platform.isWindows ? Center(
                  child: ElevatedButton(
                    onPressed: pickImagesFromGallery,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                    ),
                    child: Text('Allega Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                  ),
                ) : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                  SizedBox(width: 16,),
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
                SizedBox(height: 10),
                _buildImagePreview(),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
      }
      ), floatingActionButton: Padding(
      padding: EdgeInsets.all(10.0),
      child: ElevatedButton(
        onPressed: _selectedTipo != null ? () {
          saveTaskPlusPics();
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
    ));
  }

  Future<http.Response?> createTask() async {
    final formatter = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"); // Crea un formatter per il formato desiderato
    //var data = selectedDate != null ? selectedDate?.toIso8601String() : null;
    //final formattedDate = _dataController.text.isNotEmpty ? _dataController  // Formatta la data in base al formatter creato
    var titolo = _titoloController.text.isNotEmpty ? _titoloController.text : "TASK DEL ${DateTime.now().day}/${DateTime.now().month} ORE ${DateTime.now().hour}:${DateTime.now().minute}";
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse('$ipaddressProva/api/task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data_creazione': DateTime.now().toIso8601String(),//data, // Utilizza la data formattata
          'data_conclusione': null,
          'titolo' : titolo,
          'descrizione': _descrizioneController.text,
          'concluso': false,
          'condiviso': _condiviso,
          'accettato': false,
          'tipologia': _selectedTipo?.toMap(),
          'utente': _condiviso ? selectedUtente?.toMap() : widget.utente,
        }),
      );
      Navigator.of(context).pop();//Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task registrato con successo!'),
        ),
      );
      return response;
    } catch (e) {
      print('Errore durante il salvataggio del task $e');
    }
    return null;
  }

  Future<void> saveTaskPlusPics() async {
    final data = await createTask();
    try {
      if(data == null){
        throw Exception('Dati del sopralluogo non disponibili.');
      }
      final task = TaskModel.fromJson(jsonDecode(data.body));
      try{
        for (var image in pickedImages) {
          if (image.path.isNotEmpty) {
            print('Percorso del file: ${image.path}');
            var request = http.MultipartRequest(
              'POST',
              Uri.parse('$ipaddressProva/api/immagine/task/${int.parse(task.id!.toString())}'),
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
            } else {
              print('Errore durante l\'invio del file: ${response.statusCode}');
            }
          } else {
            // Gestisci il caso in cui il percorso del file non è valido
            print('Errore: Il percorso del file non è valido');
          }
        }
        pickedImages.clear();
      } catch (e) {
        print('Errore durante l\'invio del file: $e');
      }
    } catch (e) {
      print('Errore durante l\'invio del file: $e');
    }
  }

  Future<void> getAllTipi() async{
    try{
      var apiUrl = Uri.parse('$ipaddressProva/api/tipoTask');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<TipoTaskModel> tipi = [];
        for(var item in jsonData){
          tipi.add(TipoTaskModel.fromJson(item));
        }
        setState(() {
          allTipi = tipi;
        });
      } else {
        throw Exception(
            'Failed to load tipi task data from API: ${response.statusCode}');
      }
    } catch(e){
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

  Widget buildCustomCheckbox({
    required bool value,
    required String label,
    required void Function(bool?) onChanged,
  }) {
    return SizedBox(
      width: 400, // Dimensione regolabile
      child: InkWell(
        onTap: () => onChanged(!value), // Gestione del toggle al clic
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value ? Colors.redAccent : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
