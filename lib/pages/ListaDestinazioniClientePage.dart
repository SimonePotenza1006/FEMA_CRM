import 'dart:convert';

import 'package:fema_crm/model/ClienteModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../databaseHandler/DbHelper.dart';
import '../model/DestinazioneModel.dart';
import 'DettaglioDestinazionePage.dart';
import 'NuovaDestinazionePage.dart';

class ListaDestinazioniClientePage extends StatefulWidget{
  final ClienteModel cliente;

  const ListaDestinazioniClientePage({Key? key, required this.cliente}) : super(key:key);

  @override
  _ListaDestinazioniClientePageState createState() => _ListaDestinazioniClientePageState();
}

class _ListaDestinazioniClientePageState extends State<ListaDestinazioniClientePage>{
  DbHelper? dbHelper;
  List<DestinazioneModel> allDestinazioniByCliente = [];
  bool isLoading = true;

  @override
  void initState(){
    dbHelper = DbHelper();
    init();
    super.initState();
    getAllDestinazioniByCliente();
  }

  Future<void> init() async{
    await getAllDestinazioniByCliente();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista destinazioni di ${widget.cliente.denominazione}',
          style: const TextStyle(color : Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.add,
              size: 40,
              color: Colors.white,
            ),
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NuovaDestinazionePage(cliente: widget.cliente),)
              );
            },
          )
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
        itemCount: allDestinazioniByCliente.length,
        itemBuilder: (context, index){
          final destinazione = allDestinazioniByCliente[index];
          return buildViewDestinazioni(destinazione);
        }
      )
    );
  }


  Future<void> getAllDestinazioniByCliente() async{
    try {
      final response = await http.get(Uri.parse('http://192.168.1.52:8080/api/destinazione/cliente/${widget.cliente.id}'));
      if(response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          allDestinazioniByCliente = responseData.map((data) => DestinazioneModel.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load Destinazioni per cliente');
      }
    } catch(e) {
      print('Errore durante la richiesta HTTP: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget? buildViewDestinazioni(DestinazioneModel destinazione) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      color: Colors.white.withOpacity(0.4),
      child: ListTile(
        minLeadingWidth: 12,
        visualDensity: const VisualDensity(horizontal: 0, vertical: 4),
        onTap:(){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DettaglioDestinazionePage(destinazione: destinazione),)
          );
        },
        leading: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Icon(Icons.house_outlined, size:40)],
        ),
        title: Text(
          '${destinazione.denominazione}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
        )
      )
    );
  }
}

