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
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Codice Danea:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.codice_danea ?? 'N/A'),
              SizedBox(height: 20.0),
              Text(
                'Descrizione:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.descrizione ?? 'N/A'),
              SizedBox(height: 20.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipologia:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(prodotto.tipologia ?? 'N/A'),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categoria:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(prodotto.categoria ?? 'N/A'),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sottocategoria:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(prodotto.sottocategoria ?? 'N/A'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                'Unità di misura:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.unita_misura ?? 'N/A'),
              SizedBox(height: 20.0),
              Text(
                'IVA:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.iva ?? 'N/A'),
              SizedBox(height: 20.0),
              Text(
                'Note:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.note ?? 'N/A'),
              SizedBox(height: 20.0),
              Text(
                'Codice a Barre Danea:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.cod_barre_danea ?? 'N/A'),
              SizedBox(height: 20.0),
              Text(
                'Produttore:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.produttore ?? 'N/A'),
              SizedBox(height: 20.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Codice Fornitore:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(prodotto.cod_fornitore ?? 'N/A'),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fornitore:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(prodotto.fornitore ?? 'N/A'),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Codice Prodotto Fornitore:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(prodotto.cod_prod_forn ?? 'N/A'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                'Prezzo Fornitore:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.prezzo_fornitore != null ? '${prodotto.prezzo_fornitore} €' : 'N/A'),
              SizedBox(height: 20.0),
              Text(
                'Note Fornitura:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.note_fornitura ?? 'N/A'),
              SizedBox(height: 20.0),
              Text(
                'Quantità Giacenza:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.qta_giacenza != null ? '${prodotto.qta_giacenza}' : 'N/A'),
              SizedBox(height: 20.0),
              Text(
                'Quantità Impegnata:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.qta_impegnata != null ? '${prodotto.qta_impegnata}' : 'N/A'),
              SizedBox(height: 20.0),
              Text(
                'Ultimo Costo Acquisto:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.ultimo_costo_acquisto != null ? '${prodotto.ultimo_costo_acquisto} €' : 'N/A'),
              SizedBox(height: 20.0),
              Text(
                'Prezzo Medio Vendita:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.prezzo_medio_vendita != null ? '${prodotto.prezzo_medio_vendita} €' : 'N/A'),
              SizedBox(height: 20.0),
              Text(
                'Lotto/Seriale:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prodotto.lotto_seriale ?? 'N/A'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModificaDettaglioProdottoPage(prodotto: prodotto),
              ),
            );
          },
          icon: Icon(Icons.build, color: Colors.white),
          label: Text('MODIFICA', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
          ),
        ),
      ),
    );
  }
}
