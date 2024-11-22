import 'dart:convert';
import 'package:fema_crm/pages/HomeFormAmministrazioneNewPage.dart';
import 'package:fema_crm/pages/TableCommissioniPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fema_crm/model/CommissioneModel.dart';
import '../model/UtenteModel.dart';

class DettaglioCommissioneAmministrazionePage extends StatefulWidget {
  final CommissioneModel commissione;

  DettaglioCommissioneAmministrazionePage({Key? key, required this.commissione})
      : super(key: key);

  @override
  _DettaglioCommissioneAmministrazionePageState createState() =>
      _DettaglioCommissioneAmministrazionePageState();
}

class _DettaglioCommissioneAmministrazionePageState
    extends State<DettaglioCommissioneAmministrazionePage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<UtenteModel> allUtenti = [];

  @override
  void initState() {
    super.initState();
    _fetchUtentiAttivi();
  }

  void openAssignDialog() {
    UtenteModel? selectedUser;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleziona un utente'),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: allUtenti.length,
                        itemBuilder: (context, index) {
                          return RadioListTile<UtenteModel>(
                            title: Text(allUtenti[index].nomeCompleto() ?? "Anonimo"),
                            value: allUtenti[index],
                            groupValue: selectedUser,
                            onChanged: (UtenteModel? value) {
                              setState(() {
                                selectedUser = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        if (selectedUser != null) {
                          assegna(selectedUser!);
                          print('Utente selezionato: ${selectedUser!.nomeCompleto()}');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Seleziona un utente prima di assegnare")),
                          );
                        }
                      },
                      child: Text(
                        'ASSEGNA',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchUtentiAttivi() async {
    try {
      final response = await http.get(Uri.parse('$ipaddressProva/api/utente/attivo'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<UtenteModel> utenti = [];
        for (var singoloUtente in responseData) {
          utenti.add(UtenteModel.fromJson(singoloUtente));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception('Errore durante il recupero degli utenti');
      }
    } catch (e) {
      throw Exception('Errore durante il recupero degli utenti: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDataCreazione = DateFormat('dd/MM/yyyy HH:mm')
        .format(widget.commissione.data_creazione ?? DateTime.now());
    String formattedData = DateFormat('dd/MM/yyyy')
        .format(widget.commissione.data ?? DateTime.now());
    String descrizione = widget.commissione.descrizione ?? 'NESSUNA DESCRIZIONE DISPONIBILE';
    String note = widget.commissione.note ?? 'NESSUNA NOTA DISPONIBILE';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio commissione',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Container(
              width: 700, // Imposta la larghezza del container per centrare i dati
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildInfoRow(title: 'Data creazione', value: formattedDataCreazione, context: context),
                  buildInfoRow(title: 'Data', value: formattedData, context: context),
                  buildInfoRow(title: 'Descrizione', value: descrizione, context: context),
                  buildInfoRow(title: 'Note', value: note, context: context),
                  buildInfoRow(title: 'Utente', value: widget.commissione.utente!.nomeCompleto()!)
                ],
              ),
            ),
            SizedBox(height: 15),
          ],
        )
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              children: [
                SpeedDialChild(
                  child: Icon(Icons.check, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Concludi'.toUpperCase(),
                  onTap: () => concludiCommissione(),
                ),
                SpeedDialChild(
                  child: Icon(Icons.person, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Assegna'.toUpperCase(),
                  onTap: () => openAssignDialog(),
                ),
                SpeedDialChild(
                  child: Icon(Icons.delete_forever, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Elimina commissione'.toUpperCase(),
                  onTap: () => showDeleteConfirmationDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Impedisce di chiudere il dialog toccando all'esterno
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Conferma eliminazione'),
          content: Text('Eliminare definitivamente la commissione?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Chiude il dialog con risposta "NO"
              },
              child: Text('NO'),
            ),
            TextButton(
              onPressed: () {
                elimina();
              },
              child: Text('SI'),
            ),
          ],
        );
      },
    );
  }

  Future<void> elimina() async{
    final url = Uri.parse('$ipaddressProva/api/commissione');
    final body = jsonEncode({
      'id': widget.commissione.id,
      'data_creazione': widget.commissione.data_creazione?.toIso8601String(),
      'data': widget.commissione.data?.toIso8601String(),
      'priorita' : widget.commissione.priorita.toString().split('.').last,
      'descrizione': widget.commissione.descrizione,
      'concluso': widget.commissione.concluso,
      'note': widget.commissione.note,
      'utente': widget.commissione.utente?.toMap(),
      'intervento': widget.commissione.intervento?.toMap(),
      'attivo': false,
    });
    try{
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        print('Commissione eliminata!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TableCommissioniPage(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commissione elimiata!'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('Errore durante la creazione della commissione');
      }
    }catch(e){
      print('errore $e');
    }
  }

  Future<void> assegna(UtenteModel utente) async{
    final url = Uri.parse('$ipaddressProva/api/commissione');
    final body = jsonEncode({
      'id': widget.commissione.id,
      'data_creazione': widget.commissione.data_creazione?.toIso8601String(),
      'data': widget.commissione.data?.toIso8601String(),
      'priorita' : widget.commissione.priorita.toString().split('.').last,
      'descrizione': widget.commissione.descrizione,
      'concluso': widget.commissione.concluso,
      'note': widget.commissione.note,
      'utente': utente.toMap(),
      'intervento': widget.commissione.intervento?.toMap(),
      'attivo': widget.commissione.attivo,
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        print('Commissione eliminata!');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commissione assegnata!'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          widget.commissione.utente = utente;
        });
      } else {
        throw Exception('Errore durante la creazione della commissione');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }


  Future<void> concludiCommissione() async {
    final url = Uri.parse('$ipaddressProva/api/commissione');
    final body = jsonEncode({
      'id': widget.commissione.id,
      'data_creazione': widget.commissione.data_creazione?.toIso8601String(),
      'data': widget.commissione.data?.toIso8601String(),
      'priorita' : widget.commissione.priorita.toString().split('.').last,
      'descrizione': widget.commissione.descrizione,
      'concluso': true,
      'note': widget.commissione.note,
      'utente': widget.commissione.utente,
      'intervento': widget.commissione.intervento?.toMap(),
      'attivo': widget.commissione.attivo,
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        print('Commissione completata!');
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeFormAmministrazioneNewPage(
              userData: widget.commissione.utente!,
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commissione completata!'),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        throw Exception('Errore durante la creazione della commissione');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  Widget buildInfoRow({required String title, required String value, BuildContext? context}) {
    bool isValueTooLong = value.length > 25;
    String displayedValue = isValueTooLong ? value.substring(0, 25) + "..." : value;

    return SizedBox(
      width: 600,
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
                      width: 4,
                      height: 24,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 10),
                    Text(
                      title.toUpperCase() + ": ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
                          fontWeight: FontWeight.bold,
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
            Divider(
              color: Colors.grey[400],
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}
