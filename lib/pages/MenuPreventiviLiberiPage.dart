import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:fema_crm/pages/CassettoPreventiviServiziPage.dart';
import 'package:fema_crm/pages/PreventivoServiziPage.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MenuPreventiviLiberiPage extends StatefulWidget{
  final UtenteModel utente;

  const MenuPreventiviLiberiPage ({Key? key, required this.utente}) : super(key: key);

  @override
  _MenuPreventiviLiberiPageState createState() => _MenuPreventiviLiberiPageState();
}

class _MenuPreventiviLiberiPageState extends State<MenuPreventiviLiberiPage>{
  int _hoveredIndex = -1;
  DbHelper? dbHelper;
  List<String>? listfiles;

  @override
  void initState(){
    dbHelper = DbHelper();
    getFilesName();
  }

  Future<void> getFilesName() async{
    listfiles= await dbHelper?.getFilesnameNoleggio();
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PreventivoServiziPage(utente: widget.utente)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              CassettoPreventiviServiziPage(widget.utente, listfiles)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preventivi servizi', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Add this line
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                //     size: Size(500, 500),
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
                //       size: Size(500, 500),
                //       hoveredIndex: _hoveredIndex,
                //     ),
                //   ),
                // ),
                SizedBox(
                  width: 350,
                  child: buildMenuButton(icon: Icons.business_outlined, text: 'REGISTRA PREVENTIVO',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PreventivoServiziPage(utente: widget.utente)),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 350,
                  child: buildMenuButton(icon: Icons.sd_storage_outlined, text: 'CASSETTO PREVENTIVI SERVIZI',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PreventivoServiziPage(utente: widget.utente)),
                      );
                    },
                    isDisabled: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateHoveredIndex(Offset position) {
    final center = Offset(500 / 2, 500 / 2); // Use the same size as in CustomPaint
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    // Calcola l'angolo dell'offset rispetto al centro del cerchio
    // in base alla posizione reale degli elementi del menu
    final angle = math.atan2(dy, dx) * (math.pi / 2);

    // Mappa l'angolo all'indice dell'elemento del menu
    final hoveredIndex = (angle ~/ (math.pi / 2)) % 2;

    return hoveredIndex;
  }


  Widget buildMenuButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    bool isDisabled = false, // Aggiunto il parametro booleano
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onPressed, // Disabilita il tocco se isDisabled è true
      child: Container(
        decoration: BoxDecoration(
          gradient: isDisabled
              ? LinearGradient(
            colors: [Colors.grey.shade400, Colors.grey.shade700], // Colori per lo stato disabilitato
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade700], // Colori standard
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isDisabled
              ? [] // Nessuna ombra per il pulsante disabilitato
              : [
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
                color: isDisabled ? Colors.grey.shade200 : Colors.white, // Cambia il colore per lo stato disabilitato
                size: 30,
              ),
              SizedBox(width: 30),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isDisabled ? Colors.grey.shade200 : Colors.white, // Cambia il colore per lo stato disabilitato
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
    MenuItem(icon: Icons.playlist_add, label: 'NUOVO PREVENTIVO'),
    MenuItem(icon: Icons.sd_storage_outlined, label: 'CASSETTO'),
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
    final angle = math.pi;//2 * math.pi / _menuItems.length;
    for (int i = 0; i < _menuItems.length; i++) {
      final menuItem = _menuItems[i];
      final startAngle =  -math.pi / 2 + i * angle; //i * angle;
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
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    // Verifica se l'offset è all'interno di una zona dell'onhover
    // in base alla posizione reale degli elementi del menu
    if (dx > 0 && dy > -50 && dy < 50) {
      // Elemento del menu a destra
      onHover(0);
      return true;
    } else if (dx < 0 && dy > -50 && dy < 50) {
      // Elemento del menu a sinistra
      onHover(1);
      return true;
    }

    onHoverExit();
    return false;
  }
}

class MenuItem {
  final IconData icon;
  final String label;

  MenuItem({required this.icon, required this.label});
}