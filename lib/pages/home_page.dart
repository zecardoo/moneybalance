import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
  
}

class _HomePageState extends State<HomePage> {
    late Map<String, dynamic> documentData;



  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.blue[900],
        // ),


        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                // backgroundColor: Colors.blue[900],
                // pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                snap: true,
                // expandedHeight: 100,
                
                

              )
            ];
          },
          body:displayRecord()

        ),
      
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            Navigator.pushNamed(context, '/addRecord');
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          // backgroundColor: Colors.blue[900],
          child: const Icon(Icons.add, color: Colors.white,),
        ),
        
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

        // fix why show erros here 
        
        bottomNavigationBar: const BottomAppBar(
          shape: CircularNotchedRectangle(),
          // notchMargin: 5,
          // color: Colors.blue[900],
          height: 50,
        ),
    );
  }

  Future<void> refreshTable () async {
  
    displayRecord();
  }
  
  Widget displayRecord () {
    return RefreshIndicator(
      onRefresh: refreshTable,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection('record')
          .orderBy('createdAt', descending: true) // Order by 'createdAt' in descending order
          .snapshots(),
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
          // if no data in collection
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text('');
          }
      
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
              final data = snapshot.data!.docs[index];
                
              final subCollection = FirebaseFirestore.instance.collection('record').doc(data.id).collection('balance');
               
              return Column(
                children: [
                  StreamBuilder(
                    stream: subCollection.snapshots(),
                    builder: (context, subSnapshot) {
                      if (subSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${subSnapshot.error}'),
                        );
                      }
                    
                      // if correct
                      // if (subSnapshot.connectionState == ConnectionState.waiting) {
                      //   return Center(
                      //     child: SpinKitFadingCircle(
                      //       color: Colors.blue[900],
                      //     ),
                      //   );
                      // }

                      // if no data in collection
                      if (!subSnapshot.hasData || subSnapshot.data!.docs.isEmpty) {
                        return const Text('');
                      }

                      int subDocCount = subSnapshot.data!.docs.length;
                      final subdata = subSnapshot.data!.docs[index];

                      return   GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/displayRecord', arguments: documentData = {'name': data['name'], 'id': data.id}),
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center, // Adjust as needed
                            children: [
                              const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.green, size: 30,),
                                  
                              const Spacer(), // Adjust spacing as needed
                                  
                              Expanded(
                                flex: 2,
                                child: Text(
                                   '${subdata['amount']}',
                                  style: GoogleFonts.readexPro(textStyle:  TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                            
                                ),
                              ),
                                
                              const Spacer(), // Adjust spacing as needed
                                    
                              badges.Badge(
                                badgeContent: Text(
                                  '$subDocCount',
                                  style: GoogleFonts.readexPro(textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                                ),
                                badgeStyle: const badges.BadgeStyle(badgeColor: Colors.blueAccent),
                              ),
                                
                              const Spacer(), // Adjust spacing as needed
                              Expanded(
                                flex: 3,
                                child: Text(
                                  data['name'],
                                  style: GoogleFonts.readexPro(textStyle:  TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                                
                              const Spacer(), // Adjust spacing as needed
                              // const SizedBox(width: 15),
                              IconButton(
                                onPressed: () {}, 
                                icon: Icon(Icons.add, size: 30, color: Colors.blue[900]),
                              ),  
                            
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider() ,                   

                ],
              );
            
            },
          );
        },
      ),
    );
  }
 
}