import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneybalance/components/data_grid_source.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TableAccounting extends StatefulWidget {
  final recordID;
  TableAccounting({super.key, required this.recordID}) {
    // TODO: implement TableAccounting
  }

  @override
  State<TableAccounting> createState() => _TableAccountingState();
}

class _TableAccountingState extends State<TableAccounting> {
  late RecordDataSource _recordDataSource;
    final GlobalKey<SfDataGridState> key = GlobalKey<SfDataGridState>();

  @override
  void initState() {
    super.initState();
    _recordDataSource = RecordDataSource(records: []);
  }
  @override
  Widget build(BuildContext context) {
     double forhim = 0;
    double onhim = 0;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('record')
          .doc(widget.recordID)
          .collection('balance').orderBy('createdAt', descending: true) // Order by 'createdAt' in descending order
          .snapshots(),
      builder: (context, snapshot) {
        final subdata = snapshot.data?.docs.length ?? 0;
        forhim = 0;
        onhim = 0;
        for (int i = 0; i < subdata; i++) {
          final DocumentSnapshot? doc = snapshot.data?.docs[i];
          final Map<String, dynamic>? data = doc?.data() as Map<String, dynamic>?;
          if (data != null) {
           
            forhim += data['forhim'] ?? 0;
            onhim += data['onhim'] ?? 0;
          }
        }
        
        // logger.i('--------- $forhim ----------- $onhim ---------');
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitFadingCircle(
              color: Colors.indigo[700],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              '',
              style: GoogleFonts.readexPro(
                textStyle: const TextStyle(fontSize: 30),
              ),
            ),
          );
        }

        //############################################
        _recordDataSource.updateData(snapshot.data!.docs);
        // After updating _recordDataSource with new data
        // _recordDataSource.sortedColumns.add(const SortColumnDetails(name: 'date', sortDirection: DataGridSortDirection.descending));
      
        return SfDataGridTheme(
          data: const SfDataGridThemeData(
            sortIconColor: Colors.white,
            headerColor: Color.fromARGB(255, 83, 143, 212),
          ),


          child: SfDataGrid(
            key: key,
            source: _recordDataSource,
            allowSorting: true,
            allowPullToRefresh: true,
            columnWidthMode: ColumnWidthMode.fill,
            //swip
            allowSwiping: true,
            swipeMaxOffset: 100,
            endSwipeActionsBuilder: (context, dataGridRow, rowIndex) {
              return GestureDetector(
                onTap: () {
                  _recordDataSource.deleteRow(rowIndex);
                },
                child: Container(
                  color: Colors.redAccent,
                  child: const Center(
                    child: Icon(Icons.delete, color: Colors.white,),
                  )
                )
              );
            },
            startSwipeActionsBuilder: (context, dataGridRow, rowIndex) {
               return GestureDetector(
                onTap: () {
                  _recordDataSource.deleteRow(rowIndex);
                },
                child: Container(
                  color: Colors.redAccent,
                  child: const Center(
                    child: Icon(Icons.delete, color: Colors.white,),
                  )
                )
              );
            },
            allowTriStateSorting: true,
            footerFrozenRowsCount: 1,
            footerHeight: 30,
            footer: Container(
              color: Colors.indigo[500],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Text(
                    'مدين: $onhim',
                    
                    style: GoogleFonts.readexPro(textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                  ),

                  const SizedBox(width: 120),

                  Text(
                    'دائن: $forhim',
                    style: GoogleFonts.readexPro(textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                  ),

                  
                ],
              ),
              
            ),
            columns: [
              GridColumn(
                sortIconPosition: ColumnHeaderIconPosition.start,
                columnName: 'amount',
                label: Center(
                  child: Text(
                    'الرصيد',
                    style: GoogleFonts.readexPro(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              GridColumn(
                allowSorting: false,
                sortIconPosition: ColumnHeaderIconPosition.start,
                columnName: 'state',
                label: Center(
                  child: Text(
                    'الحالة',
                    style: GoogleFonts.readexPro(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              GridColumn(
                sortIconPosition: ColumnHeaderIconPosition.start,
                allowSorting: false,
                columnName: 'details',
                label: Center(
                  child: Text(
                    'التفاصيل',
                    style: GoogleFonts.readexPro(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              GridColumn(
                sortIconPosition: ColumnHeaderIconPosition.start,
                columnName: 'money',
                label: Center(
                  child: Text(
                    'المبلغ',
                    style: GoogleFonts.readexPro(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              GridColumn(
                
                sortIconPosition: ColumnHeaderIconPosition.start,
                
                columnName: 'date',
                label: Center(
                  child: Text(
                    'التاريخ',
                    style: GoogleFonts.readexPro(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}