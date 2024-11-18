import 'dart:io';
import 'package:fema_crm/pages/TableTaskPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../model/UtenteModel.dart';
import '../model/TaskModel.dart';
import 'package:intl/intl.dart';

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
  DateTime _dataOdierna = DateTime.now();
  DateTime? selectedDate = null;
  Tipologia? _selectedTipo;
  bool _condiviso = false;
  bool _concluso = false;
  bool _accettato = false;
  TextEditingController _condivisoController = TextEditingController();
  TextEditingController _accettatoController = TextEditingController();
  TextEditingController _conclusoController = TextEditingController();
  List<XFile> pickedImages =  [];

  @override
  void initState() {

    super.initState();
    _descrizioneController = TextEditingController(text: widget.task.descrizione);
    _titoloController = TextEditingController(text: widget.task.titolo);
    _selectedTipo = widget.task.tipologia;
    _condiviso = widget.task.condiviso!;
    _concluso = widget.task.concluso!;
    _accettato = widget.task.accettato!;
    getAllUtenti();
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
        /*leading: BackButton(
          onPressed: (){Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  TableTaskPage(utente: widget.utente),
            ),
          );},
          color: Colors.black, // <-- SEE HERE
        ),*/
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /*SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _selezionaData,
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  child: const Text('SELEZIONA DATA', style: TextStyle(color: Colors.white)),
                ),
              ),
              if(selectedDate != null)
                Text('DATA SELEZIONATA: ${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}'),
              const SizedBox(height: 20.0),*/
              SizedBox(height: 20),
              // Description Field
              SizedBox(
                width: 450,
                child: TextFormField(
                  controller: _titoloController,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Titolo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Description Field
              SizedBox(
                width: 450,
                child: TextFormField(minLines: 4,
                  controller: _descrizioneController,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Descrizione',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 400,
                child: DropdownButtonFormField<Tipologia>(
                  value: _selectedTipo,
                  onChanged: (Tipologia? newValue) {
                    setState(() {
                      _selectedTipo = newValue;
                    });
                  },

                  items: [Tipologia.PERSONALE, Tipologia.AZIENDALE, Tipologia.PREVENTIVO_FEMA_SHOP, Tipologia.PREVENTIVO_SERVIZI_ELETTRONICA,
                    Tipologia.PREVENTIVO_IMPIANTO, Tipologia.SPESE]
                      .map<DropdownMenuItem<Tipologia>>((Tipologia value) {
                    String label = "";
                    if (value == Tipologia.PERSONALE) {
                      label = 'PERSONALE';
                    } else if (value == Tipologia.AZIENDALE) {
                      label = 'AZIENDALE';
                    } else if (value == Tipologia.PREVENTIVO_FEMA_SHOP) {
                      label = 'PREVENTIVO FEMA SHOP';
                    } else if (value == Tipologia.PREVENTIVO_SERVIZI_ELETTRONICA) {
                      label = 'PREVENTIVO SERVIZI ELETTRONICA';
                    } else if (value == Tipologia.PREVENTIVO_IMPIANTO) {
                      label = 'PREVENTIVO IMPIANTO';
                    } else if (value == Tipologia.SPESE) {
                      label = 'SPESE';
                    }
                    return DropdownMenuItem<Tipologia>(
                      value: value,
                      child: Text(label),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'TIPOLOGIA',
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Selezionare la tipologia';
                    }
                    return null;
                  },
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
              if (_condiviso) SizedBox(
                width: 450,
                child: DropdownButtonFormField<UtenteModel>(
                  value: selectedUtente,
                  onChanged: (UtenteModel? newValue){
                    setState(() {
                      selectedUtente = newValue;
                    });
                  },
                  items: allUtenti.map((UtenteModel utente){
                    return DropdownMenuItem<UtenteModel>(
                      value: utente,
                      child: Text(utente.nomeCompleto()!),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                      labelText: 'Seleziona tecnico'.toUpperCase()
                  ),
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
              ) : Row(children: [Center(
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
                SizedBox(height: 30),
                if (pickedImages.isNotEmpty)
                  _buildImagePreview(),
                SizedBox(height: 20),

              ],),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  salvaTask();
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
          'tipologia': _selectedTipo.toString().split('.').last,
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
      var apiUrl = Uri.parse('$ipaddressProva/api/utente');
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
}
