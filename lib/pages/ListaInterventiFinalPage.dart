import 'package:fema_crm/pages/PDFRendicontoInterventiPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/ClienteModel.dart';
import '../model/GruppoInterventiModel.dart';
import '../model/InterventoModel.dart';
import 'CreazioneInterventoByAmministrazionePage.dart';
import 'DettaglioGruppoInterventiPage.dart';
import 'DettaglioInterventoPage.dart';
import 'ListaClientiPage.dart';

class ListaInterventiFinalPage extends StatefulWidget {
  const ListaInterventiFinalPage ({Key? key}) : super(key: key);

  @override
  _ListaInterventiFinalPageState createState() => _ListaInterventiFinalPageState();
}

class _ListaInterventiFinalPageState extends State<ListaInterventiFinalPage>{

  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  TextEditingController searchController2 = TextEditingController();
  TextEditingController importoController = TextEditingController();
  TextEditingController _descrizioneController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  TextEditingController _importoGruppoController = TextEditingController();
  bool isSearching = false;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<InterventoModel> filteredInterventi = [];
  List<InterventoModel> allInterventi = [];
  List<GruppoInterventiModel> allGruppiNonConclusi = [];
  List<GruppoInterventiModel> filteredGruppi = [];
  List<GruppoInterventiModel> allGruppiConclusi = [];
  ClienteModel? selectedCliente;
  GruppoInterventiModel? _selectedGruppo;
  List<ClienteModel> clientiList = [];
  List<ClienteModel> filteredClientiList = [];
  InterventoModel? _selectedIntervento;
  final ScrollController _scrollController = ScrollController();

  void _showGruppoDialog() {
    TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Seleziona un gruppo di interventi',
                textAlign: TextAlign.center,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6, // Imposta un'altezza massima arbitraria
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,// Utilizza SingleChildScrollView per consentire lo scrolling
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            filteredGruppi = allGruppiNonConclusi
                                .where((gruppo) =>
                                gruppo.cliente!.denominazione!
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: const InputDecoration(
                          labelText:
                          'Cerca gruppo tramite la denominazione del cliente',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true, // Imposta shrinkWrap a true
                        itemCount: filteredGruppi.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.folder_copy_outlined),
                            title: Text(
                              '${filteredGruppi[index].cliente!.denominazione!}, ${filteredGruppi[index].descrizione}',
                            ),
                            onTap: () {
                              setState(() {
                                _selectedGruppo = filteredGruppi[index];
                              });
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Confermi di aggiungere l\'intervento al gruppo: ${_selectedGruppo?.descrizione!} ?',
                                      textAlign: TextAlign.center,
                                    ),
                                    content: Container(
                                      height: 100, // Imposta un'altezza arbitraria per il contenuto
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(), // Spazio vuoto per spingere il testo verso l'alto
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  addToGruppo(_selectedIntervento!);
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Conferma'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
                          filteredClientiList = clientiList
                              .where((cliente) => cliente.denominazione!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Cerca Cliente',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredClientiList.map((cliente) {
                            return ListTile(
                              leading: const Icon(Icons.contact_page_outlined),
                              title: Text(
                                  '${cliente.denominazione}'),
                              onTap: () {
                                setState(() {
                                  selectedCliente = cliente;
                                });
                                Navigator.of(context).pop();
                                print('${selectedCliente?.denominazione}');
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
      final response = await http.get(Uri.parse('$ipaddress/api/cliente'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<ClienteModel> clienti = [];
        for (var item in jsonData) {
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          clientiList = clienti;
          filteredClientiList = clienti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  Future<void> getAllGruppi() async {
    try{
      var apiUrl = Uri.parse('$ipaddress/api/gruppi/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<GruppoInterventiModel> gruppiNonConclusi = [];
        List<GruppoInterventiModel> gruppiConclusi = [];
        for(var item in jsonData) {
          GruppoInterventiModel gruppo = GruppoInterventiModel.fromJson(item);
          if(gruppo.concluso == true){
            gruppiConclusi.add(gruppo);
          } else {
            gruppiNonConclusi.add(gruppo);
          }
        } setState(() {
          filteredGruppi = gruppiNonConclusi;
          allGruppiConclusi = gruppiConclusi;
          allGruppiNonConclusi = gruppiNonConclusi;
        });
      } else {
        throw Exception(
            'Failed to load gruppi data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Hai toppato chicco : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getAllInterventi();
    getAllGruppi();
    getAllClienti();
  }

  Future<void> saveGruppo() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/gruppi'),
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({
          'descrizione' : _descrizioneController.text,
          'note' : _noteController.text,
          'importo' : null,
          'concluso' : false,
          'cliente' : selectedCliente?.toMap()
        })
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nuova gruppo registrato con successo!'),
        ),
      );
      getAllGruppi();
      getAllInterventi();
    } catch(e){
      print('Errore: $e');
    }
  }

  Future<void> getAllInterventi() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/intervento/ordered');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          interventi.add(InterventoModel.fromJson(item));
        } setState(() {
          allInterventi = interventi;
          filteredInterventi = interventi;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  void filterInterventi(String query) {
    print('Query di ricerca: $query'); // Stampa la query di ricerca per debug
    setState(() {
      filteredInterventi = allInterventi.where((intervento) {
        final cliente = intervento.cliente?.denominazione?.toLowerCase() ?? '';
        final indirizzo = intervento.cliente?.indirizzo?.toLowerCase() ?? '';
        final indirizzoD = intervento.destinazione?.indirizzo?.toLowerCase() ?? '';
        final citta = intervento.cliente?.citta?.toLowerCase() ?? '';
        final cittaD = intervento.destinazione?.citta?.toLowerCase() ?? '';
        final codiceFiscale = intervento.cliente?.codice_fiscale?.toLowerCase() ?? '';
        final codiceFiscaleD = intervento.destinazione?.codice_fiscale?.toLowerCase() ?? '';
        final partitaIva = intervento.cliente?.partita_iva?.toLowerCase() ?? '';
        final partitaIvaD = intervento.destinazione?.partita_iva?.toLowerCase() ?? '';
        final telefono = intervento.cliente?.telefono?.toLowerCase() ?? '';
        final telefonoD = intervento.destinazione?.telefono?.toLowerCase() ?? '';
        final cellulare = intervento.cliente?.cellulare?.toLowerCase() ?? '';
        final cellulareD = intervento.destinazione?.cellulare?.toLowerCase() ?? '';
        final tipologia = intervento.tipologia?.descrizione?.toLowerCase() ?? '';

        final containsQuery = cliente.contains(query.toLowerCase()) ||
            indirizzo.contains(query.toLowerCase()) ||
            indirizzoD.contains(query.toLowerCase()) ||
            citta.contains(query.toLowerCase()) ||
            cittaD.contains(query.toLowerCase()) ||
            codiceFiscale.contains(query.toLowerCase()) ||
            codiceFiscaleD.contains(query.toLowerCase()) ||
            partitaIva.contains(query.toLowerCase()) ||
            partitaIvaD.contains(query.toLowerCase()) ||
            telefono.contains(query.toLowerCase()) ||
            telefonoD.contains(query.toLowerCase()) ||
            cellulare.contains(query.toLowerCase()) ||
            cellulareD.contains(query.toLowerCase()) ||
            tipologia.contains(query.toLowerCase());

        return containsQuery;
      }).toList();
    });
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
      filterInterventi('');
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextFormField(
          controller: searchController,
          onChanged: (value) {
            startSearch(); // Attiva il filtro quando si inizia a digitare
            filterInterventi(value); // Applica il filtro
          },
          decoration: InputDecoration(
            hintText: 'Cerca...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        )
            : Text(
          'Lista Interventi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          isSearching
              ? IconButton(
            icon: Icon(Icons.cancel, color: Colors.white),
            onPressed: stopSearch,
          )
              : IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: startSearch,
          ),
          IconButton(
            icon: Icon(Icons.person_add_alt_1, size: 40, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListaClientiPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, size: 40, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreazioneInterventoByAmministrazionePage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              getAllGruppi();
              getAllInterventi();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          :Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text('  Gruppi di intervento non conclusi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text('  Numero di gruppi non conclusi: ${allGruppiNonConclusi.length}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(height: 12),
                  GruppiTableWidget(gruppiNonConclusi: allGruppiNonConclusi, allInterventi: allInterventi, context: context, setState: () {  },),
                  Divider(),
                  SizedBox(height: 16),
                  Text('  Interventi non assegnati', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text('  Numero di interventi non assegnati: ${filteredInterventi
                      .where((intervento) =>!intervento.assegnato!).length}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(height: 12),
                  Container(
                    child: DataTable(
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(
                          label: Text('Data creazione', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Data accordata', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Gruppo di interventi', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Assegna ad un gruppo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Responsabile', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Descrizione', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Assegnato', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Concluso', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Conclusione Parziale', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Tipologia Intervento', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Saldato', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Importo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Inserisci importo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Acconto', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Totale', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                      rows: filteredInterventi
                          .where((intervento) =>!intervento.assegnato!)
                          .map((intervento) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(DateFormat('dd/MM/yyyy').format(intervento.data_apertura_intervento?? DateTime.now())),
                            ),
                            DataCell(
                              Text(DateFormat('dd/MM/yyyy').format(intervento.data?? DateTime.now())),
                            ),
                            DataCell(
                              Text(intervento.cliente?.denominazione?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.gruppo?.descrizione ?? 'N/A'),
                            ),
                            DataCell(
                              Center(
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedIntervento = intervento;
                                      print(_selectedIntervento?.descrizione);
                                    });
                                    _showGruppoDialog();
                                  },
                                  icon: Icon(Icons.folder, color:Colors.grey),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.utente?.cognome?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.descrizione?? 'N/A'),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.assegnato?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.assegnato?? false? 'Assegnato' : 'Non assegnato',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.concluso?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.concluso?? false? 'Concluso' : 'Non concluso',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.conclusione_parziale?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.conclusione_parziale?? false? 'Terminato' : 'Conclusione Parziale',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.tipologia?.descrizione?.toString()?? 'N/A'),
                            ),
                            DataCell(
                              Text(
                                intervento.note!= null
                                    ? (intervento.note!.length > 30? intervento.note!.substring(0, 30) : intervento.note!)
                                    : 'N/A',
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.saldato?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.saldato?? false? 'Saldato' : 'Non saldato',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.importo_intervento?.toStringAsFixed(2)?? 'N/A'),
                            ),
                            DataCell(
                              Center(
                                child: IconButton(
                                  onPressed: () {
                                    // Show dialog when button is pressed
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Inserisci un importo'),
                                          actions: <Widget>[
                                            TextFormField(
                                              controller: importoController,
                                              decoration: InputDecoration(
                                                labelText: 'Importo',
                                                border: OutlineInputBorder(),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly, // allow only digits
                                              ],
                                              keyboardType: TextInputType.number, // show number keyboard
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // Save the importo for the current intervento
                                                saveImporto(intervento); // <--- Pass the intervento object here
                                              },
                                              child: Text('Salva importo'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.create, color: Colors.grey),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.acconto?.toStringAsFixed(2)?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.acconto!= null && intervento.importo_intervento!= null
                                  ? (intervento.importo_intervento! - intervento.acconto!).toStringAsFixed(2)
                                  : intervento.importo_intervento?.toStringAsFixed(2)?? 'N/A'),
                            ),
                          ],
                          onSelectChanged: (isSelected) {
                            if (isSelected!= null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DettaglioInterventoPage(intervento: intervento),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),







                  SizedBox(height: 16),
                  Text('  Interventi non conclusi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text('  Numero di interventi non conclusi: ${filteredInterventi
                      .where((intervento) =>!intervento.concluso! &&!intervento.saldato! && intervento.assegnato!).length}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(height: 12),
                  Container(
                    child: DataTable(
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(
                          label: Text('Data creazione', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Data accordata', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Gruppo di interventi', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Assegna ad un gruppo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Responsabile', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Descrizione', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Assegnato', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Concluso', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Conclusione Parziale', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Tipologia Intervento', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Saldato', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Importo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Inserisci importo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Acconto', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Totale', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                      rows: filteredInterventi
                          .where((intervento) =>!intervento.concluso! &&!intervento.saldato! && intervento.assegnato!)
                          .map((intervento) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(DateFormat('dd/MM/yyyy').format(intervento.data_apertura_intervento?? DateTime.now())),
                            ),
                            DataCell(
                              Text(DateFormat('dd/MM/yyyy').format(intervento.data?? DateTime.now())),
                            ),
                            DataCell(
                              Text(intervento.cliente?.denominazione?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.gruppo?.descrizione ?? 'N/A'),
                            ),
                            DataCell(
                              Center(
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedIntervento = intervento;
                                      print(_selectedIntervento?.descrizione);
                                    });
                                    _showGruppoDialog();
                                  },
                                  icon: Icon(Icons.folder, color:Colors.grey),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.utente?.cognome?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.descrizione?? 'N/A'),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.assegnato?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.assegnato?? false? 'Assegnato' : 'Non assegnato',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.concluso?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.concluso?? false? 'Concluso' : 'Non concluso',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.conclusione_parziale?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.conclusione_parziale?? false? 'Terminato' : 'Conclusione Parziale',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.tipologia?.descrizione?.toString()?? 'N/A'),
                            ),
                            DataCell(
                              Text(
                                intervento.note!= null
                                    ? (intervento.note!.length > 30? intervento.note!.substring(0, 30) : intervento.note!)
                                    : 'N/A',
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.saldato?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.saldato?? false? 'Saldato' : 'Non saldato',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.importo_intervento?.toStringAsFixed(2)?? 'N/A'),
                            ),
                            DataCell(
                              Center(
                                child: IconButton(
                                  onPressed: () {
                                    // Show dialog when button is pressed
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Inserisci un importo'),
                                          actions: <Widget>[
                                            TextFormField(
                                              controller: importoController,
                                              decoration: InputDecoration(
                                                labelText: 'Importo',
                                                border: OutlineInputBorder(),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly, // allow only digits
                                              ],
                                              keyboardType: TextInputType.number, // show number keyboard
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // Save the importo for the current intervento
                                                saveImporto(intervento); // <--- Pass the intervento object here
                                              },
                                              child: Text('Salva importo'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.create, color: Colors.grey),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.acconto?.toStringAsFixed(2)?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.acconto!= null && intervento.importo_intervento!= null
                                  ? (intervento.importo_intervento! - intervento.acconto!).toStringAsFixed(2)
                                  : intervento.importo_intervento?.toStringAsFixed(2)?? 'N/A'),
                            ),
                          ],
                          onSelectChanged: (isSelected) {
                            if (isSelected!= null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DettaglioInterventoPage(intervento: intervento),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Divider(), // separator between sectors
                  SizedBox(height: 16),
                  Text('  Interventi conclusi e non saldati', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text('  Numero di interventi conclusi e non saldati: ${filteredInterventi
                      .where((intervento) =>intervento.concluso! &&!intervento.saldato!).length}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(height: 12),
                  // Sector 2: Interventi conclusi e non saldati
                  Container(
                    child : DataTable(
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(
                          label: Text('Data creazione', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Data accordata', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Gruppo di interventi', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Assegna ad un gruppo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Responsabile', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Descrizione', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Assegnato', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Concluso', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Conclusione Parziale', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Relazione Tecnico', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Tipologia Intervento', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Saldato', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Importo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Inserisci importo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Acconto', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Totale', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                      rows: filteredInterventi
                          .where((intervento) => intervento.concluso! &&!intervento.saldato!)
                          .map((intervento) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(DateFormat('dd/MM/yyyy').format(intervento.data_apertura_intervento?? DateTime.now())),
                            ),
                            DataCell(
                              Text(DateFormat('dd/MM/yyyy').format(intervento.data?? DateTime.now())),
                            ),
                            DataCell(
                              Text(intervento.cliente?.denominazione?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.gruppo?.descrizione ?? 'N/A'),
                            ),
                            DataCell(
                              Center(
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedIntervento = intervento;
                                      print(_selectedIntervento?.descrizione);
                                    });
                                    _showGruppoDialog();
                                  },
                                  icon: Icon(Icons.folder, color:Colors.grey),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.utente?.cognome?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.descrizione?? 'N/A'),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.assegnato?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.assegnato?? false? 'Assegnato' : 'Non assegnato',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.concluso?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.concluso?? false? 'Concluso' : 'Non concluso',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.conclusione_parziale?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.conclusione_parziale?? false? 'Terminato' : 'Conclusione Parziale',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.relazione_tecnico != null
                                  ? (intervento.relazione_tecnico!.length > 50
                                  ? intervento.relazione_tecnico!.substring(0, 50)
                                  : intervento.relazione_tecnico!)
                                  : 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.tipologia?.descrizione?.toString()?? 'N/A'),
                            ),
                            DataCell(
                              Text(
                                intervento.note!= null
                                    ? (intervento.note!.length > 30? intervento.note!.substring(0, 30) : intervento.note!)
                                    : 'N/A',
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.saldato?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.saldato?? false? 'Saldato' : 'Non saldato',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.importo_intervento?.toStringAsFixed(2)?? 'N/A'),
                            ),
                            DataCell(
                              Center(
                                child: IconButton(
                                  onPressed: () {
                                    // Show dialog when button is pressed
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Inserisci un importo'),
                                          actions: <Widget>[
                                            TextFormField(
                                              controller: importoController,
                                              decoration: InputDecoration(
                                                labelText: 'Importo',
                                                border: OutlineInputBorder(),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly, // allow only digits
                                              ],
                                              keyboardType: TextInputType.number, // show number keyboard
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // Save the importo for the current intervento
                                                saveImporto(intervento); // <--- Pass the intervento object here
                                              },
                                              child: Text('Save'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.create, color: Colors.grey),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.acconto?.toStringAsFixed(2)?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.acconto!= null && intervento.importo_intervento!= null
                                  ? (intervento.importo_intervento! - intervento.acconto!).toStringAsFixed(2)
                                  : intervento.importo_intervento?.toStringAsFixed(2)?? 'N/A'),
                            ),
                          ],
                          onSelectChanged: (isSelected) {
                            if (isSelected!= null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DettaglioInterventoPage(intervento: intervento),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('  Gruppi di intervento conclusi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text('  Numero di gruppi conclusi: ${allGruppiConclusi.length}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(height: 12),
                  GruppiConcTableWidget(gruppiConclusi: allGruppiConclusi, allInterventi: allInterventi, context: context, setState: () {  },),
                  // Sector 3: Interventi conclusi e saldati
                  Divider(),
                  SizedBox(height: 16),
                  Text('  Interventi conclusi e saldati', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text('  Numero di interventi conclusi e saldati: ${filteredInterventi
                      .where((intervento) =>intervento.concluso! && intervento.saldato!).length}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(height: 12),
                  Container(
                    child: DataTable(
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(
                          label: Text('Data creazione', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Data accordata', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Gruppo di interventi', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Assegna ad un gruppo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Responsabile', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Descrizione', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Assegnato', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Concluso', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Conclusione Parziale', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Relazione Tecnico', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Tipologia Intervento', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Saldato', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Importo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Inserisci importo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Acconto', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Totale', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                      rows: filteredInterventi
                          .where((intervento) => intervento.concluso! && intervento.saldato!)
                          .map((intervento) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(DateFormat('dd/MM/yyyy').format(intervento.data_apertura_intervento?? DateTime.now())),
                            ),
                            DataCell(
                              Text(DateFormat('dd/MM/yyyy').format(intervento.data?? DateTime.now())),
                            ),
                            DataCell(
                              Text(intervento.cliente?.denominazione?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.gruppo?.descrizione ?? 'N/A'),
                            ),
                            DataCell(
                              Center(
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedIntervento = intervento;
                                      print(_selectedIntervento?.descrizione);
                                    });
                                    _showGruppoDialog();
                                  },
                                  icon: Icon(Icons.folder, color:Colors.grey),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.utente?.cognome?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.descrizione?? 'N/A'),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.assegnato?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.assegnato?? false? 'Assegnato' : 'Non assegnato',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.concluso?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.concluso?? false? 'Concluso' : 'Non concluso',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.conclusione_parziale?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.conclusione_parziale?? false? 'Terminato' : 'Conclusione Parziale',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.relazione_tecnico != null
                                  ? (intervento.relazione_tecnico!.length > 50
                                  ? intervento.relazione_tecnico!.substring(0, 50)
                                  : intervento.relazione_tecnico!)
                                  : 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.tipologia?.descrizione?.toString()?? 'N/A'),
                            ),
                            DataCell(
                              Text(
                                intervento.note!= null
                                    ? (intervento.note!.length > 30? intervento.note!.substring(0, 30) : intervento.note!)
                                    : 'N/A',
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.saldato?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.saldato?? false? 'Saldato' : 'Non saldato',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.importo_intervento?.toStringAsFixed(2)?? 'N/A'),
                            ),
                            DataCell(
                              Center(
                                child: IconButton(
                                  onPressed: () {
                                    // Show dialog when button is pressed
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Inserisci un importo'),
                                          actions: <Widget>[
                                            TextFormField(
                                              controller: importoController,
                                              decoration: InputDecoration(
                                                labelText: 'Importo',
                                                border: OutlineInputBorder(),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly, // allow only digits
                                              ],
                                              keyboardType: TextInputType.number, // show number keyboard
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // Save the importo for the current intervento
                                                saveImporto(intervento); // <--- Pass the intervento object here
                                              },
                                              child: Text('Save'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.create, color: Colors.grey),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.acconto?.toStringAsFixed(2)?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.acconto!= null && intervento.importo_intervento!= null
                                  ? (intervento.importo_intervento! - intervento.acconto!).toStringAsFixed(2)
                                  : intervento.importo_intervento?.toStringAsFixed(2)?? 'N/A'),
                            ),
                          ],
                          onSelectChanged: (isSelected) {
                            if (isSelected!= null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DettaglioInterventoPage(intervento: intervento),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 25),
                ],
              ),
            ),
          ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text('Crea un nuovo gruppo', style: TextStyle(fontWeight: FontWeight.bold)),
                      actions: <Widget>[
                        TextFormField(
                          controller: _descrizioneController,
                          decoration: InputDecoration(
                            labelText: 'Nome del nuovo gruppo',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            labelText: 'Inserisci una nota al gruppo',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: GestureDetector(
                            onTap: () {
                              _showClientiDialog();
                            },
                            child: SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(selectedCliente?.denominazione ?? 'Seleziona Cliente', style: const TextStyle(fontSize: 16)),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            saveGruppo();
                          },
                          child: Text('Salva gruppo'),
                        ),
                      ],
                    );
                  });
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.create_new_folder, color: Colors.white),
            heroTag: "Tag2",
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PDFRendicontoInterventiPage()),
              );
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.arrow_downward_sharp, color: Colors.white),
            heroTag: "Tag3",
          ),
        ],
      ),
    );
  }

  Future<void> addToGruppo(InterventoModel intervento) async {
    try{
      final response = await http.post(
        Uri.parse('${ipaddress}/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': intervento.id,
          'data': intervento.data?.toIso8601String(),
          'orario_appuntamento' : intervento.orario_appuntamento?.toIso8601String(),
          'orario_inizio': intervento.orario_inizio?.toIso8601String(),
          'orario_fine': intervento.orario_fine?.toIso8601String(),
          'descrizione': intervento.descrizione,
          'importo_intervento': intervento.importo_intervento,
          'assegnato': intervento.assegnato,
          'conclusione_parziale': intervento.conclusione_parziale,
          'concluso': intervento.concluso,
          'saldato': intervento.saldato,
          'note': intervento.note,
          'relazione_tecnico' : intervento.relazione_tecnico,
          'firma_cliente': intervento.firma_cliente,
          'utente': intervento.utente?.toMap(),
          'cliente': intervento.cliente?.toMap(),
          'veicolo': intervento.veicolo?.toMap(),
          'merce': intervento.merce?.toMap(),
          'tipologia': intervento.tipologia?.toMap(),
          'categoria': intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': intervento.tipologia_pagamento?.toMap(),
          'destinazione': intervento.destinazione?.toMap(),
          'gruppo' : _selectedGruppo?.toMap(),
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        getAllInterventi();
        getAllGruppi();
      }
    } catch(e){
      print('Errore durante il salvataggio del intervento: $e');
    }
  }

  Future<void> saveImporto(InterventoModel intervento) async {
    try {
      final response = await http.post(
        Uri.parse('${ipaddress}/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': intervento.id,
          'data': intervento.data?.toIso8601String(),
          'orario_appuntamento' : intervento.orario_appuntamento?.toIso8601String(),
          'orario_inizio': intervento.orario_inizio?.toIso8601String(),
          'orario_fine': intervento.orario_fine?.toIso8601String(),
          'descrizione': intervento.descrizione,
          'importo_intervento': double.parse(importoController.text),
          'assegnato': intervento.assegnato,
          'conclusione_parziale': intervento.conclusione_parziale,
          'concluso': intervento.concluso,
          'saldato': intervento.saldato,
          'note': intervento.note,
          'relazione_tecnico' : intervento.relazione_tecnico,
          'firma_cliente': intervento.firma_cliente,
          'utente': intervento.utente?.toMap(),
          'cliente': intervento.cliente?.toMap(),
          'veicolo': intervento.veicolo?.toMap(),
          'merce': intervento.merce?.toMap(),
          'tipologia': intervento.tipologia?.toMap(),
          'categoria': intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': intervento.tipologia_pagamento?.toMap(),
          'destinazione': intervento.destinazione?.toMap(),
          'gruppo' : intervento.gruppo?.toMap()
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        Navigator.pop(context);
        setState(() {
          intervento.importo_intervento = double.parse(importoController.text);
        });
      }
    } catch (e) {
      print('Errore durante il salvataggio del intervento: $e');
    }
  }

}

class GruppiConcTableWidget extends StatelessWidget {

  final List<GruppoInterventiModel> gruppiConclusi;
  final List<InterventoModel> allInterventi;
  final BuildContext context;
  final VoidCallback setState;

  GruppiConcTableWidget({
    required this.gruppiConclusi,
    required this.allInterventi,
    required this.context,
    required this.setState,
  });

  final TextEditingController _importoGruppoController = TextEditingController();
  final String ipaddress = 'http://gestione.femasistemi.it:8090';

  Map<String, double> _calculateGroupImportoSum(List<InterventoModel> interventi, List<GruppoInterventiModel> gruppi) {
    Map<String, double> groupImportoSum = {};
    for (var gruppo in gruppi) {
      double sum = 0;
      for (var intervento in interventi) {
        if (intervento.gruppo != null && intervento.gruppo!.id == gruppo.id) {
          if (intervento.importo_intervento != null) {
            sum += intervento.importo_intervento!;
          }
        }
      }
      groupImportoSum[gruppo.id.toString()] = sum;
    }
    return groupImportoSum;
  }

  Future<void> saveImportoGruppo(GruppoInterventiModel gruppo, String importo) async {
    try{
      final response = await http.post(
          Uri.parse('$ipaddress/api/gruppi'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id' : gruppo.id,
            'descrizione' : gruppo.descrizione,
            'note' : gruppo.note,
            'importo' : importo, // Utilizza l'importo passato come parametro
            'concluso' : gruppo.concluso,
            'cliente' : gruppo.cliente?.toMap()
          })
      );
      if(response.statusCode == 201){
        print('EVVAIIIIIIII');
        Navigator.pop(context);
        gruppo.importo == double.parse(_importoGruppoController.text);
      }
    } catch(e){
      print('Errore: $e');
    }
  }

  @override
  Widget build(BuildContext context){
    Map<int, double> groupImportoSum = _calculateGroupImportoSum(allInterventi, gruppiConclusi).cast<int, double>();
    return DataTable(
      showCheckboxColumn: false,
      columns: [
        DataColumn(label: Text(
            'Cliente', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text(
            'Descrizione', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text(
            'Somma importo interventi', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text(
            'Importo', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
          label: Text('Inserisci importo', style: TextStyle(fontWeight: FontWeight.bold)),),
        DataColumn(label: Text(
            'Concluso', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: gruppiConclusi.map((gruppo) {
        double groupImporto = groupImportoSum[gruppo.id] ?? 0;
        return DataRow(
          cells: [
            DataCell(Text(gruppo.cliente?.denominazione ?? 'N/A')),
            DataCell(Text(gruppo.descrizione ?? 'N/A')),
            DataCell(Text(groupImporto.toStringAsFixed(2))),
            DataCell(Text(gruppo.importo?.toStringAsFixed(2) ?? 'N/A')),
            DataCell(
              Center(
                child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Inserisci un importo'),
                          actions: <Widget>[
                            TextFormField(
                              controller: _importoGruppoController, // Utilizza il controller appena creato
                              decoration: InputDecoration(
                                labelText: 'Importo',
                                border: OutlineInputBorder(),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly, // permetti solo i numeri
                              ],
                              keyboardType: TextInputType.number, // mostra la tastiera numerica
                            ),
                            TextButton(
                              onPressed: () {
                                // Salva l'importo per il gruppo corrente
                                saveImportoGruppo(gruppo, _importoGruppoController.text);
                              },
                              child: Text('Salva'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.create, color: Colors.grey),
                ),
              ),
            ),
            DataCell(
              Container(
                decoration: BoxDecoration(
                  color: gruppo.concluso ?? false ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
                padding: EdgeInsets.all(10),
                child: Text(
                  gruppo.concluso ?? false ? 'Concluso' : 'Non concluso',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
          onSelectChanged: (isSelected) {
            if (isSelected!= null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DettaglioGruppoInterventiPage(gruppo: gruppo),
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }
}

class GruppiTableWidget extends StatelessWidget {
  final List<GruppoInterventiModel> gruppiNonConclusi;
  final List<InterventoModel> allInterventi;
  final BuildContext context;
  final VoidCallback setState;

  GruppiTableWidget({required this.gruppiNonConclusi, required this.allInterventi, required this.context,
    required this.setState,});

  final TextEditingController _importoGruppoController = TextEditingController();
  final String ipaddress = 'http://gestione.femasistemi.it:8090';

  Map<String, double> _calculateGroupImportoSum(List<InterventoModel> interventi, List<GruppoInterventiModel> gruppi) {
    Map<String, double> groupImportoSum = {};

    for (var gruppo in gruppi) {
      double sum = 0;
      for (var intervento in interventi) {
        if (intervento.gruppo != null && intervento.gruppo!.id == gruppo.id) {
          if (intervento.importo_intervento != null) {
            sum += intervento.importo_intervento!;
          }
        }
      }
      groupImportoSum[gruppo.id.toString()] = sum;
    }
    return groupImportoSum;
  }

  Future<void> saveImportoGruppo(GruppoInterventiModel gruppo) async {
    print('prova1');
    try{
      print('prova2');
      final response = await http.post(
          Uri.parse('$ipaddress/api/gruppi'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id' : gruppo.id,
            'descrizione' : gruppo.descrizione,
            'note' : gruppo.note,
            'importo' : _importoGruppoController.text,
            'concluso' : gruppo.concluso,
            'cliente' : gruppo.cliente?.toMap()
          })
      );
      if(response.statusCode == 201){
        print('EVVAIIIIIIII');
        Navigator.pop(context);
      }
    } catch(e){
      print('Errore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<int, double> groupImportoSum = _calculateGroupImportoSum(allInterventi, gruppiNonConclusi).cast<int, double>();
    return DataTable(
      showCheckboxColumn: false,
      columns: [
        DataColumn(label: Text(
            'Cliente', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text(
            'Descrizione', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text(
            'Somma importo interventi', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text(
            'Importo', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
          label: Text('Inserisci importo', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(label: Text(
            'Concluso', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: gruppiNonConclusi.map((gruppo) {
        double groupImporto = groupImportoSum[gruppo.id] ?? 0;
        return DataRow(
          cells: [
            DataCell(Text(gruppo.cliente?.denominazione ?? 'N/A')),
            DataCell(Text(gruppo.descrizione ?? 'N/A')),
            DataCell(Text(groupImporto.toStringAsFixed(2))),
            DataCell(Text(gruppo.importo?.toStringAsFixed(2) ?? 'N/A')),
            DataCell(
              Center(
                child: IconButton(
                  onPressed: () {
                    // Show dialog when button is pressed
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Inserisci un importo'),
                          actions: <Widget>[
                            TextFormField(
                              controller: _importoGruppoController,
                              decoration: InputDecoration(
                                labelText: 'Importo',
                                border: OutlineInputBorder(),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly, // allow only digits
                              ],
                              keyboardType: TextInputType.number, // show number keyboard
                            ),
                            TextButton(
                              onPressed: () {
                                // Save the importo for the current intervento
                                saveImportoGruppo(gruppo, ); // <--- Pass the intervento object here
                              },
                              child: Text('Salva'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.create, color: Colors.grey),
                ),
              ),
            ),
            DataCell(
              Container(
                decoration: BoxDecoration(
                  color: gruppo.concluso ?? false ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
                padding: EdgeInsets.all(10),
                child: Text(
                  gruppo.concluso ?? false ? 'Concluso' : 'Non concluso',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
          onSelectChanged: (isSelected) {
            if (isSelected!= null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DettaglioGruppoInterventiPage(gruppo: gruppo),
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }
}


