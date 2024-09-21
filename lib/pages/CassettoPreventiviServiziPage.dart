import 'package:fema_crm/pages/HomeFormAmministrazioneNewPage.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text(
          'CASSETTO PREVENTIVI SERVIZI',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomeFormAmministrazioneNewPage(userData: widget.utente)),
              );
            },
            icon: Icon(
              Icons.home_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: _sortedList.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 15.0),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // Arrotonda la Card stessa
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfPreventivoServizio(
                        "cassetto",
                        widget.utente,
                        splitFileMetadata(_sortedList[index])[0],
                        _sortedList,
                      ),
                    ),
                        (Route<dynamic> route) => false,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade300], // Gradiente da bianco a grigio
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15), // Arrotonda il contenitore interno
                  ),
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 40.0,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 15.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              splitFileMetadata(_sortedList[index])[0]
                                  .replaceFirst("xyz0", "\\"),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              DateFormat('dd/MM/yyyy').format(
                                DateFormat('EEE MMM dd HH:mm:ss yyyy').parseLoose(
                                  splitFileMetadata(_sortedList[index])[1]
                                      .replaceAll(RegExp(r'CEST '), '')
                                      .replaceAll(RegExp(r'CET '), ''),
                                ),
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}