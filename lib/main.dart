import 'dart:io';

import 'package:fema_crm/pages/HomeFormAmministrazioneNewPage.dart';
import 'package:fema_crm/pages/HomeFormSegreteriaMobilePage.dart';
import 'package:fema_crm/pages/HomeFormTecnicoNewPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'databaseHandler/DbHelper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model/RuoloUtenteModel.dart';
import 'model/TipologiaInterventoModel.dart';
import 'model/UtenteModel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import '../model/DeviceModel.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestLocationPermission();
  initializeDateFormatting('it_IT', null).then((_) {
    runApp(MyApp());
  });
}

class CustomLocalizations {
  CustomLocalizations(this.locale);

  final Locale locale;

  static CustomLocalizations of(BuildContext context) {
    return Localizations.of<CustomLocalizations>(context, CustomLocalizations)!;
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'it': {
      'sun': 'Dom',
      'mon': 'Lun',
      'tue': 'Mar',
      'wed': 'Mer',
      'thu': 'Gio',
      'fri': 'Ven',
      'sat': 'Sab',
    },
  };

  String getDayName(String day) {
    return _localizedValues[locale.languageCode]![day] ?? day;
  }
}

class CustomLocalizationsDelegate extends LocalizationsDelegate<CustomLocalizations> {
  const CustomLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'it'].contains(locale.languageCode);
  }

  @override
  Future<CustomLocalizations> load(Locale locale) {
    return SynchronousFuture<CustomLocalizations>(CustomLocalizations(locale));
  }

  @override
  bool shouldReload(CustomLocalizationsDelegate old) => false;
}

Future<void> _requestLocationPermission() async {
  PermissionStatus status = await Permission.location.request();
  if (status.isDenied) {
    // Il permesso è stato negato dall'utente, gestire di conseguenza
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale('it', 'IT'),
      localizationsDelegates: [
        const CustomLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('it', 'IT'),
      ],
      home: LoginForm(),
    );
  }
}

ThemeData myThemeData() {
  return ThemeData(
    fontFamily: GoogleFonts.robotoFlex().fontFamily,
  );
}

class LoginForm extends StatefulWidget {
  LoginForm({Key? key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  final GlobalKey<FormState> _formKeyLice = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  final _conUserId = TextEditingController();
  final _conPassword = TextEditingController();
  final _conLicenza = TextEditingController();
  late Future<UtenteModel> _futureAlbum;
  var dbHelper;
  String? idd = null;
  List<String> dispositivi = [];
  String? platform = null;
  bool licenzaerrata = false;
  List<String> licenze = [];

  @override
  void initState() {
    dbHelper = DbHelper();
    initPlatformState().whenComplete(() =>
        getUserData()
    );
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> initPlatformState() async {
    String udid;
    try {
      udid = await FlutterUdid.consistentUdid;
    } on PlatformException {
      udid = 'Failed to get UDID.';
    }
    if (!mounted) return;
    setState(() {
      idd = udid;//_udid = udid;
    });
    (udid != null) ? print('nuovo id '+  udid!) : print('nuovo id null');
  }

  Future<void> getDev() async {
    dispositivi=await dbHelper.getAllDevice();
  }

  Future<void> getUserData() async {
    //dispositivi=await dbHelper.getAllDevice();

    getDev().whenComplete(() async {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isWindows) {
      print('windows');
      WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
      //idd = windowsInfo.deviceId.toString();
      platform = 'windows';
      print('Running on '
      //  '${androidInfo.model.toString()} ${androidInfo.id.toString()} '
          '${windowsInfo.computerName.toString()} ${windowsInfo.deviceId
          .toString()}'
      );
    } else if (Platform.isAndroid) {
      print('android');
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      //idd= androidInfo.id.toString();
      platform = 'android';
      print('Running on '
          '${androidInfo.model.toString()} ${androidInfo.serialNumber
          .toString()} '
      );
    }
    /*if (dispositivi.contains(idd)) {
      print('okok');
    } else {*/
      //DeviceModel uModel = DeviceModel('', idd);
      await insertLicenza();
    //}


    SharedPreferences sp = await _pref;

    setState(() {
      idd = idd;
    });
  });
  }

  Future<void> insertLicenza() async {
    //bool licenzaerrata = false;
    //licenze=await dbHelper.getAllLicenze();
    if (dispositivi.isEmpty) {
      return (await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) =>
              AlertDialog(
              title: new Text('Errore di rete', style: TextStyle(fontWeight: FontWeight.w600),),
              content: new Text("Siamo spiacenti ma al momento non è possibile utilizzare l\'applicazione in quanto sono presenti dei problemi di rete. "
                  "Riprova più tardi"),
              actions: <Widget>[
                TextButton(
                  onPressed: () { exit(0); }, //<-- SEE HERE
                  child: new Text('OK', style: TextStyle(fontWeight: FontWeight.w600),),
                )
              ]
          ))
      );
    } else
    if (dispositivi.contains(idd)) return;
    //Navigator.of(context).pop(false);
    else {
    return (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) =>
          WillPopScope(onWillPop: () async {
            return false;
          }, child:
          AlertDialog(
        title: new Text('Numero di licenza', style: TextStyle(fontWeight: FontWeight.w600),),
        content: new Text('Dispositivo $idd non ancora registrato: Inserisci il numero di licenza per utilizzare l\'applicazione Fema'),
        actions: <Widget>[
          Form(
              key: _formKeyLice,
              //autovalidateMode: AutovalidateMode.onUserInteraction,
              child:
              Column(
                //scrollDirection: Axis.vertical,
                //direction: Axis.vertical,
                  children: [
                    TextFormField(
                      controller: _conLicenza,
                      obscureText: false,
                      enabled: true,
                      //autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) //=> value!.length ==0 ? '' : null,
                      {
                        print("jytg? 22");

                        if (value == null || value.isEmpty || licenzaerrata) {
                          print("nuuuuuuuuuuuuuuul");
                          return 'Inserisci un codice di licenza valido';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        floatingLabelStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: 17.0),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        //floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: UnderlineInputBorder(//OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        //prefixIcon: Icon(icon),
                        //hintText: hintName,
                        labelText: 'Numero di licenza',
                        fillColor: Colors.grey[200],
                        errorStyle: TextStyle(color: Colors.black),
                        //hintStyle: TextStyle(fontWeight: FontWeight.w800),
                        labelStyle: TextStyle(fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic, color: Colors.black),
                        focusColor: Colors.grey,
                        //hoverColor: Colors.black,
                        filled: true,
                      ),
                    ),
                    TextButton(
                      onPressed: resetLicenza, //<-- SEE HERE
                      child: new Text('RESET', style: TextStyle(fontWeight: FontWeight.w600),),
                    ),
                    TextButton(
                      onPressed: () async =>
                      { if (_formKeyLice.currentState!.validate()) {
                        licenze=await dbHelper.getAllLicenze(),
                        if (licenze.contains(_conLicenza.text)) {
                          setState(() {
                            licenzaerrata = false;
                          }),
                          await dbHelper.saveDevice(DeviceModel('', idd)),
                          await dbHelper.saveLicenzaNo(_conLicenza.text),
                          Navigator.pop(context)
                          //print('okok')
                        } else {
                          setState(() {
                            licenzaerrata = true;
                          })
                        },
                      } },//Navigator.of(context).pop(true), // <-- SEE HERE
                      child: new Text('OK', style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600),),
                    ),
                  ]))
        ],
      )),
    ));} //?? false;
  }

  resetLicenza(){
    _conLicenza.text = '';
    setState(() {
      licenzaerrata = false;
    });
  }

  Future<void> setSP(UtenteModel user) async {
    final SharedPreferences sp = await _pref;
    sp.setString('id', user.id!);
    sp.setString('nome', user.nome!);
    sp.setString('cognome', user.cognome!);
    sp.setString('email', user.email!);
    sp.setString('password', user.password!);
    sp.setString('ruolo', (user.ruolo!.descrizione)!);
    _futureAlbum = dbHelper.getUtentebyId(user.id!);
  }

  Future<UtenteModel> getLoginUser(String email, String password) async {
    try {
      http.Response response = await http.post(
          Uri.parse('$ipaddress/api/utente/ulogin'),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: json.encode({
            'email': email,
            'password': password
          }),
          encoding: Encoding.getByName('utf-8')
      );
      if(response.statusCode == 200){
        var responseData = jsonDecode(response.body.toString());
        UtenteModel utente = UtenteModel(
          responseData['id'].toString(),
          responseData['attivo'],
          responseData['nome'].toString(),
          responseData['cognome'].toString(),
          responseData['email'].toString(),
          responseData['password'].toString(),
          responseData['cellulare'].toString(),
          responseData['codice_fiscale'].toString(),
          responseData['iban'].toString(),
          RuoloUtenteModel.fromJson(responseData['ruolo']),
          TipologiaInterventoModel.fromJson(responseData['tipologia_intervento']),
        );
        if (utente.attivo == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Le credenziali sono errate, riprova!'),
            ),
          );
          throw Exception('Login Failed');
        } else
        return utente;
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le credenziali sono errate, riprova!'),
          ),
        );
        throw Exception('Login Failed ${response.statusCode}');
      }
    } catch(e){
      throw Exception('$e');
    }
  }

  Future<void> login() async {
    String uid = _conUserId.text.trim();
    String passwd = _conPassword.text;

    try {
      // Ottieni userData tramite login
      var userData = await getLoginUser(uid, passwd);

      if (userData != null) {
        await setSP(userData);
        await _saveCredentials(uid, passwd);

        TextInput.finishAutofillContext();

        // Debugging: Controlla ruolo, ID e piattaforma
        print("Ruolo utente: ${userData.ruolo?.descrizione}");
        print("ID utente: ${userData.id}");
        print("Platform.isAndroid: ${Platform.isAndroid}");

        // Logica per redirezionare in base al ruolo, id, e piattaforma
        if (userData.id != null && userData.ruolo != null) {
          if (isAdministratore(userData)) {
            // Controllo della larghezza massima dello schermo
            double screenWidth = MediaQuery.of(context).size.width;
            print("Larghezza dello schermo: $screenWidth px");

            if (screenWidth < 800) {
              print("Larghezza dello schermo inferiore a 800px. Reindirizzamento verso HomeFormSegreteriaMobilePage.");
              navigateToHomeFormSegreteriaMobilePage(userData);
            } else {
              // Se la larghezza è maggiore o uguale a 800px, gestisci il reindirizzamento in base alla piattaforma
              if (Platform.isAndroid) {
                print("Platform è Android. Reindirizzamento verso HomeFormSegreteriaMobilePage.");
                navigateToHomeFormSegreteriaMobilePage(userData);
              } else {
                print("Platform NON è Android. Reindirizzamento verso HomeFormAmministrazioneNewPage.");
                navigateToHomeFormAmministrazioneNewPage(userData);
              }
            }
          } else {
            // Debugging: L'utente non è un amministratore
            print("L'utente non è un amministratore. Reindirizzamento in base al ruolo.");
            navigateToHomePageBasedOnRole(userData);
          }
        } else {
          print("Errore: userData.id o userData.ruolo sono null");
        }
      } else {
        print("Errore: userData è null");
      }
    } catch (e) {
      print("Errore durante il login: $e");
    }
  }

  bool isAdministratore(UtenteModel userData) {
    print('ruolo '+userData.ruolo!.descrizione!);
    bool isAdmin = ['12', '4'].contains(userData.id) && userData.ruolo!.descrizione! == "Amministrazione";
    print("isAdministratore: $isAdmin per l'utente con ID ${userData.id} e ruolo ${userData.ruolo?.descrizione}");
    return isAdmin;
  }

  void navigateToHomeFormSegreteriaMobilePage(UtenteModel userData) {
    print("Reindirizzamento verso HomeFormSegreteriaMobilePage");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeFormSegreteriaMobilePage(userData: userData)),
    );
  }

  void navigateToHomeFormAmministrazioneNewPage(UtenteModel userData) {
    print("Reindirizzamento verso HomeFormAmministrazioneNewPage");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeFormAmministrazioneNewPage(userData: userData)),
    );
  }

  void navigateToHomePageBasedOnRole(UtenteModel userData) {
    switch (userData.ruolo?.descrizione) {
      case "Developer":
      case "Tecnico":
        navigateToHomeFormTecnicoNewPage(userData);
        break;
      default:
        navigateToHomeFormAmministrazioneNewPage(userData);
    }
  }

  void navigateToHomeFormTecnicoNewPage(UtenteModel userData) {
    print("Reindirizzamento verso HomeFormTecnicoNewPage");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeFormTecnicoNewPage(userData: userData)),
    );
  }



  Future<void> _saveCredentials(String username, String password) async {
    final SharedPreferences sp = await _pref;
    sp.setString('username', username);
    sp.setString('password', password);
  }

  Future<void> _loadSavedCredentials() async {
    final SharedPreferences sp = await _pref;
    String? savedUsername = sp.getString('username');
    String? savedPassword = sp.getString('password');

    if (savedUsername != null && savedPassword != null) {
      _conUserId.text = savedUsername;
      _conPassword.text = savedPassword;
    }
  }

  void reset() {
    _conUserId.text = '';
    _conPassword.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(

              image: DecorationImage(
                  image: ExactAssetImage("assets/images/background_login_1_1.jpg"),
                  fit: BoxFit.cover,
                  opacity: 0.8
              ),
            ),
          ),
          Container(
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topCenter,
            //     end: Alignment.bottomCenter,
            //     colors: [Colors.white10, Colors.red.shade500],
            //   ),
            // ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Responsive logo image
                  Image.asset(
                    'assets/images/logo fema trasparente bianco.png',
                    width: MediaQuery.of(context).size.width * 0.4, // 30% of screen width
                    //height: MediaQuery.of(context).size.width * 0.3, // 30% of screen width
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 40),
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: 400,
                            child: TextFormField(
                              onFieldSubmitted: (value) {
                                login();
                              },
                              controller: _conUserId,
                              decoration: InputDecoration(
                                labelText: 'USERNAME',
                                hintText: 'INSERISCI IL TUO USERNAME',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[400]!,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2.0,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                              ),
                              autofillHints: [AutofillHints.username],
                            ),
                          ),
                          SizedBox(height: 15),
                          SizedBox(
                            width: 400,
                            child: TextFormField(
                              onFieldSubmitted: (value) {
                                login();
                              },
                              controller: _conPassword,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'PASSWORD',
                                hintText: 'INSERISCI LA PASSWORD',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[400]!,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2.0,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                              ),
                              autofillHints: [AutofillHints.password],
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: login,
                            child: Text(
                              'ACCEDI',
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text('REL. 11.12.24', textAlign: TextAlign.end, style: TextStyle(fontSize: 12))
                          )

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



}