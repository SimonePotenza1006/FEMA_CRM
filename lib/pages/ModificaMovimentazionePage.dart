import 'dart:convert';

import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/model/MovimentiModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState(){
    super.initState();
    getUtenti();
    getAllClienti();
    _importoController = TextEditingController(text: widget.movimento.importo.toString());
    _descrizioneController = TextEditingController(text: widget.movimento.descrizione);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifica movimento ${widget.movimento.descrizione}',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                ).then((date) {
                  setState(() {
                    _selectedDate = date;
                  });
                });
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Data della movimentazione',
                  ),
                  controller: TextEditingController(text: _selectedDate != null? DateFormat('dd/MM/yyyy').format(_selectedDate!) : ''),
                ),
              ),
            ),
            TextFormField(
              controller: _descrizioneController,
              decoration: InputDecoration(
                labelText: 'Descrizione',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci una descrizione';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _importoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // consenti solo numeri e fino a 2 decimali
              ],
              decoration: InputDecoration(
                labelText: 'Importo',
              ),
              validator: (value) {
                if (value == null || double.tryParse(value) == null) {
                  return 'Inserisci un importo valido';
                }
                return null;
              },
            ),
            DropdownButtonFormField<TipoMovimentazione>(
              value: _selectedTipoMovimentazione,
              onChanged: (TipoMovimentazione? newValue) {
                setState(() {
                  _selectedTipoMovimentazione = newValue;
                  selectedTipologia = newValue!; // Initialize selectedTipologia here
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
                } else {
                  label = 'Pagamento';
                }
                return DropdownMenuItem<TipoMovimentazione>(
                  value: value,
                  child: Text(label),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Tipo Movimentazione',
              ),
              validator: (value) {
                if (value == null) {
                  return 'Seleziona il tipo di movimentazione';
                }
                return null;
              },
            ),
            DropdownButtonFormField<UtenteModel>(
              value: allUtenti.contains(_selectedUtente) ? _selectedUtente : null,
              onChanged: (UtenteModel? newValue) {
                setState(() {
                  _selectedUtente = newValue;
                });
              },
              items: allUtenti.map<DropdownMenuItem<UtenteModel>>((UtenteModel value) {
                return DropdownMenuItem<UtenteModel>(
                  value: value,
                  child: Text(value.cognome!),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Utente',
              ),
              validator: (value) {
                if (value == null) {
                  return 'Seleziona l\'utente';
                }
                return null;
              },
            ),
            GestureDetector(
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
            SizedBox(height: 34),
            Center(
              child:ElevatedButton(
                onPressed: () {
                  updateMovimento();
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
        final jsonData = jsonDecode(response.body);
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

  Future<void> getUtenti() async {
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/utente'));
      var responseData = json.decode(response.body);
      if(response.statusCode == 200){
        List<UtenteModel> utenti = [];
        for(var item in responseData){
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      }
    } catch(e){
      throw Exception('Errore durante il recupero degli utenti : $e');
    }
  }

  Future<void> updateMovimento() async{
    try{
      var response = await http.post(
        Uri.parse('$ipaddress/api/movimenti'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'id' : widget.movimento.id,
          'data' : _selectedDate?.toIso8601String(),
          'utente' : _selectedUtente?.toMap(),
          'cliente' : selectedCliente?.toMap(),
          'tipo_movimentazione': selectedTipologia.toString().split('.').last,
          'descrizione' : _descrizioneController.text,
          'importo' : double.parse(_importoController.text.toString())
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Movimentazione aggionrata correttamente, ricarica la pagina per i nuovi dati'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        Navigator.pop(context);
      }
    } catch(e){
      print('Errore durante la modifica : $e');
    }
  }

}