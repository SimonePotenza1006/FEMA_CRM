import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/pages/AggiuntaNotaByTecnicoPage.dart';
import 'package:flutter/material.dart';
import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/ProdottoModel.dart';
import 'CreazioneScadenzaPage.dart';
import 'SalvataggioCredenzialiClientePage.dart';

class DettaglioMerceInRiparazioneByTecnicoPage extends StatefulWidget {
  final InterventoModel intervento;
  final MerceInRiparazioneModel merce;

  DettaglioMerceInRiparazioneByTecnicoPage({Key? key, required this.intervento, required this.merce}) : super(key: key);

  @override
  _DettaglioMerceInRiparazioneByTecnicoPageState createState() =>
      _DettaglioMerceInRiparazioneByTecnicoPageState();
}

class _DettaglioMerceInRiparazioneByTecnicoPageState
    extends State<DettaglioMerceInRiparazioneByTecnicoPage> {
  TextEditingController importoPreventivatoController = TextEditingController();
  final TextEditingController diagnosiController = TextEditingController();
  final TextEditingController risoluzioneController = TextEditingController();
  final TextEditingController prodottiInstallatiController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<ProdottoModel> allProdotti = [];
  List<ProdottoModel> filteredProdotti = [];
  List<ProdottoModel> selectedProdotti = [];
  late TextEditingController searchController;
  bool isSearching = false;


  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Cerca prodotti...'.toUpperCase(),
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.black),
      ),
      style: TextStyle(color: Colors.black),
      onChanged: filterProdotti,
    );
  }

  @override
  void initState() {
    super.initState();
    getAllProdotti();
    searchController = TextEditingController();
  }

  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      filteredProdotti = allProdotti; // Ripristina la lista dei prodotti filtrati
    });
  }

  void filterProdotti(String query) {
    final filtered = allProdotti.where((prodotto) {
      final descrizione = prodotto.descrizione?.toLowerCase() ?? '';
      final codProdForn = prodotto.cod_prod_forn?.toLowerCase() ?? '';
      final codiceDanea = prodotto.codice_danea?.toLowerCase() ?? '';
      final lottoSeriale = prodotto.lotto_seriale?.toLowerCase() ?? '';
      final categoria = prodotto.categoria?.toUpperCase() ?? '';
      return descrizione.contains(query.toLowerCase()) ||
          codProdForn.contains(query.toLowerCase()) ||
          codiceDanea.contains(query.toLowerCase()) ||
          lottoSeriale.contains(query.toLowerCase()) ||
          categoria.contains(query.toUpperCase());
    }).toList();
    setState(() {
      filteredProdotti = filtered;
    });
  }

  Future<void> getAllProdotti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/prodotto'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<ProdottoModel> prodotti = [];
        for (var item in jsonData) {
          prodotti.add(ProdottoModel.fromJson(item));
        }
        setState(() {
          allProdotti = prodotti;
          filteredProdotti = prodotti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio Merce in Riparazione',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Wrap(
          children:[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(title:'Data arrivo', value: widget.intervento.data != null ? DateFormat('dd/MM/yyyy  HH:mm').format(widget.intervento.merce!.data!) : '', context: context),
                      _buildDetailRow(title: 'Presa in carico', value: widget.merce.data_presa_in_carico != null ? DateFormat('dd/MM/yyyy  HH:mm').format(widget.merce.data_presa_in_carico!) : "NESSUNA DATA", context: context),
                      _buildDetailRow(title:'Articolo', value: widget.intervento.merce?.articolo ?? '', context: context),
                      _buildDetailRow(title:'Accessori', value: widget.intervento.merce?.accessori ?? '', context: context),
                      _buildDetailRow(title:'Difetto Riscontrato', value: widget.intervento.merce?.difetto_riscontrato ?? '', context: context),
                      //_buildDetailRotitle:w('Data Presa in Carico:', widget.merce.data_presa_in_carico != null ? DateFormat('dd/MM/yyyy').format(widget.merce.data_presa_in_carico!) : ''),
                      _buildDetailRow(title:'Password', value: widget.intervento.merce?.password ?? '', context: context),
                      _buildDetailRow(title:'Dati', value: widget.intervento.merce?.dati ?? '', context: context),
                      _buildDetailRow(title:'Preventivo', value: widget.intervento.merce?.preventivo != null ? (widget.intervento.merce!.preventivo! ? 'Richiesto' : 'non richiesto') : '', context: context),
                      if (widget.merce.preventivo != null && widget.merce.preventivo == true)
                        SizedBox(
                          child: Column(
                            children: [
                              _buildDetailRow(title: "prezzo preventivato", value: widget.merce.importo_preventivato != null ? widget.merce.importo_preventivato!.toStringAsFixed(2) : "Non Inserito", context: context),
                              SizedBox(
                                  width: 500,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 210,
                                        child: TextFormField(
                                          controller: importoPreventivatoController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Importo Preventivato'.toUpperCase(),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          if(importoPreventivatoController.text.isNotEmpty){
                                            saveImportoPreventivo();
                                          } else{
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Non puoi salvare un preventivo nullo!'),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.red,
                                          onPrimary: Colors.white,
                                        ),
                                        child: Text('Salva importo Preventivo'.toUpperCase()),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 20),
                      _buildDetailRow(title:'Diagnosi', value:widget.intervento.merce?.diagnosi ?? 'N/A', context: context),
                      SizedBox(
                        width: 500,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 250,
                              child: TextFormField(
                                controller: diagnosiController,
                                decoration: InputDecoration(
                                  labelText: 'Diagnosi'.toUpperCase(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                maxLines: null,
                              ),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                if(diagnosiController.text.isNotEmpty){
                                  saveDiagnosi();
                                } else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Non puoi salvare una diagnosi nulla!'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                onPrimary: Colors.white,
                              ),
                              child: Text('Salva diagnosi'.toUpperCase()),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20,),
                      _buildDetailRow(title: 'Risoluzione', value: widget.intervento.merce?.risoluzione ?? 'N/A', context: context),
                      SizedBox(
                        width: 500,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 250,
                              child: TextFormField(
                                controller: risoluzioneController,
                                decoration: InputDecoration(
                                  labelText: 'Risoluzione'.toUpperCase(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                maxLines: null,
                              ),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                if(risoluzioneController.text.isNotEmpty){
                                  saveRisoluzione();
                                } else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Non puoi salvare una risoluzione nulla!'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                onPrimary: Colors.white,
                              ),
                              child: Text('Salva risoluzione'.toUpperCase()),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
                      _buildDetailRow(title: 'Prodotti Installati', value: widget.intervento.merce?.prodotti_installati ?? 'N/A', context: context),
                      SizedBox(
                        width: 500,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 250,
                              child: TextFormField(
                                controller: prodottiInstallatiController,
                                decoration: InputDecoration(
                                  labelText: 'Prodotti installati'.toUpperCase(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                maxLines: null,
                              ),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                if(prodottiInstallatiController.text.isNotEmpty){
                                  saveProdotti();
                                } else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Non puoi salvare dei prodotti nulli!'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                onPrimary: Colors.white,
                              ),
                              child: Text('Salva prodotti'.toUpperCase()),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(height: 12),
                      Center(
                        child: Text('SELEZIONARE I PRODOTTI INSTALLATI SE PRESENTI IN MAGAZZINO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: 500,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSearchField(),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.search),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: 500,
                        height: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                          color: Colors.white
                        ),
                        child: FutureBuilder<List<ProdottoModel>>(
                          future: Future.value(allProdotti),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Errore: ${snapshot.error}'));
                            } else if (snapshot.hasData) {
                              List<ProdottoModel> prodotti = filteredProdotti;
                              return ListView.builder(
                                itemCount: prodotti.length,
                                itemBuilder: (context, index) {
                                  ProdottoModel prodotto = prodotti[index];
                                  final isSelected = selectedProdotti.contains(prodotto);

                                  return CheckboxListTile(
                                    title: Text(prodotto.descrizione!.toUpperCase()),
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          // Aggiungi prodotto se selezionato
                                          selectedProdotti.add(prodotto);
                                        } else {
                                          // Rimuovi prodotto se deselezionato
                                          selectedProdotti.remove(prodotto);
                                        }
                                      });
                                    },
                                  );
                                },
                              );
                            } else {
                              return const Center(child: Text('Nessun prodotto nello storico'));
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      if(selectedProdotti.isNotEmpty)
                        SizedBox(
                          width: 400,
                          child: ListaPuntataProdotti(selectedProdotti: selectedProdotti),
                        ),
                      SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: 200,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                saveRelazioni().whenComplete(() =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Prodotti aggiunti correttamente alla riparazione'),
                                    ),
                                  )
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                onPrimary: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text('salva'.toUpperCase()),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      consegna();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('merce consegnata'.toUpperCase()),
                  ),
                ),
              ],
            )
          ]
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              children: [
                SpeedDialChild(
                  child: Icon(Icons.password, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Salva credenziali'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalvataggioCredenzialiClientePage(cliente: widget.intervento.cliente!, utente: widget.intervento.utente!),
                    ),
                  ),
                ),
                SpeedDialChild(
                  child: Icon(Icons.edit, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Lascia una nota'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AggiuntaNotaByTecnicoPage(intervento: widget.intervento, utente: widget.intervento.utente!,),
                    ),
                  ),
                ),
                SpeedDialChild(
                  child: Icon(Icons.lock_clock_outlined, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Crea scadenza'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreazioneScadenzaPage(intervento: widget.intervento, cliente: widget.intervento.cliente!,),
                    ),
                  ),
                ),
                if(widget.merce.data_presa_in_carico == null)
                  SpeedDialChild(
                    child: Icon(Icons.settings, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: "Inizia riparazione".toUpperCase(),
                    onTap: () => presaInCarico(),
                  ),
                if(widget.merce.preventivo == true && widget.merce.data_comunica_preventivo == null)
                  SpeedDialChild(
                    child: Icon(Icons.contact_phone_outlined, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: "Preventivo comunicato".toUpperCase(),
                    onTap: () => comunicazionePreventivo(),
                  ),
                if(widget.merce.data_comunica_preventivo != null && widget.merce.data_accettazione_preventivo == null)
                  SpeedDialChild(
                    child: Icon(Icons.check_circle_outlined, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: "Preventivo accettato".toUpperCase(),
                    onTap: () => accettazionePreventivo(),
                  ),
                if(widget.merce.data_conclusione == null)
                  SpeedDialChild(
                    child: Icon(Icons.check_circle_outlined, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: "Concludi riparazione".toUpperCase(),
                    onTap: () {
                      concludi();
                      saveStatusIntervento();
                    }
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> saveRelazioni() async{
    try{
      for(var prodotto in selectedProdotti){
        try{
          final response = await http.post(
            Uri.parse('$ipaddress/api/relazioneProdottoIntervento'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'prodotto' : prodotto,
              'intervento' : widget.intervento.toMap(),
              'presenza_storico_utente' : true,
            })
          );
        } catch(e){
          print('1 Qualcosa non va:$e');
        }
      }
      setState(() {
        selectedProdotti.clear();
      });
    } catch(e){
      print('2 Qualcosa non va:$e');
    }
  }


  Future<void> accettazionePreventivo() async {
    try {
      String? dataPresaInCarico = widget.merce.data_presa_in_carico != null ? widget.merce.data_presa_in_carico!.toIso8601String() : null;
      String? dataComunicazionePreventivo = widget.merce.data_comunica_preventivo != null ? widget.merce.data_comunica_preventivo!.toIso8601String() : null;
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;
      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'presenza_magazzino' : widget.merce.presenza_magazzino,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': widget.merce.importo_preventivato,
          'data_comunica_preventivo' : dataComunicazionePreventivo,
          'preventivo_accettato' : widget.merce.preventivo_accettato,
          'data_accettazione_preventivo' : DateTime.now().toIso8601String(),
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'prodotti_installati': widget.merce.prodotti_installati,
          'data_consegna': dataConsegna,
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Il preventivo è stato accettato!'),
        ),
      );
      setState(() {
        widget.merce.data_accettazione_preventivo= DateTime.now();
      });
    } catch (e) {
      print('Errore durante il salvataggio dell\'importo preventivato: $e');
    }
  }

  Future<void> consegna() async{
    try{
      String? dataPresaInCarico = widget.merce.data_presa_in_carico != null ? widget.merce.data_presa_in_carico!.toIso8601String() : null;
      String? dataComunicazionePreventivo = widget.merce.data_comunica_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataAccettazionePreventivo = widget.merce.data_accettazione_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;
      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'presenza_magazzino' : widget.merce.presenza_magazzino,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': widget.merce.importo_preventivato,
          'data_comunica_preventivo' : dataComunicazionePreventivo,
          'preventivo_accettato' : widget.merce.preventivo_accettato,
          'data_accettazione_preventivo' : dataAccettazionePreventivo,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'prodotti_installati': widget.merce.prodotti_installati,
          'data_consegna': DateTime.now().toIso8601String(),
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Merce consegnata!'),
        ),
      );
      setState(() {
        widget.merce.data_consegna= DateTime.now();
      });
    } catch(e){

    }
  }

  Future<void> saveProdotti() async{
    try{
      String? dataPresaInCarico = widget.merce.data_presa_in_carico != null ? widget.merce.data_presa_in_carico!.toIso8601String() : null;
      String? dataComunicazionePreventivo = widget.merce.data_comunica_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataAccettazionePreventivo = widget.merce.data_accettazione_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;

      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'presenza_magazzino' : widget.merce.presenza_magazzino,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': widget.merce.importo_preventivato,
          'data_comunica_preventivo' : dataComunicazionePreventivo,
          'preventivo_accettato' : widget.merce.preventivo_accettato,
          'data_accettazione_preventivo' : dataAccettazionePreventivo,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'prodotti_installati': prodottiInstallatiController.text,
          'data_consegna': dataConsegna,
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prodotti utilizzati salvati con successo!'),
        ),
      );
      setState(() {
        widget.merce.prodotti_installati = prodottiInstallatiController.text;
      });
    } catch(e){

    }
  }

  Future<void> saveRisoluzione() async{
    try{
      String? dataPresaInCarico = widget.merce.data_presa_in_carico != null ? widget.merce.data_presa_in_carico!.toIso8601String() : null;
      String? dataComunicazionePreventivo = widget.merce.data_comunica_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataAccettazionePreventivo = widget.merce.data_accettazione_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;
      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'presenza_magazzino' : widget.merce.presenza_magazzino,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': widget.merce.importo_preventivato,
          'data_comunica_preventivo' : dataComunicazionePreventivo,
          'preventivo_accettato' : widget.merce.preventivo_accettato,
          'data_accettazione_preventivo' : dataAccettazionePreventivo,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': risoluzioneController.text,
          'data_conclusione': dataConclusione,
          'prodotti_installati': widget.merce.prodotti_installati,
          'data_consegna': dataConsegna,
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Risoluzione salvata con successo!'),
        ),
      );
      setState(() {
        widget.merce.risoluzione = risoluzioneController.text;
      });
    } catch(e){

    }
  }

  Future<void> saveDiagnosi() async{
    try{
      String? dataPresaInCarico = widget.merce.data_presa_in_carico != null ? widget.merce.data_presa_in_carico!.toIso8601String() : null;
      String? dataComunicazionePreventivo = widget.merce.data_comunica_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataAccettazionePreventivo = widget.merce.data_accettazione_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;
      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'presenza_magazzino' : widget.merce.presenza_magazzino,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': widget.merce.importo_preventivato,
          'data_comunica_preventivo' : dataComunicazionePreventivo,
          'preventivo_accettato' : widget.merce.preventivo_accettato,
          'data_accettazione_preventivo' : dataAccettazionePreventivo,
          'diagnosi': diagnosiController.text,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'prodotti_installati': widget.merce.prodotti_installati,
          'data_consegna': dataConsegna,
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diagnosi salvata'),
        ),
      );
      setState(() {
        widget.merce.diagnosi = diagnosiController.text;
      });
    } catch(e){

    }
  }

  Future<void> saveImportoPreventivo() async {
    try {
      // Ottieni la data attuale come stringa ISO 8601
      String? dataPresaInCarico = widget.merce.data_presa_in_carico != null ? widget.merce.data_presa_in_carico!.toIso8601String() : null;
      String? dataComunicazionePreventivo = widget.merce.data_comunica_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataAccettazionePreventivo = widget.merce.data_accettazione_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;
      // Verifica se 'data_consegna' è null e converte in stringa ISO 8601 se necessario
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;
      double? importo = double.parse(importoPreventivatoController.text);
      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'presenza_magazzino' : widget.merce.presenza_magazzino,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': importo,
          'data_comunica_preventivo' : dataComunicazionePreventivo,
          'preventivo_accettato' : widget.merce.preventivo_accettato,
          'data_accettazione_preventivo' : dataAccettazionePreventivo,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'prodotti_installati': widget.merce.prodotti_installati,
          'data_consegna': dataConsegna,
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Importo preventivato salvato'),
        ),
      );
      setState(() {
        widget.merce.importo_preventivato = importo;
      });
    } catch (e) {
      print('Errore durante il salvataggio dell\'importo preventivato: $e');
    }
  }

  Future<void> comunicazionePreventivo() async {
    try {
      // Ottieni la data attuale come stringa ISO 8601
      String? dataPresaInCarico = widget.merce.data_presa_in_carico != null ? widget.merce.data_presa_in_carico!.toIso8601String() : null;
      String? dataComunicazionePreventivo = widget.merce.data_comunica_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataAccettazionePreventivo = widget.merce.data_accettazione_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;
      // Verifica se 'data_consegna' è null e converte in stringa ISO 8601 se necessario
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;
      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'presenza_magazzino' : widget.merce.presenza_magazzino,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': widget.merce.importo_preventivato,
          'data_comunica_preventivo' : DateTime.now().toIso8601String(),
          'preventivo_accettato' : widget.merce.preventivo_accettato,
          'data_accettazione_preventivo' : dataAccettazionePreventivo,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'prodotti_installati': widget.merce.prodotti_installati,
          'data_consegna': dataConsegna,
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data comunicazione preventivo salvata con successo!'),
        ),
      );
      setState(() {
        widget.merce.data_comunica_preventivo = DateTime.now();
      });
    } catch (e) {
      print('Errore durante il salvataggio dell\'importo preventivato: $e');
    }
  }

  Future<void> presaInCarico() async{
    MerceInRiparazioneModel merce = widget.merce;
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': merce.id,
          'data': merce.data?.toIso8601String(),
          'articolo': merce.articolo,
          'accessori' : merce.accessori,
          'difetto_riscontrato' : merce.difetto_riscontrato,
          'data_presa_in_carico' : DateTime.now().toIso8601String(),
          'password': merce.password,
          'dati' : merce.dati,
          'presenza_magazzino' : false,
          'preventivo' : merce.preventivo,
          'importo_preventivato' : merce.importo_preventivato,
          'data_comunica_preventivo' : merce.data_comunica_preventivo?.toIso8601String(),
          'preventivo_accettato' : merce.preventivo_accettato,
          'data_accettazione_preventivo' : merce.data_accettazione_preventivo?.toIso8601String(),
          'diagnosi' : merce.diagnosi,
          'risoluzione' : merce.risoluzione,
          'data_conclusione' : merce.data_conclusione?.toIso8601String(),
          'prodotti_installati' : merce.prodotti_installati,
          'data_consegna' : merce.data_consegna?.toIso8601String(),
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merce in riparazione presa in carico!'),
          ),
        );
        setState(() {
          widget.merce.data_presa_in_carico = DateTime.now();
        });
      }
    } catch(e){
      print('Qualcosa non va nella presa in carico : $e');
    }
  }

  Widget _buildDetailRow({required String title, required String value, BuildContext? context}) {
    bool isValueTooLong = value.length > 25;
    String displayedValue = isValueTooLong ? value.substring(0, 25) + "..." : value;
    return SizedBox(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4, // Linea di accento colorata
                      height: 24,
                      color: Colors.redAccent, // Colore di accento per un tocco di vivacità
                    ),
                    SizedBox(width: 10),
                    Text(
                      title.toUpperCase() + ": ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Colore contrastante per il testo
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        displayedValue.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold, // Un colore secondario per differenziare il valore
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isValueTooLong && context != null)
                        IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("${title.toUpperCase()}"),
                                  content: Text(value),
                                  actions: [
                                    TextButton(
                                      child: Text("Chiudi"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Divider( // Linea di separazione tra i widget
              color: Colors.grey[400],
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveStatusIntervento() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id,
          'numerazione_danea' : widget.intervento.numerazione_danea,
          'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : widget.intervento.posizione_gps,
          'orario_inizio': widget.merce.data_presa_in_carico?.toIso8601String(),
          'orario_fine': DateTime.now().toIso8601String(),
          'descrizione': widget.intervento.descrizione,
          'importo_intervento': null,
          'prezzo_ivato' : widget.intervento.prezzo_ivato,
          'iva' : widget.intervento.iva,
          'acconto' : widget.intervento.acconto,
          'assegnato': widget.intervento.assegnato,
          'accettato_da_tecnico' : widget.intervento.accettato_da_tecnico,
          'conclusione_parziale' : false,
          'concluso': true,
          'saldato': widget.intervento.saldato,
          'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
          'note': widget.intervento.note,
          'relazione_tecnico' : widget.merce.risoluzione,
          'firma_cliente' : widget.intervento.firma_cliente,
          'utente': widget.intervento.utente?.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'merce' : widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap(),
          'gruppo' : widget.intervento.gruppo
        })
      );
      print(jsonDecode(response.body));
      InterventoModel intervento = InterventoModel.fromJson(jsonDecode(response.body));
      print(intervento.toString());
    } catch(e){
      print('Errore durante il salvataggio: $e');
    }
  }

  Future<void> concludi() async {
    try {
      String? dataPresaInCarico = widget.merce.data_presa_in_carico != null ? widget.merce.data_presa_in_carico!.toIso8601String() : null;
      String? dataComunicazionePreventivo = widget.merce.data_comunica_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataAccettazionePreventivo = widget.merce.data_accettazione_preventivo != null ? widget.merce.data_accettazione_preventivo!.toIso8601String() : null;
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;
      // Verifica se 'data_consegna' è null e converte in stringa ISO 8601 se necessario
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;
      final response = await http.post(
        Uri.parse('${ipaddress}/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.merce?.id,
          'data': widget.intervento.merce?.data?.toIso8601String(), // Converti data in stringa ISO 8601
          'articolo': widget.intervento.merce?.articolo,
          'accessori': widget.intervento.merce?.accessori,
          'difetto_riscontrato': widget.intervento.merce?.difetto_riscontrato,
          'data_presa_in_carico': dataPresaInCarico,
          'password': widget.intervento.merce?.password,
          'dati': widget.intervento.merce?.dati,
          'presenza_magazzino' : widget.intervento.merce?.presenza_magazzino,
          'preventivo': widget.intervento.merce?.preventivo,
          'importo_preventivato': widget.intervento.merce?.importo_preventivato,
          'data_comunica_preventivo' : dataComunicazionePreventivo,
          'preventivo_accettato' : widget.merce.preventivo_accettato,
          'data_accettazione_preventivo' : dataAccettazionePreventivo,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': DateTime.now().toIso8601String(),
          'prodotti_installati': widget.merce.prodotti_installati,
          'data_consegna': dataConsegna,
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La riparazione è conclusa!'),
        ),
      );
      setState(() {
        widget.merce.data_conclusione= DateTime.now();
      });
    } catch (e) {
      print('Errore $e');
    }
  }

}

class ListaPuntataProdotti extends StatelessWidget {
  final List<ProdottoModel> selectedProdotti;

  ListaPuntataProdotti({required this.selectedProdotti});

  @override
  Widget build(BuildContext context) {
    // Se la lista dei prodotti selezionati è vuota, restituiamo un messaggio
    if (selectedProdotti.isEmpty) {
      return const Text('Nessun prodotto selezionato');
    }

    // Creiamo una colonna con i testi puntati
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: selectedProdotti.map((prodotto) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            '• ${prodotto.descrizione}',
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }
}

