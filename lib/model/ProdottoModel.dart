import 'dart:core';
import 'dart:ffi';

import 'package:fema_crm/model/CategoriaProdottoModel.dart';
import 'package:fema_crm/model/FornitoreModel.dart';
import 'package:fema_crm/model/PreventivoModel.dart';
import 'package:fema_crm/model/SopralluogoModel.dart';
import 'package:flutter/foundation.dart';

class ProdottoModel {
  String? id;
  String? codiceBarre;
  String? descrizione;
  int? giacenza;
  String? unitaMisura;
  Float? prezzoFornitore;
  String? codicePerFornitore;
  Float? costoMedio;
  Float? ultimoCosto;
  CategoriaProdottoModel? categoriaProdotto;
  FornitoreModel? fornitore;
  List<DDTModel>? ddt;
  List<PreventivoModel> preventivi;
  List<SopralluogoModel> sopralluoghi;
}
