import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_image_compress/flutter_image_compress.dart';
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
  List<TipologiaInterventoModel> allTipologie = [];
  TipologiaInterventoModel? _selectedTipologia;
  List<XFile> pickedImages =  [];
  ClienteModel? selectedCliente;
  DestinazioneModel? selectedDestinazione;
  Priorita? _selectedPriorita;
  List<ClienteModel> clientiList = [];
  List<ClienteModel> filteredClientiList = [];
  List<DestinazioneModel> allDestinazioniByCliente = [];
  DateTime _dataOdierna = DateTime.now();
  DateTime? selectedDate = null;
  TimeOfDay _initialTime = TimeOfDay.now();
  TimeOfDay? selectedTime;
  bool _orarioDisponibile = false;
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
    getAllClienti();
    getAllTipologie();
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

  Future<void> getAllClienti() async{
    try{
      final response = await http.get(Uri.parse('$ipaddressProva/api/cliente'));
      if(response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
        List<ClienteModel> clienti = [];
        for(var item in jsonData){
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          clientiList = clienti;
          filteredClientiList = clienti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog(e.toString());
    }
  }

  Future<void> getAllDestinazioniByCliente(String clientId) async {
    try {
      final response = await http.get(Uri.parse('$ipaddressProva/api/destinazione/cliente/$clientId'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          allDestinazioniByCliente = responseData.map((data) => DestinazioneModel.fromJson(data)).toList();
        });
      } else {
        throw Exception('Failed to load Destinazioni per cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _initialTime,
    );
    if (picked != null && picked != _initialTime) {
      setState(() {
        selectedTime = picked;
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
                                  SizedBox(
                                    width: 200,
                                    child: ElevatedButton(
                                      onPressed: _selezionaData,
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('SELEZIONA DATA', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  if(selectedDate != null)
                                    Text('DATA SELEZIONATA: ${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}'),
                                  const SizedBox(height: 20.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        value: _orarioDisponibile,
                                        onChanged: (value) {
                                          setState(() {
                                            _orarioDisponibile = value ?? false;
                                          });
                                        },
                                      ),
                                      Text("è disponibile un orario per l'appuntamento".toUpperCase()),
                                    ],
                                  ),
                                  if (_orarioDisponibile)
                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 12),
                                          ElevatedButton(
                                            onPressed: () {
                                              _selectTime(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white, backgroundColor: Colors.red, // Colore del testo bianco quando il pulsante è premuto
                                            ),
                                            child: Text('Seleziona Orario'.toUpperCase()),
                                          ),
                                          SizedBox(height: 12),
                                          Text('Orario selezionato : ${(selectedTime?.hour)}.${(selectedTime?.minute)}'.toUpperCase())
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: 15),
                                  DropdownButton<TipologiaInterventoModel>(
                                    value: _selectedTipologia,
                                    hint:  Text('Seleziona tipologia di intervento'.toUpperCase()),
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
                                  const SizedBox(height: 20.0),
                                  SizedBox(
                                    width: 600,
                                    child: TextFormField(
                                      controller: _titoloController,
                                      maxLines: null,
                                      decoration:  InputDecoration(labelText: 'Titolo'.toUpperCase()),
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  SizedBox(
                                    width: 600,
                                    child: TextFormField(
                                      controller: _descrizioneController,
                                      maxLines: null,
                                      decoration:  InputDecoration(labelText: 'Descrizione'.toUpperCase()),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 600,
                                    child: TextFormField(
                                      controller: _notaController,
                                      maxLines: null,
                                      decoration:  InputDecoration(labelText: 'Nota'.toUpperCase()),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 400,
                                    child: DropdownButtonFormField<Priorita>(
                                      value: _selectedPriorita,
                                      onChanged: (Priorita? newValue) {
                                        setState(() {
                                          _selectedPriorita = newValue;
                                        });
                                      },
                                      // Filtra solo i valori desiderati: Acconto e Pagamento
                                      items: [Priorita.BASSA, Priorita.MEDIA, Priorita.ALTA, Priorita.URGENTE]
                                          .map<DropdownMenuItem<Priorita>>((Priorita value) {
                                        String label = "";
                                        if (value == Priorita.BASSA) {
                                          label = 'BASSA';
                                        } else if (value == Priorita.MEDIA) {
                                          label = 'MEDIA';
                                        } else if (value == Priorita.ALTA) {
                                          label = 'ALTA';
                                        } else if (value == Priorita.URGENTE) {
                                          label = 'URGENTE';
                                        }
                                        return DropdownMenuItem<Priorita>(
                                          value: value,
                                          child: Text(label),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        labelText: 'PRIORITÀ',
                                      ),
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Selezionare la priorità';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height : 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: GestureDetector(
                                          onTap: () {
                                            _showClientiDialog();
                                          },
                                          child: SizedBox(
                                            height: 50,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  (selectedCliente?.denominazione != null && selectedCliente!.denominazione!.length > 15)
                                                      ? '${selectedCliente!.denominazione?.substring(0, 15)}...'  // Troncamento a 15 caratteri e aggiunta di "..."
                                                      : (selectedCliente?.denominazione ?? 'Seleziona Cliente').toUpperCase(),  // Testo di fallback
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                                const Icon(Icons.arrow_drop_down),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 250,
                                        child: GestureDetector(
                                          onTap: () {
                                            _showDestinazioniDialog();
                                          },
                                          child: SizedBox(
                                            height: 50,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  (selectedDestinazione?.denominazione != null && selectedDestinazione!.denominazione!.length > 15)
                                                      ? '${selectedDestinazione!.denominazione!.substring(0, 15)}...'  // Troncamento a 15 caratteri e aggiunta di "..."
                                                      : (selectedDestinazione?.denominazione ?? 'Seleziona Destinazione').toUpperCase(),  // Testo di fallback
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                                const Icon(Icons.arrow_drop_down),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(height: 15,),
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
                                  SizedBox(
                                    width: 200,
                                    child: ElevatedButton(
                                      onPressed: _selezionaData,
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('SELEZIONA DATA', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  if(selectedDate != null)
                                    Text('DATA SELEZIONATA: ${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}'),
                                  const SizedBox(height: 20.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        value: _orarioDisponibile,
                                        onChanged: (value) {
                                          setState(() {
                                            _orarioDisponibile = value ?? false;
                                          });
                                        },
                                      ),
                                      Text("disponibilità appuntamento".toUpperCase()),
                                    ],
                                  ),
                                  if (_orarioDisponibile)
                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 12),
                                          ElevatedButton(
                                            onPressed: () {
                                              _selectTime(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white, backgroundColor: Colors.red, // Colore del testo bianco quando il pulsante è premuto
                                            ),
                                            child: Text('Seleziona Orario'.toUpperCase()),
                                          ),
                                          SizedBox(height: 12),
                                          Text('Orario selezionato : ${(selectedTime?.hour)}.${(selectedTime?.minute)}'.toUpperCase())
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: 15),
                                  SizedBox(
                                    width: 580,
                                    child: DropdownButton<TipologiaInterventoModel>(
                                      value: _selectedTipologia,
                                      hint:  Text('Seleziona tipologia di intervento'.toUpperCase()),
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
                                  const SizedBox(height: 20.0),
                                  SizedBox(
                                    width: 600,
                                    child: TextFormField(
                                      controller: _titoloController,
                                      maxLines: null,
                                      decoration:  InputDecoration(labelText: 'Titolo'.toUpperCase()),
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  SizedBox(
                                    width: 600,
                                    child: TextFormField(
                                      controller: _descrizioneController,
                                      maxLines: null,
                                      decoration:  InputDecoration(labelText: 'Descrizione'.toUpperCase()),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 600,
                                    child: TextFormField(
                                      controller: _notaController,
                                      maxLines: null,
                                      decoration:  InputDecoration(labelText: 'Nota'.toUpperCase()),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 400,
                                    child: DropdownButtonFormField<Priorita>(
                                      value: _selectedPriorita,
                                      onChanged: (Priorita? newValue) {
                                        setState(() {
                                          _selectedPriorita = newValue;
                                        });
                                      },
                                      // Filtra solo i valori desiderati: Acconto e Pagamento
                                      items: [Priorita.BASSA, Priorita.MEDIA, Priorita.ALTA, Priorita.URGENTE]
                                          .map<DropdownMenuItem<Priorita>>((Priorita value) {
                                        String label = "";
                                        if (value == Priorita.BASSA) {
                                          label = 'BASSA';
                                        } else if (value == Priorita.MEDIA) {
                                          label = 'MEDIA';
                                        } else if (value == Priorita.ALTA) {
                                          label = 'ALTA';
                                        } else if (value == Priorita.URGENTE) {
                                          label = 'URGENTE';
                                        }
                                        return DropdownMenuItem<Priorita>(
                                          value: value,
                                          child: Text(label),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        labelText: 'PRIORITÀ',
                                      ),
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Selezionare la priorità';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height : 20),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: GestureDetector(
                                          onTap: () {
                                            _showClientiDialog();
                                          },
                                          child: SizedBox(
                                            height: 50,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  (selectedCliente?.denominazione != null && selectedCliente!.denominazione!.length > 15)
                                                      ? '${selectedCliente!.denominazione?.substring(0, 15)}...'  // Troncamento a 15 caratteri e aggiunta di "..."
                                                      : (selectedCliente?.denominazione ?? 'Seleziona Cliente').toUpperCase(),  // Testo di fallback
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                                const Icon(Icons.arrow_drop_down),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 250,
                                            child: GestureDetector(
                                              onTap: () {
                                                _showDestinazioniDialog();
                                              },
                                              child: SizedBox(
                                                height: 50,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      (selectedDestinazione?.denominazione != null && selectedDestinazione!.denominazione!.length > 15)
                                                          ? '${selectedDestinazione!.denominazione!.substring(0, 15)}...'  // Troncamento a 15 caratteri e aggiunta di "..."
                                                          : (selectedDestinazione?.denominazione ?? 'Seleziona Destinazione').toUpperCase(),  // Testo di fallback
                                                      style: const TextStyle(fontSize: 16),
                                                    ),
                                                    const Icon(Icons.arrow_drop_down),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Aggiungi questo sotto il pulsante per la selezione degli utenti
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
                                                      SizedBox(height: 15,),
                                                      if (pickedImages.isNotEmpty) _buildImagePreview(),
                                                      SizedBox(height: 10),
                                                    ]
                                                ),
                                              ),
                                            )
                                          ]
                                      ),
                                    ),
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
    var data = selectedDate != null ? selectedDate?.toIso8601String() : null;
    var orario = selectedTime != null ? DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedTime!.hour, selectedTime!.minute).toIso8601String() : null;
    var note = _notaController.text.isNotEmpty ? _notaController.text : null;
    var titolo = _titoloController.text.isNotEmpty ? _titoloController.text : null;
    var descrizione = _descrizioneController.text.isNotEmpty ? _descrizioneController.text : null;
    String prioritaString = _selectedPriorita.toString().split('.').last;
    try{
      response = await http.post(
        Uri.parse('$ipaddressProva/api/ticket'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data' : data,
          'orario_appuntamento' : orario,
          'titolo' : titolo,
          'priorita' : prioritaString,
          'descrizione' : descrizione,
          'note' : note,
          'convertito' : false,
          'cliente' : selectedCliente?.toMap(),
          'destinazione' : selectedDestinazione?.toMap(),
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



  void _showClientiDialog() async {
    // Mostra il dialogo con un indicatore di caricamento
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'SELEZIONA CLIENTE',
            textAlign: TextAlign.center,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Attendi, caricamento clienti in corso...'), // Messaggio di caricamento
              SizedBox(height: 16),
              Center(child: CircularProgressIndicator()), // Indicatore di caricamento
            ],
          ),
        );
      },
    );
    // Carica i clienti in background
    await getAllClienti();
    // Chiudi il dialogo e mostra i clienti
    Navigator.of(context).pop(); // Chiudi il dialogo
    // Mostra il dialogo con la lista dei clienti
    _showClientiListDialog();
  }

  void _showClientiListDialog() {
    TextEditingController searchController = TextEditingController();
    List<ClienteModel> filteredClientiList = clientiList; // Inizializzazione della lista filtrata
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) { // Usa StatefulBuilder per gestire lo stato nel dialog
            return AlertDialog(
              title: Text(
                'SELEZIONA CLIENTE',
                textAlign: TextAlign.center,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        // Aggiorna lo stato del dialogo, non del widget genitore
                        setState(() {
                          filteredClientiList = clientiList.where((cliente) {
                            final denominazione = cliente.denominazione?.toLowerCase() ?? '';
                            final codice_fiscale = cliente.codice_fiscale?.toLowerCase() ?? '';
                            final partita_iva = cliente.partita_iva?.toLowerCase() ?? '';
                            final telefono = cliente.telefono?.toLowerCase() ?? '';
                            final cellulare = cliente.cellulare?.toLowerCase() ?? '';
                            final citta = cliente.citta?.toLowerCase() ?? '';
                            final email = cliente.email?.toLowerCase() ?? '';
                            final cap = cliente.cap?.toLowerCase() ?? '';

                            return denominazione.contains(value.toLowerCase()) ||
                                codice_fiscale.contains(value.toLowerCase()) ||
                                partita_iva.contains(value.toLowerCase()) ||
                                telefono.contains(value.toLowerCase()) ||
                                cellulare.contains(value.toLowerCase()) ||
                                citta.contains(value.toLowerCase()) ||
                                email.contains(value.toLowerCase()) ||
                                cap.contains(value.toLowerCase());
                          }).toList();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'CERCA CLIENTE',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredClientiList.map((cliente) {
                            return ListTile(
                              leading: Icon(Icons.contact_page_outlined),
                              title: Text(cliente.denominazione!),
                              onTap: () {
                                setState(() {
                                  selectedCliente = cliente;
                                  getAllDestinazioniByCliente(cliente.id!);
                                });
                                Navigator.of(context).pop();
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDestinazioniDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona Destinazione', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: allDestinazioniByCliente.map((destinazione) {
                        return ListTile(
                          leading: const Icon(Icons.home_work_outlined),
                          title: Text(destinazione.denominazione!),
                          onTap: () {
                            setState(() {
                              selectedDestinazione = destinazione;
                            });
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
