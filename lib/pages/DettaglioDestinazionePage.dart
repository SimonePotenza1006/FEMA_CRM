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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio ${widget.destinazione.denominazione}',
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
        Text(
          'Indirizzo: ${widget.destinazione.indirizzo}',
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          'CAP: ${widget.destinazione.cap}',
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          'Città: ${widget.destinazione.citta}',
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          'Provincia: ${widget.destinazione.provincia}',
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          'Codice Fiscale: ${widget.destinazione.codice_fiscale}',
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          'Partita IVA: ${widget.destinazione.partita_iva}',
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          'Telefono: ${widget.destinazione.telefono}',
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          'Cellulare: ${widget.destinazione.cellulare}',
          style: const TextStyle(fontSize: 20),
        ),
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
        Uri.parse('${ipaddress}/api/destinazione/$id'),
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