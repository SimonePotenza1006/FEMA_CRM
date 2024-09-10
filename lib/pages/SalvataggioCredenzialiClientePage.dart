import 'dart:convert';

import 'package:fema_crm/model/ClienteModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SalvataggioCredenzialiClientePage extends StatefulWidget{
  final ClienteModel cliente;
  final UtenteModel utente;

  const SalvataggioCredenzialiClientePage({Key? key, required this.utente, required this.cliente}) : super(key:key);

  @override
  _SalvataggioCredenzialiClientePageState createState() =>_SalvataggioCredenzialiClientePageState();
}

class _SalvataggioCredenzialiClientePageState extends State<SalvataggioCredenzialiClientePage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Definisci la chiave del form
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String? denominazione = widget.cliente.denominazione!;

    // Controllo della lunghezza e applicazione di substring se necessario
    String titolo = denominazione.length > 19
        ? denominazione.substring(0, 19)
        : denominazione;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Salvataggio credenziali $titolo".toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Form(
              // Associa la formKey al form
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 12),
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      controller: _descrizioneController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'A cosa si riferiscono le credenziali?'.toUpperCase(),
                        border: OutlineInputBorder(),
                      ),
                      // Aggiungi validazione
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Questo campo è obbligatorio';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      controller: _usernameController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Inserisci username'.toUpperCase(),
                        border: OutlineInputBorder(),
                      ),
                      // Aggiungi validazione
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Questo campo è obbligatorio';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      controller: _passwordController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Inserisci password'.toUpperCase(),
                        border: OutlineInputBorder(),
                      ),
                      // Aggiungi validazione
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Questo campo è obbligatorio';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveCredenziali();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Salva credenziali'.toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> saveCredenziali() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/credenziali'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'descrizione' : _descrizioneController.text,
          'credenziali' : "Username : ${_usernameController.text}  Password : ${_passwordController.text}",
          'cliente' : widget.cliente.toMap(),
          'utente' : widget.utente.toMap()
        }),
      );
      if(response.statusCode == 200){
          _usernameController.clear();
          _passwordController.clear();
          _descrizioneController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Credenziali salvate con successo!"),
              duration: Duration(seconds: 3),
          )
        );
      }
    } catch(e){
      print("Qualcosa non va: $e");
    }
  }
}