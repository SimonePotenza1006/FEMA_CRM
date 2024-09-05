import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class DettaglioMerceInRiparazioneAmministrazionePage extends StatefulWidget{
  final MerceInRiparazioneModel merce;
  final VoidCallback? onNavigateBack;

  const DettaglioMerceInRiparazioneAmministrazionePage(
      {Key? key, required this.merce, this.onNavigateBack}
      ): super(key: key);

  @override
  _DettaglioMerceInRiparazioneAmministrazionePageState createState() => _DettaglioMerceInRiparazioneAmministrazionePageState();
}

class _DettaglioMerceInRiparazioneAmministrazionePageState extends State<DettaglioMerceInRiparazioneAmministrazionePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<UtenteModel> allUtenti = [];
  UtenteModel? selectedUtente;
  List<XFile> pickedImages =  [];
  TextEditingController importoFinaleController = TextEditingController();
  TextEditingController importoPreventivatoController = TextEditingController();

  Future<void> takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        pickedImages.add(pickedFile);
      });
    }
  }

  void selectUtente(UtenteModel utente) {
    setState(() {
      selectedUtente = utente;
    });
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
  void initState() {
    super.initState();
    importoPreventivatoController = TextEditingController(text: widget.merce.importo_preventivato.toString());
  }

  Widget buildInfoRow({required String title, required String value}) {
    return SizedBox(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4, // Linea di accento colorata
                      height: 24,
                      color: Colors.redAccent, // Colore di accento per un tocco di vivacità
                    ),
                    SizedBox(width: 10),
                    Text(
                      title.toUpperCase() + ": ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Colore contrastante per il testo
                      ),
                    ),
                  ],
                ),
                Text(
                  value.toUpperCase(),
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold// Un colore secondario per differenziare il valore
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Divider( // Linea di separazione tra i widget
              color: Colors.grey[400],
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio Merce in Riparazione'.toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 22.0), // Aumenta la dimensione del testo dell'intestazione
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Info merce in riparazione'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: 'ID MERCE', value: widget.merce.id!),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: "articolo", value: widget.merce.articolo!),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: "accessori", value: widget.merce.accessori ?? "N/A"),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: "difetto", value: widget.merce.difetto_riscontrato ?? "N/A"),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: 'Password', value: widget.merce.password ?? "N/A"),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: "dati", value: widget.merce.dati ?? "N/A"),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: "Richiesta preventivo", value: widget.merce.preventivo != null ? (widget.merce.preventivo != true ? "NO" : "SI"): "N/A"),
                            if (widget.merce.preventivo != null && widget.merce.preventivo == true)
                              buildInfoRow(title: "prezzo preventivato", value: widget.merce.importo_preventivato != null ? widget.merce.importo_preventivato!.toStringAsFixed(2) : "Non Inserito"),
                            SizedBox(
                                width: 500,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: TextFormField(
                                        controller: importoPreventivatoController,
                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: 'Importo Preventivato'.toUpperCase(),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        saveImportoPreventivo();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red,
                                        onPrimary: Colors.white,
                                      ),
                                      child: Text('Salva importo Preventivo'.toUpperCase()),
                                    ),
                                  ],
                                )
                            ),

                          ],
                        )
                    ),
                    SizedBox(width: 20),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildInfoRow(title: "data arrivo", value: widget.merce.data != null ? DateFormat('dd/MM/yyyy').format(widget.merce.data!) : "N/A"),
                          SizedBox(height: 10.0),
                          buildInfoRow(title: "data presa in carico", value:(widget.merce.data_presa_in_carico != null ? DateFormat('dd-MM-yyyy').format(widget.merce.data_presa_in_carico!) : 'N/A' )),
                          SizedBox(height: 10.0),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (selectedUtente != null) // Mostra il pulsante solo se selectedUtente è valorizzato
                      ElevatedButton(
                        onPressed: () {
                          assegna();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Text('Assegna ad utente'),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        merceConsegnata();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Text('Merce consegnata'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        merceSaldata();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Text('Merce saldata'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        )
      ),
    );
  }

  Future<void> merceSaldata() async{
    try {
      // Ottieni la data attuale come stringa ISO 8601
      String? dataPresaInCarico = widget.merce.data_presa_in_carico != null ? widget.merce.data_presa_in_carico!.toIso8601String() : null;

      // Verifica se 'data_conclusione' è null e converte in stringa ISO 8601 se necessario
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;

      // Verifica se 'data_consegna' è null e converte in stringa ISO 8601 se necessario
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;

      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': importoPreventivatoController.text,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'prodotti_installati': widget.merce.prodotti_installati,
          'data_consegna': dataConsegna,
        }),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Merce saldata con successo!'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio dell\'importo finale: $e');
    }
  }

  Future<void> merceConsegnata() async {
    try {
      // Ottieni la data attuale come stringa ISO 8601
      String? dataPresaInCarico = widget.merce.data_presa_in_carico != null ? widget.merce.data_presa_in_carico!.toIso8601String() : null;

      // Verifica se 'data_conclusione' è null e converte in stringa ISO 8601 se necessario
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;

      // Verifica se 'data_consegna' è null e converte in stringa ISO 8601 se necessario
      String dataConsegna = DateTime.now().toIso8601String();

      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': widget.merce.importo_preventivato,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'prodotti_installati': widget.merce.prodotti_installati,
          'data_consegna': dataConsegna,
        }),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Merce consegnata con successo!'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio dell\'importo finale: $e');
    }
  }

  Future<void> saveImportoFinale() async {
    try {
      // Ottieni la data attuale come stringa ISO 8601
      String? dataPresaInCarico = widget.merce.data_presa_in_carico != null ? widget.merce.data_presa_in_carico!.toIso8601String() : null;

      // Verifica se 'data_conclusione' è null e converte in stringa ISO 8601 se necessario
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;

      // Verifica se 'data_consegna' è null e converte in stringa ISO 8601 se necessario
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;

      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': widget.merce.importo_preventivato,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'prodotti_installati': widget.merce.prodotti_installati,
          'data_consegna': dataConsegna,
        }),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Importo finale salvato'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio dell\'importo finale: $e');
    }
  }

  Future<void> saveImportoPreventivo() async {
    try {
      // Ottieni la data attuale come stringa ISO 8601
      String? dataPresaInCarico = widget.merce.data_presa_in_carico != null ? widget.merce.data_presa_in_carico!.toIso8601String() : null;

      // Verifica se 'data_conclusione' è null e converte in stringa ISO 8601 se necessario
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;

      // Verifica se 'data_consegna' è null e converte in stringa ISO 8601 se necessario
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;

      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': importoPreventivatoController.text,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'prodotti_installati': widget.merce.prodotti_installati,
          'data_consegna': dataConsegna,
        }),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Importo preventivato salvato'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio dell\'importo preventivato: $e');
    }
  }


  Future<void> assegna() async {
    try {
      // Ottieni la data attuale come stringa ISO 8601
      String dataPresaInCarico = DateTime.now().toIso8601String();

      // Verifica se 'data_conclusione' è null e converte in stringa ISO 8601 se necessario
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;

      // Verifica se 'data_consegna' è null e converte in stringa ISO 8601 se necessario
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;

      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': widget.merce.importo_preventivato,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'prodotti_installati': widget.merce.prodotti_installati,
          'data_consegna': dataConsegna,
          'utente': selectedUtente?.toJson()
        }),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Merce assegnata a tecnico'),
        ),
      );
    } catch (e) {
      print('Errore durante assegnazione $e');
    }
  }


  Widget buildLightDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],
    );
  }

  Widget buildDarkDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[600],
    );
  }

  Future<void> getAllUtenti() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/api/utente');
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

Future<void> saveImagesMerce() async {
  try {
    for (var image in pickedImages) {
      // Verifica se il percorso del file è valido
      if (image.path != null && image.path.isNotEmpty) {
        print('Percorso del file: ${image.path}');
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$ipaddress/api/immagine/merce/${int.parse(widget.merce.id!.toString())}'),
        );
        // Provide field name and file path to fromPath constructor
        request.files.add(
          await http.MultipartFile.fromPath(
            'merce', // Field name
            image.path, // File path
            contentType: MediaType('image', 'jpeg'),
          ),
        );
        var response = await request.send();
        if (response.statusCode == 200) {
          print('File inviato con successo');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Foto salvata!!'),
              duration: Duration(seconds: 1), // Durata dello Snackbar
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
}
}