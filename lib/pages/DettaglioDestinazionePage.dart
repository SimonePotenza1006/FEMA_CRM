import 'dart:io';

import 'package:fema_crm/model/DestinazioneModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../databaseHandler/DbHelper.dart';
import 'ModificaDestinazionePage.dart';

class DettaglioDestinazionePage extends StatefulWidget {
  final DestinazioneModel destinazione;

  const DettaglioDestinazionePage({Key? key, required this.destinazione})
      : super(key: key);

  @override
  _DettaglioDestinazionePageState createState() =>
      _DettaglioDestinazionePageState();
}

class _DettaglioDestinazionePageState extends State<DettaglioDestinazionePage> {
  DbHelper? dbHelper;
  List<DestinazioneModel> allDestinazioni = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DETTAGLIO ${widget.destinazione.denominazione}',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailsSection(),
            const SizedBox(height: 20),
            _buildButtonRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoText(title: 'indirizzo', value: widget.destinazione.indirizzo != null ? widget.destinazione.indirizzo! : 'non inserito'.toUpperCase()),
        _buildInfoText(title: 'cap', value: widget.destinazione.cap != null ? widget.destinazione.cap! : 'non inserito'.toUpperCase()),
        _buildInfoText(title: 'città', value: widget.destinazione.citta != null ? widget.destinazione.citta! : 'non inserito'.toUpperCase()),
        _buildInfoText(title: 'provincia', value: widget.destinazione.provincia != null ? widget.destinazione.provincia! : 'non inserito'.toUpperCase()),
        _buildInfoText(title: 'codice fiscale', value: widget.destinazione.codice_fiscale != null ? widget.destinazione.codice_fiscale! : 'non inserito'.toUpperCase()),
        _buildInfoText(title: 'partita iva', value: widget.destinazione.partita_iva != null ? widget.destinazione.partita_iva! : 'non inserito'.toUpperCase()),
        _buildInfoText(title: 'telefono', value: widget.destinazione.telefono != null ? widget.destinazione.telefono! : 'non inserito'.toUpperCase()),
        _buildInfoText(title: 'cellulare', value: widget.destinazione.cellulare != null ?  widget.destinazione.cellulare! : 'non inserito'.toUpperCase()),
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton(
          onPressed: () {
            deleteDestinazione(context, widget.destinazione.id);
          },
          icon: Icons.delete_forever,
          color: Colors.red,
        ),
        _buildButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ModificaDestinazionePage(
                    destinazione: widget.destinazione,
                  )),
            );
          },
          icon: Icons.edit_rounded,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildInfoText({required String title, required String value, BuildContext? context}) {
    // Verifica se il valore supera i 25 caratteri
    bool isValueTooLong = value.length > 25;
    String displayedValue = isValueTooLong ? value.substring(0, 25) + "..." : value;
    return SizedBox(
      width:600,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4, // Linea di accento colorata
                      height: 24,
                      color: Colors.redAccent, // Colore di accento per un tocco di vivacità
                    ),
                    SizedBox(width: 10),
                    Text(
                      title.toUpperCase() + ": ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Colore contrastante per il testo
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        displayedValue.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold, // Un colore secondario per differenziare il valore
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isValueTooLong && context != null)
                        IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("${title.toUpperCase()}"),
                                  content: Text(value),
                                  actions: [
                                    TextButton(
                                      child: Text("Chiudi"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Divider( // Linea di separazione tra i widget
              color: Colors.grey[400],
              thickness: 1,
            ),
            SizedBox(width: 50)
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return Flexible(
      child: SizedBox(
        width: 100,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35.0),
            ),
            shadowColor: Colors.black,
            elevation: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteDestinazione(BuildContext context, String? id) async {
    try {
      final response = await http.delete(
        Uri.parse('$ipaddress/api/destinazione/$id'),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destinazione eliminata con successo')),
        );
        setState(() {
          allDestinazioni.removeWhere((destinazione) => destinazione.id == id);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile eliminare la destinazione')),
        );
      }
    } on HttpException catch (e) {
      print('HttpException: $e');
    } catch (e) {
      print('Errore durante l\'eliminazione del cliente: $e');
    }
  }
}