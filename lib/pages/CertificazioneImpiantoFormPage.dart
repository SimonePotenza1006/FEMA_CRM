import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import '../Util/getTextFormFieldSmall.dart';
import '../model/AziendaModel.dart';
import '../model/TipologiaInterventoModel.dart';

class CertificazioneImpiantoFormPage extends StatefulWidget{
  const CertificazioneImpiantoFormPage({Key? key}) : super(key:key);

  @override
  _CertificazioneImpiantoFormPageState createState() => _CertificazioneImpiantoFormPageState();
}

class _CertificazioneImpiantoFormPageState extends State<CertificazioneImpiantoFormPage>{

  DbHelper? dbHelper;

  final _protocolloController = TextEditingController();
  final _aziendaController = TextEditingController();
  final _tipologiaController = TextEditingController();
  final _indirizzoAziendaController = TextEditingController();
  final _conTelefonoAzienda = TextEditingController();
  final _conPIvaAzienda = TextEditingController();
  final _cittaRegistroDittaController = TextEditingController();
  final _codRegistroDittaController = TextEditingController();
  final _cittaAlboProvincialeController = TextEditingController();
  final _codAlboProvincialeController = TextEditingController();
  final _descrizioneImpiantoController = TextEditingController();
  final _altroController = TextEditingController();
  final _denominazioneClienteController = TextEditingController();
  final _comuneClienteController = TextEditingController();
  final _provinciaClienteController = TextEditingController();
  final _viaClienteController = TextEditingController();
  final _numeroClienteController = TextEditingController();
  final _scalaClienteController = TextEditingController();
  final _pianoClienteController = TextEditingController();
  final _internoClienteController = TextEditingController();
  final _proprietaClienteController = TextEditingController();
  final _progettistaController = TextEditingController();
  final _alboProgettistaController = TextEditingController();
  final  _responsabileTecnicoImpresaController = TextEditingController();
  final  _normaController = TextEditingController();
  final _dataController = TextEditingController();
  final _sottoscrittoController = TextEditingController();

  bool? iscrizioneRegistroDitte = true;
  bool? iscrizioneAlboProvinciale = true;
  bool? nuovoImpianto = false;
  bool? trasformazione = false;
  bool? ampliamento = false;
  bool? manutenzioneStraordinaria = false;
  bool? altro = false;
  bool? industriale = false;
  bool? civile = false;
  bool? commercio = false;
  bool? altriUsi = false;
  bool? progettista = false;
  bool? responsabileTecnicoImpresa = false;
  bool? checkNorma = false;
  bool? installazioneComponenti = false;
  bool? controlloImpianto = false;
  bool? verificaImpianto = false;
  bool? progetto = false;
  bool? relazione = false;
  bool? schema = false;
  bool? riferimento = false;
  bool? visura = false;
  bool? conformita = false;

  List<TipologiaInterventoModel> allTipologie = [];
  List<AziendaModel> allAziende = [];
  AziendaModel? selectedAzienda;
  TipologiaInterventoModel? selectedTipologia;

  @override
  void initState() {
    dbHelper = DbHelper();
    init();
    super.initState();
    _dataController.text = DateFormat("dd/MM/yyyy").format(DateTime.now());
  }

  Future<void> init() async {
    allTipologie = await dbHelper?.getAllTipologieIntervento() ?? [];
    allAziende = await dbHelper?.getAllAziende() ?? [];
  }

  void _openTipologiaDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('SELEZIONA TIPOLOGIA IMPIANTO'),
          content: Container(
            height: 400,
            width: 390,
            child: ListView.builder(
                itemCount: allTipologie.length,
                itemBuilder: (BuildContext context, int index){
                  final tipologia = allTipologie[index];
                  return ListTile(
                    title: Text(tipologia.descrizione!),
                    onTap: (){
                      setState(() {
                        selectedTipologia = tipologia;
                        _tipologiaController.text = tipologia.descrizione!;
                      });
                    },
                  );
                }
            ),
          ),
        );
      }
    );
  }

  void _openAziendeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleziona azienda emettitrice'.toUpperCase()),
          content: Container(
            // Limitiamo l'altezza del dialogo per evitare che cresca troppo
            height: 300,
            width: 390,
            child: ListView.builder(
              itemCount: allAziende.length,
              itemBuilder: (BuildContext context, int index) {
                final azienda = allAziende[index];
                return ListTile(
                  title: Text(azienda.nome!),
                  onTap: () {
                    setState(() {
                      selectedAzienda = azienda;
                      _aziendaController.text = azienda.nome!;
                      _indirizzoAziendaController.text = azienda.sede_legale!;
                      _conTelefonoAzienda.text = azienda.telefono!;
                      _conPIvaAzienda.text = azienda.partita_iva!;
                      _cittaAlboProvincialeController.text = azienda.citta_albo!;
                      _cittaRegistroDittaController.text = azienda.citta_rea!;
                      _codRegistroDittaController.text = "${azienda.citta_rea!.substring(0,2)} - ${azienda.numero_rea}";
                      _codAlboProvincialeController.text = "${azienda.citta_albo!.substring(0,2)} - ${azienda.numero_albo != null ? azienda.numero_albo : ''}";
                    });
                    Navigator.of(context).pop(); // Chiude il dialogo
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text('Compilazione certificazione impianto', style: TextStyle(color: Colors.white)),
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
                  child: Icon(Icons.warehouse_outlined, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Seleziona azienda'.toUpperCase(),
                  onTap: () => _openAziendeDialog(),
                ),
                SpeedDialChild(
                  child: Icon(Icons.build, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Seleziona tipologia'.toUpperCase(),
                  onTap: () => _openTipologiaDialog(),
                ),
              ],
            ),
          )
        ],
      ),
      body: Form(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: InteractiveViewer(
                scaleEnabled: false,
                panEnabled: false,
                minScale: 0.1,
                maxScale: 4,
                child: Container(
                  padding: EdgeInsets.all(85),
                  color: Colors.white,
                  child: Center(

                    child: SizedBox(
                      width: 1000,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DICHIARAZIONE DI CONFORMITA\' DELL\'IMPIANTO A REGOLA D\'ARTE',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  Text(
                                    'Decreto Ministeriale 22 Gennaio 2008, numero 37',
                                    style: TextStyle(fontSize: 14),
                                  )
                                ],
                              ),
                              Container(
                                width: 200,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(width: 2,),
                                        Text(
                                            'Prot. n. (1)'
                                        ),
                                        RichText(text: TextSpan(
                                            children: <InlineSpan>[
                                              WidgetSpan(child: ConstrainedBox(
                                                constraints: BoxConstraints(maxWidth: 120),
                                                child: IntrinsicWidth(
                                                  child: getTextFormFieldSmall(
                                                    controller: _protocolloController,
                                                    width: 120,
                                                    inputType: TextInputType.text,
                                                    hintName: 'Numero protocollo *',
                                                  ),
                                                ),
                                              ))
                                            ]
                                        ))

                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RichText(text: TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontSize: 17),
                                    text: 'Il Sottoscritto MAZZEI FEDERICO, titolare o legale rappresentante dell\'impresa  ',
                                  ),
                                  WidgetSpan(child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: 250),
                                    child: IntrinsicWidth(
                                      child: getTextFormFieldSmall(
                                        width: 250,
                                        controller: _aziendaController,
                                        inputType: TextInputType.text,
                                        hintName: 'Nome azienda *',
                                      ),
                                    ),
                                  )),
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontSize: 17),
                                    text: ' ,',
                                  ),
                                ],

                              ),)
                            ],
                          ),
                          SizedBox(height:2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RichText(text: TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontSize: 17),
                                      text: 'operante nel settore  ',
                                    ),
                                    WidgetSpan(child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 100),
                                      child: IntrinsicWidth(
                                        child: getTextFormFieldSmall(
                                          controller: _tipologiaController,
                                          width: 180,
                                          inputType: TextInputType.text,
                                          hintName: 'Tipologia intervento *',
                                        ),
                                      ),
                                    )),
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontSize: 17),
                                      text: '  con sede in  ',
                                    ),
                                    WidgetSpan(child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 100),
                                      child: IntrinsicWidth(
                                        child: getTextFormFieldSmall(
                                          controller: _indirizzoAziendaController,
                                          width: 395,
                                          inputType: TextInputType.text,
                                          hintName: 'Indirizzo azienda',
                                        ),
                                      ),
                                    )),
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontSize: 17),
                                      text: ' ,',
                                    ),
                                  ]
                              ))
                            ],
                          ),
                          SizedBox(height:2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RichText(text: TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                        text: 'tel. '
                                    ),
                                    WidgetSpan(child: ConstrainedBox(
                                      constraints: const BoxConstraints(minWidth: 150),
                                      child: IntrinsicWidth(
                                        child: getTextFormFieldSmall(
                                          width: 150,
                                          controller: _conTelefonoAzienda,
                                          inputType: TextInputType.text,
                                          hintName: 'Telefono azienda *',
                                        ),
                                      ),
                                    ),
                                    ),
                                    TextSpan(
                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                        text: ' , P.IVA  '
                                    ),
                                    WidgetSpan(child: ConstrainedBox(
                                      constraints: const BoxConstraints(minWidth: 150),
                                      child: IntrinsicWidth(
                                        child: getTextFormFieldSmall(
                                          width: 150,
                                          controller: _conPIvaAzienda,
                                          inputType: TextInputType.text,
                                          hintName: 'P.IVA azienda *',
                                        ),
                                      ),
                                    ),
                                    ),
                                  ]
                              ))
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Checkbox(
                                value : iscrizioneRegistroDitte,
                                onChanged : (value) => setState(() => iscrizioneRegistroDitte = value),
                              ),
                              SizedBox(width : 1),
                              RichText(text: TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontSize: 14),
                                    text: ' iscritta nel registro delle ditte (DPR 07/12/1995, n 581) della camera C.I.A.A. di ',
                                  ),
                                  WidgetSpan(child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: 100),
                                    child: IntrinsicWidth(
                                      child: getTextFormFieldSmall(
                                        width: 100,
                                        controller: _cittaRegistroDittaController,
                                        inputType: TextInputType.text,
                                        hintName: 'Città registro ditta *',
                                      ),
                                    ),
                                  )),
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontSize: 14),
                                    text: ' n. ',
                                  ),
                                  WidgetSpan(child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: 150),
                                    child: IntrinsicWidth(
                                      child: getTextFormFieldSmall(
                                        width: 150,
                                        controller: _codRegistroDittaController,
                                        inputType: TextInputType.text,
                                        hintName: 'Codice registro ditta *',
                                      ),
                                    ),
                                  )),
                                ],

                              ),)
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Checkbox(
                                value : iscrizioneAlboProvinciale,
                                onChanged : (value) => setState(() => iscrizioneAlboProvinciale = value),
                              ),
                              SizedBox(width : 1),
                              RichText(text: TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontSize: 14),
                                    text: ' iscritta all\'Albo Provinciale delle Imprese Artigiane (L: 8/8/1985, n 443) di ',
                                  ),
                                  WidgetSpan(child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: 180),
                                    child: IntrinsicWidth(
                                      child: getTextFormFieldSmall(
                                        width: 180,
                                        controller: _cittaAlboProvincialeController,
                                        inputType: TextInputType.text,
                                        hintName: 'Città registrazione albo provinciale *',
                                      ),
                                    ),
                                  )),
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontSize: 14),
                                    text: ' n. ',
                                  ),
                                  WidgetSpan(child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: 150),
                                    child: IntrinsicWidth(
                                      child: getTextFormFieldSmall(
                                        width: 150,
                                        controller: _codAlboProvincialeController,
                                        inputType: TextInputType.text,
                                        hintName: 'Codice albo provinciale *',
                                      ),
                                    ),
                                  )),
                                ],
                              ),)
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              RichText(text: TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontSize: 17),
                                      text: 'Esecutrice dell\'impianto (2): ',
                                    ),
                                    WidgetSpan(child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 630),
                                      child: IntrinsicWidth(
                                        child: getTextFormFieldSmall(
                                          width: 630,
                                          controller: _descrizioneImpiantoController,
                                          inputType: TextInputType.text,
                                          hintName: 'Codice albo provinciale *',
                                        ),
                                      ),
                                    )),
                                  ]
                              ))
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Nota - Per gli impianti a gas specificare il tipo di gas distibuito: canalizzato 1, 2, 3 famiglia: GPL da serbatoio fisso',
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            'Per gli impianti elettrici specificare la potenza massima impiegata',
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            'Inteso come:',
                            style: TextStyle(fontSize: 17),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value : nuovoImpianto,
                                onChanged : (value) => setState(() => nuovoImpianto= value),
                              ),
                              SizedBox(width: 2),
                              Text('nuovo impianto;')
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value : trasformazione,
                                onChanged : (value) => setState(() => trasformazione= value),
                              ),
                              SizedBox(width: 2),
                              Text('trasformazione;')
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value : ampliamento,
                                onChanged : (value) => setState(() => ampliamento= value),
                              ),
                              SizedBox(width: 2),
                              Text('ampliamento;')
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value : manutenzioneStraordinaria,
                                onChanged : (value) => setState(() => manutenzioneStraordinaria= value),
                              ),
                              SizedBox(width: 2),
                              Text('manutenzione straordinaria;')
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value : altro,
                                onChanged : (value) => setState(() => altro = value),
                              ),
                              SizedBox(width: 2),
                              Text('altro (3)  '),
                              ConstrainedBox(
                                constraints: BoxConstraints(minWidth: 150),
                                child: IntrinsicWidth(
                                  child: getTextFormFieldSmall(
                                    width: 150,
                                    controller: _altroController,
                                    inputType: TextInputType.text,
                                    hintName: 'Altro *',
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RichText(text: TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontSize: 17),
                                      text: 'Commissionato da: ',
                                    ),
                                    WidgetSpan(child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 260),
                                      child: IntrinsicWidth(
                                        child: getTextFormFieldSmall(
                                          width: 260,
                                          controller: _denominazioneClienteController,
                                          inputType: TextInputType.text,
                                          hintName: 'Denominazione cliente *',
                                        ),
                                      ),
                                    )),
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontSize: 17),
                                      text: ' Installato nei locali siti nel Comune di  ',
                                    ),
                                    WidgetSpan(child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 140),
                                      child: IntrinsicWidth(
                                        child: getTextFormFieldSmall(
                                          width: 140,
                                          controller: _comuneClienteController,
                                          inputType: TextInputType.text,
                                          hintName: 'Comune *',
                                        ),
                                      ),
                                    )),
                                  ]
                              )),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                RichText(text: TextSpan(
                                    children: <InlineSpan>[
                                      TextSpan(
                                          style: TextStyle(color: Colors.black, fontSize: 17),
                                          text: '(prov. '
                                      ),
                                      WidgetSpan(child: ConstrainedBox(
                                        constraints: BoxConstraints(minWidth: 30),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 30,
                                            controller: _provinciaClienteController,
                                            inputType: TextInputType.text,
                                            hintName: 'Provincia *',
                                          ),
                                        ),
                                      )),
                                      TextSpan(
                                          style: TextStyle(color: Colors.black, fontSize: 17),
                                          text: ') Via '
                                      ),
                                      WidgetSpan(child: ConstrainedBox(
                                        constraints: BoxConstraints(minWidth: 220),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 220,
                                            controller: _viaClienteController,
                                            inputType: TextInputType.text,
                                            hintName: 'Via *',
                                          ),
                                        ),
                                      )),
                                      TextSpan(
                                          style: TextStyle(color: Colors.black, fontSize: 17),
                                          text: ' n. '
                                      ),
                                      WidgetSpan(child: ConstrainedBox(
                                        constraints: BoxConstraints(minWidth: 30),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 30,
                                            controller: _numeroClienteController,
                                            inputType: TextInputType.text,
                                            hintName: 'Numero *',
                                          ),
                                        ),
                                      )),
                                      TextSpan(
                                          style: TextStyle(color: Colors.black, fontSize: 17),
                                          text: ' scala '
                                      ),
                                      WidgetSpan(child: ConstrainedBox(
                                        constraints: BoxConstraints(minWidth: 50),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 50,
                                            controller: _scalaClienteController,
                                            inputType: TextInputType.text,
                                            hintName: 'Scala *',
                                          ),
                                        ),
                                      )),
                                      TextSpan(
                                          style: TextStyle(color: Colors.black, fontSize: 17),
                                          text: ' piano '
                                      ),
                                      WidgetSpan(child: ConstrainedBox(
                                        constraints: BoxConstraints(minWidth: 50),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 50,
                                            controller: _pianoClienteController,
                                            inputType: TextInputType.text,
                                            hintName: 'Piano *',
                                          ),
                                        ),
                                      )),
                                      TextSpan(
                                          style: TextStyle(color: Colors.black, fontSize: 17),
                                          text: ' interno '
                                      ),
                                      WidgetSpan(child: ConstrainedBox(
                                        constraints: BoxConstraints(minWidth: 50),
                                        child: IntrinsicWidth(
                                          child: getTextFormFieldSmall(
                                            width: 50,
                                            controller: _internoClienteController,
                                            inputType: TextInputType.text,
                                            hintName: 'Interno *',
                                          ),
                                        ),
                                      )),
                                    ]
                                ))
                              ]
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RichText(text: TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                        text: 'di proprietà di '
                                    ),
                                    WidgetSpan(child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 400),
                                      child: IntrinsicWidth(
                                        child: getTextFormFieldSmall(
                                          width: 400,
                                          controller: _proprietaClienteController,
                                          inputType: TextInputType.text,
                                          hintName: 'Proprietà *',
                                        ),
                                      ),
                                    )),
                                    TextSpan(
                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                        text: ' in edificio adibito ad uso : '
                                    ),
                                  ]
                              ))
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(value: industriale,
                                onChanged: (value) => setState(() => industriale = value),
                              ),
                              SizedBox(width: 2),
                              Text(
                                  'industriale;'
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(value: civile,
                                onChanged: (value) => setState(() => civile = value),
                              ),
                              SizedBox(width: 2),
                              Text(
                                  'civile;'
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(value: commercio,
                                onChanged: (value) => setState(() => commercio = value),
                              ),
                              SizedBox(width: 2),
                              Text(
                                  'commercio;'
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(value: altriUsi,
                                onChanged: (value) => setState(() => altriUsi = value),
                              ),
                              SizedBox(width: 2),
                              Text(
                                  'altri usi;'
                              ),
                            ],
                          ),
                          Center(
                            child: Text(
                              'DICHIARA', style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                              style: TextStyle(color: Colors.black, fontSize: 17),
                              'sotto la propria personale responsabilità, che l\'impianto è stato realizzato in modo conforme alla regola d\'arte, secondo\n'
                                  'quanto previsto previsto dall\'art. 6, tenuto conto delle condizioni di esercizio e degli usi a cui è destinato l\'edificio, avendo\n in particolare:'
                          ),
                          SizedBox(height:2),
                          Row(
                            children: [
                              Icon(
                                  Icons.arrow_right_alt
                              ),
                              SizedBox(width: 5),
                              Text(
                                  'rispettato il progetto redatto all\'articolo 5 dal (5):'
                              ),
                            ],
                          ),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Checkbox(value: progettista, onChanged: (value) => setState(() => progettista = value)),
                                    SizedBox(width: 3),
                                    RichText(text: TextSpan(
                                        children: <InlineSpan>[
                                          TextSpan(
                                            style: TextStyle(color: Colors.black, fontSize: 17),
                                            text: 'Progettista '
                                          ),
                                          WidgetSpan(child: ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 160),
                                            child: IntrinsicWidth(
                                              child: getTextFormFieldSmall(
                                                width: 160,
                                                controller: _progettistaController,
                                                inputType: TextInputType.text,
                                                hintName: 'Nome progettista *',
                                              ),
                                            ),
                                          )),
                                          TextSpan(
                                              style: TextStyle(color: Colors.black, fontSize: 17),
                                              text: ' nr. Iscrizione Albo '
                                          ),
                                          WidgetSpan(child: ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 160),
                                            child: IntrinsicWidth(
                                              child: getTextFormFieldSmall(
                                                width: 160,
                                                controller: _alboProgettistaController,
                                                inputType: TextInputType.text,
                                                hintName: 'Nome progettista *',
                                              ),
                                            ),
                                          )),
                                          TextSpan(
                                              style: TextStyle(color: Colors.black, fontSize: 17),
                                              text: ' ;'
                                          ),
                                        ]
                                    ))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Checkbox(value: responsabileTecnicoImpresa, onChanged: (value) => setState(() => responsabileTecnicoImpresa = value)),
                                    SizedBox(width: 3),
                                    RichText(text: TextSpan(
                                      children: <InlineSpan>[
                                        TextSpan(
                                          style: TextStyle(color: Colors.black, fontSize: 17),
                                          text: 'Responsabile Tecnico dell\'impresa '
                                        ),
                                        WidgetSpan(child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: 292),
                                          child: IntrinsicWidth(
                                            child: getTextFormFieldSmall(
                                              width: 292,
                                              controller: _responsabileTecnicoImpresaController,
                                              inputType: TextInputType.text,
                                              hintName: 'Nome responsabile tecnico*',
                                            ),
                                          ),
                                        )),
                                        TextSpan(
                                            style: TextStyle(color: Colors.black, fontSize: 17),
                                            text: ' ;'
                                        ),
                                      ]
                                    ))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(value: checkNorma, onChanged: (value) => setState(() => checkNorma = value)),
                                    SizedBox(width: 3),
                                    RichText(text: TextSpan(
                                        children: <InlineSpan>[
                                          TextSpan(
                                              style: TextStyle(color: Colors.black, fontSize: 17),
                                              text: 'seguito la norma tecnica applicabile all\'impiego: (6) '
                                          ),
                                          WidgetSpan(child: ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 292),
                                            child: IntrinsicWidth(
                                              child: getTextFormFieldSmall(
                                                width: 292,
                                                controller: _normaController,
                                                inputType: TextInputType.text,
                                                hintName: 'Norma *',
                                              ),
                                            ),
                                          )),
                                          TextSpan(
                                              style: TextStyle(color: Colors.black, fontSize: 17),
                                              text: ' ;'
                                          ),
                                        ]
                                    ))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(value: installazioneComponenti, onChanged: (value) => setState(() => installazioneComponenti = value)),
                                    SizedBox(width: 3),
                                    Text(
                                      style: TextStyle(color: Colors.black, fontSize: 17),
                                      'installato componenti e materiali adatti al luogo di installazione;'
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(value: controlloImpianto, onChanged: (value) => setState(() => controlloImpianto = value)),
                                    SizedBox(width: 3),
                                    Text(
                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                        'controllato l\'impianto ai fini della sicurezza e della funzionalità con esito positivo, avendo eseguito \n le verifiche richieste dalle norme e dalle disposizioni di legge;'
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(value: verificaImpianto, onChanged: (value) => setState(() => verificaImpianto = value)),
                                    SizedBox(width: 3),
                                    Text(
                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                        'Verificato la compatibilità tecnicca con l\'impianto preesistente (solo per rifacimenti parziali);'
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2),
                          Text('Allegati obbligatori:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Row(
                            children: [
                              Checkbox(value: progetto, onChanged: (value) => setState(() => progetto = value)),
                              SizedBox(width: 3),
                              Text('Progetto (ai sensi dell\'art. 5 e 7); (7)',style: TextStyle(fontSize: 17))
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(value: relazione, onChanged: (value) => setState(() => relazione = value)),
                              SizedBox(width: 3),
                              Text('Relazione con tipologie dei materiali utilizzati; (8)',style: TextStyle(fontSize: 17))
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(value: schema, onChanged: (value) => setState(() => schema = value)),
                              SizedBox(width: 3),
                              Text('Schema di impianto realizzato; (9)',style: TextStyle(fontSize: 17))
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(value: riferimento, onChanged: (value) => setState(() => riferimento = value)),
                              SizedBox(width: 3),
                              Text('Riferimento a dichiarazioni di conformità precedenti o parziali già esistenti; (10)',style: TextStyle(fontSize: 17))
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(value: visura, onChanged: (value) => setState(() => visura = value)),
                              SizedBox(width: 3),
                              Text('Copia del certificato di riconoscimento dei requisiti tecnico-professionali',style: TextStyle(fontSize: 17))
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(value: conformita, onChanged: (value) => setState(() => conformita = value)),
                              SizedBox(width: 3),
                              Text('Attestazione di conformità per impianto realizzatto con materiali o sistemi non normalizzati. (11)',style: TextStyle(fontSize: 17))
                            ],
                          ),
                          SizedBox(height: 2),
                          Text('Allegati facoltativi: (12)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 15),
                          Container(
                            width: 1200,
                            height: 2,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)
                            ),
                          ),
                          SizedBox(height: 8 ),
                          Center(
                            child: Text(
                                'DECLINA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                          ),
                          Text(
                            style: TextStyle(fontSize: 17),
                            'Ogni responsabilità per sinistri a persone o a cose derivanti da manomissione dell\'impianto da parte di terzi \n'
                                'ovvero da carenza di manutenzione o riparazione.'
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Row(
                                      children:[
                                        RichText(
                                            text: TextSpan(
                                                children: <InlineSpan>[
                                                  TextSpan(
                                                      style: TextStyle(color: Colors.black, fontSize: 17),
                                                      text: 'Data '
                                                  ),
                                                  WidgetSpan(child: ConstrainedBox(
                                                    constraints: BoxConstraints(minWidth: 80),
                                                    child: IntrinsicWidth(
                                                      child: getTextFormFieldSmall(
                                                        width: 80,
                                                        controller: _dataController,
                                                        inputType: TextInputType.text,
                                                        hintName: 'Data *',
                                                      ),
                                                    ),
                                                  )),
                                                ]
                                            )
                                        )
                                      ]
                                  ),
                                ),
                                //fine data
                                //inizo box con firma
                                Container(
                                  width: 280,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black, width: 1
                                    )
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 10),
                                      Text('Il responsabile tecnico', style: TextStyle(fontSize: 15)),
                                      Text('(Firma leggibile)(13)', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                //Fine container firma responsabile tecnico
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 14),
                                    Text('Il dichiarante', style: TextStyle(fontSize: 15)),
                                    Text('Timbro e Firma leggibile', style: TextStyle(fontSize: 12)),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 2),
                          RichText(
                              text: TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                        text: 'AVVERTENZE PER IL COMMITTENTE:  '
                                    ),
                                    TextSpan(
                                        style: TextStyle(color: Colors.black, fontSize: 14),
                                        text: 'il committente o proprietario è tenuto ad affidare i lavori di installazione, di trasformazione, \n'
                                            'di ampliamento e di manutenzione degli impianti ad imprese abilitate'
                                    ),
                                  ]
                              )
                          ),
                          SizedBox(height: 2),
                          RichText(
                              text: TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                        style: TextStyle(color: Colors.black, fontSize: 15),
                                        text: 'il sottoscritto (14) '
                                    ),
                                    WidgetSpan(child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 190),
                                      child: IntrinsicWidth(
                                        child: getTextFormFieldSmall(
                                          width: 190,
                                          controller: _sottoscrittoController,
                                          inputType: TextInputType.text,
                                          hintName: 'Sottoscritto *',
                                        ),
                                      ),
                                    )),
                                  ]
                              )
                          ),
                          RichText(
                              text: TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                        style: TextStyle(color: Colors.black, fontSize: 15),
                                        text: 'committente dei lavori, dichiara di aver ricevuto copia della presente, corredata dagli allegati indicati in data(15) '
                                    ),
                                    WidgetSpan(child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 100),
                                      child: IntrinsicWidth(
                                        child: getTextFormFieldSmall(
                                          width: 100,
                                          controller: _dataController,
                                          inputType: TextInputType.text,
                                          hintName: 'data *',
                                        ),
                                      ),
                                    )),
                                  ]
                              )
                          ),
                        ],
                      ),
                    )
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}