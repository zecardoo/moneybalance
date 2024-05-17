import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
        ),

        // body: Table(
        //   children: [
        //     TableRow(
        //       decoration: const BoxDecoration(
        //         border: Border(bottom: BorderSide(color: Color.fromARGB(255, 218, 218, 218)))
                
        //       ),
        //       children: [
        //         const Padding(
        //           padding: EdgeInsets.symmetric(vertical: 15),
        //           child: TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Icon(
        //             Icons.keyboard_arrow_up, 
        //             color: Colors.green,
        //             size: 30,
        //           )),
        //         ),
                
                                
        //         TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Text('12', 
        //         style: GoogleFonts.varelaRound(textStyle: TextStyle(
        //           fontSize: 16,
        //           color: Colors.grey[700]
        //         )),)),

        //         TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Text('30', 
        //         style: GoogleFonts.varelaRound(textStyle: TextStyle(
        //           fontSize: 16,
        //           color: Colors.grey[700]
        //         )),)),
                
        //         TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Text('Zakarya', 
        //         style: GoogleFonts.varelaRound(textStyle: TextStyle(
        //           fontSize: 18,
        //           color: Colors.grey[700],
        //         )))),

        //         TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: IconButton(onPressed: () {}, icon: Icon(
        //           Icons.add, 
        //           size: 30, 
        //           color: Colors.blue[900],
        //         )))
        //       ]
        //     ),
        //   ],
        // ),
        
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/addRecord');
          },

          child: const Icon(Icons.add),
        ),
    );
  }
}