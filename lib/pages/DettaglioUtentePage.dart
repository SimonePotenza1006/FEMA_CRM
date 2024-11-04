import 'dart:convert';

import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DettaglioUtentePage extends StatefulWidget{
  final UtenteModel utente;

  const DettaglioUtentePage({Key? key, required this.utente}) : super(key: key);

  @override
  _DettaglioUtentePageState createState() => _DettaglioUtentePageState();
}

class _DettaglioUtentePageState extends State<DettaglioUtentePage>{
  final _newUsernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isEditing = false;
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  void dispose() {
    _newUsernameController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _newUsernameController.text = widget.utente.email!;

    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio credenziale utente',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Username: ${widget.utente.email}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Password: ${widget.utente.password}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 15),
                    if (_isEditing)
                      Column(
                        children: [
                          TextFormField(
                            controller: _newUsernameController,
                            decoration: InputDecoration(
                              labelText: 'Nuovo username',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: _newPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Nuova password',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {
                              saveCredenziali().then((value) => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => DettaglioUtentePage(utente: value)),
                              ));
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red, // Background color
                              onPrimary: Colors.white, // Text color
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding
                            ),
                            child: Text(
                              'Salva modifiche',
                              style: TextStyle(fontSize: 18), // Text style
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Background color
                onPrimary: Colors.white, // Text color
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding
              ),
              child: Text(
                'Modifica credenziali',
                style: TextStyle(fontSize: 18), // Text style
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<UtenteModel> saveCredenziali() async {
    print('new pass: '+_newPasswordController.text);
    try {
      final newUsername = _newUsernameController.text.isNotEmpty
          ? _newUsernameController.text
          : widget.utente.email;

      String? newPassword = _newPasswordController.text.isNotEmpty
          ? _newPasswordController.text
          : widget.utente.password;

      final response = await http.post(Uri.parse('$ipaddress/api/utente'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.utente.id,
          'attivo': widget.utente.attivo,
          'nome': widget.utente.nome,
          'cognome': widget.utente.cognome,
          'email': newUsername,
          'password': newPassword,
          'cellulare': widget.utente.cellulare,
          'codice_fiscale': widget.utente.codice_fiscale,
          'iban': widget.utente.iban,
          'ruolo': widget.utente.ruolo?.toMap(),
          'tipologia_intervento' : widget.utente.tipologia_intervento?.toMap(),
        }),
      );

      if (response.statusCode == 201) {
        print("Utente modificato");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Credenziali utente aggiornate con successo!'),
            duration: Duration(seconds: 2),
          ),
        );
        return UtenteModel.fromJson(json.decode(response.body.toString()));
      } else {
        return widget.utente;
      }
    } catch (e) {
      print('Errore durante il salvataggio delle credenziali: $e');
      return widget.utente;
    }
  }
}
