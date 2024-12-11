import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fema_crm/model/FornitoreModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../model/MovimentiModel.dart';
import '../model/UtenteModel.dart';

class AcquistoFornitorePage extends StatefulWidget{
  final UtenteModel utente;

  AcquistoFornitorePage({Key? key, required this.utente}) : super(key:key);

  @override
  _AcquistoFornitorePageState createState() => _AcquistoFornitorePageState();
}

class _AcquistoFornitorePageState extends State<AcquistoFornitorePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  late DateTime selectedDate;
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _importoController = TextEditingController();
  FornitoreModel? selectedFornitore;
  List<FornitoreModel> fornitoriList = [];
  List<FornitoreModel> filteredFornitoriList = [];

  @override
  void initState(){
    super.initState();
    getAllFornitori();
    selectedDate = DateTime.now();
  }

  Future<void> getAllFornitori() async{
    try{
      final response = await http.get(Uri.parse('$ipaddressProva/api/fornitore'));
      if(response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
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
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                        addMovimento();
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


  Future<void> addMovimento() async{
    try{
      String prioritaString = TipoMovimentazione.Uscita.toString().split('.').last;
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/movimenti'),
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({
          'data' : selectedDate.toIso8601String(),
          'descrizione' : _descrizioneController.text,
          'importo' : double.tryParse(_importoController.text.toString()),
          'utente' : widget.utente.toMap(),
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
        Navigator.pop(context);
      }
    } catch(e){
      print('errore:$e');
    }
  }
}
