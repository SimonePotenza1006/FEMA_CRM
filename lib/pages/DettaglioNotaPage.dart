import 'package:fema_crm/model/NotaTecnicoModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DettaglioNotaPage extends StatefulWidget {
  final NotaTecnicoModel nota;

  const DettaglioNotaPage({Key? key, required this.nota})
      : super(key: key);

  @override
  _DettaglioNotaPageState createState() => _DettaglioNotaPageState();
}

class _DettaglioNotaPageState extends State<DettaglioNotaPage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio nota n°${widget.nota.id}',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        elevation: 0, // remove shadow
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
                    _buildInfoCard('Data', DateFormat('dd/MM/yyyy, HH:mm').format(widget.nota.data!)),
                    _buildInfoCard('Utente', widget.nota.utente?.nomeCompleto()?? 'Unknown'),
                    _buildInfoCard('Nota', widget.nota.nota ?? '/'),
                    if (widget.nota.intervento!= null)
                      _buildInfoCard('Id intervento', widget.nota.intervento?.id.toString() ?? '/'),
                    if (widget.nota.cliente!= null)
                      _buildInfoCard('Cliente', widget.nota.cliente?.denominazione ?? 'N/A'),
                    if (widget.nota.destinazione!= null)
                      _buildInfoCard('Destinazione', '${widget.nota.destinazione?.denominazione}, ID ${widget.nota.destinazione?.id}'),
                    if (widget.nota.sopralluogo!= null)
                      _buildInfoCard('Id sopralluogo', widget.nota.sopralluogo?.id.toString() ?? 'N/A'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSmallButton(
              onPressed: () {
                deleteNota(widget.nota.id);
              },
              icon: Icons.delete_forever,
              label: 'Elimina',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteNota(String? id) async {
    try {
      final response = await http.delete(
        Uri.parse('$ipaddress/api/noteTecnico/$id'),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nota eliminata con successo!')),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile eliminare il cliente')),
        );
      }
    } catch (e) {
      print('Errore durante l\'eliminazione della nota: $e');
    }
  }

  Widget _buildInfoCard(String label, String data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                data,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
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
}