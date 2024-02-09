import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../databaseHandler/DbHelper.dart';
import '../model/ClienteModel.dart';
import 'ModificaClientePage.dart';

class DettaglioClientePage extends StatefulWidget {
  final ClienteModel cliente;

  const DettaglioClientePage({Key? key, required this.cliente}) : super(key: key);

  @override
  _DettaglioClientePageState createState() => _DettaglioClientePageState();
}

class _DettaglioClientePageState extends State<DettaglioClientePage> {

  DbHelper? dbHelper;
  List<ClienteModel> allClienti = [];



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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Indirizzo: ${widget.cliente.indirizzo}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Partita Iva: ${widget.cliente.partita_iva}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Cap: ${widget.cliente.cap}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Città: ${widget.cliente.citta}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Provincia: ${widget.cliente.provincia}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Nazione: ${widget.cliente.nazione}',
              style: const TextStyle(fontSize: 20),
            ), Text(
              'Recapito fatturazione elettronica: ${widget.cliente
                  .recapito_fatturazione_elettronica}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Riferimento amministrativo: ${widget.cliente
                  .riferimento_amministrativo}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Referente: ${widget.cliente.referente}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Fax: ${widget.cliente.fax}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Telefono: ${widget.cliente.telefono}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Cellulare: ${widget.cliente.cellulare}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Email: ${widget.cliente.email}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'PEC: ${widget.cliente.pec}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Note: ${widget.cliente.note}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Tipologie interventi: ${widget.cliente.tipologie_interventi}',
              style: const TextStyle(fontSize: 20),
            ),


            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.15,
                  height: MediaQuery
                      .of(context)
                      .size
                      .width * 0.10,
                  child: ElevatedButton(
                    onPressed:(){ deleteCliente(context ,widget.cliente.id);},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                        shadowColor: Colors.black,
                        elevation: 15
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_forever,
                          size: 50,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.15,
                  height: MediaQuery
                      .of(context)
                      .size
                      .width * 0.10,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => ModificaClientePage(cliente: widget.cliente)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                        shadowColor: Colors.black,
                        elevation: 15
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteCliente(BuildContext context, String? id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.52:8080/api/cliente/$id'),
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
