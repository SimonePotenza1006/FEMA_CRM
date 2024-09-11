import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/ProdottoModel.dart';
import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/AziendaModel.dart';

import 'PDFDDTPage.dart';

class CompilazioneDDTByTecnicoPage extends StatefulWidget {
  final List<ProdottoModel> prodotti;
  final InterventoModel intervento;

  const CompilazioneDDTByTecnicoPage({
    Key? key,
    required this.prodotti,
    required this.intervento,
  }) : super(key: key);

  @override
  _CompilazioneDDTByTecnicoPageState createState() =>
      _CompilazioneDDTByTecnicoPageState();
}

class _CompilazioneDDTByTecnicoPageState
    extends State<CompilazioneDDTByTecnicoPage> {
  bool isLoading = true;
  late DDTModel ddt;
  late List<TextEditingController> quantityControllers;
  bool isSaveDDTPressed = false;
  List<AziendaModel> aziendeList = [];
  AziendaModel? selectedAzienda;
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  Future<void> getAllAziende() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/azienda');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<AziendaModel> aziende = [];
        for (var item in jsonData) {
          aziende.add(AziendaModel.fromJson(item));
        }
        setState(() {
          aziendeList = aziende;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in quantityControllers) {
      controller.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    getDdtByIntervento();
    getAllAziende().then((_) {
      if (aziendeList.isNotEmpty) {
        setState(() {
          selectedAzienda = aziendeList.firstWhere((azienda) => azienda.id == 3.toString());
        });
      }
    });
    quantityControllers = List.generate(
      widget.prodotti.length,
          (index) => TextEditingController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Compilazione DDT',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : ddt != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Numero DDT: ${ddt.id}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Data DDT: ${ddt.data != null ? DateFormat('dd/MM/yyyy').format(ddt.data!) : 'N/D'}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Cliente: ${ddt.cliente?.denominazione ?? "N/D"}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Destinazione: ${ddt.destinazione?.denominazione ?? "N/D"}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<AziendaModel>(
              value: selectedAzienda,
              onChanged: (azienda) {
                setState(() {
                  selectedAzienda = azienda;
                });
              },
              decoration: InputDecoration(
                labelText: 'Azienda',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              items: aziendeList.map((azienda) {
                return DropdownMenuItem<AziendaModel>(
                  value: azienda,
                  child: Text(azienda.nome!),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prodotti:',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Quantità:',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.prodotti.length,
                itemBuilder: (context, index) {
                  return buildProdottoItem(index);
                },
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  //saveRelationsProdottiUtente(widget.prodotti);
                  createRelazioni(widget.prodotti, ddt);
                  setState(() {
                    isSaveDDTPressed = true;
                  });
                },
                child: Text(
                  'Salva DDT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isSaveDDTPressed,
              child: SizedBox(height: 20),
            ),
            Visibility(
              visible: isSaveDDTPressed,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {
                    if(selectedAzienda != null)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFDDTPage(
                              ddt: ddt, azienda: selectedAzienda!),
                        ),
                      );
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Devi scegliere un\'azienda per cui emettere il DDT!'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Genera PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
            : Center(
          child: Text('DDT non trovato'),
        ),
      ),
    );
  }

  Widget buildProdottoItem(int index) {
    final prodotto = widget.prodotti[index];
    final descrizione = prodotto.descrizione != null ? prodotto.descrizione : "Descrizione non disponibile";
    final codice = prodotto.codice_danea != null ? prodotto.codice_danea : "Codice non disponibile";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${codice} - ${descrizione}',
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 50,
            child: TextFormField(
              controller: quantityControllers[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (value) {
                // Handle onChanged event
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getDdtByIntervento() async {
    try {
      final response = await http.get(
          Uri.parse('$ipaddress/api/ddt/intervento/${widget.intervento.id}'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          ddt = DDTModel.fromJson(responseData);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load DDT per cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> saveRelationsProdottiUtente(List<ProdottoModel> prodotti) async {
  //   try {
  //     for (int i = 0; i < prodotti.length; i++) {
  //       final prodotto = prodotti[i];
  //       final controller = quantityControllers[i]; // Ottieni il controller del TextFormField corrispondente
  //       final quantita = double.tryParse(controller.text) ?? 1;
  //       final response = await http.post(
  //         Uri.parse('$ipaddress/api/relazioneUtentiProdotti'),
  //         headers: {
  //           "Accept": "application/json",
  //           "Content-Type": "application/json"
  //         },
  //         body: json.encode({
  //           'prodotto': prodotto.toMap(),
  //           'utente': ddt.utente?.toMap(),
  //           'ddt': ddt.toMap(),
  //           'quantita': quantita,
  //           'assegnato': true
  //         }),
  //       );
  //       if (response.statusCode == 200) {
  //         print('Prodotto $i assegnato all\'utente');
  //       } else {
  //         print('Errore durante il salvataggio del prodotto: ${response.statusCode}');
  //       }
  //     }
  //     print('Finito');
  //   } catch (e) {
  //     print('Errore durante il salvataggio dei prodotti: $e');
  //   }
  // }

  Future<void> createRelazioni(List<ProdottoModel> prodotti, DDTModel? ddt) async {
    try {
      for (int i = 0; i < prodotti.length; i++) {
        final prodotto = prodotti[i];
        final controller = quantityControllers[i]; // Ottieni il controller del TextFormField corrispondente
        final quantita = double.tryParse(controller.text) ?? 1;
        final response = await http.post(
          Uri.parse('$ipaddress/api/relazioneDDTProdotto'),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: json.encode({
            'prodotto': prodotto.toJson(),
            'ddt': ddt?.toJson(),
            'quantita': quantita,
            'assegnato': true,
            'scaricato': false,
            'pendente': true,
          }),
        );
        if (response.statusCode == 200) {
          print('Relazione DDT-prodotto aggiornata con successo per il prodotto ${prodotto.id}');
        } else {
          print('Errore durante l\'aggiornamento della relazione DDT-prodotto per il prodotto ${prodotto.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore durante l\'aggiornamento della relazione DDT-prodotto'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Errore durante la creazione delle relazioni: $e');
    }
  }
}
