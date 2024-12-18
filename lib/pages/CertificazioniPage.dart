  import 'dart:convert';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io' as io;
import '../model/FileModel.dart';
import 'CertificazioneImpiantoFormPage.dart';
import 'CertificazioniFormPage.dart';

class CertificazioniPage extends StatefulWidget{
  final UtenteModel utente;

  const CertificazioniPage({Key? key, required this.utente}) : super(key:key);

  @override
  _CertificazioniPageState createState() => _CertificazioniPageState();
}

class _CertificazioniPageState extends State<CertificazioniPage>{

  List<FileSystemItem> fileStructure = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  String currentPath = '';

  @override
  void initState() {
    super.initState();
    print("Inizializzazione CertificazioniPage");
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    print("Fetching files...");
    final response = await http.get(Uri.parse('$ipaddress/pdfu/filesnameCertificazioni'));
    if (response.statusCode == 200) {
      print("Files fetched successfully");
      print(response.body);
      var jsonData = jsonDecode(response.body);
      setState(() {
        fileStructure = (jsonData as List)
            .map((item) => item['type'] == 'directory'
            ? DirectoryModel.fromJson(item)
            : FileModel.fromJson(item))
            .toList();
      });
    } else {
      print('Errore nel caricamento dei dati: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          'CERTIFICAZIONI',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add
            ),
            color: Colors.white,
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CertificazioneImpiantoFormPage()),
              );
            },
          )
        ],
      ),
      body: fileStructure.isEmpty
          ? Center(child: CircularProgressIndicator())
          : buildFileList(fileStructure),
    );
  }

  Widget buildFileList(List<FileSystemItem> items) {
    print("Building file list...");
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final FileSystemItem item = items[index]; // Cambiato a FileSystemItem
        print("File/Directory: ${item.name}");

        return SizedBox(height: 60,child: ListTile(
          leading: Icon(
            item is DirectoryModel ? Icons.folder : Icons.picture_as_pdf,
            size: 45,
            color: Colors.redAccent,
          ),
          title: Text(
            item.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            if (item is DirectoryModel) { // Controllo il tipo
              currentPath = item.path;  // Usa la path dal modello
              print("Entering directory: $currentPath");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DirectoryViewWrapper(directory: item), // Passa l'intero oggetto DirectoryModel
                ),
              );
            } else {// Usa la targa se disponibile
              _openFile(context, item as FileModel);
            }
          },
        ));
      },
    );
  }

  Future<void> _openFile(BuildContext context, FileModel file) async {
    String path = file.path;
    final pdfUrl = '$ipaddress/pdfu/certificazioni/$path/${file.name}';
    print('PDF URL: $pdfUrl');
    try {
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        print('Download del PDF riuscito');
        final dir = await getTemporaryDirectory();
        final fileToSave = io.File('${dir.path}/${file.name}');
        await fileToSave.writeAsBytes(response.bodyBytes);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewer(filePath: fileToSave.path),
          ),
        );
      } else {
        print('Errore durante il download del PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante il download: $e');
    }
  }

}

class DirectoryViewWrapper extends StatefulWidget {
  final DirectoryModel directory;

  DirectoryViewWrapper({required this.directory});

  @override
  _DirectoryViewWrapperState createState() => _DirectoryViewWrapperState();
}

class _DirectoryViewWrapperState extends State<DirectoryViewWrapper> {
  late DirectoryModel _directory;
  List<FileSystemItem> _filteredItems = [];
  String _searchQuery = '';
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';

  @override
  void initState() {
    super.initState();
    _directory = widget.directory;
    _filteredItems = _directory.children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(_directory.name, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white,),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: _buildFileList(_filteredItems),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ricerca'),
          content: TextField(
            decoration: InputDecoration(
              labelText: 'Filtra per nome',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filteredItems = _directory.children.where((item) {
                  return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();
              });
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFileList(List<FileSystemItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final FileSystemItem item = items[index];
        print("Elemento trovato: ${item.name}");

        return ListTile(
          leading: Icon(
            item is DirectoryModel ? Icons.folder : Icons.picture_as_pdf,
            size: item is DirectoryModel ? 40 : 30,
            color: Colors.redAccent,
          ),
          // Mostra il tasto delete solo se non è una directory
          trailing: item is FileModel
              ? IconButton(
            icon: Icon(Icons.delete_forever),
            iconSize: 28,
            onPressed: () {
              // Chiamata alla funzione di cancellazione
              _confirmDelete(context, item as FileModel);
            },
          )
              : null, // Nessuna icona per le directory
          title: Text(
            item.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Ultima modifica: ${formatLastModified(item.lastModified)}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () {
            if (item is DirectoryModel) {
              String newPath = item.path;
              print("Navigazione nella directory: $newPath");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DirectoryViewWrapper(directory: item),
                ),
              );
            } else {
              _openFile(context, item as FileModel);
            }
          },
        );
      },
    );
  }


  void _confirmDelete(BuildContext context, FileModel file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Conferma cancellazione"),
          content: Text("Sei sicuro di voler cancellare il file ${file.name}?"),
          actions: [
            TextButton(
              child: Text("Annulla"),
              onPressed: () {
                Navigator.of(context).pop(); // Chiudi il dialog
              },
            ),
            TextButton(
              child: Text("Conferma"),
              onPressed: () {
                // Chiama la funzione di cancellazione
                deleteFile(context, file);
                Navigator.of(context).pop(); // Chiudi il dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteFile(BuildContext context, FileModel file) async {
    String path = file.path.replaceAll('\\', '/');
    String modifiedPath = path.replaceAll('/', '_');
    String encodedFilename = Uri.encodeComponent(file.name);
    final deleteUrl = '$ipaddress/pdfu/certificazioni/$modifiedPath/$encodedFilename';
    print('Delete URL: $deleteUrl');
    try {
      final response = await http.delete(Uri.parse(deleteUrl));
      if (response.statusCode == 200) {
        print('Cancellazione del file riuscita');
        // Aggiorna la lista rimuovendo il file cancellato
        setState(() {
          _filteredItems.remove(file);  // Rimuove il file dalla lista
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File cancellato con successo.")),
        );
      } else {
        print('Errore durante la cancellazione del file: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore durante la cancellazione del file.")),
        );
      }
    } catch (e) {
      print('Errore durante la cancellazione: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore durante la cancellazione.")),
      );
    }
  }

  Future<void> _openFile(BuildContext context, FileModel file) async {
    // Ottieni il percorso del file
    String path = file.path.replaceAll('\\', '/');

    // Sostituisci gli slash con un carattere di tua scelta
    String modifiedPath = path.replaceAll('/', '_');
    String encodedFilename = Uri.encodeComponent(file.name);

    // Costruisci l'URL con il path modificato
    final pdfUrl = '$ipaddress/pdfu/certificazioni/$modifiedPath/$encodedFilename';
    print('PDF URL: $pdfUrl');

    try {
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        print('Download del PDF riuscito');
        final dir = await getTemporaryDirectory();
        final fileToSave = io.File('${dir.path}/${file.name}');
        await fileToSave.writeAsBytes(response.bodyBytes);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewer(filePath: fileToSave.path),
          ),
        );
      } else {
        print('Errore durante il download del PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante il download: $e');
    }
  }
}

class PDFViewer extends StatelessWidget {
  final String filePath; // Percorso del file PDF

  const PDFViewer({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PdfViewerController _pdfViewerController = PdfViewerController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Visualizzatore PDF',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.print, color: Colors.white),
            onPressed: () {
              _printPdf(filePath);
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_in, color: Colors.white),
            onPressed: () {
              _pdfViewerController.zoomLevel += 0.5;
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_out, color: Colors.white),
            onPressed: () {
              _pdfViewerController.zoomLevel -= 0.5;
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(
        io.File(filePath),
        controller: _pdfViewerController,
        enableDoubleTapZooming: true, // Funziona anche su mobile
      ),
    );
  }

  Future<void> _printPdf(String path) async {
    try {
      // Converte il file PDF in byte
      final pdfFile = io.File(path);
      final bytes = await pdfFile.readAsBytes();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
      );
    } catch (e) {
      print('Errore durante la stampa: $e');
    }
  }
}

