// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:moneybalance/bloc/record_bloc.dart';
import 'package:moneybalance/bloc/record_event.dart';
import 'package:moneybalance/bloc/record_state.dart';
import 'package:moneybalance/components/data_grid_source.dart';
import 'package:moneybalance/components/text_fild_add.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
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
  enum Type { forhim, onhim}

class _DisplayRecordState extends State<DisplayRecord> {
  
  Type? _selectedType = Type.forhim;
  final Logger logger = Logger();
  var detailsController = TextEditingController();
  var amountController = TextEditingController();
  late DateTime _dueDate;
  final _formKey = GlobalKey<FormState>();
  File? _image;
  String? _imagePath;
  final picker = ImagePicker();
  double forhim = 0;
  double onhim = 0;
  double totalamount = 0;  
  late RecordDataSource _recordDataSource;
  final GlobalKey<SfDataGridState> key = GlobalKey<SfDataGridState>();



  @override
  void initState() {
    super.initState();
    _dueDate = DateTime.now();
    _recordDataSource = RecordDataSource(records: []);

  }

  @override
  void dispose() {
    super.dispose();
    detailsController.dispose();
    amountController.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    final recordID = widget.recordID;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
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
            onPressed: () {},
                    
          
          ),
        ],
      ),
      body: BlocListener<RecordBloc, RecordState>(
        bloc: BlocProvider.of<RecordBloc>(context),
        listener: (BuildContext context, state) {
          if(state is RecordSuccess){
            // On success, pop the current screen
         
          }else if(state is RecordFailure){
            // On failure, show a snackbar with the error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error, style: GoogleFonts.readexPro(), textAlign: TextAlign.right,), 
                backgroundColor: Colors.red,
              ),    
            );
          }else if(state is RecordImagePicked){
            // When an image is picked, update the state
            setState(() {
              _image = state.image;
              saveImage(_image!);
              _imagePath = state.image.path;
            });
          }
        },
        child:tableAccounting(recordID['id']),
      ),
      floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            addNewRecord(recordID);
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          // backgroundColor: Colors.blue[900],
          child: const Icon(Icons.add, color: Colors.white,),
        ),
        
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,

        // fix why show erros here 
        
        bottomNavigationBar:BottomAppBar(

          shape: const CircularNotchedRectangle(),
          // notchMargin: 1,
          // color: Colors.blue[900],
          height: 50,

          child:StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('record')
                .doc(recordID['id'])
                .collection('balance') // Assuming you have a subcollection
                .snapshots(),
            builder: (context, snapshot) {
            

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Placeholder widget while waiting for data
              }
            
              final subDocs = snapshot.data!.docs;

              forhim = 0;
              onhim = 0;
              totalamount = 0;
              // Iterate through each document in subSnapshot.data!.docs
              for (int i = 0; i < subDocs.length; i++) {
                final DocumentSnapshot? doc = snapshot.data?.docs[i];
                final Map<String, dynamic>? subData = doc?.data() as Map<String, dynamic>?;
                if (subData != null) {
            
                  forhim += subData['forhim'] ?? 0;
                  onhim += subData['onhim'] ?? 0;
                }
              }
              totalamount = forhim - onhim;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  forhim > onhim ? Text(' دائن :  $totalamount', style: GoogleFonts.readexPro(textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white,)))
                  : Text('مدين: $totalamount', style: GoogleFonts.readexPro(textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white,))),
              
                ],
              );
            }
            
        )
      )
    );
  }
  // ########################## Data Gride ##########################
  Widget tableAccounting(recordID) {
   double forhim = 0;
    double onhim = 0;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('record')
          .doc(recordID)
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
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  ' هل تريد الحذف ؟',
                                  style: GoogleFonts.readexPro( textStyle: const TextStyle(
                                    fontSize: 20,
                                
                                  )),
                                  
                                ),
                              ),
                          
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                 
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                                                
                                    child: Text(
                                      'لا',
                                      style: GoogleFonts.readexPro( textStyle: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.redAccent
                                      )),
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                              
                                  TextButton(
                                    onPressed: () => {
                                      _recordDataSource.deleteRow(rowIndex),
                                      Navigator.pop(context)
                                    },
                                                                
                                    child: Text(
                                      'نعم',
                                      style: GoogleFonts.readexPro( textStyle: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.redAccent
                                      )),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
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
                final documentId = dataGridRow.getCells().firstWhere((cell) => cell.columnName == 'documentId').value;

               return GestureDetector(
                onTap: () {
                  // _recordDataSource.updatedilog(context, rowIndex);
                  editRecord(documentId, recordID, rowIndex);
                },
                child: Container(
                  color: Colors.blueAccent,
                  child: const Center(
                    child: Icon(Icons.edit, color: Colors.white,),
                  )
                )
              );
            },
            onCellTap: (details) {
              int rowIndex = details.rowColumnIndex.rowIndex;
              
              // Skip the header row
              if (rowIndex == 0) return;

              // Retrieve the document ID from the tapped row
              final documentId = _recordDataSource.effectiveRows[rowIndex - 1]
                .getCells()
                .firstWhere((cell) => cell.columnName == 'documentId')
              .value;
              
              final state = _recordDataSource.effectiveRows[rowIndex - 1]
                .getCells()
                .firstWhere((cell) => cell.columnName == 'state')
              .value;

              didplayData(documentId,state);
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



  // ########################## addNewRecord ##########################
  Future<void> addNewRecord(recordID) {
    return showDialog(
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(10),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                      children: 
                      [
                         Form(
                          key: _formKey,
                          child: Column(
                            children:[

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    recordID['name'], 
                                    style: GoogleFonts.readexPro(textStyle: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600
                                    )),
                                  ),
                                ),
                              ),

                              const Divider(),
                              
                              Row(children: [
                                Flexible(child: TextFormFildAdd(hinttext: 'التفاصيل',controller: detailsController ,inputnumber: false, keyboardtype: TextInputType.text, padding: 20.00)),
                                Flexible(child: TextFormFildAdd(hinttext: 'المبلغ',controller: amountController , inputnumber: true, keyboardtype: TextInputType.number, padding: 20.00)),
                              ]),
                            ]
                          ),
                          
                        ),
                        
                        const SizedBox(height: 20),
                          
                        // display the date and image
                          
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _image == null ? Container() : clickableImage(setState),
                            const SizedBox(width: 10),
                            IconButton(onPressed: () => showOptions(context, setState), icon: const Icon(Icons.add_a_photo)),
                            dateButton(setState),
                          ],
                        ),
                          
                        const Divider(),
                          
                        const SizedBox(height: 30),
                          
                        // display the submit button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            iconButtonOnhim('مدين', Colors.red, Icons.keyboard_arrow_down_rounded, recordID['id']),
                            const SizedBox(width: 20),
                            iconButtonForhim('دائن', Colors.green, Icons.keyboard_arrow_up_rounded, recordID['id']),
                          ],
                        ),
                          
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

              );
            },
          );
        },
    ).then((_) {
      // Reset the form fields and image state when dialog is closed
      setState(() {
        amountController.clear();
        detailsController.clear();
        _image = null;
        _dueDate = DateTime.now();
      });
    }); 
    
  }
  // ########################## EditRecord ##########################
  Future<void> editRecord(String documentId, String recordID, int rowIndex) async{
    DocumentSnapshot recordDoc = await FirebaseFirestore.instance.collection('record').doc(recordID).collection('balance').doc(documentId).get();
    amountController.text = (recordDoc['forhim'] - recordDoc['onhim']).toString();
    detailsController.text = recordDoc['details'];
    
    //date
    Timestamp timestamp = recordDoc['date']; 
    _dueDate = timestamp.toDate();

    //image
    _image = recordDoc['image'] != null ? File(recordDoc['image']) : null;


    return showDialog(
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(10),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                      children: 
                      [
                        const SizedBox(height: 30),

                        Form(
                          key: _formKey,
                          child: Column(
                            children:[
                            
                              Row(children: [
                                Flexible(child: TextFormFildAdd(hinttext: 'التفاصيل',controller: detailsController ,inputnumber: false, keyboardtype: TextInputType.text, padding: 20.00)),
                                Flexible(child: TextFormFildAdd(hinttext: 'المبلغ',controller: amountController , inputnumber: true, keyboardtype: TextInputType.number, padding: 20.00)),
                              ]),

                            ]
                          ),
                          
                        ),
            
                        const SizedBox(height: 10),
                          
                        // display the date and image
                          
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _image == null ? Container() : clickableImage(setState),
                            const SizedBox(width: 10),
                            IconButton(onPressed: () => showOptions(context, setState), icon: const Icon(Icons.add_a_photo)),
                            dateButton(setState),
                          ],
                        ),
                        
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           

                            Radio<Type>(
                              activeColor: Colors.indigo[600],
                              
                              value: Type.onhim, 
                              groupValue: _selectedType, 
                              onChanged: (Type? value) {
                                setState(() {
                                  _selectedType = value;
                                });
                              },
                            ),
                            Text(
                              'مدين',
                              style: GoogleFonts.readexPro(textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              )),
                            ),

                             Radio<Type>(
                              activeColor: Colors.indigo[600],

                              value: Type.forhim, 
                              groupValue: _selectedType, 
                              onChanged: (Type? value) {
                                setState(() {
                                  _selectedType = value;
                                });
                              },
                            ),
                           Text(
                              'دائن',
                              style: GoogleFonts.readexPro(textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              )),
                            ),
                          ],
                        ),

                        const Divider(),
                          
                        const SizedBox(height: 20),
                          
                        // display the submit button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                        
                            ElevatedButton(
                              onPressed: () { Navigator.pop(context);},
                              style: ButtonStyle(
                                backgroundColor: WidgetStateColor.resolveWith((states) => Colors.redAccent),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.readexPro(textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                )),

                              ),
                            ),


                            ElevatedButton(
                              onPressed: () {
                                _recordDataSource.updateRow(
                                  rowIndex, 
                                  detailsController.text,
                                  double.parse(amountController.text),
                                  _imagePath, 
                                  _dueDate, 
                                  _selectedType
                                
                                
                                );
                                Navigator.pop(context);

                              },


                              style: ButtonStyle(
                                backgroundColor: WidgetStateColor.resolveWith((states) => Colors.greenAccent),
                              ),
                              child: Text(
                                'Confirm',
                                style: GoogleFonts.readexPro(textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                )),

                              ),
                            ),
                          ],
                        ),
                          
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

              );
            },
          );
        },
    ).then((_) {
      // Reset the form fields and image state when dialog is closed
      setState(() {
        amountController.clear();
        detailsController.clear();
        _image = null;
        _dueDate = DateTime.now();
      });
    }); 
    
  }
  // ########################## EditRecord ##########################
  Future<void> didplayData(String documentId, bool state) async {
        final recordID = widget.recordID;

    DocumentSnapshot recordDoc = await FirebaseFirestore.instance.collection('record').doc(recordID['id']).collection('balance').doc(documentId).get();
    //date
    final DateTime date = recordDoc['date'].toDate();
    final String time = DateFormat('h:mm a').format(date);

    //image 
     _image = recordDoc['image'] != null ? File(recordDoc['image']) : null;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      state ? const Icon(Icons.keyboard_arrow_up_sharp, color: Colors.greenAccent, size: 40,) : const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.redAccent, size: 40,),
                      const Spacer(),
                      Text(
                      recordID['name'],
                      style: GoogleFonts.readexPro( textStyle: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600
                          
                        )
                      ),
                    ),
                    ],
                  ),
                ),
                const Divider(),
            
            
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      (recordDoc['forhim'] - recordDoc['onhim']).toString(),
                       style: GoogleFonts.readexPro( textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600
                          
                        )
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '-: المبلغ',
                      style: GoogleFonts.readexPro( textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600
                          
                        )
                      ),
                    ),
            
            
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${date.day}-${date.month}-${date.year}',
                       style: GoogleFonts.readexPro( textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600
                          
                        )
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '-: التاريخ',
                      style: GoogleFonts.readexPro( textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600
                          
                        )
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      time,
                       style: GoogleFonts.readexPro( textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600
                          
                        )
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '-: الوقت',
                      style: GoogleFonts.readexPro( textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600
                          
                        )
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${recordDoc['details']}',
                       style: GoogleFonts.readexPro( textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600
                          
                        )
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '-: التفاصيل',
                      style: GoogleFonts.readexPro( textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600
                          
                        )
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if( _image != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _image == null ? Container() : clickableImage(setState),

                    const Spacer(),
                    Text(
                      '-: صورة',
                      style: GoogleFonts.readexPro( textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600
                          
                        )
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
  }
  
  // ########################## Export Excel ##########################
  Future<void> exportToExcel() async {
    final recordID = widget.recordID;

    // Request storage permissions
    if (await _requestStoragePermission()) {
      try {
        // Fetch data from Firebase
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('record')
            .doc(recordID['id'])
            .collection('balance').orderBy('createdAt', descending: true)
            .get();
        final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

        // Create a new Excel Workbook
        final xlsio.Workbook workbook = xlsio.Workbook();
        final xlsio.Worksheet sheet = workbook.worksheets[0];

        // Add column headers and apply styling
        final xlsio.Range headerRange = sheet.getRangeByName('A1:E1');
        headerRange.cellStyle.backColor = '#495eb3'; // Background color
        headerRange.cellStyle.fontColor = '#ffffff'; // Font color
        headerRange.cellStyle.bold = true; // Bold text
        headerRange.cellStyle.fontSize = 13; // Font size
        headerRange.cellStyle.hAlign = xlsio.HAlignType.center;
        headerRange.cellStyle.vAlign = xlsio.VAlignType.center;

        // Add column headers
        sheet.getRangeByName('A1').setText('الرصيد');
        sheet.getRangeByName('B1').setText('مدين');
        sheet.getRangeByName('C1').setText('دائن');
        sheet.getRangeByName('D1').setText('التفاصيل');
        sheet.getRangeByName('E1').setText('التاريخ');

        // Add data rows
        for (int i = 0; i < documents.length; i++) {
          final Map<String, dynamic> data = documents[i].data() as Map<String, dynamic>;
          final DateTime date = data['date'].toDate();
          final String time = DateFormat('h:mm a').format(date);
          final String dateTime = '${date.day}-${date.month}-${date.year} \n $time';
         

          // Apply styling to each row
          final xlsio.Range dataRange = sheet.getRangeByIndex(i + 2, 1, i + 2, 5);
          dataRange.cellStyle.fontSize = 10; // Font size
          dataRange.cellStyle.hAlign = xlsio.HAlignType.center;
          dataRange.cellStyle.vAlign = xlsio.VAlignType.center;
          
          sheet.getRangeByIndex(i + 2, 1).setText(data['amount'].toString());
          sheet.getRangeByIndex(i + 2, 2).setText(data['onhim'].toString());
          sheet.getRangeByIndex(i + 2, 3).setText(data['forhim'].toString());
          sheet.getRangeByIndex(i + 2, 4).setText(data['details'].toString());
          sheet.getRangeByIndex(i + 2, 5).setText(dateTime.toString());
        }

        // Save the workbook
        final List<int> bytes = workbook.saveAsStream();
        workbook.dispose();

        // Get the path to save the file
        final directory = await getExternalStorageDirectory();
        const folderName = 'money_balance';
        final path = '${directory!.path}/$folderName/Excel';

        // Ensure the folder exists
        final folder = Directory(path);
        if (!folder.existsSync()) {
          folder.createSync(recursive: true);
        }
        final String fileName = '$path/Records.xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);

        // Open the file
        final result = await OpenFile.open(
          fileName,
          type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
        if (result.type != ResultType.done) {
          throw Exception('Failed to open the file: ${result.message}');
        }
      } catch (e) {
        logger.e('Error exporting to Excel: $e');
        rethrow;
      }
    } else {
      throw Exception('Storage permission not granted');
    }
  }

  Future<bool> _requestStoragePermission() async {
    // Check storage permission
    if (await Permission.storage.request().isGranted) {
      return true;
    }

    // For Android 11 and above, MANAGE_EXTERNAL_STORAGE is required for broad access
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }

    // Permission not granted
    return false;
  }
  // ########################## Select phone or camera  ##########################
  Future<void> showOptions(BuildContext context, StateSetter setState) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('الهاتف', style: GoogleFonts.readexPro()),
            onPressed: () {
              //get the image Gallery
              onPickImageGallery(setState);
              
              // close the options modal
              Navigator.of(context).pop();

              // get image from gallery form record_bloc
              // context.read<RecordBloc>().add(PickImageFromGalleryEvent());
            },
          ),
          CupertinoActionSheetAction(
            child: Text('الكاميرا', style: GoogleFonts.readexPro()),
            onPressed: () {
              // get the image from camera
              onPickImageCamera(setState);
              // close the options modal
              Navigator.of(context).pop();
              
              // get image from camera form record_bloc
            //  context.read<RecordBloc>().add(PickImageFromCameraEvent());
            
            },
          ),
        ],
      ),
    );
  }
  // ########################## Image Gallery ##########################
  Future<void> onPickImageGallery (StateSetter setState) async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        saveImage(_image!);
        _imagePath = pickedFile.path;
      });
    }
  }
  // ########################## Image Camera ##########################
  Future<void> onPickImageCamera (StateSetter setState) async{
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          saveImage(_image!);
          _imagePath = pickedFile.path;
        });
      }
  }
  // ########################## Click Image ##########################
  Widget clickableImage(StateSetter setState) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InteractiveViewer(child: Image.file(_image!)),
                        const SizedBox(height: 50),
                        ElevatedButton(
                          onPressed: () {
                            deleteImage(setState);
                          },
                          style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 90)),
                          ),
                          child: Text(
                            'حذف',
                            style: GoogleFonts.readexPro(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Image.file(_image!, width: 30),
      );
    }
  // ########################## Save Image ##########################
  Future<void> saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    const folderName = 'money_balance';
    final path = '${directory.path}/$folderName/Pictures';
    
    // Ensure the folder exists
    final folder = Directory(path);
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }
    
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final savedImage = await image.copy('$path/$fileName.png');
    
    setState(() {
      _image = savedImage;
      _imagePath = savedImage.path;
    });
  }
  // ########################## Delete image ##########################
  Future<void> deleteImage(StateSetter setState) async {
    if (_image != null) {     
      try {
        _image!.delete();
        logger.i(_image);
        setState(() {
          _image = null;
        });
        
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف الصورة بنجاح', style: GoogleFonts.readexPro(), textAlign: TextAlign.right),
            backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,

          ),
        );
        Navigator.pop(context);
        
      } catch (e) {
        logger.e(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حذف الصورة: $e')),
        );
      }
    }
  }
  // ########################## Data ##########################
  Widget dateButton(StateSetter setState) {
    return TextButton(
      onPressed: () => _selectDate(setState),
      child: Text(
        'التاريخ : ${_dueDate.year} - ${_dueDate.month} - ${_dueDate.day}',
        style: GoogleFonts.readexPro(
          textStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.5,
          ),
        ),
      ),
    );
  }
  Future<void> _selectDate(StateSetter setState) async {
    final selectDate = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (selectDate != null) {
      setState(() {
        _dueDate = selectDate;
      });
    }
  }
  // ########################## Button For HIM ##########################
  Widget iconButtonForhim(String title, Color? color, IconData? icon, String id) {
    return ElevatedButton.icon(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          context.read<RecordBloc>().add(
            AddSubRecordEvent(
              id:id,
              details: detailsController.text,
              amount: double.parse(amountController.text),
              date: _dueDate,
              createdAt: DateTime.now(),
              imagePath: _imagePath,
              forhim:double.parse(amountController.text),
              onhim: 0
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم الأضافة بنجاح', style: GoogleFonts.readexPro(), textAlign: TextAlign.right),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);

          
        }
      },
      icon: Icon(icon, size: 30, color: color),
      label: Text(
        title,
        style: GoogleFonts.readexPro(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith((states) => Colors.indigo[600]!),
      ),
    );
  }
  // ########################## Button On HIM ##########################
  Widget iconButtonOnhim(String title, Color? color, IconData? icon, String id) {
    return ElevatedButton.icon(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
         context.read<RecordBloc>().add(
            AddSubRecordEvent(
              id:id,
              details: detailsController.text,
              amount: double.parse(amountController.text),
              date: _dueDate,
              createdAt: DateTime.now(),
              imagePath: _imagePath,
              forhim:0,
              onhim: double.parse(amountController.text)
            ),
          );
         
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              content: Text('تم الأضافة بنجاح', style: GoogleFonts.readexPro(), textAlign: TextAlign.right),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,

            )
          );
          Navigator.pop(context);
        }
      },
      icon: Icon(icon, size: 30, color: color),
      label: Text(
        title,
        style: GoogleFonts.readexPro(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith((states) => Colors.indigo[600]!),
      ),
    );
  }

}
