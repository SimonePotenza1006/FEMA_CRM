import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../model/InterventoModel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intervento Table',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<InterventoModel> _allInterventi = [];
  List<InterventoModel> _filteredInterventi = [];
  int _currentSheet = 0;

  Future<void> getAllInterventi() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/intervento/ordered');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          interventi.add(InterventoModel.fromJson(item));
        }
        setState(() {
          _allInterventi = interventi;
          _filteredInterventi = interventi.where((intervento) => !intervento.concluso).toList();
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  void _changeSheet(int index) {
    setState(() {
      _currentSheet = index;
      switch (index) {
        case 0:
          _filteredInterventi = _allInterventi.where((intervento) => !intervento.concluso).toList();
          break;
        case 1:
          _filteredInterventi = _allInterventi.where((intervento) => intervento.concluso && !intervento.saldato).toList();
          break;
        case 2:
          _filteredInterventi = _allInterventi.where((intervento) => intervento.concluso && intervento.saldato).toList();
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getAllInterventi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Intervento Table'),
      ),
      body: Column(
        children: [
          SfDataGrid(
            source: _filteredInterventi,
            columnWidthMode: ColumnWidthMode.fill,
            columns: [
              GridColumn(
                columnName: 'data_apertura_intervento',
                label: Container(
                  padding: EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Text('Data Apertura'),
                ),
              ),
              GridColumn(
                columnName: 'data',
                label: Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Data'),
                ),
              ),
              GridColumn(
                columnName: 'orario_appuntamento',
                label: Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Orario Appuntamento'),
                ),
              ),
              GridColumn(
                columnName: 'descrizione',
                label: Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Descrizione'),
                ),
              ),
              GridColumn(
                columnName: 'importo_intervento',
                label: Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Importo'),
                ),
              ),
              GridColumn(
                columnName: 'acconto',
                label: Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Acconto'),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _changeSheet(0),
                child: Text('Non Conclusi'),
              ),
              ElevatedButton(
                onPressed: () => _changeSheet(1),
                child: Text('Conclusi non Saldati'),
              ),
              ElevatedButton(
                onPressed: () => _changeSheet(2),
                child: Text('Conclusi e Saldati'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}