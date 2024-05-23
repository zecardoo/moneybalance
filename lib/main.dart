import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneybalance/bloc/record_bloc.dart';
import 'package:moneybalance/pages/add_record.dart';
import 'package:moneybalance/pages/display_record.dart';
import 'package:moneybalance/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );

  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<RecordBloc>(
        create: (context) => RecordBloc(),
      ),
    ],
    child: MaterialApp(
     
      scaffoldMessengerKey: scaffoldKey,
      // initialRoute: '/',
      onGenerateRoute: (settings) {
        if(settings.name == '/displayRecord'){
          // Pass the argument to DisplayRecord widget
          final args = settings.arguments as Map<String, dynamic>; 

          return MaterialPageRoute(builder: (context) => DisplayRecord(recordID: args,));
        }
      
        return null; // Handle other routes here if necessary
      },
      routes: {
        '/': (context) => const HomePage(),
        '/addRecord': (context) => const AddRecord(),
      },
      theme: ThemeData(
        primarySwatch: Colors.red,
        appBarTheme: AppBarTheme(
          color: Colors.indigo[600], // Regular AppBar background color
        ),
        bottomAppBarTheme: BottomAppBarTheme(color: Colors.indigo[600]),
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.indigo[600]),
        scaffoldBackgroundColor: Colors.white,

        // fontFamily: FontFeature.numerators()
      ),
      debugShowCheckedModeBanner: false,
       
      ),
      
    ),
  );
}
