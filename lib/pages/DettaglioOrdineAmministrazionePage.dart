import 'dart:convert';
import 'dart:typed_data';
import 'package:fema_crm/model/OrdinePerInterventoModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/FornitoreModel.dart';
import '../model/UtenteModel.dart';

class DettaglioOrdineAmministrazionePage extends StatefulWidget {
  final OrdinePerInterventoModel ordine;
  final UtenteModel? utente;

  DettaglioOrdineAmministrazionePage({required this.utente,required this.ordine, required Future<void> Function() onNavigateBack});

  @override
  _DettaglioOrdineAmministrazionePageState createState() => _DettaglioOrdineAmministrazionePageState();
}

class _DettaglioOrdineAmministrazionePageState extends State<DettaglioOrdineAmministrazionePage> {
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
  final DateFormat timeFormatter = DateFormat('HH:mm');
  List<FornitoreModel> allFornitori = [];
  List<FornitoreModel> filteredFornitori = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  void initState() {
    super.initState();
    getAllFornitori();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text(
          'Dettaglio ordine ${widget.ordine.id}',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      buildInfoRow(
                        title: 'ID ordine',
                        value: widget.ordine.id!,
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Data creazione ordine',
                        value: formatDate(widget.ordine.data_creazione),
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Data di richiesta disponibilità',
                        value: formatDate(widget.ordine.data_disponibilita),
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Data da non superare',
                        value: formatDate(widget.ordine.data_ultima),
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Cliente',
                        value: widget.ordine.cliente?.denominazione?? 'N/A',
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Tecnico',
                        value: widget.ordine.utente!.nomeCompleto().toString(),
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Prodotto da ordinare',
                        value: widget.ordine.prodotto?.descrizione?? 'N/A',
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Prodotto non presente in magazzino',
                        value: widget.ordine.prodotto_non_presente?? 'N/A',
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Fornitore',
                        value: widget.ordine.fornitore != null ? widget.ordine.fornitore!.denominazione! : 'N/A',
                        icon: GestureDetector(
                          onTap: _showFornitoriDialog,
                          child: Icon(Icons.edit, color: Colors.grey[600]),
                        ),
                      ),
                      SizedBox(height: 15),
                      buildInfoRow(
                        title: 'Nota',
                        value: widget.ordine.note?? 'N/A',
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
            Center(
              child :
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if(widget.ordine.utente_presa_visione == null)
                      ElevatedButton(
                        onPressed: () {
                          presaVisione();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          textStyle: TextStyle(fontSize: 18),
                          primary: Colors.red,
                        ),
                        child: Text(
                          'Presa visione',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    if(widget.ordine.utente_ordine == null && widget.ordine.utente_presa_visione != null)
                      ElevatedButton(
                        onPressed: () {
                          ordinato();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          textStyle: TextStyle(fontSize: 18),
                          primary: Colors.red,
                        ),
                        child: Text(
                          'Ordinato',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    if(widget.ordine.utente_consegnato == null &&
                        widget.ordine.utente_ordine != null)
                      ElevatedButton(
                        onPressed: () {
                          arrivato();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          textStyle: TextStyle(fontSize: 18),
                          primary: Colors.red,
                        ),
                        child: Text(
                          'Arrivato',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    if(widget.ordine.utente_presa_visione != null &&
                        widget.ordine.utente_ordine != null &&
                        widget.ordine.utente_consegnato != null)
                      ElevatedButton(
                        onPressed: () {
                          consegnato();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          textStyle: TextStyle(fontSize: 18),
                          primary: Colors.red,
                        ),
                        child: Text(
                          'Consegnato',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                )
            ),
            SizedBox(height: 70),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInfoRow(
                    title: 'Presa Visione',
                    value: widget.ordine.utente_presa_visione?.nomeCompleto() ?? 'N/A',
                  ),
                  buildInfoRow(
                    title: 'Ordinato',
                    value: widget.ordine.utente_ordine?.nomeCompleto() ?? 'N/A',
                  ),
                  buildInfoRow(
                    title: 'Arrivato in sede',
                    value: widget.ordine.utente_consegnato?.nomeCompleto() ?? 'N/A',
                  ),
                  buildInfoRow(
                    title: 'Aggiornamenti',
                    value: widget.ordine.aggiornamento ?? 'N/A',
                    icon: GestureDetector(
                      onTap: _showAggiornamentiDialog,
                      child: Icon(Icons.edit, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow({
    required String title,
    required String value,
    Widget? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Spacer(),
        Expanded(
          flex: 2, // Imposta la larghezza del testo
          child: Row(
            children: [
              Flexible( // Utilizza Flexible per consentire il wrap del testo
                child: Text(
                  value,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(width: 12,),
              if (icon != null) icon,
            ],
          ),
        ),
      ],
    );
  }

  Future<void> consegnato() async{
    try{
      final response = await http.post(
          Uri.parse('$ipaddressProva/api/ordine'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id' : widget.ordine.id,
            'descrizione' : widget.ordine.descrizione,
            'intervento' : widget.ordine.intervento?.toMap(),
            'cliente' : widget.ordine.cliente?.toMap(),
            'data_creazione' : widget.ordine.data_creazione?.toIso8601String(),
            'data_richiesta' : widget.ordine.data_richiesta?.toIso8601String(),
            'data_disponibilita' : widget.ordine.data_disponibilita?.toIso8601String(),
            'data_ultima': widget.ordine.data_ultima?.toIso8601String(),
            'utente' : widget.ordine.utente?.toMap(),
            'utente_presa_visione' : widget.ordine.utente_presa_visione?.toMap(),
            'utente_ordine' : widget.ordine.utente_ordine?.toMap(),
            'utente_consegnato' : widget.ordine.utente_consegnato?.toMap(),
            'prodotto' : widget.ordine.prodotto?.toMap(),
            'fornitore' : widget.ordine.fornitore?.toMap(),
            'prodotto_non_presente' : widget.ordine.prodotto_non_presente,
            'note' : widget.ordine.note,
            'aggiornamento' : widget.ordine.aggiornamento,
            'presa_visione' : false,
            'ordinato' : false,
            'arrivato' : false,
            'consegnato' : true,
          })
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ordine aggiornato con successo, ordine arrivato!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch(e){
      print('Errore arrivato: $e');
    }
  }

  Future<void> arrivato() async{
    try{
      final response = await http.post(
          Uri.parse('$ipaddressProva/api/ordine'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id' : widget.ordine.id,
            'descrizione' : widget.ordine.descrizione,
            'intervento' : widget.ordine.intervento?.toMap(),
            'cliente' : widget.ordine.cliente?.toMap(),
            'data_creazione' : widget.ordine.data_creazione?.toIso8601String(),
            'data_richiesta' : widget.ordine.data_richiesta?.toIso8601String(),
            'data_disponibilita' : widget.ordine.data_disponibilita?.toIso8601String(),
            'data_ultima' : widget.ordine.data_ultima?.toIso8601String(),
            'utente' : widget.ordine.utente?.toMap(),
            'utente_presa_visione' : widget.ordine.utente_presa_visione?.toMap(),
            'utente_ordine' : widget.ordine.utente_ordine?.toMap(),
            'utente_consegnato' : widget.utente?.toMap(),
            'prodotto' : widget.ordine.prodotto?.toMap(),
            'fornitore' : widget.ordine.fornitore?.toMap(),
            'prodotto_non_presente' : widget.ordine.prodotto_non_presente,
            'note' : widget.ordine.note,
            'aggiornamento' : widget.ordine.aggiornamento,
            'presa_visione' : false,
            'ordinato' : false,
            'arrivato' : true,
            'consegnato' : false
          })
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ordine aggiornato con successo, ordine arrivato!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch(e){
      print('Errore arrivato: $e');
    }
  }

  Future<void> ordinato() async{
    try{
      final response = await http.post(
          Uri.parse('$ipaddressProva/api/ordine'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id' : widget.ordine.id,
            'descrizione' : widget.ordine.descrizione,
            'intervento' : widget.ordine.intervento?.toMap(),
            'cliente' : widget.ordine.cliente?.toMap(),
            'data_creazione' : widget.ordine.data_creazione?.toIso8601String(),
            'data_richiesta' : widget.ordine.data_richiesta?.toIso8601String(),
            'data_disponibilita' : widget.ordine.data_disponibilita?.toIso8601String(),
            'data_ultima' : widget.ordine.data_ultima?.toIso8601String(),
            'utente' : widget.ordine.utente?.toMap(),
            'utente_presa_visione' : widget.ordine.utente_presa_visione?.toMap(),
            'utente_ordine' : widget.utente?.toMap(),
            'utente_consegnato' : widget.ordine.utente_consegnato?.toMap(),
            'prodotto' : widget.ordine.prodotto?.toMap(),
            'fornitore' : widget.ordine.fornitore?.toMap(),
            'prodotto_non_presente' : widget.ordine.prodotto_non_presente,
            'note' : widget.ordine.note,
            'aggiornamento' : widget.ordine.aggiornamento,
            'presa_visione' : false,
            'ordinato' : true,
            'arrivato' : false,
            'consegnato' : false
          })
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ordine aggiornato con successo, ordinato!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch(e){
      print('Errore ordinato: $e');
    }
  }

  Future<void> presaVisione() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/ordine'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.ordine.id,
          'descrizione': widget.ordine.descrizione,
          'intervento': widget.ordine.intervento?.toMap(),
          'cliente': widget.ordine.cliente?.toMap(),
          'data_creazione': widget.ordine.data_creazione?.toIso8601String(),
          'data_richiesta': widget.ordine.data_richiesta?.toIso8601String(),
          'data_disponibilita': widget.ordine.data_disponibilita?.toIso8601String(),
          'data_ultima': widget.ordine.data_ultima?.toIso8601String(), // Add this line
          'utente': widget.ordine.utente?.toMap(),
          'utente_presa_visione': widget.utente?.toMap(),
          'utente_ordine': widget.ordine.utente_ordine?.toMap(),
          'utente_consegnato': widget.ordine.utente_consegnato?.toMap(),
          'prodotto': widget.ordine.prodotto?.toMap(),
          'fornitore': widget.ordine.fornitore?.toMap(),
          'prodotto_non_presente': widget.ordine.prodotto_non_presente,
          'note': widget.ordine.note,
          'aggiornamento': widget.ordine.aggiornamento,
          'presa_visione': true,
          'ordinato': false,
          'arrivato': false,
          'consegnato': false
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ordine aggiornato con successo, presa visione salvata!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch(e){
      print('Errore presa visione: $e');
    }
  }

  Future<void> saveModifiche() async{
    try{
      final response = await http.post(
          Uri.parse('$ipaddressProva/api/ordine'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id' : widget.ordine.id,
            'descrizione' : widget.ordine.descrizione,
            'intervento' : widget.ordine.intervento?.toMap(),
            'cliente' : widget.ordine.cliente?.toMap(),
            'data_creazione' : widget.ordine.data_creazione?.toIso8601String(),
            'data_richiesta' : widget.ordine.data_richiesta?.toIso8601String(),
            'data_disponibilita' : widget.ordine.data_disponibilita?.toIso8601String(),
            'data_ultima' : widget.ordine.data_ultima?.toIso8601String(),
            'utente' : widget.ordine.utente?.toMap(),
            'utente_presa_visione' : widget.ordine.utente_presa_visione?.toMap(),
            'utente_ordine' : widget.ordine.utente_ordine?.toMap(),
            'utente_consegnato' : widget.ordine.utente_consegnato?.toMap(),
            'prodotto' : widget.ordine.prodotto?.toMap(),
            'fornitore' : widget.ordine.fornitore?.toMap(),
            'prodotto_non_presente' : widget.ordine.prodotto_non_presente,
            'note' : widget.ordine.note,
            'aggiornamento' : widget.ordine.aggiornamento,
            'presa_visione' : widget.ordine.presa_visione,
            'ordinato' : widget.ordine.ordinato,
            'arrivato' : widget.ordine.arrivato,
            'consegnato' : widget.ordine.consegnato
          })
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ordine aggiornato con successo!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch(e){
      print('Errore 2: $e');
    }
  }

  void _showFornitoriDialog() {
    TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleziona fornitore', textAlign: TextAlign.center),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          filteredFornitori = allFornitori
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
                          children: filteredFornitori.map((fornitore) {
                            return ListTile(
                              leading: const Icon(Icons.business_center),
                              title: Text(
                                '${fornitore.denominazione}, ${fornitore.indirizzo}',
                              ),
                              onTap: () {
                                  widget.ordine.fornitore = fornitore;
                                setState(() {
                                  saveModifiche();
                                  setState((){});
                                });
                                Navigator.pop(context); // Chiudi il dialog
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

  void _showAggiornamentiDialog() {
    TextEditingController aggiornamentiController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifica aggiornamento', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: aggiornamentiController,
                  decoration: const InputDecoration(
                    labelText: 'Inserisci aggiornamenti',
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    widget.ordine.aggiornamento = aggiornamentiController.text;
                    saveModifiche();
                    Navigator.pop(context); // Chiudi il dialog
                  },
                  child: Text('Modifica'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> getAllFornitori() async {
    try {
      final response = await http.get(Uri.parse('$ipaddressProva/api/fornitore'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<FornitoreModel> fornitori = [];
        for (var item in jsonData) {
          fornitori.add(FornitoreModel.fromJson(item));
        }
        setState(() {
          allFornitori = fornitori;
          filteredFornitori = fornitori;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore nello scaricare i fornitori :$e');
    }
  }

  String formatDate(DateTime? date) {
    return date!= null? dateFormatter.format(date) : 'N/A';
  }

  String formatTime(DateTime? time) {
    return time!= null? timeFormatter.format(time) : 'N/A';
  }
}