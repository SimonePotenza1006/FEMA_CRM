import 'package:flutter/material.dart';
import '../Util/getTextFormFieldSmall.dart';

class CertificazioneImpiantoFormPage extends StatefulWidget{
  const CertificazioneImpiantoFormPage({Key? key}) : super(key:key);

  @override
  _CertificazioneImpiantoFormPageState createState() => _CertificazioneImpiantoFormPageState();
}

class _CertificazioneImpiantoFormPageState extends State<CertificazioneImpiantoFormPage>{

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


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text('Compilazione certificazione impianto', style: TextStyle(color: Colors.white)),
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
                                  constraints: BoxConstraints(minWidth: 150),
                                  child: IntrinsicWidth(
                                    child: getTextFormFieldSmall(
                                      width: 150,
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
                      ],
                    ),
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