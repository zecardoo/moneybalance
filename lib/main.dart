import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneybalance/bloc/record_bloc.dart';
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

  runApp(MultiBlocProvider(
      providers: [
        BlocProvider<RecordBloc>(
          create: (context) => RecordBloc(),
        ),
      ],
      
      child: MaterialApp(
        routes: {
          '/': (context) => const HomePage(),
          '/addRecord': (context) => const AddRecord(),
        },
        debugShowCheckedModeBanner: false,
      ),
    )
  );
}


