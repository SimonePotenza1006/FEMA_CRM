import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:fema_crm/pages/TableTaskPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
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
  final TextEditingController _riferimentoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  UtenteModel? selectedUtente;
  DateTime _dataOdierna = DateTime.now();
  DateTime? selectedDate = null;
  TipoTaskModel? _selectedTipo;
  bool _condiviso = false;
  final TextEditingController _condivisoController = TextEditingController();
  List<XFile> pickedImages =  [];
  final ImagePicker _picker = ImagePicker();
  final record = AudioRecorder();
  bool showPlayer = false;
  String? audioPath;
  bool isRecording = false;
  late AudioRecorder? _audioRecorder;
  String? _audioPath;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _filePath;
  double _currentPosition = 0;
  double _totalDuration = 0;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _condivisoTipo = false;
  UtenteModel? selectedUtenteTipo;

  @override
  void initState() {
    //showPlayer = false;
    super.initState();
    getAllUtenti();
    getAllTipi();
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);*/
  }

  Future<void> _startRecording() async {
    final bool isPermissionGranted = await _recorder.hasPermission();
    if (!isPermissionGranted) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    // Generate a unique file name using the current timestamp
    String fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.mp3';
    _filePath = '${directory.path}/$fileName';

    // Define the configuration for the recording
    const config = RecordConfig(
      // Specify the format, encoder, sample rate, etc., as needed
      encoder: AudioEncoder.aacLc, // For example, using AAC codec
      sampleRate: 44100, // Sample rate
      bitRate: 128000, // Bit rate
    );

    // Start recording to file with the specified configuration
    await _recorder.start(config, path: _filePath!);
    setState(() {
      _isRecording = true;
      _elapsedSeconds = 0;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  Future<void> _resetRecording() async {


    setState(() {
      _filePath = null;
      _isRecording = false;
      _elapsedSeconds = 0;
      _timer?.cancel();
      _timer = null;
    });


    /*final directory = await getApplicationDocumentsDirectory();
    // Generate a unique file name using the current timestamp
    String fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.mp3';
    _filePath = '${directory.path}/$fileName';

    // Define the configuration for the recording
    const config = RecordConfig(
      // Specify the format, encoder, sample rate, etc., as needed
      encoder: AudioEncoder.aacLc, // For example, using AAC codec
      sampleRate: 44100, // Sample rate
      bitRate: 128000, // Bit rate
    );

    // Start recording to file with the specified configuration
    await _recorder.start(config, path: _filePath!);
    setState(() {
      _isRecording = true;
      _elapsedSeconds = 0;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });*/
  }


  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
    });
    _timer?.cancel();
  }

  Future<void> _playRecording() async {
    if (_filePath != null) {
      await _audioPlayer.setFilePath(_filePath!);
      _totalDuration = _audioPlayer.duration?.inSeconds.toDouble() ?? 0;
      _audioPlayer.play();

      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _currentPosition = position.inSeconds.toDouble();
        });
      });
    }
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
      //width: 200,
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

  Future<void> saveTipologia() async{
    try{
      final response = await http.post(
          Uri.parse('$ipaddress/api/tipoTask'),
          headers: {'Content-Type' : 'application/json'},
          body: jsonEncode({
            'descrizione' : _descrizioneController.text,
            'utente' : _condivisoTipo ? selectedUtenteTipo : null,
            'utentecreate' : widget.utente
          })
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nuova tipologia registrata con successo!'.toUpperCase()),
        ),
      );
      getAllTipi();
    } catch(e){
      print('Errore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Ottieni la larghezza dello schermo
        /*final size = MediaQuery.of(context).size;
        const double thresholdWidth = 450.0;

        // Cambia l'orientamento in base alla larghezza
        if (size.width < thresholdWidth) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeRight,
          ]);
        } else {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        }*/
        // Consenti la navigazione indietro
        return true;
      },
      child:Scaffold(
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
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        // Description Field
                        SizedBox(
                          width: 600,
                          child: TextFormField(
                            controller: _titoloController,
                            maxLines: null,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Titolo'.toUpperCase(),
                              labelStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none, // Rimuove il bordo standard
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
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
                              hintText: "Inserisci il titolo",
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Description Field
                        SizedBox(
                          width: 600,
                          child: TextFormField(
                            controller: _riferimentoController,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Riferimento'.toUpperCase(),
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
                                borderSide: BorderSide(
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
                              hintText: "Inserisci il riferimento",
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Description Field
                        SizedBox(
                          width: 600,
                          child: TextFormField(
                            controller: _descrizioneController,
                            maxLines: 5,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Descrizione'.toUpperCase(),
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
                                borderSide: BorderSide(
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
                              hintText: "Inserisci la descrizione",
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(children: [
                          /*ElevatedButton(
                            onPressed:  () {

                            },
                            child: Text('+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[600]) ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),*/
                          /*IconButton(
                            //color: Colors.grey[600],
                            icon: Icon(Icons.add),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return  AlertDialog(

                                            title: Text(
                                              'CREA NUOVA TIPOLOGIA',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(height: 10),
                                                TextFormField(
                                                  controller: _descrizioneController,
                                                  onChanged: (value) {
                                                    // Aggiorna lo stato del dialogo
                                                    setState(() {});
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: 'NOME NUOVA TIPOLOGIA',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                                SizedBox(height: 12),
                                                SizedBox(
                                                  width: 200,
                                                  child: CheckboxListTile(
                                                    title: Text('CONDIVIDI'),
                                                    value: _condivisoTipo,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _condivisoTipo = value!;
                                                        /*if (_condiviso) {
                                            _condivisoController.clear();
                                          }*/
                                                      });
                                                    },
                                                  ),
                                                ),
                                                SizedBox(height: 15),// But
                                                if (_condivisoTipo) SizedBox(
                                                  //width: 400,
                                                  child: DropdownButtonFormField<UtenteModel>(
                                                    value: selectedUtenteTipo,
                                                    onChanged: (UtenteModel? newValue) {
                                                      setState(() {
                                                        selectedUtenteTipo = newValue;
                                                      });
                                                    },
                                                    items: allUtenti.map<DropdownMenuItem<UtenteModel>>((UtenteModel utente) {
                                                      return DropdownMenuItem<UtenteModel>(
                                                        value: utente,
                                                        child: Text(
                                                          utente.nomeCompleto()!.toUpperCase(),
                                                          style: TextStyle(fontSize: 14, color: Colors.black87),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    decoration: InputDecoration(
                                                      labelText: 'SELEZIONA UTENTE',
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
                                                        borderSide: BorderSide(
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
                                                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                                    ),
                                                    validator: (value) {
                                                      if (value == null) {
                                                        return 'SELEZIONA UN UTENTE';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),


                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: _descrizioneController.text.isNotEmpty
                                                    ? () {
                                                  saveTipologia();
                                                }
                                                    : null, // Disabilita il pulsante se il testo è vuoto
                                                child: Text('SALVA TIPOLOGIA'),
                                              ),
                                            ],
                                          );
                                        });
                                  });
                            },
                            tooltip: 'Crea nuova tipologia',
                          ),*/
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return  AlertDialog(

                                            title: Text(
                                              'CREA NUOVA TIPOLOGIA',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(height: 10),
                                                TextFormField(
                                                  controller: _descrizioneController,
                                                  onChanged: (value) {
                                                    // Aggiorna lo stato del dialogo
                                                    setState(() {});
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: 'NOME NUOVA TIPOLOGIA',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                                SizedBox(height: 12),
                                                SizedBox(
                                                  width: 200,
                                                  child: CheckboxListTile(
                                                    title: Text('CONDIVIDI'),
                                                    value: _condivisoTipo,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _condivisoTipo = value!;
                                                        /*if (_condiviso) {
                                            _condivisoController.clear();
                                          }*/
                                                      });
                                                    },
                                                  ),
                                                ),
                                                SizedBox(height: 15),// But
                                                if (_condivisoTipo) SizedBox(
                                                  //width: 400,
                                                  child: DropdownButtonFormField<UtenteModel>(
                                                    value: selectedUtenteTipo,
                                                    onChanged: (UtenteModel? newValue) {
                                                      setState(() {
                                                        selectedUtenteTipo = newValue;
                                                      });
                                                    },
                                                    items: allUtenti.map<DropdownMenuItem<UtenteModel>>((UtenteModel utente) {
                                                      return DropdownMenuItem<UtenteModel>(
                                                        value: utente,
                                                        child: Text(
                                                          utente.nomeCompleto()!.toUpperCase(),
                                                          style: TextStyle(fontSize: 14, color: Colors.black87),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    decoration: InputDecoration(
                                                      labelText: 'SELEZIONA UTENTE',
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
                                                        borderSide: BorderSide(
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
                                                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                                    ),
                                                    validator: (value) {
                                                      if (value == null) {
                                                        return 'SELEZIONA UN UTENTE';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),


                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: _descrizioneController.text.isNotEmpty
                                                    ? () {
                                                  saveTipologia();
                                                }
                                                    : null, // Disabilita il pulsante se il testo è vuoto
                                                child: Text('SALVA TIPOLOGIA'),
                                              ),
                                            ],
                                          );
                                        });
                                  });
                              // Azione da eseguire quando il bottone viene premuto
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black87, backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey[300]!), // Bordo
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.black87), // Icona +
                                /*SizedBox(width: 8), // Spazio tra l'icona e il testo
                                Text(
                                  'AGGIUNGI', // Testo del bottone
                                  style: TextStyle(fontSize: 14),
                                ),*/
                              ],
                            ),
                          ),
                          SizedBox(width: 8,),
                          SizedBox(
                          width: constraints.maxWidth < 460 ? 246 : 526,
                          child: DropdownButtonFormField<TipoTaskModel>(//isExpanded: true,
                            value: _selectedTipo,
                            onChanged: (TipoTaskModel? newValue) {
                              setState(() {

                                    _selectedTipo = newValue;
                                    _selectedTipo?.utente != null ?
                                      selectedUtente = allUtenti.firstWhere((element) =>
                                      element.id== (_selectedTipo?.utente!.id != widget.utente.id ? _selectedTipo?.utente!.id! : _selectedTipo?.utentecreate!.id!)) : null;
                                    _selectedTipo?.utente != null ? _condiviso = true : null;


                              });
                            },
                            items: [
                              ...allTipi.map<DropdownMenuItem<TipoTaskModel>>((TipoTaskModel tipologia) {

                              return DropdownMenuItem<TipoTaskModel>(

                                value: tipologia,
                                child: Text(
                                  tipologia.descrizione!.toUpperCase(), // Supponendo che TipologiaInterventoModel abbia una proprietà `label`
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                  overflow: TextOverflow.ellipsis, // Aggiungi questa riga
                                  maxLines: 1, // Limita a una sola riga
                                ),
                              );
                            }).toList(),

                            ],
                            decoration: InputDecoration(
                              labelText: 'TIPOLOGIA TASK',
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
                                borderSide: BorderSide(
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
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Selezionare'.toUpperCase();
                              }
                              return null;
                            },
                            selectedItemBuilder: (BuildContext context) {
                              return allTipi.map<Widget>((TipoTaskModel tipologia) {
                                return Container(
                                  //width: double.infinity, // Imposta la larghezza massima
                                  child: Text(
                                    tipologia.descrizione!.toUpperCase(),
                                    style: TextStyle(fontSize: 14, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis, // Troncamento
                                    maxLines: 1, // Limita a una sola riga
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),

                        ],),
                        SizedBox(height: 20),
                        SizedBox(
                          width: 200,
                          child: CheckboxListTile(
                            enabled: _selectedTipo?.utente != null ? false : true,
                            title: Text('Condiviso'.toUpperCase()),
                            value: _condiviso,
                            onChanged: (value) {
                              setState(() {
                                _condiviso = value!;
                                if (_condiviso) {
                                  _condivisoController.clear();
                                } else {
                                  selectedUtente = null;
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 10),// Button
                        if (_condiviso) SizedBox(
                          width: 400,
                          child: DropdownButtonFormField<UtenteModel>(
                            value: selectedUtente,
                            onChanged: _selectedTipo?.utente != null ? null : (UtenteModel? newValue) {
                              setState(() {
                                selectedUtente = newValue;
                              });
                            },
                            items: allUtenti.map<DropdownMenuItem<UtenteModel>>((UtenteModel utente) {
                              return DropdownMenuItem<UtenteModel>(
                                value: utente,
                                child: Text(
                                  utente.nomeCompleto()!.toUpperCase(),
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'SELEZIONA UTENTE',
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
                                borderSide: BorderSide(
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
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Selezionare un tecnico'.toUpperCase();
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 40),
                        Platform.isWindows ? Container(
                          child: ElevatedButton(
                            onPressed: pickImagesFromGallery,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.red,
                            ),
                            child: Text('Allega Foto'.toUpperCase(), style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                          ),
                        ) : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: ElevatedButton(
                                onPressed: takePicture,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.red,
                                ),
                                child: Text('Scatta\nFoto'.toUpperCase(), style: TextStyle(fontSize: 18.0), textAlign: TextAlign.center), // Aumenta la dimensione del testo del pulsante
                              ),
                            ),
                            SizedBox(width: 16,),
                            Center(
                              child: ElevatedButton(
                                onPressed: pickImagesFromGallery,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.red,
                                ),
                                child: Text('Allega\nFoto'.toUpperCase(), style: TextStyle(fontSize: 18.0), textAlign: TextAlign.center), // Aumenta la dimensione del testo del pulsante
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (pickedImages.isNotEmpty) _buildImagePreview(),
                        SizedBox(height: 10),
                        const SizedBox(height: 20),
                        if (Platform.isAndroid)
                          Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: _isRecording ? null : _startRecording,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 15),
                                  ),
                                  child: const Text('START', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  _isRecording ? Icons.mic : Icons.mic_none,
                                  size: 85,
                                  color: _isRecording ? Colors.red : Colors.blue,
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton(
                                  onPressed: _isRecording ? _stopRecording : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 15),
                                  ),
                                  child: const Text('STOP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ],
                            ),
                            Text(
                              '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            if (_timer != null) Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: !_isRecording ? _playRecording : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  ),
                                  child: Icon(
                                    Icons.play_arrow, // Icona di play
                                    color: Colors.white, // Colore dell'icona
                                    size: 28, // Dimensione dell'icona
                                  ),
                                ),
                                /*ElevatedButton(
                                  onPressed: !_isRecording ? _playRecording : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  ),
                                  child: const Text('PLAY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ),*/
                                SizedBox(width: 30,),
                                ElevatedButton(
                                  onPressed: _resetRecording,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  ),
                                  child: Icon(
                                    Icons.delete_forever, // Icona di play
                                    color: Colors.white, // Colore dell'icona
                                    size: 28, // Dimensione dell'icona
                                  ),
                                ),
                                //if (_timer != null)
                                  /*ElevatedButton(
                                  onPressed: _resetRecording,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  ),
                                  child: const Text('annulla', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ),*/
                              ],),
                            if (_timer != null) Slider(
                              activeColor: Colors.blue,
                              value: _currentPosition,
                              max: _totalDuration,
                              onChanged: (value) {
                                setState(() {
                                  _currentPosition = value;
                                });
                                _audioPlayer.seek(Duration(seconds: value.toInt()));
                              },
                            ),
                            SizedBox(height: 43),
                          ],
                          ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: ElevatedButton(
                            onPressed: _selectedTipo != null ? () {
                              saveTaskPlusAudio();//saveTaskPlusPics();
                            } : null,
                            child: Text('SALVA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16) ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: _selectedTipo != null ? Colors.red : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
          ), ),
    );
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
        Uri.parse('$ipaddress/api/task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data_creazione': DateTime.now().toIso8601String(),//data, // Utilizza la data formattata
          'data_conclusione': null,
          'titolo' : titolo,
          'riferimento': _riferimentoController.text,
          'descrizione': _descrizioneController.text,
          'concluso': false,
          'condiviso': _condiviso,
          'accettato': _condiviso ? false : true,
          'tipologia': _selectedTipo?.toMap(),
          'utentecreate': widget.utente,
          'utente': _condiviso ? selectedUtente?.toMap() : widget.utente,
          'attivo': true,
        }),
      );
      Navigator.of(context).pop('aggiorna');//Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task registrato con successo!'.toUpperCase()),
        ),
      );
      return response;
    } catch (e) {
      print('Errore durante il salvataggio del task $e');
    }
    return null;
  }

  Future<void> saveTaskPlusPics(TaskModel task) async {
    print('qnt foto '+pickedImages.length.toString());
    //final data = await createTask();
    /*try {
      if(data == null){
        throw Exception('Dati del sopralluogo non disponibili.');
      }*/
    //final task = TaskModel.fromJson(jsonDecode(data.body));
    try{
      for (var image in pickedImages) {
        if (image.path != null && image.path.isNotEmpty) {
          print('Percorso del file: ${image.path}');
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('$ipaddress/api/immagine/task/${int.parse(task.id!.toString())}'),
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
                content: Text('Foto salvata!'.toUpperCase()),
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
      //pickedImages.clear();
    } catch (e) {
      print('Errore durante l\'invio del file: $e');
    }
    /*} catch (e) {
      print('Errore durante l\'invio del file: $e');
    }*/
  }

  Future<void> saveTaskPlusAudio() async {
    final data = await createTask();
    try {
      if(data == null){
        throw Exception('Dati del sopralluogo non disponibili.');
      }
      final task = TaskModel.fromJson(jsonDecode(data.body));
      try{
        await saveTaskPlusPics(task);
        var file = File(_filePath!);
        //for (var image in pickedImages) {
        if (file.path != null && file.path.isNotEmpty) {
          print('Percorso del file audio: ${file.path}');
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('$ipaddress/api/immagine/taskaudio/${int.parse(task.id!.toString())}'),
          );
          request.files.add(
            await http.MultipartFile.fromPath(
              'task', // Field name
              file.path, // File path
              contentType: MediaType('audio', 'mp3'),
            ),
          );
          var response = await request.send();
          if (response.statusCode == 200) {
            print('File inviato con successo');
            /*ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Audio salvato!'),
              ),
            );*/
          } else {
            print('Errore durante l\'invio del file audio: ${response.statusCode}');
          }
        } else {
          // Gestisci il caso in cui il percorso del file non è valido
          print('Errore: Il percorso del file audio non è valido');
        }
        //}
        //pickedImages.clear();
      } catch (e) {
        print('Errore durante l\'invio del file audio: $e');
      }
    } catch (e) {
      print('Errore durante l\'invio del file audio: $e');
    }
  }

  Future<void> getAllTipi() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/tipoTask');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<TipoTaskModel> tipi = [];
        for(var item in jsonData){
          if (//widget.utente.cognome! == "Mazzei" ||
              (TipoTaskModel.fromJson(item).utentecreate!.id == widget.utente.id)
              || TipoTaskModel.fromJson(item).utente == null
              || (TipoTaskModel.fromJson(item).utente != null && TipoTaskModel.fromJson(item).utente!.id == widget.utente.id))
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
      var apiUrl = Uri.parse('$ipaddress/api/utente/attivo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
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
