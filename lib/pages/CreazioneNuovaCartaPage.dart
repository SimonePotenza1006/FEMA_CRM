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
                  width: 300,
                  child: DropdownButton<TipologiaCartaModel>(
                    value: selectedTipologiaCarta,
                    hint: Text('Seleziona la tipologia della carta'),
                    isExpanded: true,
                    onChanged: (TipologiaCartaModel? newValue) {
                      setState(() {
                        selectedTipologiaCarta = newValue;
                      });
                    },
                    items: tipologieCartaList
                        .map<DropdownMenuItem<TipologiaCartaModel>>(
                            (TipologiaCartaModel tipologia) {
                          return DropdownMenuItem<TipologiaCartaModel>(
                            value: tipologia,
                            child: Text(tipologia.descrizione ?? ''),
                          );
                        }).toList(),
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
        Uri.parse('${ipaddress}/api/cartadicredito'),
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
      width: 300,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obbligatorio';
          }
          return null;
        },
      ),
    );
  }

  Future<void> getAllTipologieCarta() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/api/tipologiacarta');
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