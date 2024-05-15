import 'package:flutter/material.dart';
import 'package:moneybalance/pages/add_record.dart';
import 'package:moneybalance/pages/home_page.dart';

void main() {
  runApp(MaterialApp(
    routes: {
      '/':(context) => const HomePage(),
      '/addRecord':(context) => const AddRecord(), 
    },
    debugShowCheckedModeBanner: false,
  ));
}


