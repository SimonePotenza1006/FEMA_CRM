import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:fema_crm/model/CartellaModel.dart';
import 'package:http_parser/http_parser.dart';

class ChildFolderPage extends StatefulWidget {
  final CartellaModel cartella;

  const ChildFolderPage({Key? key, required this.cartella}) : super(key: key);

  @override
  _ChildFolderPageState createState() => _ChildFolderPageState();
}

class _ChildFolderPageState extends State<ChildFolderPage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<CartellaModel> allCartelle = [];
  List<bool> _hoverStates = [];
  Future<List<Map<String, dynamic>>>? _futureImages;

  @override
  void initState() {
    super.initState();
    getAllCartelle();
    _fetchImages();
  }

  void _fetchImages() {
    setState(() {
      _futureImages = fetchImages();
    });
  }

  Future<List<Map<String, dynamic>>> fetchImages() async {
    final url = '$ipaddressProva2/api/immagine/cartella/${int.parse(widget.cartella.id.toString())}/images';
    http.Response? response;
    try {
      response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final images = jsonData.map<Map<String, dynamic>>((imageData) {
          final base64String = imageData['imageData'];
          final bytes = base64Decode(base64String);
          return {
            'id': imageData['id'], // Verifica che l'ID sia presente qui
            'bytes': bytes.buffer.asUint8List(),
          };
        }).toList();
        return images;
      } else {
        throw Exception('Errore durante la chiamata al server: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata al server: $e');
      if (response != null) {
        print('Risposta del server: ${response.body}');
      }
      throw e;
    }
  }


  Future<void> getAllCartelle() async {
    try {
      var apiUrl = Uri.parse("$ipaddressProva2/api/cartella/parent/${int.parse(widget.cartella.id.toString())}");
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<CartellaModel> cartelle = [];
        for (var item in jsonData) {
          cartelle.add(CartellaModel.fromJson(item));
        }
        setState(() {
          allCartelle = cartelle;
          _hoverStates = List<bool>.filled(cartelle.length, false);
        });
      }
    } catch (e) {
      print("Errore: $e");
    }
  }

  void openAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();
        final _controller = TextEditingController();
        return AlertDialog(
          title: Text('Crea nuova cartella'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Nome cartella'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci un nome per la cartella';
                }
                return null;
              },
            ),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: Text('Crea', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  createCartella(_controller.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deletePic(int immagineId) async {
    try {
      final response = await http.delete(
        Uri.parse('$ipaddressProva2/api/immagine/$immagineId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete data: ${response.statusCode}');
      } else {
        print('Deleted immagine $immagineId');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Immagine eliminata!'),
          ),
        );
        _fetchImages();
      }
    } catch (e) {
      print('Error $e');
    }
  }

  Future<void> createCartella(String? name) async {
    try {
      final response = await http.post(
        Uri.parse('$ipaddressProva2/api/cartella'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': name.toString(),
          'parent': widget.cartella.toMap(),
        }),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cartella $name creata!'),
        ),
      );
      getAllCartelle();
    } catch (e) {
      print('Errore: $e');
    }
  }

  void _showImageDialog(BuildContext context, List<Map<String, dynamic>> images, int startIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImageDialog(images: images, startIndex: startIndex, deletePic: deletePic);
      },
    );
  }

  void _selectFiles() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      // Upload the selected files to your server
      _uploadFiles(result.files);
    }
  }

  void _uploadFiles(List<PlatformFile> files) async {
    // Create a multipart request to upload the files
    final cartella = widget.cartella.id;
    final request = http.MultipartRequest('POST', Uri.parse('$ipaddressProva2/api/immagine/cartella/$cartella'));
    request.fields['cartella'] = cartella.toString();
    for (var file in files) {
      final fileStream = File(file.path!).openRead();
      final bytesBuilder = BytesBuilder();
      await fileStream.forEach((bytes) {
        bytesBuilder.add(bytes);
      });
      final fileBytes = bytesBuilder.toBytes();
      request.files.add(
        await http.MultipartFile.fromPath(
          'cartella',
          file.path!,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }
    // Send the request
    final response = await request.send();
    if (response.statusCode == 200) {
      // Files uploaded successfully
      print('Files uploaded successfully');
      _fetchImages();
    } else {
      print('Error uploading files: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.cartella.nome}', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            onPressed: openAlert,
            icon: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureImages,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Errore nel caricamento delle immagini'));
            } else if (!snapshot.hasData || (snapshot.data!.isEmpty && allCartelle.isEmpty)) {
              return Center(child: Text('Nessuna cartella o immagine presente', style: TextStyle(color: Colors.grey[700])));
            } else {
              List<Widget> items = [];

              if (allCartelle.isNotEmpty) {
                items.addAll(allCartelle.map((cartella) {
                  return MouseRegion(
                    onEnter: (event) {
                      setState(() {
                        _hoverStates[allCartelle.indexOf(cartella)] = true;
                      });
                    },
                    onExit: (event) {
                      setState(() {
                        _hoverStates[allCartelle.indexOf(cartella)] = false;
                      });
                    },
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChildFolderPage(cartella: cartella),
                          ),
                        );
                      },
                      child: Container(
                        width: 60,  // Reduced width
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white10, width: 1),
                          borderRadius: BorderRadius.circular(10),
                          color: _hoverStates[allCartelle.indexOf(cartella)] ? Colors.red[50] : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder,
                              size: 48,  // Reduced size
                              color: Colors.grey[600],
                            ),
                            Text(
                              cartella.nome!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,  // Reduced font size
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList());
              }

              if (snapshot.hasData) {
                List<Map<String, dynamic>> images = snapshot.data!;
                items.addAll(images.asMap().entries.map((entry) {
                  int index = entry.key;
                  Uint8List image = entry.value['bytes'];
                  return GestureDetector(
                    onTap: () {
                      _showImageDialog(context, images, index);
                    },
                    child: Container(
                      width: 60,  // Reduced width
                      height: 60,  // Reduced height
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white10, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.memory(
                        image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }).toList());
              }

              return GridView.count(
                crossAxisCount: 15,  // Increased number of columns
                crossAxisSpacing: 15,
                mainAxisSpacing: 10,
                children: items,
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectFiles,
        tooltip: 'Seleziona file',
        backgroundColor: Colors.red,
        child: Icon(Icons.file_upload, color: Colors.white),
      ),
    );
  }
}

class ImageDialog extends StatefulWidget {
  final List<Map<String, dynamic>> images;
  final int startIndex;
  final Future<void> Function(int) deletePic;

  ImageDialog({required this.images, required this.startIndex, required this.deletePic});

  @override
  _ImageDialogState createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 800, // Set a maximum width
                height: 800, // Set a maximum height
                child: Image.memory(
                  widget.images[_currentIndex]['bytes'],
                  fit: BoxFit.contain, // Use BoxFit.contain to scale the image
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      if (_currentIndex > 0) {
                        setState(() {
                          _currentIndex--;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (_currentIndex < widget.images.length - 1) {
                        setState(() {
                          _currentIndex++;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          // SizedBox(height: 20),
          // ElevatedButton(
          //   style: ButtonStyle(
          //     backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          //   ),
          //   onPressed: () {
          //     final imageId = widget.images[_currentIndex]['id'];
          //     if (imageId != null && imageId is int) {
          //       widget.deletePic(imageId);
          //     } else {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(
          //           content: Text('Impossibile eliminare l\'immagine. ID non valido.'),
          //         ),
          //       );
          //     }
          //   },
          //   child: Text(
          //     'Elimina Immagine',
          //     style: TextStyle(color: Colors.white),
          //   ),
          // ),
        ],
      ),
    );
  }
}

