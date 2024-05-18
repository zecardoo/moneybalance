import 'package:flutter/material.dart';
import 'package:moneybalance/pages/add_record.dart';
import 'package:moneybalance/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  
  // Ensure that WidgetsFlutterBinding is properly initialized
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
    );

  runApp(MaterialApp(
    routes: {
      '/':(context) => const HomePage(),
      '/addRecord':(context) => const AddRecord(), 
    },
    debugShowCheckedModeBanner: false,
  ));
}


