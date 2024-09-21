import 'package:fema_crm/model/ProdottoModel.dart';
import 'package:flutter/material.dart';

import 'ModificaDettaglioProdottoPage.dart';

class DettaglioProdottoPage extends StatelessWidget {
  final ProdottoModel prodotto;

  DettaglioProdottoPage({Key? key, required this.prodotto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dettaglio Prodotto - ',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              prodotto.codice_danea ?? 'N/A',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInfoRow(title: 'codice danea', value: prodotto.codice_danea != null ? prodotto.codice_danea.toString() : "N?A"),
                        buildInfoRow(title: 'prodotto', value: prodotto.descrizione != null ? prodotto.descrizione! : "N/A ", context: context),
                        buildInfoRow(title: 'tipologia', value: prodotto.tipologia != null ? prodotto.tipologia! : "N/A", context: context),
                        buildInfoRow(title: 'Unità di misura', value: prodotto.unita_misura != null ? prodotto.unita_misura! : "N/A"),
                        buildInfoRow(title: "iva", value: prodotto.iva != null ? prodotto.iva! : 'N/A'),
                        buildInfoRow(title: 'note', value: prodotto.note != null ? prodotto.note! : 'N/A'),
                        buildInfoRow(title: 'codice a barre danea', value: prodotto.cod_barre_danea != null ? prodotto.cod_barre_danea! : "N/A"),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInfoRow(title: 'produttore', value: prodotto.produttore != null? prodotto.produttore! : "N/A"),
                        buildInfoRow(title: 'fornitore', value: prodotto.fornitore != null ? prodotto.fornitore! : "N/A"),
                        buildInfoRow(title: 'Cod. fornitore', value: prodotto.cod_fornitore != null ? prodotto.cod_fornitore! : "N/A"),
                        buildInfoRow(title: "cod. prodotto fornitore", value: prodotto.cod_prod_forn != null ? prodotto.cod_prod_forn! : "N/A"),
                        buildInfoRow(title: 'prezzo fornitore', value: prodotto.prezzo_fornitore != null ? prodotto.prezzo_fornitore!.toString() : "N/A", context: context),
                        buildInfoRow(title: 'note fornitura', value: prodotto.note_fornitura != null ? prodotto.note_fornitura! : "N/A", context: context),
                        buildInfoRow(title: 'quantità giacenza' , value: prodotto.qta_giacenza != null ? prodotto.qta_giacenza!.toString() : "N/A", context: context),
                        buildInfoRow(title: 'quantità impegnata', value: prodotto.qta_impegnata != null ? prodotto.qta_impegnata!.toString() : "N/A", context: context),
                        buildInfoRow(title: 'ultimo costo acquisto', value: prodotto.ultimo_costo_acquisto != null ? prodotto.ultimo_costo_acquisto!.toString() : "N/A", context: context),
                        buildInfoRow(title: 'prezzo medio vendita', value: prodotto.prezzo_medio_vendita != null ? prodotto.prezzo_medio_vendita!.toString() : "N/A", context: context),
                        buildInfoRow(title: 'lotto/seriale', value: prodotto.lotto_seriale != null ? prodotto.lotto_seriale! : "N/A", context: context),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModificaDettaglioProdottoPage(prodotto: prodotto),
          ),
        );
      },
        child: Icon(Icons.build, color: Colors.white),
        backgroundColor: Colors.red,
      ),

    );
  }

  Widget buildInfoRow({required String title, required String value, BuildContext? context}) {
    bool isValueTooLong = value.length > 25;
    String displayedValue = isValueTooLong ? value.substring(0, 25) + "..." : value;
    return SizedBox(
      width:500,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 10),
                    Text(
                      title.toUpperCase() + ": ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        displayedValue.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isValueTooLong && context != null)
                        IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("${title.toUpperCase()}"),
                                  content: Text(value),
                                  actions: [
                                    TextButton(
                                      child: Text("Chiudi"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Divider( // Linea di separazione tra i widget
              color: Colors.grey[400],
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }

}
