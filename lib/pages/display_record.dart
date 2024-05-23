// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moneybalance/components/data_grid_source.dart';
import 'package:moneybalance/components/text_fild_add.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class DisplayRecord extends StatefulWidget {
  final Map<String, dynamic> recordID;

  const DisplayRecord({
    super.key,
    required this.recordID,
  });

  @override
  State<DisplayRecord> createState() => _DisplayRecordState();
}

class _DisplayRecordState extends State<DisplayRecord> {
  late RecordDataSource _recordDataSource;
  final GlobalKey<SfDataGridState> key = GlobalKey<SfDataGridState>();
  final detailsController = TextEditingController();
  final amountController = TextEditingController();
  late DateTime _dueDate;
  final _formKey = GlobalKey<FormState>();
  File? _image;
  String? _imagePath;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _recordDataSource = RecordDataSource(records: []);
    _dueDate = DateTime.now();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    detailsController.dispose();
    amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordID = widget.recordID;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              elevation: 0,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              snap: true,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                recordID['name'],
                style: GoogleFonts.readexPro(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.table_chart),
                  onPressed: exportToExcel,
                  tooltip: 'Excel',
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () {
                    
                  },
                  
                  tooltip: 'Excel',
                ),
              ],
            ),
          ];
        },
        body: userData(recordID['id'])
      ),
      floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(recordID['name'], style: GoogleFonts.readexPro(textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),textAlign: TextAlign.right,),

                  content: Column(
                    children: [
                      const Divider(),

                      Row(children: [
                        Flexible(child: TextFormFildAdd(hinttext: 'المبلغ',controller: amountController , inputnumber: true, keyboardtype: TextInputType.number, padding: 5)),
                        Flexible(child: TextFormFildAdd(hinttext: 'التفاصيل',controller: detailsController ,inputnumber: false, keyboardtype: TextInputType.text, padding: 5)),
                      ]),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _image == null ? const Text('') : clickableImage(),
                          const SizedBox(width: 10),
                          IconButton(onPressed: () => showOptions(), icon: const Icon(Icons.add_a_photo)),
                          _DateButton(),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
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

  Widget userData(String recordID) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('record')
          .doc(recordID)
          .collection('balance')
          .snapshots(),
      builder: (context, snapshot) {
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
              'لاتوجد بيانات متاحة',
              style: GoogleFonts.readexPro(
                textStyle: const TextStyle(fontSize: 30),
              ),
            ),
          );
        }
        _recordDataSource.updateData(snapshot.data!.docs);

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
            showColumnHeaderIconOnHover: true,
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

  Future<void> exportToExcel() async {
    final List<DataGridRow> rows = _recordDataSource.rows;

    // Create a new Excel Workbook
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Add column headers
    sheet.getRangeByName('A1').setText('الرصيد');
    sheet.getRangeByName('B1').setText('الحالة');
    sheet.getRangeByName('C1').setText('التفاصيل');
    sheet.getRangeByName('D1').setText('المبلغ');
    sheet.getRangeByName('E1').setText('التاريخ');

    // Add data rows
    for (int i = 0; i < rows.length; i++) {
      final DataGridRow row = rows[i];
      sheet.getRangeByIndex(i + 2, 1).setText(row.getCells()[0].value.toString());
      sheet.getRangeByIndex(i + 2, 2).setText(row.getCells()[1].value.toString());
      sheet.getRangeByIndex(i + 2, 3).setText(row.getCells()[2].value.toString());
      sheet.getRangeByIndex(i + 2, 4).setText(row.getCells()[3].value.toString());
      sheet.getRangeByIndex(i + 2, 5).setText(row.getCells()[4].value.toString());
    }

    // Save the workbook
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // Get the path to save the file
    final directory = await getApplicationDocumentsDirectory();
    const folderName = 'money_balance';
    final path = '${directory.path}/$folderName/Excel';
    
    // Ensure the folder exists
    final folder = Directory(path);
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }
    final String fileName = '$path/Records.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);

    // Open the file
    final result = await OpenFile.open(fileName);
    print(result.message); // Optional: handle the result
  }
}
