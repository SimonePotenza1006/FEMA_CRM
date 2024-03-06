import '';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fema_crm/pages/HomeFormAmministrazione.dart';
import 'package:fema_crm/pages/HomeFormTecnico.dart';
import 'databaseHandler/DbHelper.dart';
import 'package:google_fonts/google_fonts.dart';

import 'model/UtenteModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: myThemeData(),
      home: const LoginForm(),
    );
  }
}

ThemeData myThemeData() {
  return ThemeData(
    fontFamily: GoogleFonts.aldrich().fontFamily,
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

  final _conUserId = TextEditingController();
  final _conPassword = TextEditingController();
  late Future<UtenteModel> _futureAlbum;
  var dbHelper;

  @override
  void initState() {
    dbHelper = DbHelper();
    super.initState();
  }

  Future setSP(UtenteModel user) async {
    final SharedPreferences sp = await _pref;
    sp.setString('id', user.id!);
    sp.setString('nome', user.nome!);
    sp.setString('cognome', user.cognome!);
    sp.setString('email', user.email!);
    sp.setString('password', user.password!);
    sp.setString('ruolo', (user.ruolo!.descrizione)!);
    _futureAlbum = dbHelper.getUtentebyId(user.id!);
  }

  login() async {
    String uid = _conUserId.text.trim();
    String passwd = _conPassword.text;

    if (false) {
      print("ERROR FALSE");
    } else {
      print('Ooook!');
      print("AOOOOOO");

      await dbHelper.getLoginUser(uid, passwd).then((userData) {
        print('$uid, $passwd');
        print("Checking userData!");
        if (userData != null) {
          print("PROVA!@");
          setSP(userData).whenComplete(() {
            print("PROVA3");
            print("userdata: $userData");
            TextInput.finishAutofillContext();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => userData.ruolo.descrizione == "Developer" ||
                    userData.ruolo.descrizione == "Tecnico"
                    ? HomeFormTecnico(userData: userData)
                    : HomeFormAmministrazione(userData: userData),
              ),
                  (Route<dynamic> route) => false,
            );
          });
        }
      });
    }
  }

  reset() {
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
