import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/NotaTecnicoModel.dart';
import 'DettaglioNotaPage.dart';

class ListaNoteUtentiPage extends StatefulWidget{
  const ListaNoteUtentiPage({Key? key}) : super(key : key);

  @override
  _ListaNoteUtentiPageState createState() => _ListaNoteUtentiPageState();
}

class _ListaNoteUtentiPageState extends State<ListaNoteUtentiPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<NotaTecnicoModel> allNote = [];
  bool isSearching = false;
  List<NotaTecnicoModel> filteredNote = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  void filterNote(String query) {
    setState(() {
      filteredNote = allNote.where((nota) {
        final denominazione = nota.cliente?.denominazione?.toLowerCase();
        final codice_fiscale = nota.cliente?.codice_fiscale?.toLowerCase();
        final partita_iva = nota.cliente?.partita_iva?.toLowerCase();
        final telefono = nota.cliente?.telefono?.toLowerCase();
        final cellulare = nota.cliente?.cellulare?.toLowerCase();
        final citta = nota.cliente?.citta?.toLowerCase();
        final email = nota.cliente?.email?.toLowerCase();
        final cap = nota.cliente?.cap?.toLowerCase();
        final notaN = nota.nota?.toLowerCase();

        return denominazione!.contains(query.toLowerCase()) ||
            codice_fiscale!.contains(query.toLowerCase()) ||
            partita_iva!.contains(query.toLowerCase()) ||
            telefono!.contains(query.toLowerCase()) ||
            cellulare!.contains(query.toLowerCase()) ||
            citta!.contains(query.toLowerCase()) ||
            email!.contains(query.toLowerCase()) ||
            notaN!.contains(query.toLowerCase()) ||
            cap!.contains(query.toLowerCase());
      }).toList();
    });
  }

  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  Future<void> getAllNote() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/noteTecnico/ordered');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        List<NotaTecnicoModel> note = [];
        var jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          note.add(NotaTecnicoModel.fromJson(item));
        }
        setState(() {
          filteredNote = note;
        });
      }else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
        print('Errore durante la chiamata all\'API: $e');
    }
  }


  @override
  void initState(){
    super.initState();
    getAllNote();
    setState(() {
      filteredNote = allNote;
      isLoading = false;
    });
  }

  void stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      filterNote('');
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: isSearching
            ? TextField(
          controller: searchController,
          onChanged: filterNote,
          decoration: InputDecoration(
            hintText: 'Filtra...',
            hintStyle: TextStyle(
                color: Colors.white), // colore del testo dell'hint
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
        )
            : Text('Lista Note dei tecnici', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
          actions : [
            IconButton(
              icon: Icon(
                Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
                color: Colors.white,
              ),
              onPressed: () {
                // Funzione per ricaricare la pagina
                setState(() {});
              },
            ),
          ]
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                    child: ListView.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: filteredNote.length,
                        itemBuilder: (context, index){
                          final nota = filteredNote[index];
                          return buildViewNote(nota);
                        },
                    ),
                ),
              ],
      )
    );
  }

  Widget buildViewNote(NotaTecnicoModel nota) {
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm')
        .format(DateTime.parse(nota.data!.toIso8601String()));
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      color: Colors.white.withOpacity(0.4),
      child: ListTile(
        minLeadingWidth: 12,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        onTap: () {
           Navigator.push(
             context,
             MaterialPageRoute(
                 builder: (context) => DettaglioNotaPage(nota: nota)),
           );
        },
        leading: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Icon(Icons.message_outlined)],
        ),
        trailing: Text('Id. ${nota.id}'),
        title: Text(
          '${nota.utente?.nomeCompleto()}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Data: $formattedDate',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}