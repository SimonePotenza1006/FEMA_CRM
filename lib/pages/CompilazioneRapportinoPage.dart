import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../model/CategoriaPrezzoListinoModel.dart';
import '../model/DestinazioneModel.dart';
import '../model/VeicoloModel.dart';
import '../model/CategoriaInterventoSpecificoModel.dart';
import '../model/InterventoModel.dart';
import '../model/ImmagineModel.dart';
import 'dart:ui' as ui;
import 'HomeFormTecnico.dart';

class CompilazioneRapportinoPage extends StatefulWidget {
  final InterventoModel intervento;

  CompilazioneRapportinoPage({Key? key, required this.intervento})
      : super(key: key);

  @override
  _CompilazioneRapportinoPageState createState() =>
      _CompilazioneRapportinoPageState();
}

class _CompilazioneRapportinoPageState
    extends State<CompilazioneRapportinoPage> {
  List<VeicoloModel> allVeicoli = [];
  List<CategoriaPrezzoListinoModel> allListini = [];
  List<XFile> pickedImages =  [];
  GlobalKey<SfSignaturePadState> _signaturePadKey =
      GlobalKey<SfSignaturePadState>();
  Uint8List? signatureBytes;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController _descrizioneCredenzialiController = TextEditingController();
  late DateTime selectedDate;
  late TimeOfDay selectedStartTime;
  VeicoloModel? selectedVeicolo;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  CategoriaPrezzoListinoModel? selectedListino;
  List<DestinazioneModel> allDestinazioniByCliente = [];
  DestinazioneModel? selectedDestinazione;

  @override
  void initState() {
    super.initState();
    getAllVeicoli();
    getAllDestinazioniByCliente();
    selectedDate = DateTime.now();
    selectedStartTime = TimeOfDay.now();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Compilazione Rapportino',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
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
              Text(
                'Seleziona il veicolo:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              DropdownButton<VeicoloModel>(
                value: selectedVeicolo,
                onChanged: (VeicoloModel? newValue) {
                  setState(() {
                    selectedVeicolo = newValue;
                  });
                },
                items: allVeicoli.map((VeicoloModel veicolo) {
                  return DropdownMenuItem<VeicoloModel>(
                    value: veicolo,
                    child: Text(veicolo.descrizione!), // Sostituisci 'nome' con il campo appropriato del tuo modello VeicoloModel
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _showDestinazioniDialog();
                },
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedDestinazione?.denominazione ?? 'Seleziona Destinazione', style: const TextStyle(fontSize: 16)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Compila il rapportino:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: noteController,
                maxLines: null,
                onChanged: (value) {},
                decoration: InputDecoration(
                  hintText: 'Inserisci qui il rapportino...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: widget.intervento.conclusione_parziale ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        widget.intervento.conclusione_parziale = value;
                        print(widget.intervento.conclusione_parziale);
                      });
                    },
                  ),
                  Text('L\'intervento è terminato?'),
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Inserisci la firma del cliente:',
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
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: takePicture,
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                ),
                child: Text('Scatta Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
              ),
              _buildImagePreview(),
              SizedBox(height: 20),
              Text(
                'Credenziali cliente:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: TextFormField(
                  controller: _descrizioneCredenzialiController,
                  decoration: InputDecoration(
                    hintText: 'A cosa si riferiscono le credenziali?',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {},
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'Inserisci le credenziali del cliente (Username)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {},
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Inserisci le credenziali del cliente (Password)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if(pickedImages.isNotEmpty){
                          saveImageIntervento();
                        } else {
                          saveIntervento();
                          Navigator.pop(context);
                          Navigator.pop(context);ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Rapportino registrato!'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        onPrimary: Colors.white,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: Text('Salva Rapportino'),
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


  String timeOfDayToIso8601String(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return dateTime.toIso8601String();
  }

  Future<void> saveCredenziali() async {
    try {
      final response =
          await http.post(Uri.parse('${ipaddress}/api/credenziali'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'descrizione' : _descrizioneCredenzialiController.text,
                'credenziali':
                    "Username:${usernameController.text}, Password:${passwordController.text}",
                'cliente': widget.intervento.cliente,
                'utente': widget.intervento.utente
              }));
      if (response.statusCode == 201) {
        print("EVVIVAAAAAAAA");
      }
    } catch (e) {
      print('Errore: $e');
    }
  }

  Future<void> saveIntervento() async {
    try {
      final response = await http.post(Uri.parse('${ipaddress}/api/intervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': widget.intervento.id,
            'data': widget.intervento.data?.toIso8601String(),
            'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
            'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
            'orario_fine': DateTime.now().toIso8601String(),
            'descrizione': widget.intervento.descrizione,
            'importo_intervento': null,
            'assegnato': true,
            'conclusione_parziale' : widget.intervento.conclusione_parziale,
            'concluso': true,
            'saldato': false,
            'note': widget.intervento.note,
            'relazione_tecnico' : noteController.text,
            'firma_cliente': signatureBytes,
            'utente': widget.intervento.utente?.toMap(),
            'cliente': widget.intervento.cliente?.toMap(),
            'veicolo': selectedVeicolo?.toMap(),
            'merce' : widget.intervento.merce?.toMap(),
            'tipologia': widget.intervento.tipologia,
            'categoria': widget.intervento.categoria_intervento_specifico,
            'tipologia_pagamento': widget.intervento.tipologia_pagamento,
            'destinazione': selectedDestinazione?.toMap(),
            'gruppo' : widget.intervento.gruppo?.toMap(),
          }));
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rapportino salvato, attendere il caricamento delle foto'),
            duration: Duration(seconds: 5),
          ),
        );
        if (usernameController.text.isNotEmpty &&
            passwordController.text.isNotEmpty) {
          saveCredenziali();
        }
      }
    } catch (e) {
      print('Errore durante il salvataggio del preventivo');
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

  Future<void> saveImageIntervento() async {
    await saveIntervento();
    final intervento = widget.intervento.id;
    try {
      for (var image in pickedImages)  {
        if (image.path != null && image.path.isNotEmpty) {
          print('Percorso del file: ${image.path}');
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('$ipaddress/api/immagine/${intervento}'),
          );
          request.files.add(
            await http.MultipartFile.fromPath(
              'intervento', // Field name
              image.path, // File path
              contentType: MediaType('image', 'jpeg'),
            ),
          );
          var response = await request.send();
          if (response.statusCode == 200) {
            print('File inviato con successo');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Rapportino registrato!'),
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
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      print('Errore durante la chiamata HTTP: $e');
    }
  }

  Future<void> getAllDestinazioniByCliente() async {
    try {
      final response = await http.get(Uri.parse(
          '${ipaddress}/api/destinazione/cliente/${widget.intervento.cliente?.id}'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          allDestinazioniByCliente = responseData
              .map((data) => DestinazioneModel.fromJson(data))
              .toList();
        });
      } else {
        throw Exception('Failed to load Destinazioni per cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
      setState(() {

      });
    }
  }


  Future<void> getAllVeicoli() async {
    http.Response response =
        await http.get(Uri.parse('${ipaddress}/api/veicolo'));
    var responseData = json.decode(response.body.toString());
    if (response.statusCode == 200) {
      List<VeicoloModel> veicoli = [];
      for (var veicoloJson in responseData) {
        VeicoloModel veicolo = VeicoloModel.fromJson(veicoloJson);
        veicoli.add(veicolo);
      }
      setState(() {
        allVeicoli = veicoli;
      });
    } else {
      print("Errore");
    }
  }
}
