import 'dart:convert';
import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/ClienteModel.dart';

class ModificaClientePage extends StatefulWidget {
  final ClienteModel cliente;

  const ModificaClientePage({Key? key, required this.cliente})
      : super(key: key);

  @override
  _ModificaClientePageState createState() => _ModificaClientePageState();
}

class _ModificaClientePageState extends State<ModificaClientePage> {
  late TextEditingController _codiceFiscaleController;
  late TextEditingController _partitaIvaController;
  late TextEditingController _denominazioneController;
  late TextEditingController _indirizzoController;
  late TextEditingController _capController;
  late TextEditingController _cittaController;
  late TextEditingController _provinciaController;
  late TextEditingController _nazioneController;
  late TextEditingController _fatturazioneElettronicaController;
  late TextEditingController _riferimentoAmministrativoController;
  late TextEditingController _referenteController;
  late TextEditingController _faxController;
  late TextEditingController _telefonoController;
  late TextEditingController _cellulareController;
  late TextEditingController _emailController;
  late TextEditingController _pecController;
  late TextEditingController _noteController;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  io.File? selectedFile;

  @override
  void initState() {
    super.initState();
    _codiceFiscaleController =
        TextEditingController(text: widget.cliente.codice_fiscale);
    _partitaIvaController =
        TextEditingController(text: widget.cliente.partita_iva);
    _denominazioneController =
        TextEditingController(text: widget.cliente.denominazione);
    _indirizzoController =
        TextEditingController(text: widget.cliente.indirizzo);
    _capController = TextEditingController(text: widget.cliente.cap);
    _cittaController = TextEditingController(text: widget.cliente.citta);
    _provinciaController =
        TextEditingController(text: widget.cliente.provincia);
    _nazioneController = TextEditingController(text: widget.cliente.nazione);
    _fatturazioneElettronicaController = TextEditingController(
        text: widget.cliente.recapito_fatturazione_elettronica);
    _riferimentoAmministrativoController =
        TextEditingController(text: widget.cliente.riferimento_amministrativo);
    _referenteController =
        TextEditingController(text: widget.cliente.referente);
    _faxController = TextEditingController(text: widget.cliente.fax);
    _telefonoController = TextEditingController(text: widget.cliente.telefono);
    _cellulareController =
        TextEditingController(text: widget.cliente.cellulare);
    _emailController = TextEditingController(text: widget.cliente.email);
    _pecController = TextEditingController(text: widget.cliente.pec);
    _noteController = TextEditingController(text: widget.cliente.note);
  }

  @override
  void dispose() {
    _codiceFiscaleController.dispose();
    _partitaIvaController.dispose();
    _denominazioneController.dispose();
    _indirizzoController.dispose();
    _capController.dispose();
    _cittaController.dispose();
    _provinciaController.dispose();
    _nazioneController.dispose();
    _fatturazioneElettronicaController.dispose();
    _riferimentoAmministrativoController.dispose();
    _referenteController.dispose();
    _faxController.dispose();
    _telefonoController.dispose();
    _cellulareController.dispose();
    _emailController.dispose();
    _pecController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Cliente', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTextField('Codice Fiscale', _codiceFiscaleController),
              _buildTextField('Partita IVA', _partitaIvaController),
              _buildTextField('Denominazione', _denominazioneController),
              _buildTextField('Indirizzo', _indirizzoController),
              _buildTextField('Cap', _capController),
              _buildTextField('Città', _cittaController),
              _buildTextField('Provincia', _provinciaController),
              _buildTextField('Nazione', _nazioneController),
              _buildTextField('Recapito fatturazione Elettronica', _fatturazioneElettronicaController),
              _buildTextField('Riferimento Amministrativo', _riferimentoAmministrativoController),
              _buildTextField('Referente', _referenteController),
              _buildTextField('Fax', _faxController),
              _buildTextField('Telefono', _telefonoController),
              _buildTextField('Cellulare', _cellulareController),
              _buildTextField('Email', _emailController),
              _buildTextField('Pec', _pecController),
              _buildTextField('Note', _noteController),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment : MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.attach_file, color: Colors.black,),
                          onPressed: _pickFile,
                          tooltip: 'Seleziona un file',
                        ),
                        SizedBox(width: 5),
                        Text('Seleziona un file')
                      ],
                    ),

                    if(selectedFile != null) // Mostra il nome del file se selezionato
                      Text(
                        'File selezionato: ${selectedFile!.path.split('/').last}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: updateCliente,
                  child: const Text('Salva Modifiche'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          // Salva il file selezionato come un oggetto File
          selectedFile = io.File(result.files.single.path!);
        });
        print("File selezionato: ${selectedFile!.path}");
      } else {
        // L'utente ha annullato la selezione
        print("Nessun file selezionato.");
      }
    } catch (e) {
      print("Errore durante la selezione del file: $e");
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: 400,
        child: TextField(
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

  Future<void> updateCliente() async {
    late http.Response response;

    try {
      // Prima aggiorna il cliente esistente
      response = await http.put(
        Uri.parse('${ipaddress}/api/cliente/${widget.cliente.id}'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: json.encode({
          'id': widget.cliente.id,
          'codice_fiscale': _codiceFiscaleController.text.toString(),
          'partita_iva': _partitaIvaController.text.toString(),
          'denominazione': _denominazioneController.text.toString(),
          'indirizzo': _indirizzoController.text.toString(),
          'cap': _capController.text.toString(),
          'citta': _cittaController.text.toString(),
          'provincia': _provinciaController.text.toString(),
          'nazione': _nazioneController.text.toString(),
          'recapito_fatturazione_elettronica':
          _fatturazioneElettronicaController.text.toString(),
          'riferimento_amministrativo':
          _riferimentoAmministrativoController.text.toString(),
          'referente': _referenteController.text.toString(),
          'fax': _faxController.text.toString(),
          'telefono': _telefonoController.text.toString(),
          'cellulare': _cellulareController.text.toString(),
          'email': _emailController.text.toString(),
          'pec': _pecController.text.toString(),
          'note': _noteController.text.toString(),
          'tipologie_interventi': widget.cliente.tipologie_interventi,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Cliente modificato correttamente!");

        // Ora carica il file selezionato se esiste
        if (selectedFile != null) {
          await uploadFile(selectedFile!);
        }
        Navigator.pop(context);

      } else {
        print("Errore durante la modifica del cliente: ${response.body}");
      }
    } catch (e) {
      print("Errore: $e");
    }
  }

  Future<void> uploadFile(io.File file) async {
    try {
      // Crea una richiesta multipart per l'upload del file
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ipaddress}/pdfu/certificazioni/clienti'),
      );

      // Aggiungi il nome del cliente come parametro
      request.fields['cliente'] = _denominazioneController.text.isNotEmpty ? _denominazioneController.text : widget.cliente.denominazione!;

      // Aggiungi il file come MultipartFile
      request.files.add(
        await http.MultipartFile.fromPath(
          'pdf', // Nome del parametro nel controller
          file.path,
        ),
      );

      // Invia la richiesta
      var response = await request.send();

      if (response.statusCode == 200) {
        print("File caricato con successo!");
      } else {
        print("Errore durante il caricamento del file: ${response.statusCode}");
      }
    } catch (e) {
      print("Errore durante il caricamento del file: $e");
    }
  }
}