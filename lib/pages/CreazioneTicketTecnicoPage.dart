import 'dart:async';
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
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
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
  List<XFile> pickedImages =  [];
  final ImagePicker _picker = ImagePicker();
  final record = AudioRecorder();
  bool showPlayer = false;
  String? audioPath;
  bool isRecording = false;
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
    super.initState();
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

  Future<void> pickImagesFromGallery() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        pickedImages.addAll(pickedFiles);
      });
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  if (pickedImages.isNotEmpty) _buildImagePreview(),
                          const SizedBox(height: 30),
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
                          child: const Text('START', style: TextStyle(fontWeight: FontWeight.bold, color : Colors.white)),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _isRecording ? Icons.mic : Icons.mic_none,
                          size: 85,
                          color: _isRecording ? Colors.red : Colors.red,
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
                  /*ElevatedButton(
                  onPressed: !_isRecording ? _playRecording : null,
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('PLAY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),*/
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
                  SizedBox(height: 43,)
                      ],),
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
                                              padding: const EdgeInsets.all(0.0),
                                              child: Form(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      SizedBox(height: 15,),
                                                      if (pickedImages.isNotEmpty) _buildImagePreview(),
                                                      const SizedBox(height: 30),
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
                                                              const SizedBox(width: 1),
                                                              Icon(
                                                                _isRecording ? Icons.mic : Icons.mic_none,
                                                                size: 85,
                                                                color: _isRecording ? Colors.red : Colors.blue,
                                                              ),
                                                              const SizedBox(width: 1),
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
                                                          /*if (_timer != null) ElevatedButton(
                                                            onPressed: !_isRecording ? _playRecording : null,
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.green,
                                                              padding:
                                                              const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                                            ),
                                                            child: const Text('PLAY', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          ),*/
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
                                                          SizedBox(height: 43,)
                                                        ],),
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
        Uri.parse('$ipaddress/api/ticket'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titolo' : titolo,
          'descrizione' : descrizione,
          'note' : note,
          'convertito' : false,
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
            Uri.parse('$ipaddress/api/immagine/ticket/${int.parse(ticket.id.toString())}'),
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

      var file = File(_filePath!);
      //for (var image in pickedImages) {
      if (file.path != null && file.path.isNotEmpty) {
        print('Percorso del file audio: ${file.path}');
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$ipaddress/api/immagine/ticketaudio/${int.parse(ticket.id!.toString())}'),
        );
        request.files.add(
          await http.MultipartFile.fromPath(
            'ticket', // Field name
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
