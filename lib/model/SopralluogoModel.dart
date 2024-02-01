import 'dart:io';

import 'package:fema_crm/model/CategoriaInterventoSpecificoModel.dart';
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';

class SopralluogoModel {
  String? id;
  String? descrizione;
  File? foto;
  ClienteModel? cliente;
  TipologiaInterventoModel? tipologiaIntervento;
  CategoriaInterventoSpecificoModel? categoriaInterventoSpecifico;
  List<ProdottoModel>? prodotti;
}
