// Widget displayRecord () {
    
//     return StreamBuilder(
//       stream: FirebaseFirestore.instance.collection('record').snapshots(),
//       builder: (context, snapshot) {
//          //if has error 
//           if (snapshot.hasError) {
//             return Center(
//               child: Text('Error: ${snapshot.error}'),
//             );
//           }

//           // if correct
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: SpinKitSquareCircle(
//                 color: Colors.blue[900],
//               ),
//             );
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (BuildContext context, int index) {
//               final data = snapshot.data!.docs[index];
//               return Table(
//                     children: [
//                       TableRow(
//                         decoration: const BoxDecoration(
//                           border: Border(bottom: BorderSide(color: Color.fromARGB(255, 218, 218, 218)))
                          
//                         ),
//                         children: [
//                           const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 15),
//                             child: TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Icon(
//                               Icons.keyboard_arrow_up, 
//                               color: Colors.green,
//                               size: 30,
//                             )),
//                           ),
                          
                                          
//                           TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Text(data['amount'], 
//                           style: GoogleFonts.varelaRound(textStyle: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[700]
//                           )),)),

//                           TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Text(data['amount'], 
//                           style: GoogleFonts.varelaRound(textStyle: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[700]
//                           )),)),
                          
//                           TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Text(data['name'], 
//                           style: GoogleFonts.varelaRound(textStyle: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey[700],
//                           )))),

//                           TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: IconButton(onPressed: () {}, icon: Icon(
//                             Icons.add, 
//                             size: 30, 
//                             color: Colors.blue[900],
//                           )))
//                         ]
//                       ),
//                     ],
//                   );
          
//             },
//           );
//       },
//     );
//   }  show this Incorrect use of ParentDataWidget.
