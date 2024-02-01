import 'dart:io';

import 'package:fema_crm/model/CategoriaDDTModel.dart';
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:fema_crm/model/ProdottoModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';

class DDTModel {
  String? id;
  DateTime? data;
  DateTime? orario;
  File? firmaUser;
  File? imageData;
  ClienteModel? cliente;
  DestinazioneModel? destinazione;
  CategoriaDDTModel? categoriaDDT;
  UtenteModel? utente;
  List<ProdottoModel> prodotti;

  DDTModel(
      this.id,
      this.data,
      this.orario,
      this.firmaUser,
      this.imageData,
      this.cliente,
      this.destinazione,
      this.categoriaDDT,
      this.utente,
      this.prodotti);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'data': data,
      'orario': orario,
      'firmaUser': firmaUser,
      'imageData': imageData,
      'cliente': cliente,
      'destinazione': destinazione,
      'categoriaDDt': categoriaDDT,
      'utente': utente,
      'prodotti': prodotti
    };
    return map;
  }
}
