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

  @override
  void initState() {
    //showPlayer = false;
    super.initState();
    getAllUtenti();
    getAllTipi();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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

  /*String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
      10,
          (index) => chars[random.nextInt(chars.length)],
      growable: false,
    ).join();
  }

  Future<void> _startRecording() async {
    try {
      debugPrint(
          '=========>>>>>>>>>>> RECORDING!!!!!!!!!!!!!!! <<<<<<===========');

      String filePath = await getApplicationDocumentsDirectory()
          .then((value) => '${value.path}/${_generateRandomId()}.wav');

      await _audioRecorder?.start(
        const RecordConfig(
          // specify the codec to be `.wav`
          encoder: AudioEncoder.wav,
        ),
        path: filePath,
      );
    } catch (e) {
      debugPrint('ERROR WHILE RECORDING: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? path = await _audioRecorder?.stop();

      setState(() {
        _audioPath = path!;
      });
      debugPrint('=========>>>>>> PATH: $_audioPath <<<<<<===========');
    } catch (e) {
      debugPrint('ERROR WHILE STOP RECORDING: $e');
    }
  }

  void _record() async {
    if (isRecording == false) {
      final status = await Permission.microphone.request();

      if (status == PermissionStatus.granted) {
        setState(() {
          isRecording = true;
        });
        await _startRecording();
      } else if (status == PermissionStatus.permanentlyDenied) {
        debugPrint('Permission permanently denied');
        // TODO: handle this case
      }
    } else {
      await _stopRecording();

      setState(() {
        isRecording = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _recorder.dispose();
    super.dispose();
  }*/

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                  child: DropdownButtonFormField<TipoTaskModel>(
                    value: _selectedTipo,
                    onChanged: (TipoTaskModel? newValue){
                      setState(() {
                        _selectedTipo = newValue;
                      });
                    },
                    items: allTipi.map((TipoTaskModel tipo){
                      return DropdownMenuItem<TipoTaskModel>(
                        value: tipo,
                        child: Text(tipo.descrizione!),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                        labelText: 'Seleziona tipologia'.toUpperCase()
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
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
                ),
                SizedBox(height: 10),// Button
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
                SizedBox(height: 40),
                Platform.isWindows ? Center(
                  child: ElevatedButton(
                    onPressed: pickImagesFromGallery,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red,
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
                        foregroundColor: Colors.white, backgroundColor: Colors.red,
                      ),
                      child: Text('Scatta Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                    ),
                  ),
                  SizedBox(width: 16,),
                  Center(
                    child: ElevatedButton(
                      onPressed: pickImagesFromGallery,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red,
                      ),
                      child: Text('Allega Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                    ),
                  ),
                ],),
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
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text('START', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _isRecording ? Icons.mic : Icons.mic_none,
                      size: 95,
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
                      child: const Text('STOP', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text(
                  '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 17),
                ElevatedButton(
                  onPressed: !_isRecording ? _playRecording : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('PLAY', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Slider(
                  value: _currentPosition,
                  max: _totalDuration,
                  onChanged: (value) {
                    setState(() {
                      _currentPosition = value;
                    });
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
               SizedBox(height: 43,)
                  ],),
               /* Center(
                  child: showPlayer
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: AudioPlayer(
                      source: audioPath!,
                      onDelete: () {
                        setState(() => showPlayer = false);
                      },
                    ),
                  )
                      : Recorder(
                    onStop: (path) {
                      if (kDebugMode) print('Recorded file path: $path');
                      setState(() {
                        audioPath = path;
                        showPlayer = true;
                      });
                    },
                  ),
                ),*/
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

  Future<void> saveTaskPlusPics(TaskModel task) async {
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
              Uri.parse('$ipaddressProva/api/immagine/taskaudio/${int.parse(task.id!.toString())}'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Audio salvato!'),
                ),
              );
            } else {
              print('Errore durante l\'invio del file audio: ${response.statusCode}');
            }
          } else {
            // Gestisci il caso in cui il percorso del file non è valido
            print('Errore: Il percorso del file audio non è valido');
          }
        //}
        pickedImages.clear();
      } catch (e) {
        print('Errore durante l\'invio del file audio: $e');
      }
    } catch (e) {
      print('Errore durante l\'invio del file audio: $e');
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
}
