import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fema_crm/pages/TableTaskPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:path_provider/path_provider.dart';
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
  Future<ap.AudioPlayer>? _futureAudio;
  List<XFile> pickedImages =  [];
  late File fileaudio;
  ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  Uint8List? resp;
  double _currentPosition = 0;
  late double _totalDuration;
  Timer? _positionTimer;
  int _elapsedSeconds = 0;

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
    _fetchImagesVoid();
  }

  void _fetchImagesVoid() {
    setState(() {
      _futureImages = fetchImages();
      _futureAudio = fetchAudio();/*.whenComplete(() {
        _audioPlayer.setSource(ap.BytesSource(resp!)).whenComplete(() =>
            _audioPlayer.getDuration().then((val) => _totalDuration = val!.inSeconds.toDouble() ?? 0));

      });*/
      //_audioPlayer.setSource(ap.BytesSource(resp!));
    });
  }

  Future<void> _playRecording() async {
    /*setState(() {
      _totalDuration = _totalDuration;//duration.inSeconds.toDouble(); // Imposta la durata totale
      _currentPosition = 0;//position!.inSeconds.toDouble(); // Imposta la posizione corrente
    });*/
    //_totalDuration = (await _audioPlayer.getDuration())!.inSeconds.toDouble() ?? 0;
    await _audioPlayer.play(ap.BytesSource(resp!));

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position.inSeconds.toDouble();
      });
    });

    // Avvia il timer per aggiornare la posizione dello slider
      /*_positionTimer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
        final duration = await _audioPlayer.getDuration();
        final position = await _audioPlayer.getCurrentPosition();

      if (duration != null) {
        setState(() {
          _totalDuration = duration.inSeconds.toDouble(); // Imposta la durata totale
          _currentPosition = position!.inSeconds.toDouble(); // Imposta la posizione corrente
        });
      }
    });*/


  }

  /*Future<void> playAudio(String filePath) async {
    try {
      // Imposta il file audio per la riproduzione
      await _audioPlayer.setFilePath(filePath);
      // Avvia la riproduzione
      await _audioPlayer.play();
      print('Riproduzione audio avviata');
    } catch (e) {
      print('Errore nella riproduzione: $e');
    }
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    print('Riproduzione audio fermata');
  }*/

  Future<ap.AudioPlayer> fetchAudio() async {
    final dir = await getApplicationDocumentsDirectory();
    String filePath = '${dir.path}/audioget_${DateTime.now().millisecondsSinceEpoch}.mp3';
    final player = ap.AudioPlayer();
    final url = '$ipaddress/api/immagine/task/${int.parse(widget.task.id.toString())}/audio';
    http.Response? response;
    try {

      response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        fileaudio = File(filePath);
        print(filePath.toString()+' 3333333333 '+response.bodyBytes.toString());

        await fileaudio.writeAsBytes(response.bodyBytes);
        resp = response.bodyBytes;
        //await _audioPlayer.setFilePath(filePath);
        //await _audioPlayer.setAudioSource(AudioSource.uri(Uri.file(filePath)));
        //await player.play(ap.BytesSource(response.bodyBytes));//filePath));
        //await player.play(ap.AssetSource('audio/audio.mp3'));//filePath));
        //await _audioPlayer.setFilePath(filePath);
        //await _audioPlayer.play();
        await _audioPlayer.setSource(ap.BytesSource(resp!)).whenComplete(() =>
            _audioPlayer.getDuration().then((val) => _totalDuration = val!.inSeconds.toDouble() ?? 0));
        return player;//images; // no need to wrap with Future
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

  Future<List<Uint8List>> fetchImages() async {
    final url = '$ipaddress/api/immagine/task/${int.parse(widget.task.id.toString())}/images';
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

  Future<void> getAllTipi() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/tipoTask');
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
                          Platform.isWindows ? Center(
                            child: ElevatedButton(
                              onPressed: pickImagesFromGallery,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                              ),
                              child: Text('Allega Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                            ),
                          ) : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: ElevatedButton(
                                  onPressed: takePicture,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text('Scatta Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                                ),
                              ),
                              SizedBox(height: 16,),
                              Center(
                                child: ElevatedButton(
                                  onPressed: pickImagesFromGallery,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text('Allega Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                                ),
                              ),


              ],),
              SizedBox(height: 30),
              if (pickedImages.isNotEmpty)
                _buildImagePreview(),
              SizedBox(height: 20),
              if (resp != null)//(_futureAudio != null)
              Column(children: [
                ElevatedButton(
                  onPressed: _playRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('PLAY', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              //Text(_totalDuration.toString()),
              FutureBuilder(
                future: _futureAudio, // Usa il futuro dell'audio
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Errore nel caricamento dell\'audio'));
                  } else {
                    // Qui puoi accedere a _totalDuration e costruire il tuo widget
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              '${(_totalDuration.toInt() ~/ 60).toString().padLeft(2, '0')}:${(_totalDuration.toInt() % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            // Altri widget...
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),]),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _selectedTipo != null ? () {
                  salvaTask();
                } : null,
                child: Text('SALVA'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: _selectedTipo != null ? Colors.red : Colors.grey,
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
        Uri.parse('$ipaddress/api/task'),
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
      var apiUrl = Uri.parse('$ipaddress/api/utente/attivo');
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
