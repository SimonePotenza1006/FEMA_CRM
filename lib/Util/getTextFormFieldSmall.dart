import 'package:flutter/material.dart';

class getTextFormFieldSmall extends StatelessWidget {
  TextEditingController? controller;
  String? hintName;

  IconData? icon;
  bool isObscureText;
  TextInputType inputType;
  bool isEnable;
  bool obbliga;
  double? width;

  getTextFormFieldSmall(
      {super.key,
        this.controller,
        this.hintName,

        this.icon,
        this.isObscureText = false,
        this.inputType = TextInputType.text,
        this.isEnable = true,
        this.obbliga = true,
        this.width});

  validateCF(String cf) {
    final cfReg = new RegExp(
        r'^[A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST]{1}[0-9LMNPQRSTUV]{2}[A-Z]{1}[0-9LMNPQRSTUV]{3}[A-Z]{1}$');
    return cfReg.hasMatch(cf);
  }

  // static String _getCheckCode(String partialFiscalCode) {
  //   partialFiscalCode = partialFiscalCode.toUpperCase();
  //   int val = 0;
  //   for (int i = 0; i < 15; i = i + 1) {
  //     final String c = partialFiscalCode[i];
  //     val += (i % 2 != 0 ? CHECK_CODE_EVEN[c.toString()]! : CHECK_CODE_ODD[c.toString()]!);
  //   }
  //   val = val % 26;
  //   return CHECK_CODE_CHARS[val];
  // }

  // static bool check(String codiceFiscale) {
  //   String cf = codiceFiscale.toUpperCase();
  //   if (cf.length != 16) {
  //     return false;
  //   }
  //   if (!RegExp(r'^[A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST]{1}[0-9LMNPQRSTUV]{2}[A-Z]{1}[0-9LMNPQRSTUV]{3}[A-Z]{1}$')
  //       .hasMatch(cf)) {
  //     return false;
  //   }
  //   final expectedCheckCode = codiceFiscale[15];
  //   cf = codiceFiscale.substring(0, 15);
  //   return _getCheckCode(cf).toUpperCase() == expectedCheckCode.toUpperCase();
  // }

  @override
  Widget build(BuildContext context) {
    //print("vaaalid?");
    return Container(
        color: Color.fromRGBO(224, 224, 224, 0.6),
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.0),
        child: SizedBox( // <-- SEE HERE
          width: width,
          height: 15,
          child:
          TextFormField(
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(224, 224, 224, 0.6)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              contentPadding: EdgeInsets.all(0.0),
              isDense: true,
              //border: InputBorder.none,
            ),
            //scrollPadding: EdgeInsets.zero,
            //selectionControls: ,
            //enableInteractiveSelection: ,
            cursorRadius: Radius.zero,

            //scrollPadding: EdgeInsets.all(2.0),
            textAlignVertical: TextAlignVertical.bottom,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.0),
            //initialValue: populate,
            controller: controller,
            //obscureText: isObscureText,
            enabled: isEnable,
            keyboardType: inputType,
            validator: (value) //=> value!.length ==0 ? '' : null,
            {
              print("vaaalid? 22");

              if (value == null || value.isEmpty && obbliga) {
                print("nuuuuuuuuuuuuuuul");
                return 'Inserisci $hintName';
              }
              print('nvx '+validateCF(value!).toString());
              if (hintName == "Codice Fiscale *" && !validateCF(value.toUpperCase())) {//CodiceFiscale.check(value.toUpperCase()) == false) {

                print(hintName!+' '+value.toUpperCase());
                return 'Inserisci un codice fiscale valido';
              }
              // if (hintName == "Email" && !validateEmail(value!)) {
              //   return 'Inserisci un indirizzo email valido';
              // }
              return null;
            },

          ),


        )

    );
  }
}