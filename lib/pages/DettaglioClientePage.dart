import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../databaseHandler/DbHelper.dart';
import '../model/ClienteModel.dart';
import 'ListaDestinazioniClientePage.dart';
import 'ModificaClientePage.dart';

class DettaglioClientePage extends StatefulWidget {
  final ClienteModel cliente;

  const DettaglioClientePage({Key? key, required this.cliente})
      : super(key: key);

  @override
  _DettaglioClientePageState createState() => _DettaglioClientePageState();
}

class _DettaglioClientePageState extends State<DettaglioClientePage> {
  DbHelper? dbHelper;
  List<ClienteModel> allClienti = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio ${widget.cliente.denominazione}',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    _buildInfoText('Indirizzo: ${widget.cliente.indirizzo}'),
                    _buildInfoText('Partita Iva: ${widget.cliente.partita_iva}'),
                    _buildInfoText('Cap: ${widget.cliente.cap}'),
                    _buildInfoText('Città: ${widget.cliente.citta}'),
                    _buildInfoText('Provincia: ${widget.cliente.provincia}'),
                    _buildInfoText('Nazione: ${widget.cliente.nazione}'),
                    _buildInfoText('Recapito fatturazione elettronica: ${widget.cliente.recapito_fatturazione_elettronica}'),
                    _buildInfoText('Riferimento amministrativo: ${widget.cliente.riferimento_amministrativo}'),
                    _buildInfoText('Referente: ${widget.cliente.referente}'),
                    _buildInfoText('Fax: ${widget.cliente.fax}'),
                    _buildInfoText('Telefono: ${widget.cliente.telefono}'),
                    _buildInfoText('Cellulare: ${widget.cliente.cellulare}'),
                    _buildInfoText('Email: ${widget.cliente.email}'),
                    _buildInfoText('PEC: ${widget.cliente.pec}'),
                    _buildInfoText('Note: ${widget.cliente.note}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSmallButton(
              onPressed: () {
                deleteCliente(context, widget.cliente.id);
              },
              icon: Icons.delete_forever,
              label: 'Elimina',
            ),
            _buildSmallButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ModificaClientePage(cliente: widget.cliente)),
                );
              },
              icon: Icons.edit_rounded,
              label: 'Modifica',
            ),
            _buildSmallButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ListaDestinazioniClientePage(cliente: widget.cliente)),
                );
              },
              icon: Icons.maps_home_work_outlined,
              label: 'Destinazioni',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    // Divide il testo in due parti: etichetta e dato
    final parts = text.split(':');
    final labelText = parts[0];
    final dataText = parts[1];

    return Column(
      children: [
        Row(
          children: [
            Text(
              '$labelText: ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              dataText.trim(), // Rimuove eventuali spazi bianchi aggiunti
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
        Divider(color: Colors.grey[300], thickness: 0.5),
      ],
    );
  }


  Widget _buildSmallButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      width: 130, // larghezza fissa
      height: 80, // altezza fissa
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30, // dimensione icona
              color: Colors.white,
            ),
            SizedBox(height: 2), // riduci lo spazio tra icona e testo
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteCliente(BuildContext context, String? id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ipaddress}/api/cliente/$id'),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente eliminato con successo')),
        );
        setState(() {
          allClienti.removeWhere((cliente) => cliente.id == id);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile eliminare il cliente')),
        );
      }
    } catch (e) {
      print('Errore durante l\'eliminazione del cliente: $e');
    }
  }
}
