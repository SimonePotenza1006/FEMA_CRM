import 'package:flutter/material.dart';

class InterventoTecnicoForm extends StatefulWidget {
  const InterventoTecnicoForm({super.key});

  @override
  _InterventoTecnicoFormState createState() => _InterventoTecnicoFormState();
}

class _InterventoTecnicoFormState extends State<InterventoTecnicoForm>{
  DateTime _dataOdierna = DateTime.now();
  TimeOfDay _orarioInizio = TimeOfDay.now();
  TimeOfDay _orarioFine = TimeOfDay.now();
  String _descrizione = '';
  bool _interventoConcluso = false;

  Future<void> _selezionaData() async {
    final DateTime? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: _dataOdierna,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataSelezionata != null && dataSelezionata != _dataOdierna) {
      setState(() {
        _dataOdierna = dataSelezionata;
      });
    }
  }

  Future<void> _selezionaOrarioInizio() async {
    final TimeOfDay? orarioSelezionato = await showTimePicker(
      context: context,
      initialTime: _orarioInizio,
    );
    if (orarioSelezionato != null && orarioSelezionato != _orarioInizio) {
      setState(() {
        _orarioInizio = orarioSelezionato;
      });
    }
  }

  Future<void> _selezionaOrarioFine() async {
    final TimeOfDay? orarioSelezionato = await showTimePicker(
      context: context,
      initialTime: _orarioFine,
    );
    if (orarioSelezionato != null && orarioSelezionato != _orarioFine) {
      setState(() {
        _orarioFine = orarioSelezionato;
      });
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserimento Intervento Tecnico'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Data Odierna: ${_dataOdierna.day}/${_dataOdierna.month}/${_dataOdierna.year}'),
              ElevatedButton(
                onPressed: _selezionaData,
                child: const Text('Seleziona Data'),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selezionaOrarioInizio,
                      child: Text('Orario Inizio: ${_orarioInizio.format(context)}'),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selezionaOrarioFine,
                      child: Text('Orario Fine: ${_orarioFine.format(context)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrizione'),
                onChanged: (value) {
                  setState(() {
                    _descrizione = value;
                  });
                },
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  const Text('Intervento Concluso:'),
                  Checkbox(
                    value: _interventoConcluso,
                    onChanged: (bool? value) {
                      setState(() {
                        _interventoConcluso = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Qui puoi inviare i dati del form o eseguire altre azioni necessarie
                },
                child: const Text('Salva Intervento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}