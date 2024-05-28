import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class RecordDataSource extends DataGridSource {
  
   List<DataGridRow> _records = [];
  List<DocumentSnapshot> _documents = [];

  RecordDataSource({required List<DataGridRow> records}) {
    _records = records;
  }

  @override
  List<DataGridRow> get rows => _records;
  
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      for (var cell in row.getCells())
        Container(
          alignment: Alignment.center,
          child: cell.columnName == 'state'
              ? (cell.value == true ?  const Icon(Icons.keyboard_arrow_up_sharp, color: Colors.green, size: 30,) : const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.red, size: 30,)) 
              : Text(cell.value.toString(), style: GoogleFonts.readexPro(textStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color.fromARGB(255, 83, 83, 83),)),),
        ),
    ]);
  }
  // doc['amount']
  void updateData(List<DocumentSnapshot> docs) async{
    double amount = 0;

    // Sort the documents by date before processing
    // docs.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
  
    
    _documents = docs;
    _records = docs.map((doc) {
      final double money;
      final DateTime date = doc['date'].toDate();
      final time = DateFormat('h:mm a').format(date);

      if(doc['forhim'] != 0){
        money = doc['forhim'];

      }else{
        money = doc['onhim'];

      }
      amount+= doc['forhim'];
      amount-= doc['onhim'];
      return DataGridRow(cells: [
        DataGridCell(columnName: 'amount', value: amount),
        DataGridCell(columnName: 'state', value: doc['onhim'] < doc['forhim']),
        DataGridCell(columnName: 'details', value: doc['details']),
        DataGridCell(columnName: 'money', value: money),
        DataGridCell(columnName: 'date', value: '${date.day}-${date.month}-${date.year} \n $time'),



        // DataGridCell<String>(columnName: 'id', value: doc.id),
        
        // Add more cells here if needed
      ]);
    }).toList();

    notifyListeners();
  }

  void deleteRow(int index) async {
  // Get the ID of the parent record document
  String parentId = _documents[index].reference.parent.parent!.id;

  // Get the ID of the balance document to be deleted
  String balanceId = _documents[index].id;

  // Get the balance document to calculate the amounts
  DocumentSnapshot balanceDocument = await FirebaseFirestore.instance
      .collection('record')
      .doc(parentId)
      .collection('balance')
      .doc(balanceId)
      .get();

  // Get the parent record document
  DocumentSnapshot recordDocument = await FirebaseFirestore.instance
      .collection('record')
      .doc(parentId)
      .get();

  // Calculate the new amount
  double newAmount = recordDocument['amount'] - balanceDocument['forhim'] + balanceDocument['onhim'];

  // Delete the balance document
  await FirebaseFirestore.instance
      .collection('record')
      .doc(parentId)
      .collection('balance')
      .doc(balanceId)
      .delete();

  // Update the parent record document with the new amount
  await FirebaseFirestore.instance
      .collection('record')
      .doc(parentId)
      .update({
    'amount': newAmount
  });

  // Remove the deleted document from the local lists
  _documents.removeAt(index);
  _records.removeAt(index);
  notifyListeners();
}


}
  
  
