import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/pages/CertificazioneImpiantoPdfPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import '../Util/getTextFormFieldSmall.dart';
import '../model/AziendaModel.dart';
import '../model/TipologiaInterventoModel.dart';

class CertificazioneImpiantoFormPageNew extends StatefulWidget{
  const CertificazioneImpiantoFormPageNew({Key? key}) : super(key:key);

  @override
  _CertificazioneImpiantoFormPageNewState createState() => _CertificazioneImpiantoFormPageNewState();
}

class _CertificazioneImpiantoFormPageNewState extends State<CertificazioneImpiantoFormPageNew>{

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

  final _comuneTabellaSchematicaController =TextEditingController();
  final _alimentazioneController = TextEditingController();
  final _tensioneNominaleController = TextEditingController();
  final _collegamentoATerraController = TextEditingController();
  final _correnteCtoController = TextEditingController();
  final _cadutaTensioneController = TextEditingController();
  final _gradoProtezioneInvolucriController = TextEditingController();
  final _potenzaContrattualeController = TextEditingController();
  final _massimaCorrenteImpiegoController = TextEditingController();
  final _sezioneConduttoriController = TextEditingController();
  final _interruttoriDifferenzialiCDController = TextEditingController();
  final _interruttoriMagnetoCDController = TextEditingController();
  final _interruttoriMagnetoCNController = TextEditingController();
  final _fusibiliCNController = TextEditingController();
  final _interruttoriMagnetoPotIntController = TextEditingController();
  final _interruttoriDiffPotIntController = TextEditingController();
  final _fusibiliPotIntController = TextEditingController();
  final _tubiProtettiviController = TextEditingController();
  final _canaliController = TextEditingController();
  final _caviMultipolariController = TextEditingController();
  final _picchettiController = TextEditingController();
  final _cordaRameController = TextEditingController();
  final _tondoAcciaioController = TextEditingController();
  final _ferriArmaturaController = TextEditingController();
  final _collegamentiEquipotenzialiController = TextEditingController();
  final _principaliController = TextEditingController();
  final _supplementariController = TextEditingController();
  final _localiBagnoDocciaController = TextEditingController();
  final _comuneEsamiVistaController = TextEditingController();
  final _noteEsamiVistaController = TextEditingController();

  final _comuneProveEffettuateController = TextEditingController();

  final _noteProveEffettuateController = TextEditingController();


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
  bool? checkProgetto = false;
  bool? installazioneComponenti = false;
  bool? controlloImpianto = false;
  bool? verificaImpianto = false;
  bool? progetto = false;
  bool? relazione = false;
  bool? schema = false;
  bool? riferimento = false;
  bool? visura = false;
  bool? conformita = false;
  bool? esami = false;
  bool? prove = false;
  bool? manuale = false;

  //booleani tabella schematica
  bool? intDifferenzialiTab = false;
  bool? intMagnetoTermiciTab = false;
  bool? nomInterruttoriMagnetotermici = false;
  bool? nomFusibili = false;
  bool? potInterruttoriMagnetotermici = false;
  bool? potDifferenziali = false;
  bool? potFusibili = false;
  bool? tubiProtettiviBool = false;
  bool? canaliBool = false;
  bool? multipolariBool = false;
  bool? picchetti = false;
  bool? cordaRame = false;
  bool? tondoAcciaio = false;
  bool? ferriArmatura = false;
  bool? collegamentiEquipotenziali = false;
  bool? principali = false;
  bool? supplementari = false;
  bool? localiBagno = false;

  //booleani seconda parte della pagina
  bool? componentiElettriciInstallati = false;
  bool? compatibilitaPreesistente = false;
  bool? componentiIdonei = false;
  bool? infoApparecchi = false;

  //booleani esami a vista
  bool? conformitaDocumentazioneTecnica = false;
  bool? caratteristicheComponenti = false;
  bool? protezioniAdeguate = false;
  bool? caduteTensioni = false;
  bool? protezioniConduttureSovraccarichi = false;
  bool? protezioniConduttureCortocircuiti = false;
  bool? sezionamentoCircuiti = false;
  bool? comandoArrestoEmergenza = false;
  bool? tensioneNominaleConduttori = false;
  bool? sezioneMinimaConduttori = false;
  bool? coloreConduttori = false;
  bool? tubiProtettivi = false;
  bool? connessioneConduttori = false;
  bool? interruttoriUnipolari = false;
  bool? dimensioniDispersori = false;
  bool? nodiCollettori = false;
  bool? conduttoreProtezione = false;
  bool? conduttoreEquipotenziale = false;
  bool? conformitaImpiantoElettricoCantiere = false;

  //booleani prove su impianto
  bool? verificaContinuitaConduttori = false;
  bool? minimaResistenzaIsolamento = false;
  bool? misuraResistenzaTerra = false;
  bool? verificaInterruttoreDifferenziale = false;
  bool? polaritaFavorevole = false;
  bool? provaFunzionamento = false;
  bool? sfilabilitaCavi = false;
  bool? diametroTubi = false;



  List<Prodotto> prodotti = [];

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
      margin: EdgeInsets.symmetric(vertical: 2),
      child: TextFormField(
        style: TextStyle(
          fontSize: 13.0, // Imposta la dimensione del carattere
          color: Colors.black, // Puoi anche impostare il colore del testo
        ),
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

  void _rimuoviProdotto(){
    setState(() {
      prodotti.removeLast();
    });
  }

  void _aggiungiProdotto() {
    var nuovoProdotto = Prodotto(
      codiceController: TextEditingController(),
      descrizioneController: TextEditingController(),
      costruttoreController: TextEditingController(),
      ceController: TextEditingController(),
      imqController: TextEditingController(),
      rinaController: TextEditingController(),
      enecController: TextEditingController(),
      altriController: TextEditingController(),
    );

    // Aggiungi i listener ai controllori del nuovo prodotto
    /*nuovoProdotto.codiceController.addListener(_aggiornaTotali);
    nuovoProdotto.descrizioneController.addListener(_aggiornaTotali);
    nuovoProdotto.quantitaController.addListener(_aggiornaTotali);
    nuovoProdotto.prezzoController.addListener(_aggiornaTotali);
    nuovoProdotto.scontoController.addListener(_aggiornaTotali);
    nuovoProdotto.importoController.addListener(_aggiornaTotali);
    nuovoProdotto.ivaController.addListener(_aggiornaTotali);*/

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
        title: Text('Compilazione certificazione impianto', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context)=> CertificazioneImpiantoPdfPage(
                        protocollo : _protocolloController.text,
                        azienda: _aziendaController.text,
                        tipologia : _tipologiaController.text,
                        indirizzo_azienda: _indirizzoAziendaController.text,
                        telefono_azienda: _conTelefonoAzienda.text,
                        p_iva_azienda: _conPIvaAzienda.text,
                        citta_registro_ditta: _cittaRegistroDittaController.text,
                        cod_registro_ditta: _codRegistroDittaController.text,
                        citta_albo: _cittaAlboProvincialeController.text,
                        cod_albo: _codAlboProvincialeController.text,
                        impianto: _descrizioneImpiantoController.text,
                        altro: _altroController.text,
                        denom_cliente: _denominazioneClienteController.text,
                        comune_cliente: _comuneClienteController.text,
                        provincia_cliente: _provinciaClienteController.text,
                        via_cliente: _viaClienteController.text,
                        numero_cliente: _numeroClienteController.text,
                        scala_cliente: _scalaClienteController.text,
                        piano_cliente: _pianoClienteController.text,
                        interno_cliente: _internoClienteController.text,
                        proprieta_cliente: _proprietaClienteController.text,
                        progettista: _progettistaController.text,
                        albo_progettista: _alboProgettistaController.text,
                        responsabile_tecnico: _responsabileTecnicoImpresaController.text,
                        norma: _normaController.text,
                        data: _dataController.text,
                        sottoscritto: _sottoscrittoController.text,
                        iscrizione_registro: iscrizioneRegistroDitte,
                        iscrizione_albo: iscrizioneAlboProvinciale,
                        nuovo_impianto: nuovoImpianto,
                        trasformazione: trasformazione,
                        ampliamento: ampliamento,
                        manutenzione: manutenzioneStraordinaria,
                        bool_altro: altro,
                        industriale: industriale,
                        civile: civile,
                        commercio: commercio,
                        altri_usi: altriUsi,
                        bool_progettista: progettista,
                        bool_responsabile: responsabileTecnicoImpresa,
                        bool_norma: checkNorma,
                        installazione: installazioneComponenti,
                        controllo: controlloImpianto,
                        verifica: verificaImpianto,
                        progetto: progetto,
                        relazione: relazione,
                        schema: schema,
                        riferimento: riferimento,
                        visura: visura,
                        conformita: conformita,
                      ))
              );
            },
            child: Text(
              'Genera Pdf', style : TextStyle(color : Colors.white,fontSize: 17),
            ),
          )
        ],
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
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

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
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'DICHIARAZIONE DI CONFORMITA\' DELL\'IMPIANTO ALLA REGOLA DELL\'ARTE',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),

                                      ],
                                    ),

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
                                          text: ' iscritta nel registro delle imprese (DPR 07/12/1995, n 581) della camera C.I.A.A. di ',
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
                                          text: ' iscritta all\'Albo Provinciale delle Imprese Artigiane (L: 8/8/1985, n 433) di ',
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
                                            text: 'Esecutrice dell\'impianto (descrizione schematica): ',
                                          ),
                                          WidgetSpan(child: ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 600),
                                            child: IntrinsicWidth(
                                              child: getTextFormFieldSmall(
                                                width: 600,
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
                                    Text('altro (1)  '),
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
                                    ),

                                  ],
                                ),
                                Text(
                                  'Nota - Per gli impianti a gas specificare il tipo di gas distibuito: canalizzato della 1^, 2^, 3^ famiglia; GPL da recipienti mobili; '
                                      'fisso; GPL da serbatoio fisso. Per gli impianti elettrici specificare la potenza massima impegnabile.',
                                  style: TextStyle(fontSize: 11),
                                ),
                                Text(
                                  'Potenza massima impegnabile 3kW',
                                  style: TextStyle(fontSize: 11),
                                ),
                                Row(
                                    children: [

                                    ]),
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
                                              text: ' in edificio adibito ad uso: '
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
                                        'industriale'
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
                                        'civile'
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
                                        'commercio'
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
                                        'ad altri usi (CANTIERE)'
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
                                    'sotto la propria personale responsabilità, che l\'impianto è stato realizzato in modo conforme alla regola dell\'arte, secondo\n'
                                        'quanto previsto previsto dall\'art. 6, tenuto conto delle condizioni di esercizio e degli usi a cui è destinato l\'edificio, avendo\n in particolare:'
                                ),
                                SizedBox(height:2),
                                Center(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(value: checkProgetto, onChanged: (value) => setState(() => checkProgetto = value)),
                                          SizedBox(width: 3),
                                          RichText(text: TextSpan(
                                              children: <InlineSpan>[
                                                TextSpan(
                                                    style: TextStyle(color: Colors.black, fontSize: 17),
                                                    text: 'rispettato il progetto redatto ai sensi dell\'art. 5 da (2), iscritto  di  con n. '
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
                                          Checkbox(value: checkNorma, onChanged: (value) => setState(() => checkNorma = value)),
                                          SizedBox(width: 3),
                                          RichText(text: TextSpan(
                                              children: <InlineSpan>[
                                                TextSpan(
                                                    style: TextStyle(color: Colors.black, fontSize: 17),
                                                    text: 'seguito la normativa tecnica applicabile all’impiego (3): CEI 64-8 2024-07'
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
                                              'installato componenti e materiali adatti al luogo di installazione (artt. 5 e 6);'
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
                                              'controllato l’impianto ai fini della sicurezza e della funzionalità con esito positivo, avendo eseguito le verifiche richieste\n dalle norme e dalle disposizioni di legge.'
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text('Allegati obbligatori:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Row(
                                  children: [
                                    Checkbox(value: progetto, onChanged: (value) => setState(() => progetto = value)),
                                    SizedBox(width: 3),
                                    Text('progetto ai sensi degli articoli 5 e 7 (4); (Rif. progetto: )',style: TextStyle(fontSize: 17))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(value: relazione, onChanged: (value) => setState(() => relazione = value)),
                                    SizedBox(width: 3),
                                    Text('relazione con tipologie dei materiali utilizzati (5);',style: TextStyle(fontSize: 17))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(value: schema, onChanged: (value) => setState(() => schema = value)),
                                    SizedBox(width: 3),
                                    Text('schema di impianto realizzato (6);',style: TextStyle(fontSize: 17))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(value: riferimento, onChanged: (value) => setState(() => riferimento = value)),
                                    SizedBox(width: 3),
                                    Text('riferimento a dichiarazioni di conformità precedenti o parziali, già esistenti (7);',style: TextStyle(fontSize: 17))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(value: visura, onChanged: (value) => setState(() => visura = value)),
                                    SizedBox(width: 3),
                                    Text('copia del certificato di riconoscimento dei requisiti tecnico-professionali',style: TextStyle(fontSize: 17))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(value: conformita, onChanged: (value) => setState(() => conformita = value)),
                                    SizedBox(width: 3),
                                    Text('attestazione di conformità per impianto realizzatto con materiali o sistemi non normalizzati (8). (Rif. progetto: )',style: TextStyle(fontSize: 17))
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text('Allegati facoltativi (9)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Row(
                                  children: [
                                    Checkbox(value: esami, onChanged: (value) => setState(() => esami = value)),
                                    SizedBox(width: 3),
                                    Text('esami a vista effettuati sull\'impianto;',style: TextStyle(fontSize: 17))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(value: prove, onChanged: (value) => setState(() => prove = value)),
                                    SizedBox(width: 3),
                                    Text('prove effettuate sull\'impianto;',style: TextStyle(fontSize: 17))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(value: manuale, onChanged: (value) => setState(() => manuale = value)),
                                    SizedBox(width: 3),
                                    Text('manuale d\'uso e manutenzione;',style: TextStyle(fontSize: 17))
                                  ],
                                ),
                                SizedBox(height: 15),
                                /*Container(
                            width: 1200,
                            height: 2,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)
                            ),
                          ),*/
                                SizedBox(height: 8 ),
                                Center(
                                  child: Text(
                                      'DECLINA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                                  ),
                                ),
                                Text(
                                    style: TextStyle(fontSize: 17),
                                    'ogni responsabilità per sinistri a persone o a cose derivanti da manomissione dell\'impianto da parte di terzi ovvero da carenze di manutenzione o riparazione.'
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
                                        /*decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black, width: 1
                                    )
                                  ),*/
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(height: 10),
                                            Text('Il Responsabile Tecnico', style: TextStyle(fontSize: 15)),
                                            Text('(timbro e firma)', style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      //Fine container firma responsabile tecnico
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 14),
                                          Text('Il Dichiarante', style: TextStyle(fontSize: 15)),
                                          Text('timbro e firma', style: TextStyle(fontSize: 12)),
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
                                              style: TextStyle(color: Colors.black, fontSize: 14),
                                              text: 'AVVERTENZE PER IL COMMITTENTE:  '
                                          ),
                                          TextSpan(
                                              style: TextStyle(color: Colors.black, fontSize: 14),
                                              text: 'responsabilità del committente o del proprietario, art. 8 (10)'
                                          ),
                                        ]
                                    )
                                ),
                                SizedBox(height: 15,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'LEGENDA',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.underline),
                                        ),

                                      ],
                                    ),

                                  ],
                                ),
                                SizedBox(height: 2),
                                RichText(
                                    text: TextSpan(
                                        children: <InlineSpan>[
                                          TextSpan(
                                              style: TextStyle(color: Colors.black, fontSize: 15),
                                              text: '1) Come esempio nel caso di impianti a gas, con "altro" si può intendere la sostituzione di un apparecchio '
                                                  'installato in modo fisso.\n\n2) Indicare: nome, cognome, qualifica e, quando ne ricorra l’obbligo ai sensi '
                                                  'dell\'articolo 5, comma 2 (DM 37/08), estremi di iscrizione nel relativo Albo professionale, del tecnico che ha '
                                                  'redatto il progetto.\n\n3) Citare la o le norme tecniche e di legge, distinguendo tra quelle riferite alla '
                                                  'progettazione, all\'esecuzione e alle verifiche.\n\n4) Qualora l\'impianto eseguito su progetto sia variato in '
                                                  'opera, il progetto presentato alla fine dei lavori deve comprendere le varianti realizzate in corso d\'opera.\nFa '
                                                  'parte del progetto la citazione della pratica prevenzione incendi (ove richiesta).\n\n5) La relazione deve contenere, '
                                                  'per i prodotti soggetti a norme, la dichiarazione di rispondenza alle stesse completata, ove esistente, con '
                                                  'riferimenti a marchi, certificati di prova, ecc. rilasciati da istituti autorizzati.\nPer gli altri prodotti '
                                                  '(da elencare) il firmatario deve dichiarare che trattasi di materiali, prodotti e componenti conformi a quanto '
                                                  'previsto dagli articoli 5 e 6 (DM37/08). La relazione deve dichiarare l\'idoneità rispetto all\'ambiente di '
                                                  'installazione.\nQuando rilevante ai fini del buon funzionamento dell\'impianto, si devono fornire indicazioni '
                                                  'sul numero e caratteristiche degli apparecchi installati od installabili (ad esempio per il gas: 1) numero, tipo '
                                                  'e potenza degli apparecchi; 2) caratteristiche dei componenti il sistema di ventilazione dei locali; 3) '
                                                  'caratteristiche del sistema di scarico dei prodotti della combustione; 4) indicazioni sul collegamento elettrico '
                                                  'degli apparecchi, ove previsto).\n\n6) Per schema dell\'impianto realizzato si intende la descrizione dell\'opera '
                                                  'come eseguita (si fa semplice rinvio al progetto quando questo è stato redatto da un professionista abilitato e non '
                                                  'sono state apportate varianti in corso d’opera).\nNel caso di trasformazione, ampliamento e manutenzione '
                                                  'straordinaria, l\'intervento deve essere inquadrato, se possibile, nello schema dell\'impianto preesistente.\nLo '
                                                  'schema citerà la pratica prevenzione incendi (ove richiesto).\n\n7) I riferimenti sono costituiti dal nome '
                                                  'dell\'impresa esecutrice e dalla data della dichiarazione.\nPer gli impianti o parti di impianti costruiti prima '
                                                  'dell\'entrata in vigore del Decreto Ministeriale 37/08, il riferimento a dichiarazioni di conformità può essere '
                                                  'sostituito dal rinvio a dichiarazioni di rispondenza (DM 37/08, art. 7, comma 6).\nNel caso che parte dell\'impianto '
                                                  'sia predisposto ad altra impresa (ad esempio ventilazione e scarico fumi negli impianti a gas), la dichiarazione '
                                                  'deve riportare gli analoghi riferimenti per dette parti.\n\n8) Se nell’impianto risultano incorporati dei prodotti '
                                                  'o sistemi legittimamente utilizzati per il medesimo impiego in un altro Stato membro dell’Unione europea o che sia '
                                                  'parte contraente dell’Accordo sullo Spazio economico europeo, per i quali non esistono norme tecniche di prodotto o '
                                                  'di installazione, la dichiarazione di conformità deve essere sempre corredata con il progetto redatto e sottoscritto '
                                                  'da un ingegnere iscritto all’albo professionale secondo la specifica competenza tecnica richiesta, che attesta di'
                                                  ' avere eseguito l’analisi dei rischi connessi con l’impiego del prodotto o sistema sostitutivo, di avere prescritto '
                                                  'e fatto adottare tutti gli accorgimenti necessari per raggiungere livelli di sicurezza equivalenti a quelli garantiti'
                                                  ' dagli impianti eseguiti secondo la regola dell’arte e di avere sorvegliato la corretta esecuzione delle fasi di '
                                                  'installazione dell’impianto nel rispetto di tutti gli eventuali disciplinari tecnici predisposti dal fabbricante del '
                                                  'sistema o del prodotto.\n\n9) Esempio: eventuali certificati dei risultati delle verifiche eseguite sull\'impianto '
                                                  'prima della messa in esercizio o trattamenti per pulizia, disinfezione, ecc.\n\n10) Al termine dei lavori l\'impresa'
                                                  ' installatrice è tenuta a rilasciare al committente la dichiarazione di conformità degli impianti nel rispetto delle'
                                                  ' norme di cui all\'art.7 (DM 37/08).\nIl committente o il proprietario è tenuto ad affidare i lavori di installazione,'
                                                  ' di trasformazione, di ampliamento e di manutenzione degli impianti di cui all\'art.1 ad imprese abilitate'
                                                  ' ai sensi dell\'art. 3 (DM 37/08).'
                                          ),

                                        ]
                                    )
                                ),

                                SizedBox(height: 26),
                                relazione == true ? Wrap(children: [
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'RELAZIONE CON TIPOLOGIE DEI MATERIALI UTILIZZATI',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.underline),
                                          ),

                                        ],
                                      ),

                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          width: 990, // Imposta una larghezza fissa per il contenitore
                                          child:
                                          RichText(
                                            softWrap: true,
                                            text: TextSpan(
                                              children: <InlineSpan>[
                                                TextSpan(
                                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                                  text: '\nIl Sottoscritto MAZZEI FEDERICO, titolare dell\'impresa (ragione sociale) ',
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
                                                  text: ', esecutrice dell\'impianto elettrico installato nei locali siti nel comune di ',
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
                                              ],

                                            ),))
                                    ],
                                  ),
                                  SizedBox(height: 8 ),
                                  Center(
                                    child: Text(
                                        'DICHIARA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                                    ),
                                  ),
                                  Text('di aver utilizzato materiali e componenti conformi alle normative vigenti e che gli stessi possiedono marchi, '
                                      'certificati di conformità alle norme di riferimento o, comunque, conformi alla regola dell\'arte come da '
                                      'dichiarazione del costruttore.'),

                                  SizedBox(height: 16),
                                  SizedBox(height: 16),
                                  Text('Elenco componenti:'),
                                  Container(
                                    width: double.maxFinite,
                                    height: 400,
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
                                              _buildHeaderCell('Costruttore', 180),
                                              _buildHeaderCell('Descrizione', 355),
                                              _buildHeaderCell('CE', 66),
                                              _buildHeaderCell('IMQ', 66),
                                              _buildHeaderCell('RINA', 66),
                                              _buildHeaderCell('ENEC', 66),
                                              _buildHeaderCell('Altri', 66),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),

                                        Expanded(
                                          child: ListView.builder(

                                            itemCount: prodotti.length,
                                            itemBuilder: (context, index) {
                                              return Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [

                                                  _buildTableCell(prodotti[index].codiceController, 120, 1, 1, TextInputType.text),  // Campo "Codice" sempre di 1 riga
                                                  _buildTableCell(prodotti[index].costruttoreController, 180, 1, 4, TextInputType.text),
                                                  _buildTableCell(prodotti[index].descrizioneController, 355, 1, 2, TextInputType.text), // Campo "Quantità"
                                                  _buildTableCell(prodotti[index].ceController, 66, 1, 1, TextInputType.text),  // Campo "Prezzo"
                                                  _buildTableCell(prodotti[index].imqController, 66, 1, 1, TextInputType.text),  // Campo "Sconto"
                                                  _buildTableCell(prodotti[index].rinaController, 66, 1, 1, TextInputType.text),  // Campo "Importo"
                                                  _buildTableCell(prodotti[index].enecController, 66, 1, 1, TextInputType.text),
                                                  _buildTableCell(prodotti[index].altriController, 66, 1, 1, TextInputType.text),

                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                        Row(children: [
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            iconSize: 30.0,
                                            color: Colors.grey,
                                            onPressed: () {
                                              _aggiungiProdotto();
                                              // Azione da eseguire quando il bottone viene premuto

                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            iconSize: 30.0,
                                            color: Colors.grey,
                                            onPressed: () {
                                              _rimuoviProdotto();
                                              // Azione da eseguire quando il bottone viene premuto

                                            },
                                          ),
                                        ],)
                                      ],
                                    ),
                                  ),
                                  Center(child:
                                  SizedBox(
                                    width: 750,
                                    height: 80,
                                    child: Image.asset(
                                        "assets/images/loghi.png"
                                    ),
                                  ),
                                  ),
                                  Row(
                                    children: [
                                      Checkbox(value: componentiElettriciInstallati, onChanged: (value) => setState(() => componentiElettriciInstallati = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 960, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'Vengono qui di seguito elencati i componenti elettrici installati nell\'impianto e non dotati delle indicazioni di cui sopra, che sono comunque conformi a quanto previsto dall\'art. 6 del DM 37/08.'
                                                    ),

                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Checkbox(value: compatibilitaPreesistente, onChanged: (value) => setState(() => compatibilitaPreesistente = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 960, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'L\'impianto è compatibile con gli impianti preesistenti.'
                                                    ),

                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Checkbox(value: componentiIdonei, onChanged: (value) => setState(() => componentiIdonei = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 960, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'I componenti elettrici sono idonei rispetto all\'ambiente di installazione.'
                                                    ),

                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Checkbox(value: infoApparecchi, onChanged: (value) => setState(() => infoApparecchi = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 960, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'Eventuali informazioni sul numero e caratteristiche degli apparecchi utilizzatori, essendo considerati rilevanti ai fini del buon funzionamento dell\'impianto'
                                                    ),

                                                  ]
                                              )))
                                    ],
                                  ),
                                  SizedBox(height: 75),
                                  SizedBox(
                                    height: 150,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        //SizedBox(width: 1,),
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
                                                ),

                                              ]
                                          ),
                                        ),
                                        //fine data
                                        //inizo box con firma

                                        //Fine container firma responsabile tecnico
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            //SizedBox(height: 14),
                                            Text('Il dichiarante', style: TextStyle(fontSize: 15)),
                                            Text('Timbro e Firma leggibile', style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                        SizedBox(width: 1,),
                                      ],
                                    ),
                                  ),


                                ],) : Container(),

                                schema == true ? Wrap(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'TABELLA SCHEMATICA DELL\'IMPIANTO REALIZZATO',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.underline),
                                          ),

                                        ],
                                      ),


                                    ],
                                  ),
                                  //SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          width: 990, // Imposta una larghezza fissa per il contenitore
                                          child:
                                          RichText(
                                            softWrap: true,
                                            text: TextSpan(
                                              children: <InlineSpan>[
                                                TextSpan(
                                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                                  text: '\nIl Sottoscritto MAZZEI FEDERICO, titolare dell\'impresa (ragione sociale) ',
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
                                                  text: ', esecutrice dell\'impianto elettrico installato nei locali siti nel comune di ',
                                                ),
                                                WidgetSpan(child: ConstrainedBox(
                                                  constraints: BoxConstraints(minWidth: 250),
                                                  child: IntrinsicWidth(
                                                    child: getTextFormFieldSmall(
                                                      width: 250,
                                                      controller: _comuneTabellaSchematicaController,
                                                      inputType: TextInputType.text,
                                                      hintName: 'Comune *',
                                                    ),
                                                  ),
                                                )),
                                                TextSpan(
                                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                                  text: '\ndichiara di aver realizzato l\'impianto in oggetto come descritto nella tabella schematica che segue.'
                                                      '\n\nDATI GENERALI\n\nAlimentazione: ',
                                                ),
                                                WidgetSpan(child: ConstrainedBox(
                                                  constraints: BoxConstraints(minWidth: 100),
                                                  child: IntrinsicWidth(
                                                    child: getTextFormFieldSmall(
                                                      width: 100,
                                                      controller: _alimentazioneController,
                                                      inputType: TextInputType.text,
                                                      hintName: 'Alimentazione *',
                                                    ),
                                                  ),
                                                )),
                                                TextSpan(
                                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                                  text: '\nTensione nominale: ',
                                                ),
                                                WidgetSpan(child: ConstrainedBox(
                                                  constraints: BoxConstraints(minWidth: 100),
                                                  child: IntrinsicWidth(
                                                    child: getTextFormFieldSmall(
                                                      width: 100,
                                                      controller: _tensioneNominaleController,
                                                      inputType: TextInputType.text,
                                                      hintName: 'Tensione nominale *',
                                                    ),
                                                  ),
                                                )),
                                                TextSpan(
                                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                                  text: '\nCollegamento a terra: ',
                                                ),
                                                WidgetSpan(child: ConstrainedBox(
                                                  constraints: BoxConstraints(minWidth: 100),
                                                  child: IntrinsicWidth(
                                                    child: getTextFormFieldSmall(
                                                      width: 100,
                                                      controller: _collegamentoATerraController,
                                                      inputType: TextInputType.text,
                                                      hintName: 'Collegamento a terra *',
                                                    ),
                                                  ),
                                                )),
                                                TextSpan(
                                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                                  text: '\nCorrente di cto.cto origine dell\'impianto: ',
                                                ),
                                                WidgetSpan(child: ConstrainedBox(
                                                  constraints: BoxConstraints(minWidth: 100),
                                                  child: IntrinsicWidth(
                                                    child: getTextFormFieldSmall(
                                                      width: 100,
                                                      controller: _correnteCtoController,
                                                      inputType: TextInputType.text,
                                                      hintName: 'Corrente CTO *',
                                                    ),
                                                  ),
                                                )),
                                                TextSpan(
                                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                                  text: '\nCaduta di tensione nell\'impianto: ',
                                                ),
                                                WidgetSpan(child: ConstrainedBox(
                                                  constraints: BoxConstraints(minWidth: 100),
                                                  child: IntrinsicWidth(
                                                    child: getTextFormFieldSmall(
                                                      width: 100,
                                                      controller: _cadutaTensioneController,
                                                      inputType: TextInputType.text,
                                                      hintName: 'Caduta tensione *',
                                                    ),
                                                  ),
                                                )),
                                                TextSpan(
                                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                                  text: '\nGrado di protezione involucri: ',
                                                ),
                                                WidgetSpan(child: ConstrainedBox(
                                                  constraints: BoxConstraints(minWidth: 100),
                                                  child: IntrinsicWidth(
                                                    child: getTextFormFieldSmall(
                                                      width: 100,
                                                      controller: _gradoProtezioneInvolucriController,
                                                      inputType: TextInputType.text,
                                                      hintName: 'Grado protezione involucri *',
                                                    ),
                                                  ),
                                                )),
                                                TextSpan(
                                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                                  text: '\nPotenza contrattuale: ',
                                                ),
                                                WidgetSpan(child: ConstrainedBox(
                                                  constraints: BoxConstraints(minWidth: 100),
                                                  child: IntrinsicWidth(
                                                    child: getTextFormFieldSmall(
                                                      width: 100,
                                                      controller: _potenzaContrattualeController,
                                                      inputType: TextInputType.text,
                                                      hintName: 'Potenza contrattuale *',
                                                    ),
                                                  ),
                                                )),
                                                TextSpan(
                                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                                  text: '\n\nCIRCUITI DI DISTRIBUZIONE\n\nMassima corrente d\'impiego: ',
                                                ),
                                                WidgetSpan(child: ConstrainedBox(
                                                  constraints: BoxConstraints(minWidth: 100),
                                                  child: IntrinsicWidth(
                                                    child: getTextFormFieldSmall(
                                                      width: 100,
                                                      controller: _massimaCorrenteImpiegoController,
                                                      inputType: TextInputType.text,
                                                      hintName: 'Massima corrente d\'impiego *',
                                                    ),
                                                  ),
                                                )),
                                                TextSpan(
                                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                                  text: '\nSezione dei conduttori (Cu): ',
                                                ),
                                                WidgetSpan(child: ConstrainedBox(
                                                  constraints: BoxConstraints(minWidth: 100),
                                                  child: IntrinsicWidth(
                                                    child: getTextFormFieldSmall(
                                                      width: 100,
                                                      controller: _sezioneConduttoriController,
                                                      inputType: TextInputType.text,
                                                      hintName: 'Sezione conduttori *',
                                                    ),
                                                  ),
                                                )),
                                                TextSpan(
                                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                                  text: '\nCorrente nominale/differenziale ',
                                                ),

                                              ],

                                            ),)
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: intDifferenzialiTab, onChanged: (value) => setState(() => intDifferenzialiTab = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'degli interruttori differenziali '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _interruttoriDifferenzialiCDController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Interruttore differenziale *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: intMagnetoTermiciTab, onChanged: (value) => setState(() => intMagnetoTermiciTab = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'degli interruttori magnetotermici/differenziali '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _interruttoriMagnetoCDController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Interruttori magnetotermici *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: 990, // Imposta una larghezza fissa per il contenitore
                                            child:
                                            RichText(
                                                softWrap: true,
                                                text: TextSpan(
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'Corrente nominale: ',
                                                      ),
                                                    ])))]),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: nomInterruttoriMagnetotermici, onChanged: (value) => setState(() => nomInterruttoriMagnetotermici = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'degli interruttori magnetotermici '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _interruttoriMagnetoCNController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Interruttori magnetotermici corrente nominale *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: nomFusibili, onChanged: (value) => setState(() => nomFusibili = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'dei fusibili '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _fusibiliCNController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Fusibili corrente nominale *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: 990, // Imposta una larghezza fissa per il contenitore
                                            child:
                                            RichText(
                                                softWrap: true,
                                                text: TextSpan(
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'Potere di interruzione: ',
                                                      ),
                                                    ])))]),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: potInterruttoriMagnetotermici, onChanged: (value) => setState(() => potInterruttoriMagnetotermici = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'degli interruttori magnetotermici '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _interruttoriMagnetoPotIntController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Potenza interruttore magnetotermico*',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: potDifferenziali, onChanged: (value) => setState(() => potDifferenziali = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'degli interruttori magnetotermici/differenziali '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _interruttoriDiffPotIntController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Potenza interruttore magnetotermico/differenziale *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: potFusibili, onChanged: (value) => setState(() => potFusibili = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'dei fusibili '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _fusibiliPotIntController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Potenza interruzuione fusibili *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: 990, // Imposta una larghezza fissa per il contenitore
                                            child:
                                            RichText(
                                                softWrap: true,
                                                text: TextSpan(
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'Tipi di posa delle condutture: ',
                                                      ),
                                                    ])))]),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: tubiProtettiviBool, onChanged: (value) => setState(() => tubiProtettiviBool = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'in tubi protettivi '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _tubiProtettiviController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Tubi protettivi *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: canaliBool, onChanged: (value) => setState(() => canaliBool = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'in canali '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _canaliController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Canali *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: multipolariBool, onChanged: (value) => setState(() => multipolariBool = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'cavi multipolari '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _caviMultipolariController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Cavi multipolari *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: 990, // Imposta una larghezza fissa per il contenitore
                                            child:
                                            RichText(
                                                softWrap: true,
                                                text: TextSpan(
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: '\nIMPIANTO DI TERRA',
                                                      ),
                                                    ])))]),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: picchetti, onChanged: (value) => setState(() => picchetti = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'Picchetti: '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _picchettiController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Picchetti *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: cordaRame, onChanged: (value) => setState(() => cordaRame = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'Corda di rame: '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _cordaRameController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Corda rame *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: tondoAcciaio, onChanged: (value) => setState(() => tondoAcciaio = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'Tondo di acciaio: '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _tondoAcciaioController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Tondo acciaio *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: ferriArmatura, onChanged: (value) => setState(() => ferriArmatura = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'Collegati i ferri d\'armatura di fondazione all\'impianto di terra principale '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _ferriArmaturaController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Collegamento ferri armatura *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 13),
                                      Checkbox(value: collegamentiEquipotenziali, onChanged: (value) => setState(() => collegamentiEquipotenziali = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 930, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'Realizzati i collegamenti equipotenziali: '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _collegamentiEquipotenzialiController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Collegamenti equipotenziali *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 55),
                                      Checkbox(value: principali, onChanged: (value) => setState(() => principali = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 900, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'principali '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _principaliController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Principali *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 55),
                                      Checkbox(value: supplementari, onChanged: (value) => setState(() => supplementari = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 900, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'supplementari'
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _supplementariController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Supplementari *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 55),
                                      Checkbox(value: localiBagno, onChanged: (value) => setState(() => localiBagno = value)),
                                      SizedBox(width: 3),
                                      Container(
                                          width: 900, // Imposta una larghezza fissa per il contenitore
                                          child: RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: 'locali bagno e doccia '
                                                    ),
                                                    WidgetSpan(child: ConstrainedBox(
                                                      constraints: BoxConstraints(minWidth: 100),
                                                      child: IntrinsicWidth(
                                                        child: getTextFormFieldSmall(
                                                          width: 100,
                                                          controller: _localiBagnoDocciaController,
                                                          inputType: TextInputType.text,
                                                          hintName: 'Locali bagno e doccia *',
                                                        ),
                                                      ),
                                                    )),
                                                  ]
                                              )))
                                    ],
                                  ),
                                  SizedBox(height: 50),
                                  SizedBox(
                                    height: 150,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        //SizedBox(width: 1,),
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
                                                ),

                                              ]
                                          ),
                                        ),
                                        //fine data
                                        //inizo box con firma

                                        //Fine container firma responsabile tecnico
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            //SizedBox(height: 14),
                                            Text('Il dichiarante', style: TextStyle(fontSize: 15)),
                                            Text('Timbro e Firma leggibile', style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                        SizedBox(width: 1,),
                                      ],
                                    ),
                                  ),
                                ]) : Container(),

                                riferimento == true ? Wrap(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'ESAMI A VISTA EFFETTUATI SULL\'IMPIANTO',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.underline),
                                          ),

                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: 990, // Imposta una larghezza fissa per il contenitore
                                            child:
                                            RichText(
                                                softWrap: true,
                                                text: TextSpan(
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: '\nIl Sottoscritto MAZZEI FEDERICO, titolare dell\'impresa (ragione sociale) ',
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
                                                        text: ', esecutrice dell\'impianto elettrico installato nei locali siti nel comune di ',
                                                      ),
                                                      WidgetSpan(child: ConstrainedBox(
                                                        constraints: BoxConstraints(minWidth: 250),
                                                        child: IntrinsicWidth(
                                                          child: getTextFormFieldSmall(
                                                            width: 250,
                                                            controller: _comuneClienteController,
                                                            inputType: TextInputType.text,
                                                            hintName: 'Comune cliente *',
                                                          ),
                                                        ),
                                                      )),
                                                      TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: '\n\ndichiara sotto la propria responsabilità di avere eseguito i seguenti'
                                                            '\n\n',
                                                      ),
                                                    ])))]),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'ESAMI A VISTA:',
                                            style: TextStyle(fontSize: 18),
                                          ),

                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '1. L\'impianto eseguito è conforme alla documentazione tecnica',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: conformitaDocumentazioneTecnica, onChanged: (value) => setState(() => conformitaDocumentazioneTecnica = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '2. I componenti hanno caratteristiche adeguate all\'ambiente per costruzione e/o installazione',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: caratteristicheComponenti, onChanged: (value) => setState(() => caratteristicheComponenti = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '3. Le protezioni contro i contatti diretti ed indiretti sono adeguate',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: protezioniAdeguate, onChanged: (value) => setState(() => protezioniAdeguate = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '5. I conduttori sono stati scelti e posati in modo da assicurare le portate e cadute di tensione previste',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: caduteTensioni, onChanged: (value) => setState(() => caduteTensioni = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '6. Le protezioni delle condutture contro i sovraccarichi sono conformi alle prescrizioni delle norme CEI',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: protezioniConduttureSovraccarichi, onChanged: (value) => setState(() => protezioniConduttureSovraccarichi = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '7. Le protezioni delle condutture contro i cortocircuiti sono conformi alle prescrizioni delle norme CEI',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: protezioniConduttureCortocircuiti, onChanged: (value) => setState(() => protezioniConduttureCortocircuiti = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '8. Il sezionamento dei circuiti è conforme alle prescrizioni delle norme CEI',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: sezionamentoCircuiti, onChanged: (value) => setState(() => sezionamentoCircuiti = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '9. Il comando e/o l\'arresto di emergenza è stato previsto dove necessario',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: comandoArrestoEmergenza, onChanged: (value) => setState(() => comandoArrestoEmergenza = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '10. I conduttori hanno tensione nominale d\'isolamento adeguate',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: tensioneNominaleConduttori, onChanged: (value) => setState(() => tensioneNominaleConduttori = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '11. I conduttori hanno le sezioni minime previste',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: sezioneMinimaConduttori, onChanged: (value) => setState(() => sezioneMinimaConduttori = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '12. I colori e/o le marcature per l\'identificazione dei conduttori sono rispettati',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: coloreConduttori, onChanged: (value) => setState(() => coloreConduttori = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '13. I tubi protettivi ed i canali hanno dimensioni adeguate',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: tubiProtettivi, onChanged: (value) => setState(() => tubiProtettivi = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '14. Le connessioni dei conduttori sono idonee',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: connessioneConduttori, onChanged: (value) => setState(() => connessioneConduttori = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '15. Gli interruttori di comando unipolari sono inseriti sul conduttore di fase',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: interruttoriUnipolari, onChanged: (value) => setState(() => interruttoriUnipolari = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '16. Le dimensioni minime dei dispersori, dei conduttori di terra e dei conduttori di protezione ed equipotenziali (principali e supplementari) sono conformi alle prescrizioni delle norme CEI',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: dimensioniDispersori, onChanged: (value) => setState(() => dimensioniDispersori = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '17. I(il) nodi(o) collettori(e) di terra sono(è) accessibili(e)o',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: nodiCollettori, onChanged: (value) => setState(() => nodiCollettori = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '18. Il conduttore di protezione è stato predisposto per tutte le masse',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: conduttoreProtezione, onChanged: (value) => setState(() => conduttoreProtezione = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '19. Il conduttore equipotenziale principale è stato predisposto per tutte le masse estranee',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: conduttoreEquipotenziale, onChanged: (value) => setState(() => conduttoreEquipotenziale = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '26. L\'impianto elettrico del cantiere di costruzione e demolizione è conforme alle prescrizioni della Norma CEI 64-8/parte 7/sez. 704',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: conformitaImpiantoElettricoCantiere, onChanged: (value) => setState(() => conformitaImpiantoElettricoCantiere = value)),
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: 990, // Imposta una larghezza fissa per il contenitore
                                            child:
                                            RichText(
                                                softWrap: true,
                                                text: TextSpan(
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: '\nNote: ',
                                                      ),
                                                      WidgetSpan(child: ConstrainedBox(
                                                        constraints: BoxConstraints(minWidth: 800),
                                                        child: IntrinsicWidth(
                                                          child: getTextFormFieldSmall(
                                                            width: 800,
                                                            controller: _noteEsamiVistaController,
                                                            inputType: TextInputType.text,
                                                            hintName: 'Note prove effettuate *',
                                                          ),
                                                        ),
                                                      ))])))]),
                                  SizedBox(height: 80,),
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

                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 10),
                                              Text('Il Responsabile Tecnico', style: TextStyle(fontSize: 15)),
                                              Text('(timbro e firma)', style: TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        //Fine container firma responsabile tecnico
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(height: 14),
                                            Text('Il Dichiarante', style: TextStyle(fontSize: 15)),
                                            Text('timbro e firma', style: TextStyle(fontSize: 12)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'PROVE EFFETTUATE SULL\'IMPIANTO',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.underline),
                                          ),

                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: 990, // Imposta una larghezza fissa per il contenitore
                                            child:
                                            RichText(
                                                softWrap: true,
                                                text: TextSpan(
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: '\nIl Sottoscritto MAZZEI FEDERICO, titolare dell\'impresa (ragione sociale) ',
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
                                                        text: ', esecutrice dell\'impianto elettrico installato nei locali siti nel comune di ',
                                                      ),
                                                      WidgetSpan(child: ConstrainedBox(
                                                        constraints: BoxConstraints(minWidth: 250),
                                                        child: IntrinsicWidth(
                                                          child: getTextFormFieldSmall(
                                                            width: 250,
                                                            controller: _comuneClienteController,
                                                            inputType: TextInputType.text,
                                                            hintName: 'Comune cliente *',
                                                          ),
                                                        ),
                                                      )),
                                                      TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: '\n\ndichiara sotto la propria responsabilità di avere eseguito i seguenti'
                                                            '\n\n',
                                                      ),
                                                    ])))]),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'PROVE:',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '1. La verifica della continuità dei conduttori di protezione e dei conduttori equipotenziali principali e supplementari, '
                                              'accertata facendo circolare una corrente di almeno 0,2A utilizzazando una sorgente di tensione alternata o continua '
                                              'compresa tra 4 e 24V a vuoto, ha dato esito positivo',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: verificaContinuitaConduttori, onChanged: (value) => setState(() => verificaContinuitaConduttori = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '2. La minima resistenza di isolamento tra i conduttri attivi di un sistema avente tensione nominale non superiore a '
                                              '500V (ad esclusione di SELV e PELV) e: \n- altri circuiti \n- terra\nè risultata essere maggiore o uguale a '
                                              '0,5Mohm.\nE\' stato utilizzato un apparecchio di prova in grado di fornire 500V in c.c. quando eroga  1mA',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: minimaResistenzaIsolamento, onChanged: (value) => setState(() => minimaResistenzaIsolamento = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '7. La misura della resistenza di terra , effettuata mediante il metodo voltamperometrico,  eseguita nelle ordinarie condizioni'
                                              ' di funzionamento è di 20 Ohm e soddisfa il coordinamento delle protezioni associate.',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: misuraResistenzaTerra, onChanged: (value) => setState(() => misuraResistenzaTerra = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '8. E\' stato verificato che ogni interruttore differenziale installato nell\'impianto interviene con una corrente differenziale '
                                              'di valore uguale alla propria corrente differenziale nominale (Idn).',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: verificaInterruttoreDifferenziale, onChanged: (value) => setState(() => verificaInterruttoreDifferenziale = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '11. La prova di polarità ha fornito esito favorevole',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: polaritaFavorevole, onChanged: (value) => setState(() => polaritaFavorevole = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '12. La prova di funzionamento ha avuto esito favorevole',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: provaFunzionamento, onChanged: (value) => setState(() => provaFunzionamento = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '13. La verifica di sfilabilità dei cavi effettuata lungo circa il 2% del tubo protettivo totale dell\'impianto '
                                              'ha dato esito positivo',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: sfilabilitaCavi, onChanged: (value) => setState(() => sfilabilitaCavi = value)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '14. La verifica del rapporto tra il diametro interno del tubi protettivi e il diametro del cerchio circoscrittto '
                                              'al fascio al fascio di cavi contenuti nei tubi protettivi stessi ha dato esito positivo',
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      Checkbox(value: diametroTubi, onChanged: (value) => setState(() => diametroTubi = value)),
                                    ],
                                  ),

                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: 990, // Imposta una larghezza fissa per il contenitore
                                            child:
                                            RichText(
                                                softWrap: true,
                                                text: TextSpan(
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 17),
                                                        text: '\nNote: ',
                                                      ),
                                                      WidgetSpan(child: ConstrainedBox(
                                                        constraints: BoxConstraints(minWidth: 800),
                                                        child: IntrinsicWidth(
                                                          child: getTextFormFieldSmall(
                                                            width: 800,
                                                            controller: _noteProveEffettuateController,
                                                            inputType: TextInputType.text,
                                                            hintName: 'Nome azienda *',
                                                          ),
                                                        ),
                                                      ))])))]),
                                  SizedBox(height: 80,),
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

                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 10),
                                              Text('Il Responsabile Tecnico', style: TextStyle(fontSize: 15)),
                                              Text('(timbro e firma)', style: TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        //Fine container firma responsabile tecnico
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(height: 14),
                                            Text('Il Dichiarante', style: TextStyle(fontSize: 15)),
                                            Text('timbro e firma', style: TextStyle(fontSize: 12)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),


                                ]) : Container(),

                              ],
                            ),
                          )
                      ),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

}

class Prodotto {
  TextEditingController codiceController;
  TextEditingController descrizioneController;
  TextEditingController costruttoreController;
  TextEditingController ceController;
  TextEditingController imqController;
  TextEditingController rinaController;
  TextEditingController enecController;
  TextEditingController altriController;

  Prodotto({
    required this.codiceController,
    required this.descrizioneController,
    required this.costruttoreController,
    required this.ceController,
    required this.imqController,
    required this.rinaController,
    required this.enecController,
    required this.altriController,
  });

}