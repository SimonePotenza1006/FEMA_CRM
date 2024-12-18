import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:fema_crm/model/FornitoreModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../model/MovimentiModel.dart';
import '../model/UtenteModel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class AcquistoFornitorePage extends StatefulWidget{
  final UtenteModel utente;

  AcquistoFornitorePage({Key? key, required this.utente}) : super(key:key);

  @override
  _AcquistoFornitorePageState createState() => _AcquistoFornitorePageState();
}

class _AcquistoFornitorePageState extends State<AcquistoFornitorePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  late DateTime selectedDate;
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _importoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FornitoreModel? selectedFornitore;
  List<FornitoreModel> fornitoriList = [];
  List<FornitoreModel> filteredFornitoriList = [];
  List<UtenteModel> allUtenti = [];
  UtenteModel? selectedUtente;
  List<XFile> pickedImages =  [];

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
  void initState(){
    super.initState();
    getAllFornitori();
    getAllUtenti();
    selectedDate = DateTime.now();
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
      print('Qualcosa non va utenti : $e');
    }
  }

  Future<void> saveMovimentoPlusPics() async{
    final data = await addMovimento();
    try{
      if(data == null){
        throw Exception('Dati del movimento non disponibili.');
      }
      final movimento = MovimentiModel.fromJson(jsonDecode(data.body));
      try{
        for(var image in pickedImages){
          if(image.path.isNotEmpty){
            print('Percorso del file: ${image.path}');
            var request = http.MultipartRequest(
              'POST',
              Uri.parse('$ipaddress/api/immagine/movimento/${int.parse(movimento.id!.toString())}'),
            );
            request.files.add(
              await http.MultipartFile.fromPath(
                'movimento',
                image.path,
                contentType: MediaType('image', 'jpeg')
              )
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
          }
          pickedImages.clear();
          Navigator.pop(context);
        }
      } catch(e){
        print('Errore 1 durante l\'invio del file: $e');
      }
    } catch(e){
      print('Errore 2 durante l\'invio del file: $e');
    }
  }

  Future<void> getAllFornitori() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/fornitore'));
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<FornitoreModel> fornitori = [];
        for(var item in jsonData){
          fornitori.add(FornitoreModel.fromJson(item));
        }
        setState(() {
          fornitoriList = fornitori;
          filteredFornitoriList = fornitori;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamata all\'API: $e');
    }
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
                      value: selectedUtente,
                      items: allUtenti.map((utente) {
                        return DropdownMenuItem<UtenteModel>(
                          value: utente,
                          child: Text(utente.nomeCompleto() ??
                              'Nome non disponibile'),
                        );
                      }).toList(),
                      onChanged: (UtenteModel? val) {
                        setState(() {
                          selectedUtente = val;
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
                if(_passwordController.text == selectedUtente?.password){
                  if(pickedImages.length >0){
                    saveMovimentoPlusPics();
                  } else{
                    addMovimento();
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


  void _showFornitoriDialog(){
    TextEditingController searchController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
            builder: (context, setState){
              return AlertDialog(
                title: const Text('Seleziona fornitore', textAlign: TextAlign.center),
                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController, // Aggiungi il controller
                        onChanged: (value) {
                          setState(() {
                            filteredFornitoriList = fornitoriList
                                .where((fornitore) => fornitore.denominazione!
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Cerca Fornitore',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: filteredFornitoriList.map((fornitore) {
                              return ListTile(
                                leading: const Icon(Icons.contact_page_outlined),
                                title: Text(
                                    '${fornitore.denominazione}, ${fornitore.indirizzo}'),
                                onTap: () {
                                  setState(() {
                                    selectedFornitore= fornitore;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagamento fornitore', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.white),
            onPressed: (){
              takePicture();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 500,
                      child: Container(
                        child: GestureDetector(
                          onTap: () {
                            _showFornitoriDialog();
                          },
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(selectedFornitore?.denominazione ?? 'Seleziona fornitore'.toUpperCase(), style: const TextStyle(fontSize: 16)),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: 500,
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
                    SizedBox(height: 15),
                    SizedBox(
                      width: 500,
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
                    SizedBox(height: 10),
                    if(pickedImages.length > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildImagePreview()
                        ],
                      ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if(widget.utente.nome == "Segreteria"){
                          _showVerificaDialog();
                        } else {
                          if(pickedImages.length > 0){
                            saveMovimentoPlusPics();
                          } else {
                            addMovimento();
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
                  ],
                ),
              )
          ),
        ),
      ),
    );
  }


  Future<http.Response?> addMovimento() async{
    late http.Response response;
    try{
      String prioritaString = TipoMovimentazione.Uscita.toString().split('.').last;
      response = await http.post(
          Uri.parse('$ipaddress/api/movimenti'),
          headers: {'Content-Type' : 'application/json'},
          body: jsonEncode({
            'data' : selectedDate.toIso8601String(),
            'descrizione' : _descrizioneController.text,
            'importo' : double.tryParse(_importoController.text.toString()),
            'utente' : widget.utente.nome == "Segreteria" ? selectedUtente?.toMap() : widget.utente.toMap(),
            'fornitore' : selectedFornitore?.toMap(),
            'tipo_movimentazione' : prioritaString,
          })
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Movimentazione salvata con successo!'),
          ),
        );
        return response;
      }
    } catch(e){
      print('errore:$e');
      return null;
    }
    return null;
  }
}
