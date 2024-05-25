import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFormFildAdd extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardtype;
  final bool inputnumber;
  final double padding;
  final String hinttext;

  const TextFormFildAdd({
     super.key,
    required this.controller,
    required this.keyboardtype,
    required this.inputnumber,
    required this.padding,
    required this.hinttext,
  });

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: TextFormField(
        controller: controller,
        //for text to start from left or right
        textAlign: TextAlign.right,
        // select the datat type numbers only or text with number 
        keyboardType: keyboardtype,
        
        // what format of data numbers only or text 
        inputFormatters: inputnumber ? <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
        ] : null,

        style:  GoogleFonts.readexPro(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: 1
              
            ),
        ),

        decoration:  InputDecoration(
          hintText:hinttext,
         focusedBorder: const UnderlineInputBorder( 
          borderSide: BorderSide(color: Color.fromARGB(255, 13, 71, 161))
         )
        ),

        validator: (value) {
          if(value == null || value.isEmpty){
              return 'الرجاء إدخال نص';
          }
          return null;
        },
        
        
      ),
    );
  }

  
}
