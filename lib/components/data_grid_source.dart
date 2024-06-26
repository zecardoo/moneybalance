
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:moneybalance/pages/display_record.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class RecordDataSource extends DataGridSource {
  
  List<DataGridRow> _records = [];
  List<DocumentSnapshot> _documents = [];
  Logger logger = Logger();
  
  
  RecordDataSource({required List<DataGridRow> records}) {
    _records = records;
  }

  @override
  List<DataGridRow> get rows => _records;
  
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      for (var cell in row.getCells())
        if (cell.columnName != 'documentId') // Check if column name is not 'id'
        Container(
          alignment: Alignment.center,
          child: cell.columnName == 'state'
              ? (cell.value == true ?  const Icon(Icons.keyboard_arrow_up_sharp, color: Colors.green, size: 30,) : const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.red, size: 30,)) 
              : Text(cell.value.toString(), style: GoogleFonts.readexPro(textStyle: const TextStyle(fontSize: 13,fontWeight: FontWeight.w600, color: Color.fromARGB(255, 83, 83, 83),)),),
        ),
    ]);
  }


  // Update data method
  void updateData(List<DocumentSnapshot> docs) async {
    _documents = docs; // Update local documents list
    _records = docs.map((doc) {
      // Process each document
     final double money = (doc['forhim'] != 0 ? doc['forhim'] : doc['onhim']).toDouble();

      final DateTime date = doc['date'].toDate();
      final String time = DateFormat('h:mm:ss a').format(date);


      return DataGridRow(cells: [
        DataGridCell(columnName: 'amount', value: doc['amount']),
        DataGridCell(columnName: 'state', value: doc['onhim'] < doc['forhim']),
        DataGridCell(columnName: 'details', value: doc['details']),
        DataGridCell(columnName: 'money', value: money),
        DataGridCell(columnName: 'date', value: '${date.day}-${date.month}-${date.year} \n $time'),
        DataGridCell(columnName: 'documentId', value: doc.id),
      ]);
    }).toList();
    notifyListeners();
  }
  // delete data
  Future<void> deleteRow(int index) async {
  try {
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
    double newAmount = recordDocument['amount'];
    if (balanceDocument['forhim'] != 0) {
      newAmount -= balanceDocument['forhim'];
    } else {
      newAmount += balanceDocument['onhim'];
    }

    // Update the parent record document with the new amount
    await FirebaseFirestore.instance
        .collection('record')
        .doc(parentId)
        .update({
      'amount': newAmount
    });
    recalculateAmounts(parentId);

    // Delete the balance document
    await FirebaseFirestore.instance
        .collection('record')
        .doc(parentId)
        .collection('balance')
        .doc(balanceId)
        .delete();

    // Remove the deleted document from the local lists
    _documents.removeAt(index);
    _records.removeAt(index);

    // Recalculate amounts for the remaining documents

    notifyListeners();
  } catch (e) {
    logger.e(e);
  }
}
  // Recalculate amounts for all documents in the collection
  Future<void> recalculateAmounts(String parentId) async {
    double amount = 0;
    CollectionReference collectionRef = FirebaseFirestore.instance
        .collection('record')
        .doc(parentId)
        .collection('balance');

    QuerySnapshot querySnapshot = await collectionRef.orderBy('createdAt', descending: false).get();

    for (DocumentSnapshot doc in querySnapshot.docs) {
      amount += doc['forhim'] - doc['onhim'];
      await collectionRef.doc(doc.id).update({'amount': amount});
    }
  }

  Future<void> updateRow (int index, String details, double amount, String? image, DateTime date, Type? selectedType) async{
    try {
      String parentId = _documents[index].reference.parent.parent!.id;
      String balanceId = _documents[index].id;
      
      //first call the main colloection 

      DocumentReference balanceDocument = FirebaseFirestore.instance
        .collection('record')
        .doc(parentId)
        .collection('balance')
        .doc(balanceId);
      if(selectedType == Type.forhim){
        balanceDocument.update({
          'details': details,
          'date': date,
          'forhim': amount,
          'onhim': 0,
          'image': image
        });
      }else{
         balanceDocument.update({
          'details': details,
          'date': date,
          'forhim': 0,
          'onhim': amount,
          'image': image

        });
      }
      

      recalculateAmounts(parentId);


    } catch (e) {
      logger.e(e);
    }
  }


}

 






  
  
