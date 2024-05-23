// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class RecordDataSource extends DataGridSource {
//   RecordDataSource({required List<DataGridRow> records}) {
//     _records = records;
//   }

//   List<DataGridRow> _records = [];

//   @override
//   List<DataGridRow> get rows => _records;

//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(cells: [
//       for (var cell in row.getCells())
//         Container(
//           alignment: Alignment.center,
//           padding: EdgeInsets.all(8.0),
//           child: Text(cell.value.toString()),
//         ),
//     ]);
//   }

//   void updateData(List<DocumentSnapshot> docs) {
//     _records = docs.map((doc) {
//       return DataGridRow(cells: [
//         DataGridCell<String>(columnName: 'name', value: doc['name']),
//         DataGridCell<String>(columnName: 'id', value: doc.id),
//         // Add more cells here if needed
//       ]);
//     }).toList();
//     notifyListeners();
//   }
// }
