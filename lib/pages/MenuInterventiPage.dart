import 'dart:io';

import 'package:fema_crm/model/UtenteModel.dart';
import 'package:fema_crm/pages/CreazioneInterventoByAmministrazionePage.dart';
import 'package:fema_crm/pages/TableInterventiPage.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'ListaClientiPage.dart';
import 'TableGruppiPage.dart';

class MenuInterventiPage extends StatefulWidget{
  final UtenteModel utente;

  const MenuInterventiPage ({Key? key, required this.utente}) : super(key:key);

  @override
  _MenuInterventiPageState createState() => _MenuInterventiPageState();
}

class _MenuInterventiPageState extends State<MenuInterventiPage>{
  int _hoveredIndex = -1;
  Map<int, int> _menuItemClickCount = {};
  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.list_outlined, label: 'LISTA INTERVENTI'),
    MenuItem(icon: Icons.playlist_add, label: 'CREA INTERVENTO'),
    MenuItem(icon: Icons.groups, label: 'GRUPPI DI INTERVENTO')
  ];

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid){
      _menuItemClickCount.clear();
      for (int i = 0; i < _menuItems.length; i++) {
        _menuItemClickCount[i] = 0;
      };
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('INTERVENTI', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1, size: 40, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ListaClientiPage()),
              );
            },
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints){
          if(constraints.maxWidth >= 800){
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 10),
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
                          size: Size(500, 500),
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
                            size: Size(500, 500),
                            hoveredIndex: _hoveredIndex,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else{
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 350,
                    child: buildMenuButton(icon: Icons.add, text: 'CREA INTERVENTO',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreazioneInterventoByAmministrazionePage(utente: widget.utente)),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 350,
                    child: buildMenuButton(icon: Icons.list_outlined, text: 'LISTA INTERVENTI',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TableInterventiPage(utente : widget.utente)),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 350,
                    child: buildMenuButton(icon: Icons.groups, text: 'GRUPPI DI INTERVENTO',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TableGruppiPage(utente : widget.utente)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        }
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

  int _calculateHoveredIndex(Offset position) {
    final center = Offset(500 / 2, 500 / 2); // Use the same size as in CustomPaint
    final angle = (math.atan2(position.dy - center.dy, position.dx - center.dx) + math.pi * 2) % (math.pi * 2);
    final sectorAngle = (2 * math.pi) / 3; // 3 menu items
    final hoveredIndex = (angle ~/ sectorAngle) % 3;
    return hoveredIndex;
  }

  int _lastClickedIndex = 0;

  void _navigateToPage(int index) {
    if(Platform.isAndroid){
      if (_lastClickedIndex != index) {
        _menuItemClickCount.clear(); // azzerare tutti i contatori quando si clicca su un bottone diverso
        _lastClickedIndex = index; // aggiornare l'indice dell'ultimo bottone cliccato
      }
    }

    if(Platform.isAndroid){
      if (_menuItemClickCount.containsKey(index)) {
        _menuItemClickCount[index] = (_menuItemClickCount[index] ?? 0) + 1;
      } else {
        _menuItemClickCount[index] = 1;
      }
    }

    if ((_menuItemClickCount[index] ?? 0) % 2 == 0 && _hoveredIndex != -1) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TableInterventiPage(utente: widget.utente)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              CreazioneInterventoByAmministrazionePage(utente : widget.utente)),
        );
        break;
      case 2: Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              TableGruppiPage(utente : widget.utente)),
        );
        break;
      }
    }
  }
}

class MenuPainter extends CustomPainter {
  final Function(int) onHover;
  final Function() onHoverExit;
  final Size size;
  final int hoveredIndex;
  final BuildContext context; // Add BuildContext

  MenuPainter(this.onHover, this.onHoverExit, this.context, {required this.size, required this.hoveredIndex});

  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.list, label: 'LISTA INTERVENTI'),
    MenuItem(icon: Icons.playlist_add, label: 'CREA INTERVENTO'),
    MenuItem(icon: Icons.groups, label: 'GRUPPI DI INTERVENTO')
  ];

  TextPainter labelPainter = TextPainter(
    text: TextSpan(
      text: '',
      style: TextStyle(
        fontSize: 13,
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