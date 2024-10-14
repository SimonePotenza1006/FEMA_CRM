import '../model/GruppoInterventiModel.dart';
import '../model/InterventoModel.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'DettaglioInterventoPage.dart';

class DettaglioGruppoPage extends StatefulWidget {
  final GruppoInterventiModel gruppo;

  DettaglioGruppoPage({required this.gruppo});

  @override
  _DettaglioGruppoPageState createState() => _DettaglioGruppoPageState();
}

class _DettaglioGruppoPageState extends State<DettaglioGruppoPage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<InterventoModel> interventi = [];
  bool modificaDescrizioneVisible = false;
  final TextEditingController descrizioneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getInterventi();
  }

  Future<void> getInterventi() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/intervento/gruppo/${widget.gruppo.id}');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> associatedInterventi = [];
        for (var item in jsonData) {
          associatedInterventi.add(InterventoModel.fromJson(item));
        }
        setState(() {
          interventi = associatedInterventi; // Aggiorna la lista di interventi
        });
      } else {
        throw Exception('Failed to load interventi');
      }
    } catch (e) {
      print('Errore: $e');
    }
  }

  void modificaDescrizione() async {
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/gruppi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.gruppo.id,
          'descrizione': descrizioneController.text,
          'note': widget.gruppo.note,
          'importo': widget.gruppo.importo,
          'concluso': widget.gruppo.concluso,
          'cliente': widget.gruppo.cliente?.toMap(),
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Descrizione cambiata con successo!'),
          ),
        );
        setState(() {
          widget.gruppo.descrizione = descrizioneController.text;
        });
      }
    } catch (e) {
      print('Qualcosa non va: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String descrizioneInterventoSub = widget.gruppo.descrizione!.length < 30
        ? widget.gruppo.descrizione!
        : widget.gruppo.descrizione!.substring(0, 30);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "DETTAGLIO ${widget.gruppo.descrizione}".toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGruppoInfo(descrizioneInterventoSub),
              SizedBox(height: 15),
              Text(
                'Interventi Associati',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildInterventiList(), // Costruisce la lista degli interventi
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGruppoInfo(String descrizioneInterventoSub) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informazioni di base',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 500,
                child: buildInfoRow(
                    title: 'Descrizione',
                    value: descrizioneInterventoSub,
                    context: context),
              ),
              SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    modificaDescrizioneVisible = !modificaDescrizioneVisible;
                  });
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.black,
                ),
              )
            ],
          ),
          SizedBox(height: 15),
          if (modificaDescrizioneVisible)
            SizedBox(
                width: 500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        maxLines: null,
                        controller: descrizioneController,
                        decoration: InputDecoration(
                          labelText: 'Descrizione',
                          hintText: 'Aggiungi una descrizione',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 170,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: FloatingActionButton(
                        heroTag: "Tag2",
                        onPressed: () {
                          if (descrizioneController.text.isNotEmpty) {
                            modificaDescrizione();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Non è possibile salvare una descrizione nulla!'),
                              ),
                            );
                          }
                        },
                        backgroundColor: Colors.red,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Modifica Descrizione'.toUpperCase(),
                                style: TextStyle(color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
        ],
      ),
    );
  }

  Widget _buildInterventiList() {
    return interventi.isEmpty
        ? Center(child: Text('Nessun intervento associato'))
        : ListView.builder(
      shrinkWrap: true, // Questo è importante per evitare problemi di altezza
      physics: NeverScrollableScrollPhysics(), // Disabilita lo scroll per evitare conflitti con lo scroll principale
      itemCount: interventi.length,
      itemBuilder: (context, index) {
        var intervento = interventi[index];
        return GestureDetector(
          onTap: () {
            if (intervento != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DettaglioInterventoPage(intervento: intervento),
                ),
              );
            }
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: Text(
                  intervento.descrizione != null ? intervento.descrizione! : '///',
                  style: TextStyle(
                    color: intervento != null ? Colors.blue : Colors.black,
                  ),
                ),
              ),
              if (intervento != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget buildInfoRow({required String title, required String value, BuildContext? context}) {
    bool isValueTooLong = value.length > 25;
    String displayedValue = isValueTooLong ? value.substring(0, 25) + "..." : value;
    return SizedBox(
      width: 280,
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
                              context: context!,
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
