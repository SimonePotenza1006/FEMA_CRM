import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NuovaDestinazionePage extends StatefulWidget {
  final ClienteModel cliente;

  const NuovaDestinazionePage({Key? key1, required this.cliente})
      : super(key: key1);

  @override
  _NuovaDestinazionePageState createState() => _NuovaDestinazionePageState();
}

class _NuovaDestinazionePageState extends State<NuovaDestinazionePage> {
  final _formKey = GlobalKey<FormState>();
  final _denominazioneController = TextEditingController();
  final _indirizzoController = TextEditingController();
  final _capController = TextEditingController();
  final _cittaController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _codiceFiscaleController = TextEditingController();
  final _partitaIvaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _cellulareController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';

  DbHelper? dbHelper;
  bool isLoading = true;

  @override
  void initState() {
    dbHelper = DbHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
              'Aggiungi destinazione al cliente ${widget.cliente.denominazione}',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTextFormField(_denominazioneController, 'Denominazione', 'Inserisci una denominazione'),
                    SizedBox(height: 15,),
                    _buildTextFormField(_indirizzoController, 'Indirizzo', 'Inserisci un indirizzo'),
                    SizedBox(height: 15,),
                    _buildTextFormField(_capController, 'CAP', 'Inserisci un CAP'),
                    SizedBox(height: 15,),
                    _buildTextFormField(_cittaController, 'Città', 'Inserisci una città'),
                    SizedBox(height: 15,),
                    _buildTextFormField(_provinciaController, 'Provincia (Solo la sigla)', 'Inserisci una provincia'),
                    SizedBox(height: 15,),
                    _buildTextFormField(_codiceFiscaleController, 'Codice Fiscale', 'Inserisci un codice fiscale'),
                    SizedBox(height: 15,),
                    _buildTextFormField(_partitaIvaController, 'Partita IVA', 'Inserisci una partita IVA'),
                    SizedBox(height: 15,),
                    _buildTextFormField(_telefonoController, 'Telefono', 'Inserisci un numero di telefono'),
                    SizedBox(height: 15,),
                    _buildTextFormField(_cellulareController, 'Cellulare', 'Inserisci un numero di cellulare'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final denominazione = _denominazioneController.text;
                          final indirizzo = _indirizzoController.text;
                          final cap = _capController.text;
                          final citta = _cittaController.text;
                          final provincia = _provinciaController.text;
                          final codice_fiscale = _codiceFiscaleController.text;
                          final partita_iva = _partitaIvaController.text;
                          final telefono = _telefonoController.text;
                          final cellulare = _cellulareController.text;
                          final cliente = widget.cliente;
                          createNewDestinazione(
                              denominazione,
                              indirizzo,
                              cap,
                              citta,
                              provincia,
                              codice_fiscale,
                              partita_iva,
                              telefono,
                              cellulare,
                              cliente);
                        }
                      },
                      child: Text('Salva',
                          style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                      ),
                    )
                  ],
                ),
              )
            )));
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText) {
    return SizedBox(
      width: 500,
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

  Future<void> createNewDestinazione(
      String denominazione,
      String indirizzo,
      String cap,
      String citta,
      String provincia,
      String codice_fiscale,
      String partita_iva,
      String telefono,
      String cellulare,
      ClienteModel cliente) async {
    print('${widget.cliente}');
    final url = Uri.parse('$ipaddress2/api/destinazione');
    final body = jsonEncode({
      'denominazione': denominazione,
      'indirizzo': indirizzo,
      'cap': cap,
      'citta': citta,
      'provincia': provincia,
      'codice_fiscale': codice_fiscale,
      'partita_iva': partita_iva,
      'telefono': telefono,
      'cellulare': cellulare,
      'cliente': widget.cliente,
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        print('Destinazione aggiunta con successo!');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Destinazione creata!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
      } else {
        throw Exception('Errore durante la creazione della destinazione');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }
}
