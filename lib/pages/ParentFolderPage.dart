import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:core';

import '../model/CartellaModel.dart';
import 'ChildFolderPage.dart';

class ParentFolderPage extends StatefulWidget {
  const ParentFolderPage({Key? key}) : super(key: key);

  @override
  _ParentFolderPageState createState() => _ParentFolderPageState();
}

class _ParentFolderPageState extends State<ParentFolderPage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<CartellaModel> allCartelle = [];
  List<bool> _hoverStates = [];

  @override
  void initState() {
    super.initState();
    getAllCartelle();
  }

  Future<void> getAllCartelle() async {
    try {
      var apiUrl = Uri.parse("$ipaddress/api/cartella");
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<CartellaModel> cartelle = [];
        for (var item in jsonData) {
          var cartella = CartellaModel.fromJson(item);
          if (cartella.parent == null) {
            cartelle.add(cartella);
          }
        }
        setState(() {
          allCartelle = cartelle;
          _hoverStates = List<bool>.filled(cartelle.length, false);
        });
      }
    } catch (e) {
      print("Errore: $e");
    }
  }

  void openAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();
        final _controller = TextEditingController();
        return AlertDialog(
          title: Text('Crea nuova cartella'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Nome cartella'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci un nome per la cartella';
                }
                return null;
              },
            ),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: Text('Crea', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  createCartella(_controller.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createCartella(String? name) async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/cartella'),
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({
          'nome' : name.toString(),
          'parentFolder' : null,
        })
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cartella $name creata!'),
        ),
      );
      getAllCartelle();
    } catch(e){
      print('Errore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Archivio', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            onPressed: openAlert,
            icon: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: allCartelle.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Wrap(
          spacing: 10,
          runSpacing: 10,
          children: allCartelle.map((cartella) {
            int index = allCartelle.indexOf(cartella);
            return MouseRegion(
              onEnter: (event) {
                setState(() {
                  _hoverStates[index] = true;
                });
              },
              onExit: (event) {
                setState(() {
                  _hoverStates[index] = false;
                });
              },
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChildFolderPage(cartella : cartella)
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white10, width: 1),
                    borderRadius: BorderRadius.circular(10),
                    color: _hoverStates[index] ? Colors.red[50] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      Text(
                        cartella.nome!,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}