import 'dart:convert';
import 'dart:io';
import 'package:fema_crm/pages/MenuPreventiviLiberiPage.dart';
import 'package:fema_crm/pages/PreventivoServiziPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:fema_crm/pages/ReportPreventiviPage.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:math' as math;
import '../model/PreventivoModel.dart';
import 'CreazioneClientePage.dart';
import 'DettaglioPreventivoAmministrazionePage.dart';
import 'RegistrazioneAgentePage.dart';
import 'RegistrazioneAziendaPage.dart';
import 'RegistrazionePreventivoAmministrazionePage.dart';
import 'ReportPreventiviPerAgentePage.dart';

class LogisticaPreventiviHomepage extends StatefulWidget {
  final UtenteModel userData;

  const LogisticaPreventiviHomepage({Key? key, required this.userData}) : super(key: key);

  @override
  _LogisticaPreventiviHomepageState createState() => _LogisticaPreventiviHomepageState();
}

class _LogisticaPreventiviHomepageState extends State<LogisticaPreventiviHomepage> {

  int _hoveredIndex = -1;
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<PreventivoModel> preventiviList = [];
  ScrollController _verticalScrollController = ScrollController();
  ScrollController _horizontalScrollController = ScrollController();
  ScrollController _horizontalScrollController2 = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getAllPreventivi();
  }

  Future<void> getAllPreventivi() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/preventivo/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<PreventivoModel> preventivi = [];
        for (var item in jsonData) {
          preventivi.add(PreventivoModel.fromJson(item));
        }
        setState(() {
          preventiviList = preventivi;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Errore di connessione'),
            content: Text(
                'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _navigateToDetailsPage(PreventivoModel preventivo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DettaglioPreventivoAmministrazionePage(
            preventivo: preventivo, onNavigateBack: getAllPreventivi),
      ),
    );
  }

  int _calculateHoveredIndex(Offset position) {
    final center = Offset(500 / 2, 500 / 2); // Use the same size as in CustomPaint
    final angle = (math.atan2(position.dy - center.dy, position.dx - center.dx) + math.pi * 2) % (math.pi * 2);
    final sectorAngle = (2 * math.pi) / 14; // 14 menu items
    final hoveredIndex = (angle ~/ sectorAngle) % 14;
    return hoveredIndex;
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegistrazioneAziendaPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegistrazioneAgentePage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegistrazionePreventivoAmministrazionePage(userData: widget.userData)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportPreventiviPage()),//ListaInterventiFinalPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportPreventiviPerAgentePage()),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MenuPreventiviLiberiPage(utente: widget.userData)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logistica e Preventivi', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1, size: 40, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreazioneClientePage()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints){
          if(Platform.isWindows){
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTapUp: (details) {
                              if (_hoveredIndex != -1) {
                                _navigateToPage(_hoveredIndex);
                              }
                            },
                            onPanUpdate: (details) {
                              RenderBox box = context.findRenderObject() as RenderBox;
                              Offset localOffset = box.globalToLocal(details.globalPosition);
                              setState(() {
                                _hoveredIndex = _calculateHoveredIndex(localOffset);
                              });
                            },
                            child: CustomPaint(
                              size: Size(600, 600),
                              painter: MenuPainter(
                                    (index) {
                                  setState(() {
                                    _hoveredIndex = index;
                                  });
                                },
                                    () {
                                  setState(() {
                                    _hoveredIndex = -1;
                                  });
                                },
                                context,
                                size: Size(650, 650),
                                hoveredIndex: _hoveredIndex,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 50),
                      SizedBox(
                        width: 350,
                        child: buildMenuButton(icon: Icons.business_outlined, text: 'REGISTRA AZIENDA',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegistrazioneAziendaPage()),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 350,
                        child: buildMenuButton(icon: Icons.person_add_alt_1_outlined, text: 'REGISTRA AGENTE',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegistrazioneAgentePage()),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 350,
                        child: buildMenuButton(icon: Icons.playlist_add_outlined, text: 'REGISTRA PREVENTIVO',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegistrazionePreventivoAmministrazionePage(userData: widget.userData)),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 350,
                        child: buildMenuButton(icon: Icons.edit_outlined, text: 'PREVENTIVO SERVIZI',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MenuPreventiviLiberiPage(utente : widget.userData)),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 350,
                        child: buildMenuButton(icon: Icons.bar_chart_outlined, text: 'REPORT PREVENTIVI',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReportPreventiviPage()),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 350,
                        child: buildMenuButton(icon: Icons.folder_shared_outlined, text: 'REPORT PREVENTIVI/AGENTE',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReportPreventiviPerAgentePage()),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      // GestureDetector(
                      //   onTapUp: (details) {
                      //     if (_hoveredIndex != -1) {
                      //       _navigateToPage(_hoveredIndex);
                      //     }
                      //   },
                      //   onPanUpdate: (details) {
                      //     RenderBox box = context.findRenderObject() as RenderBox;
                      //     Offset localOffset = box.globalToLocal(details.globalPosition);
                      //     setState(() {
                      //       _hoveredIndex = _calculateHoveredIndex(localOffset);
                      //     });
                      //   },
                      //   child: CustomPaint(
                      //     size: Size(600, 600),
                      //     painter: MenuPainter(
                      //           (index) {
                      //         setState(() {
                      //           _hoveredIndex = index;
                      //         });
                      //       },
                      //           () {
                      //         setState(() {
                      //           _hoveredIndex = -1;
                      //         });
                      //       },
                      //       context,
                      //       size: Size(650, 650),
                      //       hoveredIndex: _hoveredIndex,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                )
              ),


            );
          }
        },
      )
    );
  }

  Widget buildMenuButton(
      {required IconData icon, required String text, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(width: 30),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class MenuPainter extends CustomPainter {
  final Function(int) onHover;
  final Function() onHoverExit;
  final Size size;
  final int hoveredIndex;
  final BuildContext context; // Add BuildContext

  MenuPainter(this.onHover, this.onHoverExit, this.context, {required this.size, required this.hoveredIndex});

  // List of menu items
  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.business_outlined, label: 'REGISTRA AZIENDA'),
    MenuItem(icon: Icons.person_add_alt_1_outlined, label: 'REGISTRA AGENTE'),
    MenuItem(icon: Icons.playlist_add_outlined, label: 'REGISTRA PREVENTIVO'),
    MenuItem(icon: Icons.bar_chart_outlined, label: 'REPORT PREVENTIVI'),
    MenuItem(icon: Icons.folder_shared_outlined, label: 'REPORT PREVENTIVI/AGENTE'),
    MenuItem(icon: Icons.edit_outlined, label: 'PREVENTIVO SERVIZI')
  ];

  TextPainter labelPainter = TextPainter(
    text: TextSpan(
      text: '',
      style: TextStyle(
        fontSize: 15,
        color: Colors.black,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Radius
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 4.5;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw the menu items
    final angle = 2 * math.pi / _menuItems.length;
    for (int i = 0; i < _menuItems.length; i++) {
      final menuItem = _menuItems[i];
      final startAngle = i * angle;
      final sweepAngle = angle - 0.02; // Add a small gap between each arc

      // Determine if this menu item is hovered
      bool isHovered = hoveredIndex == i;

      // Calculate the scale factor for the hovered section
      double scaleFactor = isHovered ? 1.2 : 1.0;

      // Draw the sections
      paint.color = isHovered ? Colors.red[900]!.withOpacity(0.6 ) : Colors.red;
      Path path = Path();
      path.arcTo(
        Rect.fromCircle(center: center, radius: outerRadius * scaleFactor),
        startAngle,
        sweepAngle,
        false,
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius * scaleFactor),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      path.close();
      canvas.drawPath(path, paint);

      //Draw the icon in white
      final iconX = center.dx +
          (outerRadius * scaleFactor + (isHovered ? innerRadius * scaleFactor * 1.2 : innerRadius * scaleFactor)) /
              2 *
              math.cos(startAngle + sweepAngle / 2);
      final iconY = center.dy +
          (outerRadius * scaleFactor + (isHovered ? innerRadius * scaleFactor * 1.2 : innerRadius * scaleFactor)) /
              2 *
              math.sin(startAngle + sweepAngle / 2);
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(menuItem.icon.codePoint),
          style: TextStyle(
            fontSize: isHovered ? 28 : 24,
            fontFamily: menuItem.icon.fontFamily,
            color: Colors.white,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(iconX - textPainter.width / 2,
              iconY - textPainter.height / 2));

      // Draw the label if hovered
      if (isHovered) {
        final labelX = center.dx;
        labelPainter.text = TextSpan(
          text: menuItem.label,
          style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold
          ),
        );
        labelPainter.layout();
        final labelHeight = labelPainter.height;
        final labelY = center.dy - innerRadius * scaleFactor * 0.1 + labelHeight / 2;
        labelPainter.paint(
            canvas,
            Offset(labelX - labelPainter.width / 2,
                labelY - labelHeight / 2));
      }
    }
  }

  @override
  bool shouldRepaint(MenuPainter oldDelegate) => oldDelegate.hoveredIndex != hoveredIndex;

  @override
  bool hitTest(Offset position) {
    final center = Offset(size.width / 2, size.height / 2);
    final distance = math.sqrt(math.pow(position.dx - center.dx, 2) + math.pow(position.dy - center.dy, 2));
    final radius = size.width / 2;

    if (distance <= radius) {
      final angle = (math.atan2(position.dy - center.dy, position.dx - center.dx) + math.pi * 2) % (math.pi * 2);
      final section = (angle / (2 * math.pi / _menuItems.length)).floor();

      final newIndex = section % _menuItems.length;
      onHover(newIndex); // Call the onHover callback
      return true;
    }
    onHoverExit(); // Call the onHoverExit callback
    return false;
  }
}

class MenuItem {
  final IconData icon;
  final String label;

  MenuItem({required this.icon, required this.label});
}
