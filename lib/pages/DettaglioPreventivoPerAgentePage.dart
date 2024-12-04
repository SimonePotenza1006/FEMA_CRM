import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/model/PreventivoModel.dart';
import '../model/RelazionePreventivoProdottiModel.dart';

class DettaglioPreventivoPerAgentePage extends StatefulWidget {
  final PreventivoModel preventivo;

  const DettaglioPreventivoPerAgentePage({Key? key, required this.preventivo})
      : super(key: key);

  @override
  _DettaglioPreventivoPerAgentePageState createState() =>
      _DettaglioPreventivoPerAgentePageState();
}

class _DettaglioPreventivoPerAgentePageState
    extends State<DettaglioPreventivoPerAgentePage> {
  List<RelazionePreventivoProdottiModel> allProdotti = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Chiamata all'API
    getProdotti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          'Dettaglio Preventivo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: ${widget.preventivo.id}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8),
              Text(
                  'Data Creazione: ${DateFormat('yyyy-MM-dd').format(widget.preventivo.data_creazione!)}'),
              SizedBox(height: 8),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8),
              Text(
                'Azienda:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${widget.preventivo.azienda?.nome}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8),
              Text(
                'Categoria Merceologica:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${widget.preventivo.categoria_merceologica ?? 'N/A'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8),
              Text(
                'Listino:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${widget.preventivo.listino ?? 'N/A'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8),
              Text(
                'Descrizione:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${widget.preventivo.descrizione ?? 'N/A'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8),
              Text(
                'Importo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  '${widget.preventivo.importo != null ? widget.preventivo.importo!.toStringAsFixed(2) + ' €' : 'N/A'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8),
              Text(
                'Cliente:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${widget.preventivo.cliente?.denominazione ?? 'N/A'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8),
              Text(
                'Accettato:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${widget.preventivo.accettato ?? false ? 'SI' : 'NO'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8),
              Text(
                'Rifiutato:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${widget.preventivo.rifiutato ?? false ? 'SI' : 'NO'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8),
              Text(
                'Attesa:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${widget.preventivo.attesa ?? false ? 'SI' : 'NO'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8),
              Text(
                'Pendente:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${widget.preventivo.pendente ?? false ? 'SI' : 'NO'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8),
              Text(
                'Consegnato:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${widget.preventivo.consegnato ?? false ? 'SI' : 'NO'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8),
              Text(
                'Provvigioni:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  '${widget.preventivo.provvigioni != null ? widget.preventivo.provvigioni!.toStringAsFixed(2) + ' €' : 'N/A'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8),
              Text(
                'Data Consegna:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  '${widget.preventivo.data_consegna != null ? DateFormat('yyyy-MM-dd').format(widget.preventivo.data_consegna!) : 'N/A'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8),
              Text(
                'Data Accettazione:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  '${widget.preventivo.data_accettazione != null ? DateFormat('yyyy-MM-dd').format(widget.preventivo.data_accettazione!) : 'N/A'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8),
              Text(
                'Utente:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${widget.preventivo.utente?.nome ?? 'N/A'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8),
              Text(
                'Agente:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${widget.preventivo.agente?.nome ?? 'N/A'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              isLoading ? CircularProgressIndicator() : buildProdottiList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProdottiList() {
    if (allProdotti.isEmpty) {
      return Text('Nessun prodotto trovato');
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prodotti:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            itemCount: allProdotti.length,
            itemBuilder: (context, index) {
              final prezzoFornitore =
                  allProdotti[index].prodotto?.prezzo_fornitore ?? 0;
              final listino = widget.preventivo.listino != null &&
                      widget.preventivo.listino!.length >= 2
                  ? double.tryParse(
                          widget.preventivo.listino!.substring(0, 2)) ??
                      0
                  : 0;
              final prezzoVendita = prezzoFornitore * (1 + listino / 100);
              return ListTile(
                title: Text(allProdotti[index].prodotto?.descrizione ?? 'N/A'),
                subtitle: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Prezzo di vendita: ',
                      ),
                      TextSpan(
                        text: '${prezzoFornitore.toStringAsFixed(2)} € ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.blue, // Colore blu
                        ),
                      ),
                      TextSpan(
                        text:
                            '(Prezzo fornitore) + ${listino.toStringAsFixed(2)}% = ',
                      ),
                      TextSpan(
                        text: '${prezzoVendita.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.lightGreen[700], // Colore verde
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    }
  }

  Future<void> getProdotti() async {
    setState(() {
      isLoading = true;
    });
    try {
      var apiUrl = Uri.parse(
          '$ipaddressProva/api/relazionePreventivoProdotto/preventivo/${widget.preventivo.id}');
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
          isLoading = false;
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
      setState(() {
        isLoading = false;
      });
    }
  }

  // Funzione per creare una riga divisoria grigia chiara
  Widget buildLightDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],
    );
  }

  // Funzione per creare una riga divisoria grigia scura
  Widget buildDarkDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[600],
    );
  }
}
