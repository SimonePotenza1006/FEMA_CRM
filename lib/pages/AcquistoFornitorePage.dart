import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fema_crm/model/FornitoreModel.dart';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 400,
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
              ],
            ),
          ),
        ),
      ),
    );
  }


}