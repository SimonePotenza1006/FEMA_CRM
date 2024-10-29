import 'dart:convert';
import 'package:fema_crm/pages/HomeFormTecnicoNewPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/InterventoModel.dart';
import '../model/UtenteModel.dart';
import 'AggiuntaFotoPage.dart';
import 'package:http/http.dart' as http;

class MenuSceltaSaldoPage extends StatefulWidget {
  final UtenteModel utente;
  final InterventoModel intervento;

  MenuSceltaSaldoPage({Key? key, required this.utente, required this.intervento}) : super(key: key);

  @override
  _MenuSceltaSaldoPageState createState() => _MenuSceltaSaldoPageState();
}

class _MenuSceltaSaldoPageState extends State<MenuSceltaSaldoPage> {
  bool? isInterventoSaldato; // Variable to track selected value
  TextEditingController saldoController = TextEditingController(); // Controller for TextFormField
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RAPPORTINO', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                buildMenuButton(
                  icon: Icons.camera,
                  text: 'ALLEGA FOTO INERENTI',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AggiuntaFotoPage(
                          utente: widget.utente,
                          intervento: widget.intervento,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 30), // Space below button
                Center(
                  child: Text(
                    "L'intervento è stato saldato?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),

                // Checkbox for "Yes" and "No"
                CheckboxListTile(
                  title: Row(
                    children: [
                      Text("Sì"),
                      SizedBox(width: 10),
                      if (isInterventoSaldato == true) // Show TextFormField if "Yes" is selected
                        Expanded(
                          child: TextFormField(
                            controller: saldoController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true), // Numeric keyboard with decimal
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Allows up to 2 decimal places
                            ],
                            decoration: InputDecoration(
                              hintText: 'Inserisci dettagli saldo',
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                    ],
                  ),
                  value: isInterventoSaldato == true,
                  onChanged: (value) {
                    setState(() {
                      isInterventoSaldato = true;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: Text("No"),
                  value: isInterventoSaldato == false,
                  onChanged: (value) {
                    setState(() {
                      isInterventoSaldato = false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 80),

                // "CONCLUDI" button, enabled only if appropriate conditions are met
                buildMenuButton(
                  icon: Icons.check,
                  text: 'CONCLUDI',
                  onPressed: (isInterventoSaldato == true && saldoController.text.isNotEmpty) ||
                      isInterventoSaldato == false
                      ? () {
                    concludi();
                  }
                      : null, // Disable button if no valid input in TextFormField
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMenuButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [Colors.grey.shade400, Colors.grey.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void concludi() async {
    var importo = saldoController.text.isNotEmpty ? double.tryParse(saldoController.text.toString()) : null;
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id?.toString(),
          'titolo' : widget.intervento.titolo,
          'numerazione_danea': widget.intervento.numerazione_danea,
          'priorita': widget.intervento.priorita.toString().split('.').last,
          'data_apertura_intervento': widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento': widget.intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps': widget.intervento.posizione_gps,
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': DateTime.now().toIso8601String(),
          'descrizione': widget.intervento.descrizione,
          'importo_intervento': widget.intervento.importo_intervento,
          'saldo_tecnico': importo,
          'prezzo_ivato': widget.intervento.prezzo_ivato,
          'iva': widget.intervento.iva,
          'acconto': widget.intervento.acconto,
          'assegnato': widget.intervento.assegnato,
          'accettato_da_tecnico': widget.intervento.accettato_da_tecnico,
          'annullato' : widget.intervento.annullato,
          'conclusione_parziale': widget.intervento.conclusione_parziale,
          'concluso': true,
          'saldato': isInterventoSaldato,
          'saldato_da_tecnico': isInterventoSaldato,
          'note': widget.intervento.note,
          'relazione_tecnico': widget.intervento.relazione_tecnico,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente_apertura': widget.intervento.utente_apertura?.toMap(),
          'utente': widget.intervento.utente?.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'merce': widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria_intervento_specifico': widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap(),
          'gruppo': widget.intervento.gruppo?.toMap(),
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervento concluso!'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeFormTecnicoNewPage(userData: widget.utente)),
        );
      }
    } catch (e) {
      print('Qualcosa non va: $e');
    }
  }
}
