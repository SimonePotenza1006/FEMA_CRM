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

  void _showAssignTechnicianDialog(BuildContext context) async {
    await getAllUtenti();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleziona un tecnico'),
          content: SingleChildScrollView(
            child: Column(
              children: allUtenti.map((utente) {
                return ListTile(
                  title: Text(utente.nome ?? ''),
                  onTap: () {
                    selectUtente(utente); // Chiamata alla funzione per memorizzare l'utente selezionato
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
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
  void initState() {
    super.initState();
    importoPreventivatoController = TextEditingController(text: widget.merce.importo_preventivato.toString());
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio Merce in Riparazione',
          style: TextStyle(color: Colors.white, fontSize: 22.0), // Aumenta la dimensione del testo dell'intestazione
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15,),
            ElevatedButton(
              onPressed: takePicture,
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                onPrimary: Colors.white,
              ),
              child: Text('Scatta Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
            ),
            SizedBox(height: 15,),
            _buildImagePreview(),
            if(pickedImages.length > 0)
              ElevatedButton(
                onPressed: () async {
                  if (pickedImages.isNotEmpty) {
                    await saveImagesMerce();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Devi scattare almeno una foto!'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: Text('Salva e Invia Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                ),
              ),
            SizedBox(height: 10.0),
            Text('ID:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.id ?? '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildDarkDivider(),
            Text('Data arrivo merce:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.data != null ? DateFormat('dd-MM-yyyy').format(widget.merce.data!) : '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildLightDivider(),
            Text('Articolo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.articolo ?? '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildLightDivider(),
            Text('Accessori:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.accessori ?? '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildDarkDivider(),
            Text('Difetto Riscontrato:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.difetto_riscontrato ?? '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildLightDivider(),
            Text('Data Presa in Carico:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.data_presa_in_carico != null ? DateFormat('dd-MM-yyyy').format(widget.merce.data_presa_in_carico!) : '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildDarkDivider(),
            Text('Password:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.password ?? '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildLightDivider(),
            Text('Dati:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.dati ?? '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildDarkDivider(),
            if (selectedUtente != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tecnico Selezionato:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                  Text(selectedUtente?.nome ?? '', style: TextStyle(fontSize: 18.0)),
                ],
              ),
            SizedBox(height: 20,),
            Text('Preventivo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.preventivo == true ? 'SI' : 'NO', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildLightDivider(),
            Text('Importo Preventivato:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
            if (widget.merce.preventivo == true && widget.merce.importo_preventivato == 0.0)
              TextFormField(
                controller: importoPreventivatoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Importo Preventivato',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Non è più necessario aggiornare widget.merce.importo_preventivato qui
                },
              ),
            if (!(widget.merce.preventivo == true && widget.merce.importo_preventivato == 0.0))
              Text(widget.merce.importo_preventivato?.toString() ?? '', style: TextStyle(fontSize: 18.0)),
            if (widget.merce.preventivo == true && widget.merce.importo_preventivato == 0.0)
              SizedBox(height: 10),
            if (widget.merce.preventivo == true && widget.merce.importo_preventivato == 0.0)
              ElevatedButton(
                onPressed: () {
                  saveImportoPreventivo();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                ),
                child: Text('Salva importo Preventivo'),
              ),
            SizedBox(height: 10),
            buildDarkDivider(),
            Text('Diagnosi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.diagnosi ?? '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildLightDivider(),
            Text('Risoluzione:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.risoluzione ?? '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildDarkDivider(),
            Text('Data Conclusione:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.data_conclusione != null ? DateFormat('dd-MM-yyyy').format(widget.merce.data_conclusione!) : '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildLightDivider(),
            Text('Prodotti Installati:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.prodotti_installati ?? '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildDarkDivider(),
            Text('Data Consegna:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)), // Aumenta la dimensione del testo
            Text(widget.merce.data_consegna != null ? DateFormat('dd-MM-yyyy').format(widget.merce.data_consegna!) : '', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo
            buildLightDivider(),



            // ElevatedButton(
            //   onPressed: () {
            //     saveImportoFinale(); // Funzione da implementare per salvare l'importo finale
            //   },
            //   style: ElevatedButton.styleFrom(
            //     primary: Colors.red,
            //     onPrimary: Colors.white,
            //   ),
            //   child: Text('Salva importo finale'),
            // ),
            SizedBox(height: 60.0),
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