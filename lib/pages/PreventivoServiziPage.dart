import 'dart:convert';

import 'package:fema_crm/pages/CreazioneClientePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'dart:io' as io;
import '../model/AziendaModel.dart';
import '../model/ClienteModel.dart';
import '../model/UtenteModel.dart';
import 'package:http/http.dart' as http;

import 'PreventivoServiziPdfPage.dart';

class PreventivoServiziPage extends StatefulWidget{
  final UtenteModel utente;
  final String? path;
  final io.File? file;

  PreventivoServiziPage({Key? key, required this.utente, this.path, this.file}) : super(key: key);

  _PreventivoServiziPageState createState() => _PreventivoServiziPageState();
}

class _PreventivoServiziPageState extends State<PreventivoServiziPage> with WidgetsBindingObserver{
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  final _formKey = GlobalKey<FormState>();
  List<AziendaModel> allAziende = [];
  AziendaModel? selectedAzienda;
  List<Prodotto> prodotti = [];
  List<ClienteModel> allClienti = [];
  List<ClienteModel> filteredClienti = [];
  ClienteModel? selectedCliente;
  double _totaleImponibile = 0.0;
  double _totaleIva = 0.0;
  double _totaleDocumento = 0.0;
  final _conNumeroPreventivo = TextEditingController();
  final _conDataPreventivo = TextEditingController();
  final _conDenomDestinatario = TextEditingController();
  final _conIndirizzoDestinatario = TextEditingController();
  final _conCittaDestinatario = TextEditingController();
  final _conCFDestinatario = TextEditingController();
  final _conDenomDestinazione = TextEditingController();
  final _conIndirizzoDestinazione = TextEditingController();
  final _conCittaDestinazione = TextEditingController();

  void _rimuoviProdotto(){
    setState(() {
      prodotti.removeLast();
    });
  }

  void _aggiungiProdotto() {
    var nuovoProdotto = Prodotto(
      codiceController: TextEditingController(),
      descrizioneController: TextEditingController(),
      quantitaController: TextEditingController(),
      prezzoController: TextEditingController(),
      scontoController: TextEditingController(),
      importoController: TextEditingController(),
      ivaController: TextEditingController(),
    );

    // Aggiungi i listener ai controllori del nuovo prodotto
    nuovoProdotto.codiceController.addListener(_aggiornaTotali);
    nuovoProdotto.descrizioneController.addListener(_aggiornaTotali);
    nuovoProdotto.quantitaController.addListener(_aggiornaTotali);
    nuovoProdotto.prezzoController.addListener(_aggiornaTotali);
    nuovoProdotto.scontoController.addListener(_aggiornaTotali);
    nuovoProdotto.importoController.addListener(_aggiornaTotali);
    nuovoProdotto.ivaController.addListener(_aggiornaTotali);

    setState(() {
      prodotti.add(nuovoProdotto);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text("compilazione preventivo servizi".toUpperCase(), style: TextStyle(color: Colors.white)),
        actions: [
          Row(
            children: [
              PopupMenuButton<AziendaModel>(
                icon: Icon(Icons.warehouse_outlined, color: Colors.white,), // Icona della casa
                onSelected: (AziendaModel azienda) {
                  setState(() {
                    selectedAzienda = azienda;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return allAziende.map((AziendaModel azienda) {
                    return PopupMenuItem<AziendaModel>(
                      value: azienda,
                      child: Text(azienda.nome!),
                    );
                  }).toList();
                },
              ),
              SizedBox(width: 2),
              Text('${selectedAzienda?.nome}', style: TextStyle(color: Colors.white),),
              SizedBox(width: 6)
            ],
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: InteractiveViewer(
            scaleEnabled: false,
            panEnabled: false,
            minScale: 0.1,
            maxScale: 4,
            child: Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Center(
                child: Container(
                  width: 800,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 100,
                            child: Image.asset(
                                "assets/images/logo_no_bg.png"
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Per allineare il testo a sinistra
                                children: [
                                  SizedBox(height: 20),
                                  Text(
                                    '${selectedAzienda != null ? selectedAzienda?.nome : '//'}'.toUpperCase(),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                                  ),
                                  // Aggiungi uno spazio sopra la linea
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 585,
                                        height: 3,
                                        child: Container(
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Sede legale:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      SizedBox(width: 1),
                                      Text('${selectedAzienda?.sede_legale}', style: TextStyle(fontSize: 13),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Sede operativa:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      SizedBox(width: 1),
                                      Text('${selectedAzienda?.luogo_di_lavoro}', style: TextStyle(fontSize: 13),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Tel:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      SizedBox(width: 1),
                                      Text('${selectedAzienda?.telefono}', style: TextStyle(fontSize: 13),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('C.F./P.Iva:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      SizedBox(width: 1),
                                      Text('${selectedAzienda?.partita_iva}', style: TextStyle(fontSize: 13),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Codice SdI:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      SizedBox(width: 1),
                                      Text('${selectedAzienda?.recapito_fatturazione_elettronica}', style: TextStyle(fontSize: 13),),
                                    ],
                                  ),
                                  Text('${selectedAzienda?.sito}', style: TextStyle(fontSize: 13)),
                                  Text('${selectedAzienda?.email}', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Text('Preventivo', style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('n.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400)),
                          SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 40),
                            child: IntrinsicWidth(
                              child: getTextFormFieldSmall(
                                width: 100,
                                controller: _conNumeroPreventivo,
                                inputType: TextInputType.text,
                                hintName: 'Numero contratto *',
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Text('del  ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400)),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 40),
                            child: IntrinsicWidth(
                              child: getTextFormFieldSmall(
                                width: 100,
                                controller: _conDataPreventivo,
                                inputType: TextInputType.text,
                                hintName: 'Numero contratto *',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 360,
                            height: 130,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1
                              )
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Destinatario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text('Denominazione: ', style: TextStyle(fontSize: 12)),
                                      SizedBox(width: 3),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: 40),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 220,
                                            controller: _conDenomDestinatario,
                                            inputType: TextInputType.text,
                                            hintName: 'Numero contratto *',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text('Indirizzo: ', style: TextStyle(fontSize: 12)),
                                      SizedBox(width: 3),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: 40),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 220,
                                            controller: _conIndirizzoDestinatario,
                                            inputType: TextInputType.text,
                                            hintName: 'Numero contratto *',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text('Cap/Città/Provincia: ', style: TextStyle(fontSize: 12)),
                                      SizedBox(width: 3),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: 40),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 220,
                                            controller: _conCittaDestinatario,
                                            inputType: TextInputType.text,
                                            hintName: 'Numero contratto *',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text('C.F./P. Iva: ', style: TextStyle(fontSize: 12)),
                                      SizedBox(width: 3),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: 40),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 250,
                                            controller: _conCFDestinatario,
                                            inputType: TextInputType.text,
                                            hintName: 'Numero contratto *',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 360,
                            height: 130,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black,
                                    width: 1
                                )
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Destinazione', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text('Denominazione: ', style: TextStyle(fontSize: 12)),
                                      SizedBox(width: 3),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: 40),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 220,
                                            controller: _conDenomDestinazione,
                                            inputType: TextInputType.text,
                                            hintName: 'Numero contratto *',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text('Indirizzo: ', style: TextStyle(fontSize: 12)),
                                      SizedBox(width: 3),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: 40),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 220,
                                            controller: _conIndirizzoDestinazione,
                                            inputType: TextInputType.text,
                                            hintName: 'Numero contratto *',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text('Cap/Città/Provincia: ', style: TextStyle(fontSize: 12)),
                                      SizedBox(width: 3),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: 40),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 220,
                                            controller: _conCittaDestinazione,
                                            inputType: TextInputType.text,
                                            hintName: 'Numero contratto *',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height:16),
                      Container(
                        width: double.maxFinite,
                        height: 800,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide.none,
                            right: BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            ),
                            left: BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            ),
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            ),
                          )
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.maxFinite,
                              height: 30,
                              color: Colors.grey.shade200,
                              child: Row(
                                children: [
                                  _buildHeaderCell('Codice', 120),
                                  _buildHeaderCell('Descrizione', 270),
                                  _buildHeaderCell('Quantità', 60),
                                  _buildHeaderCell('Prezzo', 120),
                                  _buildHeaderCell('Sconto', 60),
                                  _buildHeaderCell('Importo', 120),
                                  _buildHeaderCell('IVA', 47),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: prodotti.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildTableCell(prodotti[index].codiceController, 120, 1, 1, TextInputType.text),  // Campo "Codice" sempre di 1 riga
                                      _buildTableCell(prodotti[index].descrizioneController, 270, 1, 5, TextInputType.text),  // Campo "Descrizione" che cresce fino a 5 righe
                                      _buildTableCell(prodotti[index].quantitaController, 60, 1, 1, TextInputType.number),  // Campo "Quantità"
                                      _buildTableCell(prodotti[index].prezzoController, 120, 1, 1, TextInputType.number),  // Campo "Prezzo"
                                      _buildTableCell(prodotti[index].scontoController, 60, 1, 1, TextInputType.number),  // Campo "Sconto"
                                      _buildTableCell(prodotti[index].importoController, 120, 1, 1, TextInputType.number),  // Campo "Importo"
                                      _buildTableCell(prodotti[index].ivaController, 48, 1, 1, TextInputType.number),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 400,
                            height: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20),
                                    Text('Modalità di pagamento', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 80),
                                    Text('Tutti i prezzi indicati hanno validità 10 giorni', style: TextStyle(fontWeight: FontWeight.bold),)

                                  ],
                                ),
                                Column(
                                  children: [
                                    SizedBox(height: 20),
                                    Text('Acconto', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 150,
                            width: 350,
                            color: Colors.grey.shade200,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Tot. imponibile',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${_totaleImponibile.toStringAsFixed(2)}€', // Totale imponibile
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Tot. Iva',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${_totaleIva.toStringAsFixed(2)}€', // Totale IVA
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 60),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Tot. documento',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      Text(
                                        '${_totaleDocumento.toStringAsFixed(2)}€', // Totale documento
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
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
                  child: Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Genera pdf'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreventivoServiziPdfPage(utente : widget.utente,
                          azienda: selectedAzienda!,
                          servizi: estraiServizi(),
                          totaleImponibile: _totaleImponibile.toStringAsFixed(2),
                          totaleIva: _totaleIva.toStringAsFixed(2),
                          totaleDocumento: _totaleDocumento.toStringAsFixed(2),
                          numeroPreventivo: _conNumeroPreventivo.text.isNotEmpty ? _conNumeroPreventivo.text : "//",
                          dataPreventivo: _conDataPreventivo.text.isNotEmpty ? _conDataPreventivo.text : null,
                          denomDestinatario: _conDenomDestinatario.text.isNotEmpty ? _conDenomDestinatario.text : null,
                          denomDestinazione: _conDenomDestinazione.text.isNotEmpty ? _conDenomDestinazione.text : null,
                          indirizzoDestinatario: _conIndirizzoDestinatario.text.isNotEmpty ? _conIndirizzoDestinatario.text : null,
                          indirizzoDestinazione: _conIndirizzoDestinazione.text.isNotEmpty ? _conIndirizzoDestinazione.text : null,
                          cittaDestinatario: _conCittaDestinatario.text.isNotEmpty ? _conCittaDestinatario.text : null,
                          cittaDestinazione: _conCittaDestinazione.text.isNotEmpty ? _conCittaDestinazione.text : null,
                          codFisc: _conCFDestinatario.text.isNotEmpty ? _conCFDestinatario.text : null,
                      ),
                    ),
                  ),
                ),
                SpeedDialChild(
                  child: Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Crea nuovo cliente'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreazioneClientePage(),
                    ),
                  ),
                ),
                SpeedDialChild(
                  child: Icon(Icons.person, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Seleziona cliente'.toUpperCase(),
                  onTap: () => _showClientiDialog(),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
              bottom: 165,
              child: Tooltip(
                message: "Aggiungi riga",
                child: FloatingActionButton(
                  onPressed: _aggiungiProdotto,
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              )
          ),
          Positioned(
              right: 16,
              bottom: 90,
              child: Tooltip(
                message: "Rimuovi ultima riga",
                child: FloatingActionButton(
                  onPressed: _rimuoviProdotto,
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }

  void _showClientiDialog() {
    TextEditingController searchController = TextEditingController(); // Aggiungi un controller
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) { // Usa StatefulBuilder per aggiornare lo stato del dialogo
            return AlertDialog(
              title: const Text('Seleziona Cliente', textAlign: TextAlign.center),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController, // Aggiungi il controller
                      onChanged: (value) {
                        setState(() {
                          filteredClienti = allClienti.where((cliente) {
                            final searchLower = value.toLowerCase();
                            return (cliente.denominazione?.toLowerCase().contains(searchLower) ?? false) ||
                                (cliente.codice_fiscale?.toLowerCase().contains(searchLower) ?? false) ||
                                (cliente.partita_iva?.toLowerCase().contains(searchLower) ?? false) ||
                                (cliente.indirizzo?.toLowerCase().contains(searchLower) ?? false) ||
                                (cliente.cellulare?.toLowerCase().contains(searchLower) ?? false) ||
                                (cliente.email?.toLowerCase().contains(searchLower) ?? false) ||
                                (cliente.pec?.toLowerCase().contains(searchLower) ?? false) ||
                                (cliente.telefono?.toLowerCase().contains(searchLower) ?? false) ||
                                (cliente.cap?.toLowerCase().contains(searchLower) ?? false) ||
                                (cliente.citta?.toLowerCase().contains(searchLower) ?? false);
                          }).toList();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Cerca Cliente',
                        prefixIcon: Icon(Icons.search),
                      ),
                    )
                    ,
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredClienti.map((cliente) {
                            return ListTile(
                              leading: const Icon(Icons.contact_page_outlined),
                              title: Text(
                                  '${cliente.denominazione}, ${cliente.indirizzo}'),
                              onTap: () {
                                setState(() {
                                  selectedCliente = cliente;
                                  _conDenomDestinatario.text = cliente.denominazione != null ? cliente.denominazione! : "//";
                                  _conDenomDestinazione.text = cliente.denominazione != null ? cliente.denominazione! : "//";
                                  _conIndirizzoDestinatario.text = cliente.indirizzo != null ? cliente.indirizzo! : "//";
                                  _conIndirizzoDestinazione.text = cliente.indirizzo != null ? cliente.indirizzo! : "//";
                                  _conCittaDestinatario.text = cliente.citta != null ? cliente.citta! : "//";
                                  _conCittaDestinazione.text = cliente.citta != null ? cliente.citta! : "//";
                                  if (cliente.codice_fiscale != null) {
                                    _conCFDestinatario.text = cliente.codice_fiscale!;
                                  } else if (cliente.partita_iva != null) {
                                    _conCFDestinatario.text = cliente.partita_iva!;
                                  } else {
                                    _conCFDestinatario.text = "//";
                                  }
                                });
                                Navigator.of(context).pop();
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> getAllClienti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddressProva/api/cliente'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<ClienteModel> clienti = [];
        for (var item in jsonData) {
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          allClienti = clienti;
          filteredClienti = clienti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  void _aggiornaTotali() {
    double totaleImponibile = 0.0;
    double totaleIva = 0.0;

    for (var prodotto in prodotti) {
      double prezzo = double.tryParse(prodotto.prezzoController.text) ?? 0.0;
      double sconto = double.tryParse(prodotto.scontoController.text) ?? 0.0;
      double quantita = double.tryParse(prodotto.quantitaController.text) ?? 0.0;
      double ivaPercentuale = double.tryParse(prodotto.ivaController.text) ?? 0.0;

      double importo = (prezzo - sconto) * quantita;
      prodotto.importoController.text = importo.toStringAsFixed(2);

      double iva = importo * (ivaPercentuale / 100);

      totaleImponibile += importo;
      totaleIva += iva;
    }

    double totaleDocumento = totaleImponibile + totaleIva;

    setState(() {
      _totaleImponibile = totaleImponibile;
      _totaleIva = totaleIva;
      _totaleDocumento = totaleDocumento;
    });
  }


  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTableCell(
      TextEditingController controller,
      double width,
      int minLines,
      int maxLines,
      TextInputType inputType // Aggiunto il parametro per specificare il tipo di input
      ) {
    return Container(
      width: width,  // Fissa la larghezza della cella
      margin: EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: controller,
        minLines: minLines,  // Altezza iniziale
        maxLines: maxLines,  // Altezza massima
        keyboardType: inputType,  // Usa il tipo di input passato come parametro
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300), // Colore bordo grigio chiaro
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300), // Mantiene il bordo grigio anche quando attivo
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300), // Bordo grigio chiaro quando il campo è abilitato
          ),
        ),
        textAlignVertical: TextAlignVertical.top,  // Allinea il testo all'inizio verticalmente
      ),
    );
  }

  List<Servizio> estraiServizi(){
    return prodotti.map((prodotto) => prodotto.toModel()).toList();
  }

  Future<void> getAllAziende() async{
    try{
      var apiUrl = Uri.parse('$ipaddressProva/api/azienda');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        List<AziendaModel> aziende = [];
        var jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          aziende.add(AziendaModel.fromJson(item));
        }
        setState(() {
          allAziende = aziende;
          selectedAzienda = aziende.first;
        });
      }
    } catch(e){
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getAllAziende();
    _aggiungiProdotto();
    getAllClienti();
    _conDataPreventivo.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }
}

class getTextFormFieldSmall extends StatelessWidget {
  TextEditingController? controller;
  String? hintName;

  IconData? icon;
  bool isObscureText;
  TextInputType inputType;
  bool isEnable;
  bool obbliga;
  double? width;

  getTextFormFieldSmall(
      {super.key,
        this.controller,
        this.hintName,
        this.icon,
        this.isObscureText = false,
        this.inputType = TextInputType.text,
        this.isEnable = true,
        this.obbliga = true,
        this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color.fromRGBO(234, 234, 240, 0.6),
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.0),
        child: SizedBox( // <-- SEE HERE
          width: width,
          height: 15,
          child:
          TextFormField(
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              contentPadding: EdgeInsets.all(0.0),
              isDense: true,
            ),
            cursorRadius: Radius.zero,
            textAlignVertical: TextAlignVertical.bottom,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.0),
            controller: controller,
            enabled: isEnable,
            keyboardType: inputType,
          ),
        )
    );
  }
}

class Prodotto {
  TextEditingController codiceController;
  TextEditingController descrizioneController;
  TextEditingController quantitaController;
  TextEditingController prezzoController;
  TextEditingController scontoController;
  TextEditingController importoController;
  TextEditingController ivaController;

  Prodotto({
    required this.codiceController,
    required this.descrizioneController,
    required this.quantitaController,
    required this.prezzoController,
    required this.scontoController,
    required this.importoController,
    required this.ivaController,
  });

  Servizio toModel(){
    return Servizio(
      codice: codiceController.text.isNotEmpty ? codiceController.text.toString() : "N/A",
      descrizione: descrizioneController.text.isNotEmpty ? descrizioneController.text.toString() : "N/A",
      quantita: quantitaController.text.isNotEmpty ? quantitaController.text.toString() : "0",
      prezzo: prezzoController.text.isNotEmpty ? prezzoController.text.toString() : "0",
      sconto: scontoController.text.isNotEmpty ? scontoController.text.toString() : "",
      importo: importoController.text.isNotEmpty ? importoController.text.toString() : "",
      iva: ivaController.text.isNotEmpty ? ivaController.text.toString() + "%" : "0%",
    );
  }
}

class Servizio{
  String codice;
  String descrizione;
  String quantita;
  String prezzo;
  String sconto;
  String importo;
  String iva;

  Servizio({
    required this.codice,
    required this.descrizione,
    required this.quantita,
    required this.prezzo,
    required this.sconto,
    required this.importo,
    required this.iva
  });

}
