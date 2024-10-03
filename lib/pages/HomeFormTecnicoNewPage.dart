import 'dart:async';
import 'dart:convert';
import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/pages/CalendarioUtentePage.dart';
import 'package:fema_crm/pages/DettaglioCommissioneTecnicoPage.dart';
import 'package:fema_crm/pages/DettaglioMerceInRiparazioneByTecnicoPage.dart';
import 'package:fema_crm/pages/FormOrdineFornitorePage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/pages/SpesaSuVeicoloPage.dart';
import 'package:fema_crm/pages/TimbraturaPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../main.dart';
import '../model/CommissioneModel.dart';
import '../model/InterventoModel.dart';
import '../model/RelazioneUtentiInterventiModel.dart';
import '../model/UtenteModel.dart';
import 'DettaglioInterventoByTecnicoPage.dart';
import 'MenuSopralluoghiTecnicoPage.dart';
import 'package:device_info_plus/device_info_plus.dart';

class HomeFormTecnicoNewPage extends StatefulWidget{
  final UtenteModel? userData;

  const HomeFormTecnicoNewPage({Key? key, required this.userData}) : super(key:key);

  @override
  _HomeFormTecnicoNewPageState createState() => _HomeFormTecnicoNewPageState();
}

class _HomeFormTecnicoNewPageState extends State<HomeFormTecnicoNewPage>{
  DateTime selectedDate = DateTime.now();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
  int _hoveredIndex = -1;
  // static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  // Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    saveIngresso();
  }

  int _calculateHoveredIndex(Offset position) {
    final center = Offset(650 / 2, 650 / 2); // Use the same size as in CustomPaint
    final angle = (math.atan2(position.dy - center.dy, position.dx - center.dx) + math.pi * 2) % (math.pi * 2);
    final sectorAngle = (2 * math.pi) / 14; // 14 menu items
    final hoveredIndex = (angle ~/ sectorAngle) % 14;
    return hoveredIndex;
  }

  Future<void> saveIngresso() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/ingresso'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orario': formattedDate,
          'utente' : widget.userData?.toMap(),
        }),
      );
    } catch (e) {
      print('Errore durante il salvataggio dell\'intervento: $e');
    }
  }

  Future<List<CommissioneModel>> getAllCommissioniByUtente(
      String userId) async {
    try {
      String userId = widget.userData!.id.toString();
      http.Response response = await http
          .get(Uri.parse('${ipaddress}/api/commissione/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<CommissioneModel> allCommissioniByUtente = [];
        for (var item in responseData) {
          CommissioneModel commissione = CommissioneModel.fromJson(item);
          if (commissione.concluso == false) {
            allCommissioniByUtente.add(commissione);
          }
        }
        return allCommissioniByUtente;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching commissioni: $e');
      return [];
    }
  }

  Future<List<RelazioneUtentiInterventiModel>> getAllRelazioniByUtente(String userId, DateTime date) async {
    try{
      String userId = widget.userData!.id.toString();
      http.Response response = await http
          .get(Uri.parse('${ipaddress}/api/relazioneUtentiInterventi/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<RelazioneUtentiInterventiModel> allRelazioniByUtente = [];
        for(var item in responseData){
          RelazioneUtentiInterventiModel relazione = RelazioneUtentiInterventiModel.fromJson(item);
          allRelazioniByUtente.add(relazione);
        }
        return allRelazioniByUtente;
      }else {
        return [];
      }
    } catch (e) {
      print('Error fetching interventi: $e');
      return [];
    }
  }

  Future<List<InterventoModel>> getMerce(String userId) async{
    try{
      String userId = widget.userData!.id.toString();
      http.Response response = await http.get(Uri.parse('$ipaddress/api/intervento/withMerce/$userId'));
      if(response.statusCode == 200){
        var responseData = json.decode(response.body);
        List<InterventoModel> interventi = [];
        for(var interventoJson in responseData){
          InterventoModel intervento = InterventoModel.fromJson(interventoJson);
          interventi.add(intervento);
        }
        return interventi;
      } else {
        return [];
      }
    } catch(e){
      print('Errore fetch merce: $e');
      return[];
    }
  }

  Future<List<InterventoModel>> getAllInterventiByUtente(String userId, DateTime date) async {
    try {
      String userId = widget.userData!.id.toString();
      http.Response response = await http
          .get(Uri.parse('${ipaddress}/api/intervento/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<InterventoModel> allInterventiByUtente = [];
        for (var interventoJson in responseData) {
          InterventoModel intervento = InterventoModel.fromJson(interventoJson);
          // Aggiungi il filtro per interventi non conclusi
          if(intervento.merce == null){
            allInterventiByUtente.add(intervento);
          }
        }
        return allInterventiByUtente;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching interventi: $e');
      return [];
    }
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalendarioUtentePage(utente: widget.userData!)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FormOrdineFornitorePage(utente: widget.userData!)),
        );
        break;
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TimbraturaPage(utente: widget.userData!)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MenuSopralluoghiTecnicoPage(utente: widget.userData!)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SpesaSuVeicoloPage(utente: widget.userData!)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home ${widget.userData!.nomeCompleto().toString()}',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginForm()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 40, bottom: 40),
        child: LayoutBuilder(
          builder: (context, constraints){
            if (constraints.maxWidth < 800) {
              // Tablet/Mobile layout
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
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
                            size: Size(300, 300),
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
                              size: Size(300, 300),
                              hoveredIndex: _hoveredIndex,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Interventi',
                            style: TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 15),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null && pickedDate != selectedDate) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    FutureBuilder<List<InterventoModel>>(
                      future: getAllInterventiByUtente(widget.userData!.id.toString(), selectedDate),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Errore: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          List<InterventoModel> interventi = snapshot.data!;

// Filtra ulteriormente nel FutureBuilder per sicurezza
                          interventi = interventi.where((intervento) => intervento.merce == null).toList();

                          interventi = interventi.where((intervento) => intervento.data!.isSameDay(selectedDate)).toList();

                          if (interventi.isEmpty) {
                            return Center(child: Text('Nessun intervento trovato'));
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: interventi.length,
                            itemBuilder: (context, index) {
                              InterventoModel intervento = interventi[index];
                              Color backgroundColor = intervento.concluso ?? false ? Colors.green : Colors.white;
                              TextStyle textStyle = intervento.concluso ?? false
                                  ? TextStyle(color: Colors.white, fontSize: 15)
                                  : TextStyle(color: Colors.black, fontSize: 15);

                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  title: Text(
                                    '${intervento.descrizione}',
                                    style: textStyle,
                                  ),
                                  subtitle: Text(
                                    intervento.cliente?.denominazione.toString() ?? '',
                                    style: textStyle,
                                  ),
                                  trailing: Column(
                                    children: [
                                      Text(
                                        intervento.data != null
                                            ? '${intervento.data!.day}/${intervento.data!.month}/${intervento.data!.year}'
                                            : 'Data non disponibile',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: intervento.concluso ?? false ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        intervento.orario_appuntamento != null
                                            ? '${intervento.orario_appuntamento?.hour}:${intervento.orario_appuntamento?.minute}'
                                            : 'Nessun orario di appuntamento',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: intervento.concluso ?? false ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DettaglioInterventoByTecnicoPage(
                                          utente: widget.userData!,
                                          intervento: intervento,
                                        ),
                                      ),
                                    );
                                  },
                                  tileColor: backgroundColor,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.grey.shade100, width: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(child: Text('Nessun intervento trovato'));
                        }
                      },
                    ),
                    const SizedBox(height: 50.0),
                    Center(
                      child: Text(
                        'Merce in riparazione',
                        style: TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    FutureBuilder<List<InterventoModel>>(
                      future: getMerce(
                        widget.userData!.id.toString()
                      ),
                      builder:(context, snapshot){
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Errore: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          List<InterventoModel> merce = snapshot.data!;
                          if(merce.isEmpty){
                            return Center(child: Text('Nessuna mece in riparazione'));
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: merce.length,
                            itemBuilder:(context, index){
                              InterventoModel singolaMerce = merce[index];
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),
                                child: ListTile(
                                  title: Text(
                                    '${singolaMerce.merce?.articolo}',
                                  ),
                                  subtitle: Text(
                                    '${singolaMerce.merce?.difetto_riscontrato}',
                                  ),
                                  trailing: Column(
                                    children: [
                                      Text('Data arrivo merce:'),
                                      SizedBox(height: 3),
                                      Text('${singolaMerce.data_apertura_intervento != null ? DateFormat("dd/MM/yyyy").format(singolaMerce.data_apertura_intervento!) : "Non disponibile"}')
                                    ],
                                  ),
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DettaglioMerceInRiparazioneByTecnicoPage(
                                            intervento: singolaMerce,
                                            merce : singolaMerce.merce!,
                                        ),
                                      )
                                    );
                                  },
                                  tileColor: Colors.white60,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.grey.shade100, width: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          );
                        } else{
                          return Center(child: Text('Nessuna merce trovata'));
                        }
                      }
                    ),
                    const SizedBox(height: 50.0),
                    Center(
                      child: Text(
                        'Agenda commissioni',
                        style: TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    FutureBuilder<List<CommissioneModel>>(
                      future: getAllCommissioniByUtente(
                          widget.userData!.id.toString()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Errore: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          List<CommissioneModel> commissioni = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: commissioni.length,
                            itemBuilder: (context, index) {
                              CommissioneModel commissione = commissioni[index];
                              return ListTile(
                                title: Text(
                                    '${commissione.descrizione.toString()}'),
                                subtitle: Text(commissione.note?? ''),
                                trailing: Text(
                                  commissione.data!= null
                                      ? '${commissione.data!.day}/${commissione.data!.month}/${commissione.data!.year} ${commissione.data!.hour}:${commissione.data!.minute.toStringAsFixed(1)}'
                                      : 'Data non disponibile',
                                  style: TextStyle(
                                      fontSize: 16),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DettaglioCommissioneTecnicoPage(
                                              commissione: commissione),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        } else {
                          return Center(child: Text('Nessun intervento trovato'));
                        }
                      },
                    ),
                  ],
                ),
              );
            } else {
              return Scaffold();
            }
          }
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

  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.more_time, label: 'TIMBRATURA'),
    MenuItem(icon: Icons.snippet_folder_outlined, label: 'RICHIESTA ORDINE'),
    MenuItem(icon: Icons.remove_red_eye_outlined, label: 'SOPRALLUOGHI'),
    MenuItem(icon: Icons.emoji_transportation_sharp, label: 'SPESE SU VEICOLO'),
    MenuItem(icon: Icons.calendar_month_sharp, label: 'CALENDARIO'),
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
    textDirection: ui.TextDirection.ltr,
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
        textDirection: ui.TextDirection.ltr,
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
              fontSize: 12,
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
      onHover(newIndex);
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

