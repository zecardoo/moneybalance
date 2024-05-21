// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class DisplayRecord extends StatefulWidget {
  final Map<String, dynamic> recordID;

  const DisplayRecord({
    Key? key,
    required this.recordID,
  }) : super(key: key);

  @override
  State<DisplayRecord> createState() => _DisplayRecordState();
}

class _DisplayRecordState extends State<DisplayRecord> {
  @override
  Widget build(BuildContext context) {

    final recordID = widget.recordID;
    return Scaffold(

      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.blue[900],
              floating: true,
              forceElevated: innerBoxIsScrolled,
              snap: true,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                recordID['name'],
                style: GoogleFonts.readexPro(textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                
              ),
            ),
          ];
        },
        body: userData(recordID['id']),
      ),
    );
  }

  Widget userData(String recordID) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('record').doc(recordID).collection('balance').snapshots(),
      builder: (context, snapshot) {
        //if has error 
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
      
        // if correct
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitFadingCircle(
              color: Colors.blue[900],
            ),
          );
        }
        
       
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('لاتوجد بيانات متاحة ', style: GoogleFonts.readexPro(textStyle: TextStyle(fontSize: 30)),));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index];
            final DateTime dateTime = data['date'].toDate();

            return ListTile(

              title: Text('التاريخ : ${dateTime.year} - ${dateTime.month} - ${dateTime.day}'), // Replace 'fieldName' with your actual field name
            );
          },
        );
      },
    );
  }
}
