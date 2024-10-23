import 'package:fema_crm/model/ProdottoModel.dart';
import 'package:fema_crm/pages/MagazzinoPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ModificaDettaglioProdottoPage extends StatefulWidget {
  final ProdottoModel prodotto;

  ModificaDettaglioProdottoPage({Key? key, required this.prodotto})
      : super(key: key);

  @override
  _ModificaDettaglioProdottoPageState createState() =>
      _ModificaDettaglioProdottoPageState();
}

class _ModificaDettaglioProdottoPageState
    extends State<ModificaDettaglioProdottoPage> {
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _tipologiaController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _sottocategoriaController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _fornitoreController = TextEditingController();
  final TextEditingController _codFornitoreController = TextEditingController();
  final TextEditingController _codProdFornitoreController =
      TextEditingController();
  final TextEditingController _qtaGiacenzaController = TextEditingController();
  final TextEditingController _ultimoCostoAcquistoController =
      TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  void initState() {
    super.initState();
    _descrizioneController.text = widget.prodotto.descrizione ?? '';
    _tipologiaController.text = widget.prodotto.tipologia ?? '';
    _categoriaController.text = widget.prodotto.categoria ?? '';
    _sottocategoriaController.text = widget.prodotto.sottocategoria ?? '';
    _noteController.text = widget.prodotto.note ?? '';
    _fornitoreController.text = widget.prodotto.fornitore ?? '';
    _codFornitoreController.text = widget.prodotto.cod_fornitore ?? '';
    _codProdFornitoreController.text = widget.prodotto.cod_prod_forn ?? '';
    _qtaGiacenzaController.text =
        widget.prodotto.qta_giacenza?.toString() ?? '';
    _ultimoCostoAcquistoController.text =
        widget.prodotto.ultimo_costo_acquisto?.toString() ?? '';

    // Controllo se il valore è null e imposto il placeholder a "0.0" in caso positivo
    if (_qtaGiacenzaController.text.isEmpty) {
      _qtaGiacenzaController.text = '0.0';
    }
    if (_ultimoCostoAcquistoController.text.isEmpty) {
      _ultimoCostoAcquistoController.text = '0.0';
    }
  }

  Future<http.Response> updateProdotto() async {
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse('$ipaddress/api/prodotto'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: json.encode({
          'id': widget.prodotto.id,
          'codice_danea': widget.prodotto.codice_danea,
          'descrizione': _descrizioneController.text.toString(),
          'tipologia': _tipologiaController.text.toString(),
          'categoria': _categoriaController.text.toString(),
          'sottocategoria': _sottocategoriaController.text.toString(),
          'unita_misura': widget.prodotto.unita_misura,
          'iva': widget.prodotto.iva,
          'note': _noteController.text.toString(),
          'cod_barre_danea': widget.prodotto.cod_barre_danea,
          'produttore': widget.prodotto.produttore,
          'cod_fornitore': _codFornitoreController.text.toString(),
          'fornitore': _fornitoreController.text.toString(),
          'cod_prod_forn': _codProdFornitoreController.text.toString(),
          'prezzo_fornitore': widget.prodotto.prezzo_fornitore,
          'note_fornitura': widget.prodotto.note_fornitura,
          'qta_giacenza': double.parse(_qtaGiacenzaController.text),
          'qta_impegnata': widget.prodotto.qta_impegnata,
          'ultimo_costo_acquisto':
              double.parse(_ultimoCostoAcquistoController.text),
          'prezzo_medio_vendita': widget.prodotto.prezzo_medio_vendita,
          'lotto_seriale': widget.prodotto.lotto_seriale,
          'preventivi': widget.prodotto.preventivi,
          'sopralluoghi': widget.prodotto.sopralluoghi,
          'relazioni_ddt': widget.prodotto.relazioni_ddt
        }),
      );
      if (response.statusCode == 201) {
        print("Prodotto modificato correttamente!");
      } else {
        print("C'è qualcosa che non va!");
      }
    } catch (e) {
      print("Errore!!!---> ${e.toString()}");
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          'Modifica prodotto - ${widget.prodotto.codice_danea}',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descrizioneController,
                decoration: InputDecoration(
                  labelText: 'Descrizione',
                  hintText: 'Descrizione',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _tipologiaController,
                decoration: InputDecoration(
                  labelText: 'Tipologia',
                  hintText: 'Tipologia',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _categoriaController,
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  hintText: 'Categoria',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _sottocategoriaController,
                decoration: InputDecoration(
                  labelText: 'Sottocategoria',
                  hintText: 'Sottocategoria',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  hintText: 'Note',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _fornitoreController,
                decoration: InputDecoration(
                  labelText: 'Fornitore',
                  hintText: 'Fornitore',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _codFornitoreController,
                decoration: InputDecoration(
                  labelText: 'Codice Fornitore',
                  hintText: 'Codice Fornitore',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _codProdFornitoreController,
                decoration: InputDecoration(
                  labelText: 'Codice Prodotto Fornitore',
                  hintText: 'Codice Prodotto Fornitore',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _qtaGiacenzaController,
                decoration: InputDecoration(
                  labelText: 'Quantità Giacenza',
                  hintText: 'Quantità Giacenza',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _ultimoCostoAcquistoController,
                decoration: InputDecoration(
                  labelText: 'Ultimo Costo Acquisto',
                  hintText: 'Ultimo Costo Acquisto',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  updateProdotto();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MagazzinoPage()));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
                child: Text(
                  'Salva modifiche',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
