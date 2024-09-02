import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart' as exc;
import 'package:fema_crm/pages/DettaglioSpesaVeicoloPage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import '../model/SpesaVeicoloModel.dart';
import '../model/VeicoloModel.dart';

class TableSpeseVeicoliPage extends StatefulWidget{
  TableSpeseVeicoliPage({Key? key}) : super(key: key);

  @override
  _TableSpeseVeicoliPageState createState() =>_TableSpeseVeicoliPageState();
}

class _TableSpeseVeicoliPageState extends State<TableSpeseVeicoliPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  late SpesaDataSource _dataSource;
  VeicoloModel? _selectedVeicolo;
  List<SpesaVeicoloModel> allSpese = [];
  int _selectedYear = DateTime.now().year;
  Map<String, double> _columnWidths ={
    'spesa' : 0,
    'data' : 200,
    'veicolo' : 200,
    'tipologia_spesa' : 200,
    'note_tipologia' : 200,
    'fornitore' : 200,
    'note_fornitore' : 200,
    'importo' : 200,
    'chilometraggio' : 200,
    'utente' : 200,
    'totale_importo' : 200
  };

  Future<void> _pickYear() async {
    int? selectedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempYear = _selectedYear;
        return AlertDialog(
          title: Text('Seleziona Anno'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 300, // Assicurati che il dialogo prenda tutta la larghezza disponibile
                child: ListView.builder( // Usa ListView.builder con shrinkWrap
                  shrinkWrap: true,
                  itemCount: DateTime.now().year - 2020,
                  itemBuilder: (context, index) {
                    int year = DateTime.now().year - index; // Cast esplicito a int non necessario
                    return RadioListTile<int>(
                      title: Text('$year'),
                      value: year,
                      groupValue: tempYear,
                      onChanged: (value) {
                        setState(() {
                          tempYear = value!;
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, tempYear);
              },
              child: Text('Seleziona'),
            ),
          ],
        );
      },
    );
    if (selectedYear != null && selectedYear != _selectedYear) {
      setState(() {
        _selectedYear = selectedYear;
      });
      filterSpeseByYear(selectedYear);
    }
  }

  void filterSpeseByYear(int year) {
    setState(() {
      List<SpesaVeicoloModel> filteredSpese = allSpese
          .where((spesa) =>
      spesa.data != null && spesa.data!.year == year)
          .toList();
      _dataSource = SpesaDataSource(context, filteredSpese);
    });
  }

  @override
  void initState(){
    super.initState();
    getAllSpese();
    _dataSource = SpesaDataSource(context, allSpese);
  }

  Future<void> getAllSpese() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/spesaVeicolo/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<SpesaVeicoloModel> spese = [];
        for (var item in jsonData) {
          spese.add(SpesaVeicoloModel.fromJson(item));
        }
        spese.sort((a, b) => a.veicolo!.id!.compareTo(b.veicolo!.id!));
        setState(() {
          allSpese = spese;
          _dataSource = SpesaDataSource(context, allSpese);
        });
      } else {
        throw Exception(
            'Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Errore di connessione'),
            content: Text(
                'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.'),
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

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("REPORT SPESE SU VEICOLO",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.calendar_today, color: Colors.white,),
                onPressed: _pickYear,
              ),
              SizedBox(width: 5),
              Text(
                '${_selectedYear}', style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 20,)
            ],
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
                child: SfDataGrid(
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
                      columnName: 'spesa',
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
                          'SPESA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['spesa']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'data',
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
                          'DATA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'veicolo',
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
                          'VEICOLO',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['veicolo']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'tipologia_spesa',
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
                          'TIPOLOGIA SPESA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['tipologia_spesa']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'note_tipologia',
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
                          'NOTE TIPOLOGIA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['note_tipologia']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'fornitore',
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
                          'FORNITORE',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['fornitore']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'note_fornitore',
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
                          'NOTE FORNITORE',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['note_fornitore']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'importo',
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
                          'IMPORTO',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['importo']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'chilometraggio',
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
                          'CHILOMETRAGGIO',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['chilometraggio']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'utente',
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
                          'UTENTE',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['utente']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'totale_importo',
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
                          'TOTALE IMPORTO',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['totale_importo'] ?? double.nan,
                      minimumWidth: 0,
                    ),
                  ],
                  onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                    setState(() {
                      _columnWidths[details.column.columnName] = details.width;
                    });
                    return true;
                  },
                )
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _showVehicleSelectionDialog,
        child: Icon(
          Icons.download,
          color: Colors.white,
        ),
      ),
    );
  }

  List<VeicoloModel> getUniqueVeicoli() {
    Map<int, VeicoloModel> veicoloMap = {}; // Usa una mappa per evitare duplicati
    for (var spesa in allSpese) {
      if (spesa.veicolo != null) {
        veicoloMap[int.parse(spesa.veicolo!.id!.toString())] = spesa.veicolo!;
      }
    }
    return veicoloMap.values.toList();
  }

  void _showVehicleSelectionDialog() async {
    List<VeicoloModel> uniqueVeicoli = getUniqueVeicoli();
    VeicoloModel? selectedVeicolo = await showDialog<VeicoloModel>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Seleziona Veicolo'),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: uniqueVeicoli.length,
              itemBuilder: (context, index) {
                VeicoloModel veicolo = uniqueVeicoli[index];
                return ListTile(
                  title: Text(veicolo.descrizione ?? 'Sconosciuto'),
                  onTap: () {
                    setState(() {
                      _selectedVeicolo = veicolo;
                    });
                    Navigator.pop(context, veicolo);
                  },
                );
              },
            ),
          ),
        );
      },
    );
    if (selectedVeicolo != null) {
      _generateAndDownloadExcel(selectedVeicolo);
    }
  }

  Future<void> _generateAndDownloadExcel(VeicoloModel veicolo) async {
    try {
      List<SpesaVeicoloModel> filteredSpese = allSpese
          .where((spesa) =>
      spesa.veicolo?.id == veicolo.id &&
          spesa.data != null &&
          spesa.data!.year == _selectedYear)
          .toList();
      // Crea un nuovo file Excel
      final excel = exc.Excel.createExcel();
      // Crea il foglio principale "SpeseVeicolo"
      exc.Sheet sheetObject = excel['Sheet1'];
      // Aggiungi intestazioni al foglio
      sheetObject.appendRow([
        'Data      ',
        'Veicolo      ',
        'Tipologia Spesa        ',
        'Importo       ',
        'Chilometraggio        ',
        'Utente       '
      ]);
      // Aggiungi i dati delle spese filtrate
      for (var spesa in filteredSpese) {
        sheetObject.appendRow([
          DateFormat('dd/MM/yyyy').format(spesa.data!),
          veicolo.descrizione ?? '',
          spesa.tipologia_spesa?.descrizione ?? '',
          spesa.importo?.toString() ?? '',
          spesa.km?.toString() ?? '',
          spesa.utente?.nomeCompleto() ?? ''
        ]);
      }
      Directory? directory;
      String filePath;
      try {
        late String filePath;
        if (Platform.isWindows) {
          String appDocumentsPath = 'C:\\APP_FEMA\\spese_${_selectedVeicolo!.descrizione!.toString().replaceAll(" ", "_")}';
          filePath = '$appDocumentsPath\\report_spese_${_selectedYear.toString()}.xlsx';
        } else if (Platform.isAndroid) {
          Directory? externalStorageDir = await getExternalStorageDirectory();
          if (externalStorageDir != null) {
            String appDocumentsPath = externalStorageDir.path;
            filePath = '$appDocumentsPath/report_registro_cassa.xlsx';
          } else {
            throw Exception('Impossibile ottenere il percorso di salvataggio.');
          }
        }
        var excelBytes = await excel.encode();
        if (excelBytes != null) {
          await File(filePath).create(recursive: true).then((file) {
            file.writeAsBytesSync(excelBytes);
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Excel salvato in $filePath')));
          OpenFile.open(filePath);
        } else {
          // Gestisci il caso in cui excel.encode() restituisce null
          print('Errore durante la codifica del file Excel');
        }
      } catch (error) {
        // Gestisci eventuali errori durante il salvataggio del file
        print('Errore durante il salvataggio del file Excel: $error');
      }
    } catch(e){
      print('Nope $e');
    }
  }


}

class SpesaDataSource extends DataGridSource {
  List<SpesaVeicoloModel> _spese = [];
  BuildContext context;
  String ipaddres = 'http://gestione.femasistemi.it:8090';

  SpesaDataSource(this.context, List<SpesaVeicoloModel> spese) {
    _spese = spese;
  }

  // Funzione per calcolare il totale per tipologia e veicolo
  double calcolaTotalePerTipologiaEVeicolo(SpesaVeicoloModel spesaCorrente) {
    double totale = 0.0;

    for (var spesa in _spese) {
      if (spesa.veicolo?.id == spesaCorrente.veicolo?.id &&
          spesa.tipologia_spesa?.id == spesaCorrente.tipologia_spesa?.id) {
        // Verifichiamo il tipo di 'importo' e lo convertiamo in double se necessario
        if (spesa.importo is double) {
          totale += spesa.importo as double;
        } else if (spesa.importo is String) {
          totale += double.tryParse(spesa.importo as String) ?? 0.0;
        } else {
          totale += 0.0;
        }
      }
    }
    return totale;
  }


  @override
  List<DataGridRow> get rows {
    List<DataGridRow> rows = [];
    for (int i = 0; i < _spese.length; i++) {
      SpesaVeicoloModel spesa = _spese[i];
      String? formattedData = spesa.data != null
          ? DateFormat('dd/MM/yyyy').format(spesa.data!)
          : "//";
      String? veicolo =
      spesa.veicolo != null ? spesa.veicolo!.descrizione! : '//';
      String? tipologia = spesa.tipologia_spesa != null
          ? spesa.tipologia_spesa!.descrizione!
          : '//';
      String? noteTipologia = spesa.note_tipologia_spesa != null
          ? spesa.note_tipologia_spesa!
          : '//';
      String? fornitore =
      spesa.fornitore_carburante != null ? spesa.fornitore_carburante! : "//";
      String? noteFornitore =
      spesa.note_fornitore != null ? spesa.note_fornitore! : '//';
      String? importo =
      spesa.importo != null ? spesa.importo.toString() + '€' : '//';
      String? chilometraggio =
      spesa.km != null ? spesa.km.toString() + ' km' : '//';
      String? utente =
      spesa.utente != null ? spesa.utente!.nomeCompleto() : '//';

      // Calcolo del totale per tipologia e veicolo
      double totaleImporto = calcolaTotalePerTipologiaEVeicolo(spesa);

      rows.add(DataGridRow(cells: [
        DataGridCell<SpesaVeicoloModel?>(columnName: 'spesa', value: spesa),
        DataGridCell<String?>(columnName: 'data', value: formattedData),
        DataGridCell<String?>(columnName: 'veicolo', value: veicolo),
        DataGridCell<String?>(columnName: 'tipologia_spesa', value: tipologia),
        DataGridCell<String?>(columnName: 'note_tipologia', value: noteTipologia),
        DataGridCell<String?>(columnName: 'fornitore', value: fornitore),
        DataGridCell<String?>(columnName: 'note_fornitore', value: noteFornitore),
        DataGridCell<String?>(columnName: 'importo', value: importo),
        DataGridCell<String?>(columnName: 'chilometraggio', value: chilometraggio),
        DataGridCell<String?>(columnName: 'utente', value: utente),
        DataGridCell<String?>(
            columnName: 'totale_importo', value: "Tot. ${tipologia}: " + totaleImporto.toStringAsFixed(2) + '€'),
      ]));
    }
    return rows;
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final SpesaVeicoloModel spesa = row
        .getCells()
        .firstWhere((cell) => cell.columnName == 'spesa')
        .value;

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        final String columnName = dataGridCell.columnName;
        final value = dataGridCell.value;

        Color textColor = Colors.black;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DettaglioSpesaVeicoloPage(spesa: spesa),
              ),
            );
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Text(
              value.toString(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textColor),
            ),
          ),
        );
      }).toList(),
    );
  }
}
