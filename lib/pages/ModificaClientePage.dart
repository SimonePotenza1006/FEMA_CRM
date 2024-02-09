import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/ClienteModel.dart';


class ModificaClientePage extends StatefulWidget {
  final ClienteModel cliente;

  const ModificaClientePage({Key? key, required this.cliente}) : super(key: key);

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


  @override
  void initState() {
    super.initState();
    _codiceFiscaleController = TextEditingController(text: widget.cliente.codice_fiscale);
    _partitaIvaController = TextEditingController(text: widget.cliente.partita_iva);
    _denominazioneController = TextEditingController(text: widget.cliente.denominazione);
    _indirizzoController = TextEditingController(text: widget.cliente.indirizzo);
    _capController = TextEditingController(text: widget.cliente.cap);
    _cittaController = TextEditingController(text: widget.cliente.citta);
    _provinciaController = TextEditingController(text: widget.cliente.provincia);
    _nazioneController = TextEditingController(text: widget.cliente.nazione);
    _fatturazioneElettronicaController = TextEditingController(text: widget.cliente.recapito_fatturazione_elettronica);
    _riferimentoAmministrativoController = TextEditingController(text: widget.cliente.riferimento_amministrativo);
    _referenteController = TextEditingController(text: widget.cliente.referente);
    _faxController = TextEditingController(text: widget.cliente.fax);
    _telefonoController = TextEditingController(text: widget.cliente.telefono);
    _cellulareController = TextEditingController(text: widget.cliente.cellulare);
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
        title: const Text('Modifica Cliente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _codiceFiscaleController,
              decoration: const InputDecoration(labelText: 'Codice Fiscale'),
            ),
            TextField(
              controller: _partitaIvaController,
              decoration: const InputDecoration(labelText: 'Partita IVA'),
            ),
            TextField(
              controller: _denominazioneController,
              decoration: const InputDecoration(labelText: 'Denominazione'),
            ),
            TextField(
              controller: _indirizzoController,
              decoration: const InputDecoration(labelText: 'Indirizzo'),
            ),
            TextField(
              controller: _capController,
              decoration: const InputDecoration(labelText: 'Cap'),
            ),
            TextField(
              controller: _cittaController,
              decoration: const InputDecoration(labelText: 'Città'),
            ),
            TextField(
              controller: _provinciaController,
              decoration: const InputDecoration(labelText: 'Provincia'),
            ),
            TextField(
              controller: _nazioneController,
              decoration: const InputDecoration(labelText: 'Nazione'),
            ),
            TextField(
              controller: _fatturazioneElettronicaController,
              decoration: const InputDecoration(labelText: 'Recapito fatturazione Elettronica'),
            ),
            TextField(
              controller: _riferimentoAmministrativoController,
              decoration: const InputDecoration(labelText: 'Riferimento Amministrativo'),
            ),
            TextField(
              controller: _referenteController,
              decoration: const InputDecoration(labelText: 'Referente'),
            ),
            TextField(
              controller: _faxController,
              decoration: const InputDecoration(labelText: 'Fax'),
            ),
            TextField(
              controller: _telefonoController,
              decoration: const InputDecoration(labelText: 'Telefono'),
            ),
            TextField(
              controller: _cellulareController,
              decoration: const InputDecoration(labelText: 'Cellulare'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _pecController,
              decoration: const InputDecoration(labelText: 'Pec'),
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateCliente,
              child: const Text('Salva Modifiche'),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> updateCliente() async {
  //   try {
  //     print('${widget.cliente.tipologie_interventi}');
  //     ClienteModel updatedCliente = ClienteModel(
  //       widget.cliente.id,
  //       _codiceFiscaleController.text,
  //       _partitaIvaController.text,
  //       _denominazioneController.text,
  //       _indirizzoController.text,
  //       _capController.text,
  //       _cittaController.text,
  //       _provinciaController.text,
  //       _nazioneController.text,
  //       _fatturazioneElettronicaController.text,
  //       _riferimentoAmministrativoController.text,
  //       _referenteController.text,
  //       _faxController.text,
  //       _telefonoController.text,
  //       _cellulareController.text,
  //       _emailController.text,
  //       _pecController.text,
  //       _noteController.text,
  //       widget.cliente.tipologie_interventi
  //     );
  //
  //     final response = await http.put(
  //       Uri.parse('http://192.168.1.52:8080/api/cliente/${widget.cliente.id}'),
  //       body: updatedCliente.toJson(),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Cliente aggiornato con successo')),
  //       );
  //       Navigator.pop(context, updatedCliente);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Impossibile aggiornare il cliente')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Errore durante l\'aggiornamento del cliente: $e');
  //   }
  // }
 
Future<http.Response> updateCliente() async {
    late http.Response response;
    try{
      response = await http.put(
        Uri.parse('http://192.168.1.52:8080/api/cliente/${widget.cliente.id}'),
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
          'recapito_fatturazione_elettronica': _fatturazioneElettronicaController.text.toString(),
          'riferimento_amministrativo': _riferimentoAmministrativoController.text.toString(),
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
      if (response.statusCode == 200){
        print("Cliente modificato correttamente!");
      } else {
        print("Hai toppato :(");
        print(response.toString());
      }
    }
    catch(e) {
      print(e.toString());
    }
    return response;
}
}
