import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fema_crm/pages/HomeFormAmministrazione.dart';
import 'package:fema_crm/pages/HomeFormTecnico.dart';
import 'databaseHandler/DbHelper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'model/RuoloUtenteModel.dart';
import 'model/TipologiaInterventoModel.dart';
import 'model/UtenteModel.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestLocationPermission();
  initializeDateFormatting('it_IT', null).then((_) {
    runApp(const MyApp());
  });
}

Future<void> _requestLocationPermission() async {
  PermissionStatus status = await Permission.location.request();
  if (status.isDenied) {
    // Il permesso è stato negato dall'utente, gestire di conseguenza
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      theme: myThemeData(),
      home: const LoginForm(),
    );
  }
}

ThemeData myThemeData() {
  return ThemeData(
    fontFamily: GoogleFonts.robotoFlex().fontFamily,
  );
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();

  final _formKey = GlobalKey<FormState>();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  final _conUserId = TextEditingController();
  final _conPassword = TextEditingController();
  late Future<UtenteModel> _futureAlbum;
  var dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    _loadSavedCredentials();
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

    await getLoginUser(uid, passwd).then((userData) {
      if (userData != null) {
        setSP(userData).then((_) {
          TextInput.finishAutofillContext();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => userData.ruolo?.descrizione == "Developer" ||
                  userData.ruolo?.descrizione == "Tecnico"
                  ? HomeFormTecnico(userData: userData)
                  : HomeFormAmministrazione(userData: userData),
            ),
                (Route<dynamic> route) => false,
          );
        });
      }
    });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: Center(
                child: SizedBox(
                  width: 400,
                  height: 250,
                  child: Image(image: AssetImage('assets/images/logo.png')),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextFormField(
                controller: _conUserId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  labelText: 'Username',
                  hintText: 'Inserisci il tuo username',
                ),
                autofillHints: [AutofillHints.username],
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: _conPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  labelText: 'Password',
                  hintText: 'Inserisci la password',
                ),
                autofillHints: [AutofillHints.password],
              ),
            ),
            SizedBox(height: 30),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(25),
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: login,
                child: const Text(
                  'ACCEDI',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
