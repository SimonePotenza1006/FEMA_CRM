import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/UtenteModel.dart';

class ListaUtentiPage extends StatefulWidget{
  const ListaUtentiPage({Key? key}) : super(key: key);

  @override
  _ListaUtentiPageState createState() => _ListaUtentiPageState();
}

class _ListaUtentiPageState extends State<ListaUtentiPage>{
  List<UtenteModel> allUtenti = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAllUtenti();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Lista utenti', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                    child: ListView.separated(
                      itemCount: allUtenti.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index){
                        final utente = allUtenti[index];
                        return buildViewUtenti(utente, context);
                      },
                    ))
              ],
      )
    );
  }
  
  
  Future<void> getAllUtenti() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/utente');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<UtenteModel> utenti = [];
        for(var item in jsonData){
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      // Gestione degli errori
      print('Errore durante la chiamata all\'API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Errore di connessione'),
            content: Text(
                'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showPasswordUpdateDialog(BuildContext context, UtenteModel utente) {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Inserire la nuova password'),
          content: TextFormField(
            controller: passwordController,
            maxLines: null,
            decoration: InputDecoration(
              labelText: 'NUOVA PASSWORD',
              labelStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.redAccent,
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.0,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Chiude l'alert senza salvare
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Colore rosso per il testo di "Annulla"
              ),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                if(passwordController.text.isNotEmpty){
                  saveNewPassword(passwordController.text, utente).whenComplete(() => setState(() {
                    utente.password = passwordController.text;
                  }));
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Non puoi salvare una password vuota!'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Sfondo rosso
                foregroundColor: Colors.white, // Testo bianco
              ),
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveNewPassword(String password, UtenteModel utente) async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/utente'),
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({
          'id' : utente.id,
          'attivo' : utente.attivo,
          'nome' : utente.nome,
          'cognome' : utente.cognome,
          'email' : utente.email,
          'password' : password,
          'cellulare' : utente.cellulare,
          'codice_fiscale' : utente.codice_fiscale,
          'iban' : utente.iban,
          'ruolo' : utente.ruolo?.toMap(),
          'tipologia_intervento' : utente.tipologia_intervento?.toMap()
        })
      );
      if(response.statusCode == 201){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password modificata con successo!'),
          ),
        );
      }
    } catch(e){
      print('Errore modifica password: $e');
    }
  }


  Widget buildViewUtenti(UtenteModel utente, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      color: Colors.white,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          '${utente.nome} ${utente.cognome}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Ruolo: ${utente.ruolo?.descrizione}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey[600],
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.email, size: 20, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text(
                      'Email:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        utente.email ?? 'Non disponibile',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.lock, size: 20, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text(
                      'Password:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        utente.password ?? 'Non disponibile',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _showPasswordUpdateDialog(context, utente);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Modifica',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}