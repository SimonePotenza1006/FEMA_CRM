import 'dart:convert';
import 'dart:io';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/model/MovimentiModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../model/ClienteModel.dart';

class ModificaMovimentazionePage extends StatefulWidget{
  final MovimentiModel movimento;

  const ModificaMovimentazionePage({Key? key, required this.movimento}) : super(key:key);

  @override
  _ModificaMovimentazionePageState createState() => _ModificaMovimentazionePageState();
}

class _ModificaMovimentazionePageState extends State<ModificaMovimentazionePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<UtenteModel> allUtenti = [];
  late UtenteModel? _selectedUtente = widget.movimento.utente;
  ClienteModel? selectedCliente;
  List<ClienteModel> clientiList = [];
  List<ClienteModel> filteredClientiList = [];
  late TextEditingController _descrizioneController;
  late TextEditingController _importoController;
  late TipoMovimentazione selectedTipologia;
  late DateTime? _selectedDate = widget.movimento.data;
  TipoMovimentazione? _selectedTipoMovimentazione;
  List<XFile> pickedImages =  [];

  @override
  void initState(){
    super.initState();
    getAllClienti();
    _importoController = TextEditingController(text: widget.movimento.importo!.toStringAsFixed(2));
    _descrizioneController = TextEditingController(text: widget.movimento.descrizione);
  }

  Future<void> takePicture() async {
    final ImagePicker _picker = ImagePicker();
    if (Platform.isAndroid) {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          pickedImages.add(pickedFile);
        });
      }
    }
    else if (Platform.isWindows) {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          pickedImages.addAll(pickedFiles);
        });
      }
    }
  }

  Future<void> savePics() async{
    final movimento = widget.movimento;
    try{
      for(var image in pickedImages){
        if(image.path.isNotEmpty){
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
      }
    } catch(e){
      print('Errore 1 durante l\'invio del file: $e');
    } finally{
      pickedImages.clear();
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.movimento.descrizione}',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.white),
            onPressed: (){
              takePicture();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              _buildDatePickerField(
                context,
                TextEditingController(
                    text: _selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                        : ''),
                'Data Tagliando'.toUpperCase(),
                initialDate: _selectedDate ?? DateTime.now().add(Duration(days: 1)),
                firstDate: DateTime.now().add(Duration(days: 1)),
                lastDate: DateTime(2100),
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
              SizedBox(height: 10),
              _buildTextFormField(_descrizioneController, "Descrizione", "Inserisci la descrizione"),
              SizedBox(height: 10),
              _buildTextFormField(_importoController, "Importo", "Inserisci importo"),
              SizedBox(height :10),
              SizedBox(
                width: 450,
                child: DropdownButtonFormField<TipoMovimentazione>(
                  value: _selectedTipoMovimentazione,
                  onChanged: (TipoMovimentazione? newValue) {
                    setState(() {
                      _selectedTipoMovimentazione = newValue;
                    });
                  },
                  items: TipoMovimentazione.values.map<DropdownMenuItem<TipoMovimentazione>>((TipoMovimentazione value) {
                    String label;
                    if (value == TipoMovimentazione.Entrata) {
                      label = 'Entrata';
                    } else if (value == TipoMovimentazione.Uscita) {
                      label = 'Uscita';
                    } else if(value == TipoMovimentazione.Acconto){
                      label = 'Acconto';
                    } else if(value == TipoMovimentazione.Pagamento) {
                      label = 'Pagamento';
                    } else if(value == TipoMovimentazione.Prelievo){
                      label = 'Prelievo';
                    } else {
                      label = 'Versamento';
                    }
                    return DropdownMenuItem<TipoMovimentazione>(
                      value: value,
                      child: Text(
                        label,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'TIPO MOVIMENTAZIONE',
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
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Selezionare il tipo di movimentazione';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                width: 350,
                child: GestureDetector(
                  onTap: () {
                    _showClientiDialog();
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedCliente?.denominazione ?? 'Seleziona Cliente', style: const TextStyle(fontSize: 16)),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              if(pickedImages.length > 0)
                _buildImagePreview(),
              SizedBox(height: 34),
              Center(
                child:ElevatedButton(
                  onPressed: () {
                    if(pickedImages.length > 0){
                      savePics().whenComplete(() => updateMovimento().whenComplete(() => Navigator.pop(context)));
                    } else {
                      updateMovimento().whenComplete(() => Navigator.pop(context));
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text(
                    'Conferma modifiche',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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


  Future<void> updateMovimento() async{
    var cliente = selectedCliente != null ? selectedCliente?.toMap() : null;
    try{
      var response = await http.post(
        Uri.parse('$ipaddress/api/movimenti'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'id' : widget.movimento.id,
          'data' : _selectedDate?.toIso8601String(),
          'utente' : _selectedUtente?.toMap(),
          'cliente' : cliente,
          'tipo_movimentazione': selectedTipologia.toString().split('.').last,
          'descrizione' : _descrizioneController.text,
          'importo' : double.parse(_importoController.text.toString())
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Movimentazione aggiornata correttamente, ricarica la pagina per i nuovi dati'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        Navigator.pop(context);
      }
    } catch(e){
      print('Errore durante la modifica : $e');
    }
  }

  Widget _buildDatePickerField(
      BuildContext context, TextEditingController controller, String label,
      {DateTime? initialDate, DateTime? firstDate, DateTime? lastDate, void Function(DateTime?)? onDateSelected}) {
    return SizedBox(
      width: 450, // Larghezza modificata
      child: GestureDetector(
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: initialDate ?? DateTime.now(),
            firstDate: firstDate ?? DateTime.now(),
            lastDate: lastDate ?? DateTime(2100),
          ).then((selectedDate) {
            if (selectedDate != null && onDateSelected != null) {
              onDateSelected(selectedDate);
            }
          });
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              hintText: 'Seleziona una data', // Testo suggerimento
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText,
      {String? Function(String?)? validator}) {
    return SizedBox(
      width: 450, // Larghezza modificata
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
}