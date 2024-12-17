import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../model/AziendaModel.dart';

class CertificazioniFormPage extends StatefulWidget {
  const CertificazioniFormPage({Key? key}) : super(key:key);

  @override
  _CertificazioniFormPageState createState() => _CertificazioniFormPageState();
}

class _CertificazioniFormPageState extends State<CertificazioniFormPage>{
  List<AziendaModel> allAziende = [];
  AziendaModel? selectedAzienda;
  List<TipologiaInterventoModel> allTipologie = [];
  TipologiaInterventoModel? selectedTipologia;
  List<UtenteModel> allUtenti = [];
  UtenteModel? selectedUtente;
  List<ClienteModel> allClienti = [];
  ClienteModel? selectedCliente;
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  TextEditingController _impiantoController = TextEditingController();

  @override
  void initState(){
    super.initState();
    getAllAziende();
    getAllClienti();
    getAllTipologie();
  }

  Future<void> getAllClienti() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/cliente'));
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<ClienteModel> clienti = [];
        for(var item in jsonData){
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          allClienti = clienti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamataa all\'API getAllClienti: $e');
    }
  }

  Future<void> getAllTipologie() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/tipologiaIntervento'));
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<TipologiaInterventoModel> tipologie = [];
        for(var item in jsonData){
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }
        setState(() {
          allTipologie = tipologie;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamataa all\'API getAllTipologie: $e');
    }
  }

  Future<void> getAllAziende() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/azienda'));
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<AziendaModel> aziende = [];
        for(var item in jsonData){
          aziende.add(AziendaModel.fromJson(item));
        }
        setState(() {
          allAziende = aziende;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamataa all\'API getAllAziende: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compilazione certificazione', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  DropdownButton<AziendaModel>(
                    value: selectedAzienda,
                    onChanged: (AziendaModel? newValue){
                      setState(() {
                        selectedAzienda = newValue;
                      });
                    },
                    items: allAziende.map((AziendaModel azienda){
                      return DropdownMenuItem<AziendaModel>(
                          value: azienda,
                          child: Text(azienda.nome!)
                      );
                    }).toList(),
                    hint: Text('Azienda'),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<TipologiaInterventoModel>(
                    value: selectedTipologia,
                    onChanged: (TipologiaInterventoModel? newValue){
                      setState(() {
                        selectedTipologia = newValue;
                      });
                    },
                    items: allTipologie.map((TipologiaInterventoModel tipologia){
                      return DropdownMenuItem<TipologiaInterventoModel>(
                          value: tipologia,
                          child: Text(tipologia.descrizione!)
                      );
                    }).toList(),
                    hint: Text('Tipologia di intervento'),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 220,
                    child: DropdownSearch<ClienteModel>(
                      items: allClienti,
                      itemAsString: (ClienteModel cliente) => cliente.denominazione ?? '',
                      selectedItem: selectedCliente,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Cliente",
                          hintText: "Seleziona un cliente",
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                      onChanged: (ClienteModel? newValue) {
                        setState(() {
                          selectedCliente = newValue;
                        });
                      },
                      validator: (ClienteModel? value) {
                        if (value == null) {
                          return 'Seleziona un cliente';
                        }
                        return null;
                      },
                      popupProps: PopupProps.dialog( // Gestisce il popup come dialogo
                        showSearchBox: true, // Mostra il campo di ricerca
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            labelText: 'Cerca cliente',
                          ),
                        ),
                        itemBuilder: (context, ClienteModel cliente, bool isSelected) {
                          return ListTile(
                            title: Text(cliente.denominazione ?? ''),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildTextField('Inserisci la descrizione dell\'impianto', _impiantoController)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SizedBox(
          width: 600,
          child: TextField(
            maxLines: 5,
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        )
    );
  }
}