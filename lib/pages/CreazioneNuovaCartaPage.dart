import 'package:fema_crm/model/TipologiaCarta.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreazioneNuovaCartaPage extends StatefulWidget {
  const CreazioneNuovaCartaPage ({Key? key}) : super(key:key);

  @override
  _CreazioneNuovaCartaPageState createState() => _CreazioneNuovaCartaPageState();
}

class _CreazioneNuovaCartaPageState extends State<CreazioneNuovaCartaPage>{
  final _formKey = GlobalKey<FormState>();
  List<TipologiaCartaModel> tipologieCartaList = [];
  final _descrizioneController = TextEditingController();
  TipologiaCartaModel? selectedTipologiaCarta;
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  void initState(){
    super.initState();
    getAllTipologieCarta();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Creazione nuova carta',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 200,),
                _buildTextFormField(_descrizioneController, "Numero carta", "Inserisci i 4 numeri finali della carta"),
                SizedBox(height: 15),
                SizedBox(
                  width: 400,
                  child: SizedBox(
                    width: 600,
                    child: DropdownButtonFormField<TipologiaCartaModel>(
                      value: selectedTipologiaCarta,
                      hint: Text(
                        'SELEZIONA TIPOLOGIA CARTA',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onChanged: (TipologiaCartaModel? newValue) {
                        setState(() {
                          selectedTipologiaCarta = newValue;
                        });
                      },
                      items: tipologieCartaList
                          .map<DropdownMenuItem<TipologiaCartaModel>>(
                            (TipologiaCartaModel value) => DropdownMenuItem<TipologiaCartaModel>(
                          value: value,
                          child: Text(
                            value.descrizione!,
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      )
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'TIPOLOGIA CARTA',
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
                      validator: (value) {
                        if (value == null) {
                          return 'Selezionare una tipologia di carta';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      saveCarta();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      ),
                    ),
                    child: Text(
                      'Salva Carta',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveCarta() async {
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/cartadicredito'),
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({
          'descrizione' : _descrizioneController.text,
          'tipologia_carta' : selectedTipologiaCarta?.toMap(),
        })
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nuova carta registrata con successo!'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio del sopralluogo');
    }
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText) {
    return SizedBox(
      width: 400, // Larghezza modificata
      child: TextFormField(
        controller: controller,
        maxLines: null, // Permette più righe
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200], // Sfondo riempito
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Nessun bordo di default
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.redAccent,
              width: 2.0, // Larghezza bordo focale
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.0, // Larghezza bordo abilitato
            ),
          ),
          contentPadding:
          EdgeInsets.symmetric(vertical: 15, horizontal: 10), // Padding contenuto
        ), // Funzione di validazione
      ),
    );
  }

  Future<void> getAllTipologieCarta() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/tipologiacarta');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<TipologiaCartaModel> tipologieCarta = [];
        for(var item in jsonData){
          tipologieCarta.add(TipologiaCartaModel.fromJson(item));
        }
        setState(() {
          tipologieCartaList = tipologieCarta;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errore di connessione'),
          content: Text(
            'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.',
          ),
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