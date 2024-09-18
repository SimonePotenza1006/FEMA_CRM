import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io' as io;
import '../model/AziendaModel.dart';
import '../model/UtenteModel.dart';
import 'package:http/http.dart' as http;

class PreventivoServiziPage extends StatefulWidget{
  final UtenteModel utente;
  final String? path;
  final io.File? file;

  PreventivoServiziPage({Key? key, required this.utente, this.path, this.file}) : super(key: key);

  _PreventivoServiziPageState createState() => _PreventivoServiziPageState();
}

class _PreventivoServiziPageState extends State<PreventivoServiziPage> with WidgetsBindingObserver{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  final _formKey = GlobalKey<FormState>();
  List<AziendaModel> allAziende = [];
  AziendaModel? selectedAzienda;
  final _conNumeroPreventivo = TextEditingController();
  final _conDataPreventivo = TextEditingController();
  final _conDenomDestinatario = TextEditingController();
  final _conIndirizzoDestinatario = TextEditingController();
  final _conCittaDestinatario = TextEditingController();
  final _conCFDestinatario = TextEditingController();
  final _conDenomDestinazione = TextEditingController();
  final _conIndirizzoDestinazione = TextEditingController();
  final _conCittaDestinazione = TextEditingController();
  final _conCFDestinazione = TextEditingController();

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
                        height: 600,
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
                                  SizedBox(
                                    width: 100,
                                    child: Center(
                                      child: Text(
                                        'Codice',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 280,
                                    child: Center(
                                      child: Text(
                                        'Descrizione',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 55,
                                    child: Center(
                                      child: Text(
                                        'Quantità',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: Center(
                                      child: Text(
                                        'Prezzo',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Center(
                                      child: Text(
                                        'Sconto',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Center(
                                      child: Text(
                                        'Importo',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Center(
                                      child: Text(
                                        'Iva',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getAllAziende() async{
    try{
      var apiUrl = Uri.parse('${ipaddress}/api/azienda');
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