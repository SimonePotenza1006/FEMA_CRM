import 'package:fema_crm/model/OrdinePerInterventoModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:fema_crm/pages/DettaglioOrdineAmministrazionePage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ReportOrdiniPerUtentePage extends StatefulWidget{
  final UtenteModel? utente;

  const ReportOrdiniPerUtentePage({Key? key, required this.utente}) : super(key: key);

  @override
  _ReportOrdiniPerUtentePageState createState() =>
      _ReportOrdiniPerUtentePageState();
}

class _ReportOrdiniPerUtentePageState extends State<ReportOrdiniPerUtentePage>{
  List<UtenteModel> utentiList = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  Map<String, List<OrdinePerInterventoModel>> ordiniPerUtenteMap = {};
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getAllUtenti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ordini per utente',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildUtentiTables(),
                ),
              ),
            ),
          ),
          Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalScrollController,
              child: Container(
                height: 20,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> getAllUtenti() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/utente');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for (var item in jsonData){
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          utentiList = utenti;
        });
        await getAllOrdiniOrderedByUtente();
      }
    } catch(e){
      print('Error fetching utenti data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text(
                'Unable to load data from API. Please check your internet connection and try again.'),
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

  Future<void> getAllOrdiniOrderedByUtente() async{
    for(var utente in utentiList){
      await getAllOrdiniForUtente(utente.id!);
    }
  }

  Future<void> getAllOrdiniForUtente(String utenteId) async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/ordine/utente/$utenteId');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<OrdinePerInterventoModel> ordini = [];
        for(var item in jsonData){
          ordini.add(OrdinePerInterventoModel.fromJson(item));
        }
        setState(() {
          ordiniPerUtenteMap[utenteId] = ordini;
        });
      }
    } catch(e){
      print('Error fetching utente $utenteId: $e');
    }
  }

  List<Widget> _buildUtentiTables(){
    if(utentiList.isEmpty) {
      return [Text('Nessun utente trovato')];
    }

    List<Widget> tables = [];

    for(var utente in utentiList){
      final ordini = ordiniPerUtenteMap[utente.id!] ?? [];
      if (ordini.length > 0)
      tables.add(
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${utente.nomeCompleto()}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              DataTable(
                columnSpacing: 100 ,
                  columns: [
                    DataColumn(label: Text('Data Creazione', style: TextStyle(fontWeight: FontWeight.bold),)),
                    DataColumn(label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold),)),
                    DataColumn(label: Text('Data richiesta disponibilità', style: TextStyle(fontWeight: FontWeight.bold),)),
                    DataColumn(label: Text('Entro e non oltre il', style: TextStyle(fontWeight: FontWeight.bold),)),
                    DataColumn(label: Text('Descrizione', style: TextStyle(fontWeight: FontWeight.bold),)),
                    DataColumn(label: Text('Fornitore', style: TextStyle(fontWeight: FontWeight.bold),)),
                  ],
                  rows: _buildRows(ordini, utente.id!),
              ),
            ],
          ),
        )
      );
      if(utentiList.last != utente){
        tables.add(SizedBox(height: 20));
      }
    }
    return tables;
  }

  List<DataRow> _buildRows(List<OrdinePerInterventoModel> ordini, String utenteId){
    return ordini.map((ordine) {
      Color backgroundColor = Colors.white;
      Color textColor = Colors.black;

      if(ordine.presa_visione ?? false) {
        backgroundColor = Colors.yellow;
      } else if (ordine.ordinato ?? false){
        backgroundColor = Colors.orange;
      } else if (ordine.arrivato ?? false){
        backgroundColor = Colors.lightBlueAccent;
      } else if (ordine.consegnato ?? false){
        backgroundColor = Colors.lightGreen;
      }

      if(backgroundColor == Colors.lightGreen ||
          backgroundColor == Colors.lightBlueAccent){
        textColor = Colors.white;
      }
      return DataRow(
        color: MaterialStateColor.resolveWith((states) => backgroundColor),
        cells: [
          DataCell(
            Text(
              ordine.data_richiesta != null ?
                DateFormat('yyyy-MM-dd').format(ordine.data_richiesta!)
                : 'N/A',
              style: TextStyle(color: textColor),
            )
          ),
          DataCell(
            Text(
              ordine.cliente?.denominazione ?? 'N/A',
              style: TextStyle(color: textColor),
            )
          ),
          DataCell(
            Text(
              ordine.data_disponibilita != null ?
                  DateFormat('yyyy-MM-dd').format(ordine.data_disponibilita!)
                  : 'N/A',
              style: TextStyle(color: textColor),
            )
          ),
          DataCell(
              Text(
                ordine.data_ultima != null ?
                DateFormat('yyyy-MM-dd').format(ordine.data_ultima!)
                    : 'N/A',
                style: TextStyle(color: textColor),
              )
          ),
          DataCell(
            Text(
              ordine.descrizione ?? 'N/A',
              style: TextStyle(color: textColor),
            )
          ),
          DataCell(
            Text(
              ordine.fornitore?.denominazione ?? 'N/A',
              style: TextStyle(color: textColor),
            )
          )
        ].map<DataCell>((cell){
          return DataCell(
            InkWell(
              onTap: (){
                _handleRowTap(ordine);
              },
              child: cell.child,
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  void _handleRowTap(OrdinePerInterventoModel ordine) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              DettaglioOrdineAmministrazionePage(ordine: ordine, onNavigateBack: getAllUtenti, utente: widget.utente)
      ),
    );
  }


}