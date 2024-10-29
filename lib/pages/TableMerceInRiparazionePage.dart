import 'dart:convert';
import 'dart:io';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import '../model/ClienteModel.dart';
import '../model/GruppoInterventiModel.dart';
import '../model/InterventoModel.dart';
import '../model/RelazioneUtentiInterventiModel.dart';
import '../model/UtenteModel.dart';
import 'CreazioneInterventoByAmministrazionePage.dart';
import 'ListaClientiPage.dart';
import 'DettaglioInterventoPage.dart';
import 'TableInterventiPage.dart';

class TableMerceInRiparazionePage extends StatefulWidget{
  TableMerceInRiparazionePage({Key? key}) : super(key : key);

  @override
  _TableMerceInRiparazionePageState createState() => _TableMerceInRiparazionePageState();
}

class _TableMerceInRiparazionePageState extends State<TableMerceInRiparazionePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<InterventoModel> _allInterventi = [];
  List<InterventoModel> _filteredInterventi = [];
  TextEditingController importoController = TextEditingController();
  bool isSearching = false;
  late InterventoDataSource _dataSource;
  Map<String, double> _columnWidths = {
    'intervento' : 0,
    'id_intervento' : 150,
    'codice_danea' : 200,
    'priorita' : 45,
    'cliente': 200,
    'data_apertura_intervento': 210,
    'articolo': 300,
    'difetto' : 300,
    'responsabile' : 230,
    'richiesta_preventivo' : 200,
    'importo_preventivato': 150,
    'tipologia' : 180,
    'stato' : 100
  };
  bool isLoading = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataSource = InterventoDataSource(context, _filteredInterventi);
    getAllMerci();
    _filteredInterventi = _allInterventi.toList();
  }

  Future<void> getAllMerci() async{
    setState(() {
      isLoading = true; // Inizio del caricamento
    });
    try{
      var apiUrl = Uri.parse('$ipaddressProva/api/intervento/withMerce');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        for(var item in jsonData){
          interventi.add(InterventoModel.fromJson(item));
        }
        setState(() {
          _isLoading = false;
          _allInterventi = interventi;
          _filteredInterventi = interventi;
          _dataSource = InterventoDataSource(context, _filteredInterventi);
        });
      } else {
        _isLoading = false;
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during API call: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Fine del caricamento
      });
    }
  }

  void filterInterventi(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _filteredInterventi = _allInterventi.where((intervento) {
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
        final descrizione = intervento.descrizione?.toLowerCase() ?? '';

        return cliente.contains(lowerCaseQuery) ||
            indirizzo.contains(lowerCaseQuery) ||
            indirizzoD.contains(lowerCaseQuery) ||
            citta.contains(lowerCaseQuery) ||
            cittaD.contains(lowerCaseQuery) ||
            codiceFiscale.contains(lowerCaseQuery) ||
            codiceFiscaleD.contains(lowerCaseQuery) ||
            partitaIva.contains(lowerCaseQuery) ||
            partitaIvaD.contains(lowerCaseQuery) ||
            telefono.contains(lowerCaseQuery) ||
            telefonoD.contains(lowerCaseQuery) ||
            cellulare.contains(lowerCaseQuery) ||
            cellulareD.contains(lowerCaseQuery) ||
            tipologia.contains(lowerCaseQuery) ||
            descrizione.contains(lowerCaseQuery);
      }).toList();
      _dataSource.updateData(_filteredInterventi);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('LISTA MERCE IN RIPARAZIONE', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TableMerceInRiparazionePage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
                child: isLoading ? Center(child: CircularProgressIndicator()) : SfDataGrid(
                    allowPullToRefresh: true,
                    allowSorting: true,
                    source: _dataSource,
                    columnWidthMode: ColumnWidthMode.auto,
                    allowColumnsResizing: true,
                    isScrollbarAlwaysShown: true,
                    rowHeight: 40,
                    gridLinesVisibility: GridLinesVisibility.both,
                    headerGridLinesVisibility: GridLinesVisibility.both,
                    columns: [
                      GridColumn(
                        columnName: 'intervento',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'intervento',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        width: _columnWidths['intervento']?? double.nan,
                        minimumWidth: 0,
                      ),
                      GridColumn(
                        columnName: 'id_intervento',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ColumnFilter(
                            columnName: 'ID',
                            onFilterApplied: (filtro) {
                              setState(() {
                                _dataSource.filtraColonna('id_intervento', filtro);
                              });
                            },
                          ),
                        ),
                        width: _columnWidths['id_intervento']?? double.nan,
                        minimumWidth: 150,
                      ),
                      GridColumn(
                        columnName: 'priorita',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text('PR'),
                        ),
                        width: _columnWidths['priorita']?? double.nan,
                        minimumWidth: 45,
                      ),
                      GridColumn(
                        columnName: 'codice_danea',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ColumnFilter(
                            columnName: 'CODICE DANEA',
                            onFilterApplied: (filtro) {
                              setState(() {
                                _dataSource.filtraColonna('codice_danea', filtro);
                              });
                            },
                          ),
                        ),
                        width: _columnWidths['codice_danea']?? double.nan,
                        minimumWidth: 200,
                      ),
                      GridColumn(
                        columnName: 'cliente',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ColumnFilter(
                            columnName: 'Cliente'.toUpperCase(),
                            onFilterApplied: (filtro) {
                              setState(() {
                                _dataSource.filtraColonna('cliente', filtro);
                              });
                            },
                          ),
                        ),
                        width: _columnWidths['cliente']?? double.nan,
                        minimumWidth: 200, // Imposta la larghezza minima
                      ),
                      GridColumn(
                        columnName: 'data_apertura_intervento',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ColumnFilter(
                            columnName: 'Data arrivo merce'.toUpperCase(),
                            onFilterApplied: (filtro) {
                              setState(() {
                                _dataSource.filtraColonna('data_apertura_intervento', filtro);
                              });
                            },
                          ),
                        ),
                        width: _columnWidths['data_apertura_intervento']?? double.nan,
                        minimumWidth: 210, // Imposta la larghezza minima
                      ),
                      GridColumn(
                        columnName: 'articolo',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ColumnFilter(
                            columnName: 'articolo'.toUpperCase(),
                            onFilterApplied: (filtro) {
                              setState(() {
                                _dataSource.filtraColonna('articolo', filtro);
                              });
                            },
                          ),
                        ),
                        width: _columnWidths['articolo']?? double.nan,
                        minimumWidth: 300, // Imposta la larghezza minima
                      ),
                      GridColumn(
                        columnName: 'difetto',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ColumnFilter(
                            columnName: 'difetto'.toUpperCase(),
                            onFilterApplied: (filtro) {
                              setState(() {
                                _dataSource.filtraColonna('difetto', filtro);
                              });
                            },
                          ),
                        ),
                        width: _columnWidths['difetto']?? double.nan,
                        minimumWidth: 300, // Imposta la larghezza minima
                      ),
                      GridColumn(
                        columnName: 'responsabile',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ColumnFilter(
                            columnName: 'responsabile'.toUpperCase(),
                            onFilterApplied: (filtro) {
                              setState(() {
                                _dataSource.filtraColonna('responsabile', filtro);
                              });
                            },
                          ),
                        ),
                        width: _columnWidths['responsabile']?? double.nan,
                        minimumWidth: 300, // Imposta la larghezza minima
                      ),
                      GridColumn(
                        columnName: 'richiesta_preventivo',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        width: _columnWidths['richiesta_preventivo']?? double.nan,
                        minimumWidth: 300, // Imposta la larghezza minima
                      ),
                      GridColumn(
                        columnName: 'importo_preventivato',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        width: _columnWidths['importo_preventivato']?? double.nan,
                        minimumWidth: 300, // Imposta la larghezza minima
                      ),
                      GridColumn(
                        columnName: 'stato',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ColumnFilter(
                            columnName: 'stato'.toUpperCase(),
                            onFilterApplied: (filtro) {
                              setState(() {
                                _dataSource.filtraColonna('stato', filtro);
                              });
                            },
                          ),
                        ),
                        width: _columnWidths['stato']?? double.nan,
                        minimumWidth: 300, // Imposta la larghezza minima
                      ),
                    ],
                  onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                    setState(() {
                      _columnWidths[details.column.columnName] = details.width;
                    });
                    return true;
                  },
                )
            )
          ],
        ),
      ),
    );
  }

}

class InterventoDataSource extends DataGridSource{
  List<InterventoModel> _interventions = [];
  List<InterventoModel> interventiFiltrati = [];
  BuildContext context;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  InterventoModel? _selectedIntervento;
  TextEditingController codiceDaneaController = TextEditingController();

  InterventoDataSource(
      this.context,
      List<InterventoModel> interventions,
      ) {
    _interventions = List.from(interventions);
    interventiFiltrati = List.from(interventions);
  }

  void updateData(List<InterventoModel> newInterventions) {
    _interventions.clear();
    _interventions.addAll(newInterventions);
    interventiFiltrati = List.from(newInterventions);  // Aggiorna anche la lista filtrata
    notifyListeners();
  }

  void filtraColonna(String columnName, String filtro) {
    if (filtro.isEmpty) {
      interventiFiltrati = List.from(_interventions);
    } else {
      interventiFiltrati = _interventions.where((intervento) {
        switch (columnName) {
          case 'descrizione':
            bool result = intervento.titolo?.toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'id_intervento':
            bool result = intervento.id?.toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'data_apertura_intervento':
            bool result = intervento.data_apertura_intervento?.toString().toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'data':
            bool result = intervento.data?.toString().toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'orario_appuntamento':
            bool result = intervento.orario_appuntamento?.toString().toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'cliente':
            bool result = intervento.cliente?.denominazione!.toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'importo_intervento' :
            bool result = intervento.importo_intervento?.toString().toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'responsabile':
            return (intervento.utente?.nome?.toLowerCase().contains(filtro.toLowerCase()) ?? false) ||
                (intervento.utente?.cognome?.toLowerCase().contains(filtro.toLowerCase()) ?? false);
          default:
            return true;
        }
      }).toList();
    }
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows{
    List<DataGridRow> rows = [];
    for(int i = 0; i < interventiFiltrati.length; i++){
      InterventoModel intervento = interventiFiltrati[i];
      Color? prioritaColor;
      switch (intervento.priorita) {
        case Priorita.BASSA :
          prioritaColor = Colors.lightGreen;
          break;
        case Priorita.MEDIA :
          prioritaColor = Colors.yellow; // grigio chiaro
          break;
        case Priorita.ALTA:
          prioritaColor = Colors.orange; // giallo chiaro
          break;
        case Priorita.URGENTE:
          prioritaColor = Colors.red; // azzurro chiaro
          break;
        default:
          prioritaColor = Colors.blueGrey[200];
      }
      String? preventivo = intervento.merce?.preventivo != null ? (intervento.merce?.preventivo == true ? "SI" : "NO") : "NON INSERITO";
      String? stato = (intervento.orario_inizio == null && intervento.orario_fine == null)
          ? "Assegnato".toUpperCase()
          : (intervento.orario_inizio != null && intervento.orario_fine == null)
          ? "In lavorazione".toUpperCase()
          : (intervento.orario_inizio != null && intervento.orario_fine != null)
          ? "Concluso".toUpperCase()
          : "///";

      rows.add(DataGridRow(
        cells: [
          DataGridCell<InterventoModel>(columnName: 'intervento', value: intervento),
          DataGridCell<String>(
            columnName: 'id_intervento',
            value: "${intervento.id}/${intervento.data_apertura_intervento?.year != null ? intervento.data_apertura_intervento?.year : DateTime.now().year }APP",
          ),
          DataGridCell<Priorita>(
            columnName: 'priorita',
            value : intervento.priorita,
          ),
          DataGridCell<Widget>(
            columnName: 'codice_danea',
            value: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return
                      StatefulBuilder(
                          builder: (context, setState){
                            return AlertDialog(
                              title: Text('Inserisci un codice'.toUpperCase()),
                              actions: <Widget>[
                                TextFormField(
                                  controller: codiceDaneaController,
                                  decoration: InputDecoration(
                                    labelText: 'CODICE DANEA',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    saveCodice(intervento).then((_) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => TableInterventiPage()),
                                      );
                                    });
                                  },
                                  child: Text('Salva codice'.toUpperCase()),
                                ),
                              ],
                            );
                          }
                      );
                  },
                );
              },
              child: Text(
                  '${intervento.numerazione_danea != null ? intervento.numerazione_danea : 'N/A'}'
              ),
            ),
          ),
          DataGridCell<String>(
            columnName: 'cliente',
            value: intervento.cliente?.denominazione ?? '',
          ),
          DataGridCell<String>(
            columnName: 'data_apertura_intervento',
            value: intervento.data_apertura_intervento != null
                ? DateFormat('dd/MM/yyyy').format(intervento.data_apertura_intervento!)
                : '',
          ),
          DataGridCell<String>(
            columnName: 'articolo',
            value: intervento.merce?.articolo ?? '',
          ),
          DataGridCell<String>(
            columnName: 'difetto',
            value: intervento.merce?.difetto_riscontrato ?? '',
          ),
          DataGridCell<String>(
            columnName: 'responsabile',
            value: intervento.utente?.nomeCompleto() ?? 'NON ASSEGNATO',
          ),
          DataGridCell<String>(
            columnName: 'richiesta_preventivo',
            value: preventivo,
          ),
          DataGridCell<String>(
            columnName: 'importo_preventivato',
            value: intervento.merce?.importo_preventivato?.toStringAsFixed(2),
          ),
          DataGridCell<String>(
            columnName: 'stato',
            value: stato,
          ),
        ]
      ));
    }
    return rows;
  }

  Future<void> saveCodice(InterventoModel intervento) async {
    try {
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': intervento.id,
          'attivo' : intervento.attivo,
          'titolo' : intervento.titolo,
          'numerazione_danea' : codiceDaneaController.text.isNotEmpty ? codiceDaneaController.text : "N/A",
          'data_apertura_intervento' : intervento.data_apertura_intervento?.toIso8601String(),
          'data': intervento.data?.toIso8601String(),
          'orario_appuntamento' : intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : intervento.posizione_gps,
          'orario_inizio': intervento.orario_inizio?.toIso8601String(),
          'orario_fine': intervento.orario_fine?.toIso8601String(),
          'descrizione': intervento.descrizione,
          'importo_intervento': intervento.importo_intervento,
          'saldo_tecnico' : intervento.saldo_tecnico,
          'prezzo_ivato' : intervento.prezzo_ivato,
          'iva' : intervento.iva,
          'assegnato': intervento.assegnato,
          'accettato_da_tecnico' : intervento.accettato_da_tecnico,
          'annullato' : intervento.annullato,
          'conclusione_parziale': intervento.conclusione_parziale,
          'concluso': intervento.concluso,
          'saldato': intervento.saldato,
          'saldato_da_tecnico' : intervento.saldato_da_tecnico,
          'note': intervento.note,
          'relazione_tecnico' : intervento.relazione_tecnico,
          'firma_cliente': intervento.firma_cliente,
          'utente_apertura' : intervento.utente_apertura?.toMap(),
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
        codiceDaneaController.clear();
        print('EVVAIIIIIIII');
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Errore durante il salvataggio del intervento: $e');
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row){
    final InterventoModel intervento = row.getCells().firstWhere(
          (cell) => cell.columnName == 'intervento',
    ).value as InterventoModel;
    Color? prioritaColor;
    switch (intervento.priorita) {
      case Priorita.BASSA :
        prioritaColor = Colors.lightGreen;
        break;
      case Priorita.MEDIA :
        prioritaColor = Colors.yellow; // grigio chiaro
        break;
      case Priorita.ALTA:
        prioritaColor = Colors.orange; // giallo chiaro
        break;
      case Priorita.URGENTE:
        prioritaColor = Colors.red; // azzurro chiaro
        break;
      default:
        prioritaColor = Colors.blueGrey[200];
    }
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell){
          if (dataGridCell.columnName == 'intervento') {
            // Cella invisibile per l'oggetto InterventoModel
            return SizedBox.shrink(); // La cella sarà invisibile ma presente
          }
          if( dataGridCell.columnName == 'priorita'){
            return Container(
              color: prioritaColor,
            );
          }
          if (dataGridCell.value is Widget) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey[600]!,
                    width: 1,
                  ),
                ),
              ),
              child: dataGridCell.value,
            );
          } else {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DettaglioInterventoPage(intervento: intervento),
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey[600]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  dataGridCell.value.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }
        }).toList(),
    );
  }
}