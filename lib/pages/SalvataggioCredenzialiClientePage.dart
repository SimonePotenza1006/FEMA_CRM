import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../model/CredenzialiClienteModel.dart';

class SalvataggioCredenzialiClientePage extends StatefulWidget{
  final ClienteModel cliente;
  final UtenteModel utente;

  const SalvataggioCredenzialiClientePage({Key? key, required this.utente, required this.cliente}) : super(key:key);

  @override
  _SalvataggioCredenzialiClientePageState createState() =>_SalvataggioCredenzialiClientePageState();
}

class _SalvataggioCredenzialiClientePageState extends State<SalvataggioCredenzialiClientePage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Uint8List? _combinedImage;
  bool salvaSimbolo = false;

  // Definisci la chiave del form
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String? denominazione = widget.cliente.denominazione!;

    // Controllo della lunghezza e applicazione di substring se necessario
    String titolo = denominazione.length > 19
        ? denominazione.substring(0, 19)
        : denominazione;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Salvataggio credenziali $titolo".toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Form(
              // Associa la formKey al form
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 12),
                  _buildTextFormField(_descrizioneController, "A cosa si riferiscono le credenziali?", "A cosa si riferiscono le credenziali?"),
                  SizedBox(height: 12),
                  _buildTextFormField(_usernameController, "Username", "Inserisci l'username"),
                  SizedBox(height: 12),
                  _buildTextFormField(_passwordController, "Password", "Inserisci la password"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        salvaSimbolo = !salvaSimbolo;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Salva simbolo'.toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height:20),
                  if(salvaSimbolo)
                    Container(
                        child : Column(
                          mainAxisAlignment : MainAxisAlignment.center,
                          children : [
                            GestureDetector(
                              onTap: () async {
                                final combinedImage = await showDialog<Uint8List?>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SignatureDialog(imagePath: "assets/images/password.jpg");
                                  },
                                );

                                if (combinedImage != null) {
                                  setState(() {
                                    _combinedImage = combinedImage;
                                  });
                                }
                              },
                              child: Image.asset("assets/images/password.jpg", width: 213),
                            ),
                            SizedBox(height: 10),
                          ],
                        )
                    ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if(_combinedImage != null){
                          savePic(_combinedImage!);
                        } else {
                          saveCredenziali();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Salva credenziali'.toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText,
      {String? Function(String?)? validator}) {
    return SizedBox(
      width: 600, // Larghezza modificata
      child: TextFormField(
        controller: controller,
        maxLines: null, // Permette più righe
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200], // Sfondo riempito
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Nessun bordo di default
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.redAccent,
              width: 2.0, // Larghezza bordo focale
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.0, // Larghezza bordo abilitato
            ),
          ),
          contentPadding:
          EdgeInsets.symmetric(vertical: 15, horizontal: 10), // Padding contenuto
        ),
        validator: validator, // Funzione di validazione
      ),
    );
  }
  
  Future<http.Response?> saveCredenziali() async{
    late http.Response response;
    try{
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/credenziali'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'descrizione' : _descrizioneController.text,
          'credenziali' : "Username : ${_usernameController.text}  Password : ${_passwordController.text}",
          'cliente' : widget.cliente.toMap(),
          'utente' : widget.utente.toMap()
        }),
      );
      if(response.statusCode == 200){
          _usernameController.clear();
          _passwordController.clear();
          _descrizioneController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Credenziali salvate con successo!"),
              duration: Duration(seconds: 3),
          )
        );
      }
      return response;
    } catch(e){
      print("Qualcosa non va: $e");
      return null;
    }
  }

  Future<void> savePic(Uint8List image) async {
    final data = await saveCredenziali();
    try {
      if (data == null) {
        throw Exception('Dati del ddt non disponibili.');
      }
      final credenziali = CredenzialiClienteModel.fromJson(jsonDecode(data.body));
      try {
        showDialog(
          context: context,
          barrierDismissible: false, // Impedisce la chiusura del dialog premendo fuori
          builder: (BuildContext context) {
            return AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Caricamento in corso..."),
                ],
              ),
            );
          },
        );
        try {
          // Usa `fromBytes` al posto di `fromPath` per inviare `Uint8List`
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('$ipaddressProva/api/immagine/credenziali/${credenziali.id}'),
          );
          request.files.add(
            http.MultipartFile.fromBytes(
              'credenziali', // Nome del campo del file
              image,        // Dati dell'immagine come Uint8List
              filename: 'credenziali_${credenziali.id}', // Nome file (opzionale)
              contentType: MediaType('image', 'jpg'),
            ),
          );
          var response = await request.send();
          Navigator.pop(context); // Chiude il dialog di caricamento
          if (response.statusCode == 200) {
            print('File inviato con successo');
            Navigator.pop(context);
          } else {
            print('Errore durante l\'invio del file: ${response.statusCode}');
          }
        } catch (e) {
          Navigator.pop(context); // Chiude il dialog di caricamento
          print('Errore durante l\'invio del file 2: $e');
        }
      } catch (e) {
        Navigator.pop(context); // Chiudi il dialog di caricamento in caso di errore
        print('Errore durante l\'invio del file: $e');
      }
    } catch (e) {
      print('Errore: $e');
    }
  }

}

class Stroke {
  final Color color;
  final List<Offset?> points;

  Stroke(this.color, this.points);
}

class SignatureDialog extends StatefulWidget {
  final String imagePath;

  SignatureDialog({required this.imagePath});

  @override
  _SignatureDialogState createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  final List<Stroke> _strokes = [];
  Color currentColor = Colors.red;
  final double dialogWidth = 600;
  final double dialogHeight = 600;

  final GlobalKey _dialogKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _strokes.add(Stroke(currentColor, []));
  }

  void _addStroke() {
    if (_strokes.isNotEmpty) {
      _strokes.add(Stroke(currentColor, []));
    }
  }

  void _saveSignature() async {
    final combinedImage = await _combineSignatures();
    Navigator.of(context).pop(combinedImage);
  }

  Future<Uint8List> _combineSignatures() async {
    final baseImage = await _captureBaseImage();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(baseImage, Offset.zero, Paint());

    for (final stroke in _strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        if (stroke.points[i] != null && stroke.points[i + 1] != null) {
          canvas.drawLine(stroke.points[i]!, stroke.points[i + 1]!, paint);
        }
      }
    }

    final picture = recorder.endRecording();
    final imgFinale = await picture.toImage(dialogWidth.toInt(), dialogHeight.toInt());
    final byteData = await imgFinale.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<ui.Image> _captureBaseImage() async {
    final RenderRepaintBoundary boundary =
    _dialogKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    return image;
  }

  void _changeColor(Color color) {
    setState(() {
      currentColor = color;
      _strokes.add(Stroke(currentColor, []));
    });
  }

  // Funzione per calcolare l'offset corretto sull'asse X
  double _calculateHorizontalOffset(Size imageSize, Size containerSize) {
    double scale = containerSize.width / imageSize.width;
    double scaledImageWidth = imageSize.width * scale;

    // Se l'immagine scalata non riempie il contenitore in larghezza, calcoliamo l'offset
    if (scaledImageWidth < containerSize.width) {
      return (containerSize.width - scaledImageWidth) / 2;
    } else {
      return 0; // Nessun offset necessario se riempie la larghezza
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: RepaintBoundary(
        key: _dialogKey,
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onPanUpdate: (details) {
                        RenderBox renderBox = context.findRenderObject() as RenderBox;
                        Offset localPosition = renderBox.globalToLocal(details.globalPosition);

                        // Calcola l'offset orizzontale basato sulle dimensioni reali dell'immagine e del container
                        Size containerSize = Size(dialogWidth, dialogHeight);
                        Size imageSize = Size(600, 600); // Cambia con la dimensione corretta dell'immagine

                        double offsetX = _calculateHorizontalOffset(imageSize, containerSize);

                        // Applica l'offset X alle coordinate
                        Offset correctedPosition = Offset(localPosition.dx - offsetX, localPosition.dy);

                        // Print per monitorare
                        print("Coordinate del dito (globali): ${details.globalPosition}");
                        print("Coordinate disegno (locali corrette): ${correctedPosition}");

                        if (_strokes.isNotEmpty) {
                          _strokes.last.points.add(correctedPosition);
                          setState(() {});
                        }
                      },
                      onPanEnd: (details) {
                        _addStroke();
                      },
                      child: CustomPaint(
                        painter: SignaturePainter(_strokes),
                        child: Container(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.circle, color: Colors.red),
              onPressed: () => _changeColor(Colors.red),
            ),
            IconButton(
              icon: Icon(Icons.circle, color: Colors.blue),
              onPressed: () => _changeColor(Colors.blue),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _strokes.clear();
              _strokes.add(Stroke(currentColor, []));
            });
          },
          child: Text("Cancella".toUpperCase()),
        ),
        TextButton(
          onPressed: _saveSignature,
          child: Text("Salva".toUpperCase()),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class SignaturePainter extends CustomPainter {
  final List<Stroke> strokes;

  SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        if (stroke.points[i] != null && stroke.points[i + 1] != null) {
          canvas.drawLine(stroke.points[i]!, stroke.points[i + 1]!, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}