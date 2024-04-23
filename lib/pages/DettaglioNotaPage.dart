import 'package:fema_crm/model/NotaTecnicoModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DettaglioNotaPage extends StatefulWidget{
  final NotaTecnicoModel nota;

  const DettaglioNotaPage({Key? key, required this.nota})
      : super(key : key);

  @override
  _DettaglioNotaPageState createState() => _DettaglioNotaPageState();
}

class _DettaglioNotaPageState extends State<DettaglioNotaPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio nota n°${widget.nota.id}',
            style: const TextStyle(color: Colors.white)
        ),
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
                      _buildInfoText('Data = ${widget.nota.data}'),
                      _buildInfoText('Utente = ${widget.nota.utente?.nomeCompleto()}'),
                      _buildInfoText('Nota = ${widget.nota.nota}'),
                      if(widget.nota.intervento != null)
                        _buildInfoText('Id intervento = ${widget.nota.intervento?.id}'),
                      if(widget.nota.cliente != null)
                        _buildInfoText('Cliente = ${widget.nota.cliente?.denominazione}'),
                      if(widget.nota.destinazione != null)
                        _buildInfoText('Destinazione = ${widget.nota.destinazione?.denominazione}, ID ${widget.nota.destinazione?.id}'),
                      if(widget.nota.sopralluogo !=null)
                        _buildInfoText('Id sopralluogo = ${widget.nota.sopralluogo?.id}')
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
      print('Errore durante l\'eliminazione del cliente: $e');
    }
  }

  Widget _buildInfoText(String text) {
    // Divide il testo in due parti: etichetta e dato
    final parts = text.split('=');
    final labelText = parts[0];
    final dataText = parts[1];

    // Formatta la data se è presente nella parte di dato
    String formattedData = dataText.trim();
    if (labelText.contains('Data')) {
      final dateTime = DateTime.tryParse(dataText.trim());
      if (dateTime != null) {
        formattedData = '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
      }
    }

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
              formattedData,
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

}

