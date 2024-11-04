import 'package:fema_crm/model/PosizioneGPSModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
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
  List<PosizioneGPSModel> allPosizioni = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  void initState() {
    super.initState();
    getPosizioni();
  }

  Future<void> getPosizioni() async{
    try{
      final response = await http.get(
        Uri.parse('$ipaddress/api/posizioni/cliente/${widget.cliente.id}'));
        var responseData = json.decode(response.body);
        if(response.statusCode == 200){
          List<PosizioneGPSModel> posizioni = [];
          for(var item in responseData){
            posizioni.add(PosizioneGPSModel.fromJson(item));
          }
          setState(() {
            allPosizioni = posizioni;
          });
        }
    } catch(e){
      print('Errore durante il recupero delle posizioni: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DETTAGLIO ${widget.cliente.denominazione}',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(

          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoText(title:'Indirizzo', value: widget.cliente.indirizzo != null ? widget.cliente.indirizzo! : "Non inserito"),
                _buildInfoText(title:'Partita Iva', value:widget.cliente.partita_iva != null ? widget.cliente.partita_iva! : "Non inserito"),
                _buildInfoText(title:'Cap', value:widget.cliente.cap != null ? widget.cliente.cap!: "Non inserito"),
                _buildInfoText(title:'Città', value:widget.cliente.citta != null ? widget.cliente.citta!: "Non inserito"),
                _buildInfoText(title:'Provincia', value:widget.cliente.provincia != null ? widget.cliente.provincia!: "Non inserito"),
                _buildInfoText(title:'Nazione', value:widget.cliente.nazione != null ? widget.cliente.nazione!: "Non inserito"),
                _buildInfoText(title:'Recapito fatturazione elettronica', value:widget.cliente.recapito_fatturazione_elettronica != null ? widget.cliente.recapito_fatturazione_elettronica!: "Non inserito"),
                _buildInfoText(title:'Riferimento amministrativo', value:widget.cliente.riferimento_amministrativo != null ? widget.cliente.riferimento_amministrativo!: "Non inserito"),
                _buildInfoText(title:'Referente', value:widget.cliente.referente != null ? widget.cliente.referente!: "Non inserito"),
                _buildInfoText(title:'Fax', value:widget.cliente.fax != null ? widget.cliente.fax!: "Non inserito"),
                _buildInfoText(title:'Telefono', value:widget.cliente.telefono != null ? widget.cliente.telefono!: "Non inserito"),
                _buildInfoText(title:'Cellulare', value:widget.cliente.cellulare != null ? widget.cliente.cellulare!: "Non inserito"),
                _buildInfoText(title:'Email', value:widget.cliente.email != null ? widget.cliente.email!: "Non inserito"),
                _buildInfoText(title:'PEC', value:widget.cliente.pec != null ? widget.cliente.pec!: "Non inserito"),
                _buildInfoText(title:'Note', value: widget.cliente.note != null ? widget.cliente.note!: "Non inserito"),
                if(allPosizioni.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      Text('Ultime posizioni salvate dai tecnici:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      for(var posizione in allPosizioni)
                        Text('${posizione.dataCreazione?.day}/${posizione.dataCreazione?.month}/${posizione.dataCreazione?.day} ${posizione.indirizzo}')
                    ],
                  )
              ],
            ),
          )
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

  Widget _buildInfoText({required String title, required String value, BuildContext? context}) {
    // Verifica se il valore supera i 25 caratteri
    bool isValueTooLong = value.length > 25;
    String displayedValue = isValueTooLong ? value.substring(0, 25) + "..." : value;

    return SizedBox(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                                  content: Text(value), // Mostra il valore completo qui
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

  Future<void> deleteCliente(BuildContext context, String? id) async {
    try {
      final response = await http.delete(
        Uri.parse('$ipaddress/api/cliente/$id'),
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
