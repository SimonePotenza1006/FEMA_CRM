import 'package:fema_crm/pages/RegistrazioneMerceRiparazionePage.dart';
import 'package:flutter/material.dart';
import '../model/UtenteModel.dart';
import 'ListaClientiPage.dart';
import 'ReportMerceInRiparazionePage.dart';
import 'dart:math' as math;

class MenuMerceInRiparazionePage extends StatefulWidget{
  final UtenteModel utente;

  const MenuMerceInRiparazionePage ({Key? key, required this.utente}) : super(key:key);

  @override
  _MenuMerceInRiparazionePageState createState() => _MenuMerceInRiparazionePageState();
}

class _MenuMerceInRiparazionePageState extends State<MenuMerceInRiparazionePage>{

  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merce in riparazione', style: TextStyle(color: Colors.white)),
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
      ),
    );
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegistrazioneMerceRiparazionePage(utente: widget.utente)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              ReportMerceInRiparazionePage()),
        );
        break;
    }
  }

  int _calculateHoveredIndex(Offset position) {
    final center = Offset(500 / 2, 500 / 2); // Use the same size as in CustomPaint
    final angle = (math.atan2(position.dy - center.dy, position.dx - center.dx) + math.pi * 2) % (math.pi * 2);
    final sectorAngle = (2 * math.pi) / 14; // 14 menu items
    final hoveredIndex = (angle ~/ sectorAngle) % 14;
    return hoveredIndex;
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
    MenuItem(icon: Icons.playlist_add, label: 'NUOVA RIPARAZIONE'),
    MenuItem(icon: Icons.bar_chart_outlined, label: 'REPORT RIPARAZIONI'),
  ];

  TextPainter labelPainter = TextPainter(
    text: TextSpan(
      text: '',
      style: TextStyle(
        fontSize: 18,
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
              fontSize: 17,
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