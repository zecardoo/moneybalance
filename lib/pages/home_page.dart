import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
  
}

class _HomePageState extends State<HomePage> {
  
  late Map<String, dynamic> documentData;
  double amount = 0;
  Logger logger = Logger();

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'عام',
              style: GoogleFonts.readexPro(textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                
              )),
            ),
          ),
          
        ),
        
        body: displayRecord(),
        // body: NestedScrollView(
        //   headerSliverBuilder: (context, innerBoxIsScrolled) {
        //     return [
        //       SliverAppBar(
        //         // backgroundColor: Colors.blue[900],
        //         pinned: true,
        //         // floating: true,
        //         forceElevated: innerBoxIsScrolled,
        //         snap: true,
        //         // expandedHeight: 100,
                
                

        //       )
        //     ];
        //   },
        //   body:displayRecord()

        // ),
      
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
    double forhim = 0;
    double onhim = 0;
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
              // get the id of the data 
              final docsID = data.id;
              // get the data of that id doc to update or delete 
              final documentReference = FirebaseFirestore.instance.collection('record').doc(docsID);
              final subCollection = FirebaseFirestore.instance.collection('record').doc(data.id).collection('balance').orderBy('createdAt', descending: true);
              
              return Column(
                children: [
                  StreamBuilder(
                    stream: subCollection.snapshots(),
                    builder: (context, subSnapshot) {
                       if (subSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Placeholder widget while waiting for data
                        }
                      final subDocs = subSnapshot.data!.docs;

                      forhim = 0;
                      onhim = 0;
                      // Iterate through each document in subSnapshot.data!.docs
                      for (int i = 0; i < subDocs.length; i++) {
                        final DocumentSnapshot? doc = subSnapshot.data?.docs[i];
                        final Map<String, dynamic>? subData = doc?.data() as Map<String, dynamic>?;
                        if (subData != null) {
           
                          forhim += subData['forhim'] ?? 0;
                          onhim += subData['onhim'] ?? 0;
                        }
                      }
                      // logger.i('--------- $forhim ------------ $onhim');
                    
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

                      int subDocCount = 0;
                      // if no data in collection
                      if (!subSnapshot.hasData || subSnapshot.data!.docs.isEmpty) {
                        
                      }else{
                        subDocCount = subSnapshot.data!.docs.length;
                      }

                      

                      return Dismissible(
                        
                        key:  Key(docsID),
                        onDismissed: (direction) {
                          // Implement deletion logic here
                          documentReference.delete().then((_) {
                            logger.i('----------[ Deleted Successfully ]----------');
                          }).catchError((onError) {
                            logger.e('Error: $onError');
                          });
                        },
                        confirmDismiss: (direction) {
                          return showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'تأكيد الحذف',
                                    style: GoogleFonts.readexPro(textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                    )),
                                  ),
                                ),
                                content: Text(
                                  'سيتم حذف جميع المبالغ المرتبطة بهذا الحساب, هل تريد الحذف ؟',
                                  style: GoogleFonts.readexPro(textStyle: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[800] 
                                  )),
                                ),
                                actions: [
                                   TextButton(
                                    onPressed: () => Navigator.pop(context),
                                                                
                                    child: Text(
                                      'لا',
                                      style: GoogleFonts.readexPro( textStyle: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.redAccent
                                      )),
                                    ),
                                  ),
                                  
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                      // Implement deletion logic here
                                      documentReference.delete().then((_) {
                                        logger.i('----------[ Deleted Successfully ]----------');
                                      }).catchError((onError) {
                                        logger.e('Error: $onError');
                                      });
                                    },
                                    child: Text(
                                      'نعم',
                                      style: GoogleFonts.readexPro( textStyle: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.redAccent
                                      )),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        background: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.redAccent
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                    
                          ),
                        ),
                        secondaryBackground: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.redAccent
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                    
                          ),

                          
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/displayRecord', arguments: documentData = {'name': data['name'], 'id': data.id}),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center, // Adjust as needed
                              children: [
                                forhim > onhim ? const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.green, size: 30) : const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.red, size: 30),
                                    
                                const Spacer(), // Adjust spacing as needed
                                    
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                     '${data['amount']}',
                                    style: GoogleFonts.readexPro(textStyle:  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                              
                                  ),
                                ),
                                  
                                const Spacer(), // Adjust spacing as needed
                        
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.blueAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                    '$subDocCount',
                                    style: GoogleFonts.readexPro(textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                                  ),
                                  ),
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
                                  onPressed: () => Navigator.pushNamed(context, '/addNewData', arguments: documentData = {'name': data['name'], 'id': data.id}), 
                                  icon: Icon(Icons.add, size: 30, color: Colors.blue[900]),
                                ),  
                              
                              ],
                            ),
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