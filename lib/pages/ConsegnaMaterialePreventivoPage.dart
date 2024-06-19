import 'package:fema_crm/model/AziendaModel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/DestinazioneModel.dart';
import '../model/PreventivoModel.dart';
import '../model/RelazionePreventivoProdottiModel.dart';
import 'PDFConsegnaPage.dart';

class ConsegnaMaterialePreventivoPage extends StatefulWidget {
  final PreventivoModel preventivo;

  const ConsegnaMaterialePreventivoPage({Key? key, required this.preventivo})
      : super(key: key);

  @override
  _ConsegnaMaterialePreventivoPageState createState() =>
      _ConsegnaMaterialePreventivoPageState();
}

class _ConsegnaMaterialePreventivoPageState
    extends State<ConsegnaMaterialePreventivoPage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<DestinazioneModel> allDestinazioniByCliente = [];
  List<AziendaModel> allAziende = [];
  AziendaModel? selectedAzienda;
  DestinazioneModel? selectedDestinazione;
  List<RelazionePreventivoProdottiModel> allProdotti = [];
  TextEditingController _dateController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    getProdotti();
    getAllDestinazioniByCliente();
    getAziende();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conferma consegna preventivo",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _showDatePickerDialog(context);
                },
                child: Text("Giorno di consegna"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                ),
              ),
            ),
            if (selectedDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Data selezionata: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _showDestinazioniDialog();
                },
                child: Text("Seleziona Destinazione"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                ),
              ),
            ),
            if (selectedDestinazione != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Destinazione selezionata: ${selectedDestinazione!.denominazione}",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _showAziendaDialog();
                },
                child: Text("Seleziona l'azienda emittente"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                ),
              ),
            ),
            if (selectedAzienda != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Azienda selezionata: ${selectedAzienda!.nome}",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: allProdotti.length,
              itemBuilder: (context, index) {
                final prodotto = allProdotti[index].prodotto; // Otteniamo l'oggetto ProdottoModel
                return ListTile(
                  title: Text(prodotto!.descrizione!), // Supponiamo che ci sia una proprietà "nome" in ProdottoModel
                   // Supponiamo che ci sia una proprietà "descrizione" in ProdottoModel
                  // Aggiungi altre informazioni di ProdottoModel che desideri visualizzare
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            consegnato();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PDFConsegnaPage(preventivo: widget.preventivo, destinazione: selectedDestinazione, data: selectedDate, azienda: selectedAzienda),
              ),
            );
          },
          child: Text("Genera documento di consegna"),
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
            onPrimary: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showDatePickerDialog(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          this.selectedDate = selectedDate;
          _dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
        });
      }
    });
  }

  Future<void> getAziende() async{
    try{
      var apiUrl = Uri.parse(
        '${ipaddress}/api/azienda'
      );
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<AziendaModel> aziende = [];
        for(var item in jsonData){
          aziende.add(AziendaModel.fromJson(item));
        }
        setState(() {
          allAziende = aziende;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Errore di connessione'),
            content: Text(
                'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.'),
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

  Future<void> getProdotti() async {
    try {
      var apiUrl = Uri.parse(
          '${ipaddress}/api/relazionePreventivoProdotto/preventivo/${widget.preventivo.id}');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        debugPrint('JSON ricevuto: ${response.body}', wrapWidth: 1024);
        var jsonData = jsonDecode(response.body);
        List<RelazionePreventivoProdottiModel> prodotti = [];
        for (var item in jsonData) {
          prodotti.add(RelazionePreventivoProdottiModel.fromJson(item));
        }
        setState(() {
          allProdotti = prodotti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Errore di connessione'),
            content: Text(
                'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.'),
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

  void _showAziendaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Seleziona l\'azienda emittente',
            textAlign: TextAlign.center,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: allAziende.map((azienda) {
                        return ListTile(
                          leading: Icon(Icons.home),
                          title: Text(azienda.nome!),
                          onTap: () {
                            setState(() {
                              selectedAzienda = azienda;
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

  void _showDestinazioniDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Seleziona Destinazione',
            textAlign: TextAlign.center,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: allDestinazioniByCliente.map((destinazione) {
                        return ListTile(
                          leading: Icon(Icons.home_work_outlined),
                          title: Text(destinazione.denominazione!),
                          onTap: () {
                            setState(() {
                              selectedDestinazione = destinazione;
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

  Future<void> consegnato() async {
      late http.Response response;
      try {
        response = await http.post(
          Uri.parse('${ipaddress}/api/preventivo'),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: json.encode({
            'id': widget.preventivo.id,
            'data_creazione': widget.preventivo.data_creazione?.toIso8601String(),
            'azienda': widget.preventivo.azienda?.toJson(),
            'categoria_merceologica': widget.preventivo.categoria_merceologica,
            'listino': widget.preventivo.listino,
            'descrizione': widget.preventivo.descrizione,
            'importo': widget.preventivo.importo,
            'cliente': widget.preventivo.cliente?.toJson(),
            'accettato': false,
            'rifiutato': false,
            'attesa': false,
            'pendente': false,
            'consegnato': true,
            'provvigioni': widget.preventivo.provvigioni,
            'data_consegna': DateTime.now().toIso8601String(),
            'data_accettazione':
                widget.preventivo.data_accettazione?.toIso8601String(),
            'utente': widget.preventivo.utente?.toJson(),
            'agente': widget.preventivo.agente?.toJson(),
          }),
        );
        if (response.statusCode == 201) {
          print("Preventivo consegnato");
        } else {
          print("Hai toppato :(");
          print(response.body.toString());
        }
      } catch (e) {
        print(e.toString());
      }
    }

  Future<void> getAllDestinazioniByCliente() async {
    try {
      final response = await http.get(Uri.parse(
          '${ipaddress}/api/destinazione/cliente/${widget.preventivo.cliente?.id}'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          allDestinazioniByCliente = responseData
              .map((data) => DestinazioneModel.fromJson(data))
              .toList();
        });
        print(response.body.toString());
      } else {
        throw Exception('Failed to load Destinazioni per cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }
}
