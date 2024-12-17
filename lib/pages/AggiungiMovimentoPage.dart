import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../model/ClienteModel.dart';
import '../model/InterventoModel.dart';
import '../model/MovimentiModel.dart';
import '../model/UtenteModel.dart';
import '../model/UtenteModel.dart';
import 'PDFPagamentoAccontoPage.dart';
import 'PDFPrelievoCassaPage.dart';
import 'dart:io';


class AggiungiMovimentoPage extends StatefulWidget {
  final UtenteModel userData;

  const AggiungiMovimentoPage({Key? key, required this.userData}) : super(key: key);

  @override
  _AggiungiMovimentoPageState createState() => _AggiungiMovimentoPageState();
}

class _AggiungiMovimentoPageState extends State<AggiungiMovimentoPage> {
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _importoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late DateTime selectedDate;
  UtenteModel? selectedUtente;
  UtenteModel? selectedUtenteSegreteria;
  TipoMovimentazione? _selectedTipoMovimentazione;
  List<UtenteModel> allUtenti = [];
  Uint8List? signatureBytesIncaricato;
  GlobalKey<SfSignaturePadState> _signaturePadKeyIncaricato = GlobalKey<SfSignaturePadState>();
  Uint8List? signatureBytes;
  GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey<SfSignaturePadState>();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  ClienteModel? selectedCliente;
  List<ClienteModel> clientiList = [];
  List<ClienteModel> filteredClientiList = [];
  List<InterventoModel> interventi = [];
  InterventoModel? selectedIntervento;
  List<XFile> pickedImages =  [];
  bool tecnico = false;

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
  void initState() {
    super.initState();
    getAllUtentiAttivi();
    getAllClienti();
    _signaturePadKey = GlobalKey<SfSignaturePadState>();
    selectedDate = DateTime.now(); // Inizializza la data selezionata con la data corrente
  }

  void _showInterventiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona l\'intervento', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: interventi.map((intervento) {
                        // Calcola l'importo ivato, se i campi sono presenti
                        double? importoIvato = (intervento.importo_intervento != null && intervento.iva != null)
                            ? intervento.importo_intervento! * (1 + (intervento.iva! / 100))
                            : null;
                        return ListTile(
                          leading: const Icon(Icons.settings),
                          title: Text(
                            '${intervento.numerazione_danea} - ${intervento.descrizione!}, importo: ${importoIvato != null ? importoIvato.toStringAsFixed(2) + "€" : "Importo non inserito"}',
                          ),
                          subtitle: Text(intervento.saldato! ? 'Saldato' : 'Non saldato'),
                          onTap: () {
                            setState(() {
                              selectedIntervento = intervento;
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


  void _showClientiDialog() {
    TextEditingController searchController = TextEditingController(); // Aggiungi un controller
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) { // Usa StatefulBuilder per aggiornare lo stato del dialogo
            return AlertDialog(
              title: const Text('Seleziona Cliente', textAlign: TextAlign.center),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController, // Aggiungi il controller
                      onChanged: (value) {
                        setState(() {
                          filteredClientiList = clientiList
                              .where((cliente) => cliente.denominazione!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Cerca Cliente',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredClientiList.map((cliente) {
                            return ListTile(
                              leading: const Icon(Icons.contact_page_outlined),
                              title: Text(
                                  '${cliente.denominazione}, ${cliente.indirizzo}'),
                              onTap: () {
                                setState(() {
                                  selectedCliente = cliente;
                                  getAllInterventiByCliente(cliente.id!);
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

  Future<void> getAllInterventiByCliente(String clientId) async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/intervento/cliente/$clientId'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          interventi = responseData.map((data) => InterventoModel.fromJson(data)).toList();
        });
      } else {
        throw Exception('Failed to load Destinazioni per cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  Future<void> getAllClienti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/cliente'));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<ClienteModel> clienti = [];
        for (var item in jsonData) {
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          clientiList = clienti;
          filteredClientiList = clienti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Pagamento/Acconto Intervento', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 400,
                  child: DropdownButtonFormField<TipoMovimentazione>(
                    value: _selectedTipoMovimentazione,
                    onChanged: (TipoMovimentazione? newValue) {
                      setState(() {
                        _selectedTipoMovimentazione = newValue;
                      });
                    },
                    // Filtra solo i valori desiderati: Acconto e Pagamento
                    items: [TipoMovimentazione.Acconto, TipoMovimentazione.Pagamento]
                        .map<DropdownMenuItem<TipoMovimentazione>>((TipoMovimentazione value) {
                      String label = '';
                      if (value == TipoMovimentazione.Acconto) {
                        label = 'ACCONTO';
                      } else if (value == TipoMovimentazione.Pagamento) {
                        label = 'PAGAMENTO';
                      }
                      return DropdownMenuItem<TipoMovimentazione>(
                        value: value,
                        child: Text(label),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'TIPO MOVIMENTAZIONE',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      hintText: 'Seleziona il tipo di movimentazione',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
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
                        return 'Seleziona il tipo di movimentazione';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 400,
                  child: Container(
                    child: GestureDetector(
                      onTap: () {
                        _showClientiDialog();
                      },
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedCliente?.denominazione ?? 'Seleziona Cliente'.toUpperCase(), style: const TextStyle(fontSize: 16)),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 400,
                  child: Container(
                    child: GestureDetector(
                      onTap: () {
                        _showInterventiDialog();
                      },
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedIntervento?.descrizione ?? 'Seleziona l\'intervento'.toUpperCase(), style: const TextStyle(fontSize: 16)),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    controller: _descrizioneController,
                    decoration: InputDecoration(
                      labelText: 'DESCRIZIONE',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      hintText: 'Inserisci una descrizione',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
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
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una descrizione';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    controller: _importoController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // consenti solo numeri e fino a 2 decimali
                    ],
                    decoration: InputDecoration(
                      labelText: 'IMPORTO',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      hintText: 'Inserisci l\'importo',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
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
                      if (value == null || double.tryParse(value) == null) {
                        return 'Inserisci un importo valido';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),

                Text(
                  'Data di riferimento:'.toUpperCase(),
                  style: TextStyle(color: Colors.black),
                ),
                //),
                Center(
                  child: GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year.toString().substring(2)} ',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            Icon(Icons.edit, size: 16),
                          ])
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min, // Mantiene il contenuto centrato e compatto
                  children: [
                    Checkbox(
                      value: tecnico,
                      onChanged: (bool? value) {
                        setState(() {
                          tecnico = value!; // Aggiorna il valore booleano
                        });
                      },
                    ),
                    Text('IL TECNICO HA EFFETTUATO LA MOVIMENTAZIONE?'), // Testo accanto alla checkbox
                  ],
                ),
                SizedBox(height: 10),
                if(tecnico == true)
                  SizedBox(
                    width: 400,
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
                                final signatureImage = await _signaturePadKey
                                    .currentState!
                                    .toImage(pixelRatio: 3.0);
                                final data = await signatureImage.toByteData(
                                    format: ui.ImageByteFormat.png);
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
                    width: 500,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: signatureBytes != null
                          ? Image.memory(signatureBytes!)
                          : Text(
                        'Firma responsabile cassa'.toUpperCase(),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
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
                              key: _signaturePadKeyIncaricato,
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
                                final signatureImage = await _signaturePadKeyIncaricato
                                    .currentState!
                                    .toImage(pixelRatio: 3.0);
                                final data = await signatureImage.toByteData(
                                    format: ui.ImageByteFormat.png);
                                setState(() {
                                  signatureBytesIncaricato = data!.buffer.asUint8List();
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
                    width: 500,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: signatureBytesIncaricato != null
                          ? Image.memory(signatureBytesIncaricato!)
                          : Text(
                        tecnico == false ? 'Firma cliente'.toUpperCase() : 'Firma Tecnico'.toUpperCase(),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(height: 30),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: takePicture,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red,
                      ),
                      child: Text('Scatta Foto', style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                    ),
                    if(pickedImages.isNotEmpty)
                      _buildImagePreview(),
                  ],
                ),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_validateInputs()) {
                        if(widget.userData.nome == "Segreteria"){
                          _showVerificaDialog();
                        } else {
                          if(_selectedTipoMovimentazione == TipoMovimentazione.Pagamento){
                            saveStatusInterventoPagamento();
                            saveMovimentoPlusPics();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => PDFPagamentoAccontoPage(utente : selectedUtente != null ? selectedUtente : widget.userData, data: selectedDate, descrizione : _descrizioneController.text, importo: _importoController.text, tipoMovimentazione: _selectedTipoMovimentazione!, cliente : selectedCliente, intervento : selectedIntervento, firmaCassa: signatureBytes, firmaIncaricato: signatureBytesIncaricato))
                            );
                            return;
                          }
                          if(_selectedTipoMovimentazione == TipoMovimentazione.Acconto){
                            saveStatusInterventoAcconto();
                            saveMovimentoPlusPics();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => PDFPagamentoAccontoPage(utente : selectedUtente != null ? selectedUtente : widget.userData, data: selectedDate, descrizione : _descrizioneController.text, importo: _importoController.text, tipoMovimentazione: _selectedTipoMovimentazione!, cliente : selectedCliente, intervento : selectedIntervento, firmaCassa: signatureBytes, firmaIncaricato: signatureBytesIncaricato))
                            );
                            return;
                          }
                        }
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 10, vertical: 2))
                    ),
                    child: Text(
                      'Conferma Inserimento',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVerificaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('VERIFICA UTENZA'),
          content: Form( // Avvolgi tutto dentro un Form
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  children: [
                    DropdownButtonFormField<UtenteModel>(
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
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                      ),
                      value: selectedUtenteSegreteria,
                      items: allUtenti.map((utente) {
                        return DropdownMenuItem<UtenteModel>(
                          value: utente,
                          child: Text(utente.nomeCompleto() ??
                              'Nome non disponibile'),
                        );
                      }).toList(),
                      onChanged: (UtenteModel? val) {
                        setState(() {
                          selectedUtenteSegreteria = val;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleziona un utente';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'PASSWORD UTENTE',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: 'Inserire la password dell\'utente',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
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
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci una password valida';
                        }
                        return null;
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () { // Convalida il form
                if(_passwordController.text == selectedUtenteSegreteria?.password){
                  if(_selectedTipoMovimentazione == TipoMovimentazione.Pagamento){
                    saveStatusInterventoPagamento();
                    saveMovimentoPlusPics();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PDFPagamentoAccontoPage(utente : selectedUtenteSegreteria, data: selectedDate, descrizione : _descrizioneController.text, importo: _importoController.text, tipoMovimentazione: _selectedTipoMovimentazione!, cliente : selectedCliente, intervento : selectedIntervento, firmaCassa: signatureBytes, firmaIncaricato: signatureBytesIncaricato))
                    );
                    return;
                  }
                  if(_selectedTipoMovimentazione == TipoMovimentazione.Acconto){
                    saveStatusInterventoAcconto();
                    saveMovimentoPlusPics();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PDFPagamentoAccontoPage(utente : selectedUtenteSegreteria, data: selectedDate, descrizione : _descrizioneController.text, importo: _importoController.text, tipoMovimentazione: _selectedTipoMovimentazione!, cliente : selectedCliente, intervento : selectedIntervento, firmaCassa: signatureBytes, firmaIncaricato: signatureBytesIncaricato))
                    );
                    return;
                  }
                  Navigator.pop(context);
                } else {
                  showPasswordErrorDialog(context);
                }
              },
              child: Text('Conferma'.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  Future<void> showPasswordErrorDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Impedisce la chiusura toccando fuori dal dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errore'),
          content: Text('Password errata, impossibile creare il movimento'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Chiude il dialog
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool _validateInputs() {
    if (_selectedTipoMovimentazione == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seleziona il tipo di movimentazione'),
        ),
      );
      return false;
    }
    if (_descrizioneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci una descrizione'),
        ),
      );
      return false;
    }
    if (_importoController.text.isEmpty || double.tryParse(_importoController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci un importo valido'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> getAllUtenti() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/utente');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<UtenteModel> utenti = [];
        for(var item in jsonData){
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception(
            'Failed to load agenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
    }
  }

  Future<void> getAllUtentiAttivi() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/utente/attivo');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<UtenteModel> utenti = [];
        for(var item in jsonData){
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception(
            'Failed to load agenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
    }
  }

  Future<void> saveNotaAcconto() async{
    try{
      final now = DateTime.now().toIso8601String();
      final response = await http.post(
        Uri.parse('$ipaddress/api/noteTecnico'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': now,
          'utente': widget.userData.toMap(),
          'nota': "Ricevuto un acconto di ${_importoController.text}".toUpperCase(),
          'cliente' : selectedCliente?.toMap(),
          'intervento' : selectedIntervento?.toMap()
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII2');
      }
    } catch(e){
      print('Errore: $e');
    }
  }

  Future<void> saveStatusInterventoAcconto() async{
    try{
      final response = await http.post(Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': selectedIntervento?.id,
          'attivo' : selectedIntervento?.attivo,
          'visualizzato' : selectedIntervento?.visualizzato,
          'titolo' : selectedIntervento?.titolo,
          'priorita' : selectedIntervento?.priorita.toString().split('.').last,
          'numerazione_danea' : selectedIntervento?.numerazione_danea,
          'data_apertura_intervento' : selectedIntervento?.data_apertura_intervento?.toIso8601String(),
          'data': selectedIntervento?.data?.toIso8601String(),
          'orario_appuntamento' : selectedIntervento?.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : selectedIntervento?.posizione_gps,
          'orario_inizio': selectedIntervento?.orario_inizio?.toIso8601String(),
          'orario_fine': selectedIntervento?.orario_fine?.toIso8601String(),
          'descrizione': selectedIntervento?.descrizione,
          'importo_intervento': selectedIntervento?.importo_intervento,
          'saldo_tecnico': selectedIntervento?.saldo_tecnico,
          'prezzo_ivato' : selectedIntervento?.prezzo_ivato,
          'iva' : selectedIntervento?.iva,
          'acconto' : double.parse(_importoController.text),
          'assegnato': selectedIntervento?.assegnato,
          'accettato_da_tecnico' : selectedIntervento?.accettato_da_tecnico,
          'annullato' : selectedIntervento?.annullato,
          'conclusione_parziale' : selectedIntervento?.conclusione_parziale,
          'concluso': selectedIntervento?.concluso,
          'saldato': false,
          'saldato_da_tecnico' : selectedIntervento?.saldato_da_tecnico,
          'note': selectedIntervento?.note,
          'relazione_tecnico' : selectedIntervento?.relazione_tecnico,
          'firma_cliente': selectedIntervento?.firma_cliente,
          'utente_apertura' : selectedIntervento?.utente_apertura?.toMap(),
          'utente': selectedIntervento?.utente?.toMap(),
          'cliente': selectedIntervento?.cliente?.toMap(),
          'veicolo': selectedIntervento?.veicolo?.toMap(),
          'merce': selectedIntervento?.merce?.toMap(),
          'tipologia': selectedIntervento?.tipologia?.toMap(),
          'categoria': selectedIntervento?.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': selectedIntervento?.tipologia_pagamento?.toMap(),
          'destinazione': selectedIntervento?.destinazione?.toMap(),
          'gruppo': selectedIntervento?.gruppo?.toMap()
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lo stato dell\'intervento è stato salvato correttamente!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch(e){
      print('Errore: $e');
    }
  }

  Future<void> saveStatusInterventoPagamento() async{
    try{
      final response = await http.post(Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': selectedIntervento?.id,
          'attivo' : selectedIntervento?.attivo,
          'visualizzato' : selectedIntervento?.visualizzato,
          'titolo' : selectedIntervento?.titolo,
          'priorita' : selectedIntervento?.priorita.toString().split('.').last,
          'numerazione_danea' : selectedIntervento?.numerazione_danea,
          'data_apertura_intervento' : selectedIntervento?.data_apertura_intervento?.toIso8601String(),
          'data': selectedIntervento?.data?.toIso8601String(),
          'orario_appuntamento' : selectedIntervento?.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : selectedIntervento?.posizione_gps,
          'orario_inizio': selectedIntervento?.orario_inizio?.toIso8601String(),
          'orario_fine': selectedIntervento?.orario_fine?.toIso8601String(),
          'descrizione': selectedIntervento?.descrizione,
          'importo_intervento': selectedIntervento?.importo_intervento,
          'saldo_tecnico' : selectedIntervento?.saldo_tecnico,
          'prezzo_ivato' : selectedIntervento?.prezzo_ivato,
          'iva' : selectedIntervento?.iva,
          'acconto' : double.parse(_importoController.text.toString()),
          'assegnato': selectedIntervento?.assegnato,
          'accettato_da_tecnico' : selectedIntervento?.accettato_da_tecnico,
          'annullato' : selectedIntervento?.annullato,
          'conclusione_parziale' : selectedIntervento?.conclusione_parziale,
          'concluso': selectedIntervento?.concluso,
          'saldato': true,
          'saldato_da_tecnico' : selectedIntervento?.saldato_da_tecnico,
          'note': selectedIntervento?.note,
          'relazione_tecnico' : selectedIntervento?.relazione_tecnico,
          'firma_cliente': selectedIntervento?.firma_cliente,
          'utente_apertura' : selectedIntervento?.utente_apertura?.toMap(),
          'utente': selectedIntervento?.utente?.toMap(),
          'cliente': selectedIntervento?.cliente?.toMap(),
          'veicolo': selectedIntervento?.veicolo?.toMap(),
          'merce': selectedIntervento?.merce?.toMap(),
          'tipologia': selectedIntervento?.tipologia?.toMap(),
          'categoria': selectedIntervento?.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': selectedIntervento?.tipologia_pagamento?.toMap(),
          'destinazione': selectedIntervento?.destinazione?.toMap(),
          'gruppo': selectedIntervento?.gruppo?.toMap()
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lo stato dell\'intervento è stato salvato correttamente!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch(e){
      print('Errore: $e');
    }
  }

  Future<http.Response?> addMovimento() async {
    ClienteModel? cliente = selectedCliente != null ? selectedCliente : null;
    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(selectedDate.toUtc());
    Map<String, dynamic>? intervento = selectedIntervento != null ? selectedIntervento!.toMap() : null;
    String tipoMovimentazioneString = _selectedTipoMovimentazione.toString().split('.').last; // Otteniamo solo il nome dell'opzione
    Map<String, dynamic> body = {
      'id': null,
      'data': selectedDate.toIso8601String(),
      'descrizione': _descrizioneController.text.toUpperCase(),
      'tipo_movimentazione': tipoMovimentazioneString,
      'importo': double.parse(_importoController.text.toString()),
      'utente': widget.userData.nome == "Segreteria" ? selectedUtenteSegreteria?.toMap() : widget.userData.toMap(),
      'intervento' : intervento,
      'cliente' : cliente?.toMap()
    };
    try {
      debugPrint("Body della richiesta: ${body.toString()}");
      final response = await http.post(
        Uri.parse('$ipaddress/api/movimenti'),
        body: jsonEncode(body),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 201) {
        print('Movimentazione salvata con successo');
        return response;
      } else {
        print('Errore durante il salvataggio della movimentazione: ${response.statusCode}');

      }
    } catch (e) {
      print('Errore durante la chiamata HTTP: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante la chiamata HTTP'),
          ),
        );
      }
    }
  }

  Future<void> saveMovimentoPlusPics() async{
    final data = await addMovimento();
    try{
      if(data == null){
        throw Exception('Dati della movimentazione non disponibili.');
      }
      final movimento = MovimentiModel.fromJson(jsonDecode(data.body));
      try{
        for(var image in pickedImages){
          if(image.path != null && image.path.isNotEmpty){
            var request = http.MultipartRequest(
              'POST',
              Uri.parse('$ipaddress/api/immagine/movimento/${int.parse(movimento.id!.toString())}'),
            );
            request.files.add(
                await http.MultipartFile.fromPath(
                  'movimento',
                  image.path,
                  contentType: MediaType('image', 'jpeg'),
                )
            );
            var response = await request.send();
            if(response.statusCode == 200){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Movimentazione registrata con successo!')
                ),
              );
            } else{
              print('Errore: Il percorso del file non è valido');
            }
          }
          pickedImages.clear();
          Navigator.pop(context);
        }
      } catch(e){
        print('Errore $e');
      }
    } catch(e){
      print('Errore $e');
    }
  }
}
