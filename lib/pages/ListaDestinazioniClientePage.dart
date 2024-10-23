import 'dart:convert';

import 'package:fema_crm/model/ClienteModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../databaseHandler/DbHelper.dart';
import '../model/DestinazioneModel.dart';
import 'DettaglioDestinazionePage.dart';
import 'NuovaDestinazionePage.dart';

class ListaDestinazioniClientePage extends StatefulWidget {
  final ClienteModel cliente;

  const ListaDestinazioniClientePage({Key? key, required this.cliente})
      : super(key: key);

  @override
  _ListaDestinazioniClientePageState createState() =>
      _ListaDestinazioniClientePageState();
}

class _ListaDestinazioniClientePageState
    extends State<ListaDestinazioniClientePage> {
  DbHelper? dbHelper;
  List<DestinazioneModel> allDestinazioniByCliente = [];
  bool isLoading = true;
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  void initState() {
    dbHelper = DbHelper();
    init();
    super.initState();
    getAllDestinazioniByCliente();
  }

  Future<void> init() async {
    await getAllDestinazioniByCliente();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Lista destinazioni di ${widget.cliente.denominazione}',
              style: const TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.red,
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
                color: Colors.white,
              ),
              onPressed: () {
                // Funzione per ricaricare la pagina
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.add,
                size: 40,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NuovaDestinazionePage(cliente: widget.cliente),
                    ));
              },
            )
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: allDestinazioniByCliente.length,
                itemBuilder: (context, index) {
                  final destinazione = allDestinazioniByCliente[index];
                  return buildViewDestinazioni(destinazione);
                }));
  }

  Future<void> getAllDestinazioniByCliente() async {
    try {
      final response = await http.get(Uri.parse(
          '$ipaddress/api/destinazione/cliente/${widget.cliente.id}'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          allDestinazioniByCliente = responseData
              .map((data) => DestinazioneModel.fromJson(data))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load Destinazioni per cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildViewDestinazioni(DestinazioneModel destinazione) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Arrotondamento del bordo
      ),
      elevation: 5, // Aggiunge un'ombra per creare profondità
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Più spazio tra le card
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade300], // Aggiunge un gradiente di colore
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15), // Arrotondamento anche per il contenitore interno
        ),
        child: ListTile(
            minLeadingWidth: 20, // Aumenta la larghezza minima per maggiore spaziatura
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // Più padding interno
            visualDensity: const VisualDensity(horizontal: 0, vertical: -2), // Riduce leggermente la densità verticale
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DettaglioDestinazionePage(destinazione: destinazione)),
              );
            },
            leading: CircleAvatar(
              radius: 25, // Aumenta la dimensione dell'icona
              backgroundColor: Colors.red, // Cambia il colore dello sfondo dell'icona
              child: Icon(Icons.account_circle_rounded, color: Colors.white, size: 30), // Icona più grande e bianca
            ),
            trailing: Text(
              'Id. ${destinazione.id}'.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Colore più discreto per l'id
              ),
            ),
            title: Text(
              destinazione.denominazione!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, // Dimensione del testo leggermente più grande
              ),
            ),
            subtitle:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Codice Fiscale: ${destinazione.codice_fiscale != null ? destinazione.codice_fiscale! : 'Non inserito'}'.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black // Colore del testo del sottotitolo
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Telefono: ${destinazione.cellulare != null ? destinazione.cellulare! : "Non inserito"}'.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black // Colore del testo del sottotitolo
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }
}
