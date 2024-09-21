import 'package:fema_crm/pages/PdfPreventivoServizio.dart';
import 'package:fema_crm/pages/PreventivoServiziPdfPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../databaseHandler/DbHelper.dart';
import '../model/UtenteModel.dart';

class CassettoPreventiviServiziPage extends StatefulWidget{
  final UtenteModel utente;
  final List<String>? listfilename;
  const CassettoPreventiviServiziPage(this.utente, this.listfilename);

  @override
  _CassettoPreventiviServiziPageState createState()=>_CassettoPreventiviServiziPageState();
}

class _CassettoPreventiviServiziPageState extends State<CassettoPreventiviServiziPage>{
  var dbHelper;
  List<String>? listfiles;
  List<String> _sortedList = [];

  @override
  initState(){
    dbHelper = DbHelper();
    getUserData();
    _sortedList = widget.listfilename!;
    super.initState();
  }

  Future<void> getUserData() async {
    listfiles=await dbHelper.getFilesnameNoleggio();
  }

  List<String> splitFileMetadata(String metadata) {
    return metadata.split('|');
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text('CASSETTO PREVENTIVI SERVIZI', style: TextStyle(color: Colors.white),),
      ),
      body: Expanded(
        child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: _sortedList.length,
          itemBuilder: (BuildContext context, int index){
            return InkWell(
              onTap: (){
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => PdfPreventivoServizio("cassetto", widget.utente, splitFileMetadata(
                        _sortedList[index])[
                    0], _sortedList)),
                        (Route<dynamic> route) => false);
              },
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth:
                        110), // imposto un limite massimo di 150 pixel
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(
                              DateFormat(
                                  'EEE MMM dd HH:mm:ss yyyy')
                                  .parseLoose(
                                  splitFileMetadata(
                                      _sortedList[
                                      index])[1]
                                      .replaceAll(
                                      RegExp(
                                          r'CEST '),
                                      '')
                                      .replaceAll(
                                      RegExp(r'CET '),
                                      ''))),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontSize: 19.0,
                          ),
                          textAlign: TextAlign.right,
                        )),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      splitFileMetadata(_sortedList[index])[0]
                          .replaceFirst("xyz0", "\\"),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 22.0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      )
    );
  }
}