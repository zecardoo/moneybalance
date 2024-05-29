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
    final Logger logger = Logger();
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
    super.dispose();
    detailsController.dispose();
    amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordID = widget.recordID;
    return Scaffold(
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
      resizeToAvoidBottomInset: true,
      body: BlocListener<RecordBloc, RecordState>(
        bloc: BlocProvider.of<RecordBloc>(context),
        listener: (BuildContext context, state) {
          if(state is RecordSuccess){
              // On success, pop the current screen
      
              // Navigator.pop(context);
   
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
        child: userData(recordID['id']),
      ),
      floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            showDialog(
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
                            children: [
                              Form(
                                key: _formKey,
                                child: Padding(
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
                              ),
                              const Divider(),
                              Row(children: [
                                Flexible(child: TextFormFildAdd(hinttext: 'المبلغ',controller: amountController , inputnumber: true, keyboardtype: TextInputType.number, padding: 20.00)),
                                Flexible(child: TextFormFildAdd(hinttext: 'التفاصيل',controller: detailsController ,inputnumber: false, keyboardtype: TextInputType.text, padding: 20.00)),
                              ]),
                          
                              const SizedBox(height: 20),
                          
                              // display the date and image
                          
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _image == null ? const Text('') : clickableImage(setState),
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
  // ########################## Data Gride ##########################
  Widget userData(String recordID) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('record')
          .doc(recordID)
          .collection('balance') // Order by 'createdAt' in descending order
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
        _recordDataSource.sortedColumns.add(const SortColumnDetails(name: 'date', sortDirection: DataGridSortDirection.descending));
  
        return SfDataGridTheme(
          data: const SfDataGridThemeData(
            sortIconColor: Colors.white,
            headerColor: Color.fromARGB(255, 83, 143, 212),
          ),


          child: SfDataGrid(
            key: key,
            source: _recordDataSource,
            allowSwiping: true,
            swipeMaxOffset: 100.0, 
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
            allowSorting: true,
            allowPullToRefresh: true,
            columnWidthMode: ColumnWidthMode.fill,
            
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
  // ########################## Export Excel ##########################
Future<void> exportToExcel() async {
  final recordID = widget.recordID;
  double amount = 0;

  // Request storage permissions
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission not granted');
    }
  }

  // Fetch data from Firebase
  final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('record')
      .doc(recordID['id'])
      .collection('balance')
      .get();
  final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

  // Create a new Excel Workbook
  final xlsio.Workbook workbook = xlsio.Workbook();
  final xlsio.Worksheet sheet = workbook.worksheets[0];

  // Add column headers and apply styling
  final xlsio.Range headerRange = sheet.getRangeByName('A1:E1');
  headerRange.cellStyle.backColor = '#495eb3'; // Background color
  headerRange.cellStyle.fontColor = '#ffffff'; // Background color
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
    amount += data['forhim'];
    amount -= data['onhim'];

    // Apply styling to each row
    final xlsio.Range dataRange = sheet.getRangeByIndex(i + 2, 1, i + 2, 5);
    dataRange.cellStyle.fontSize = 10; // Font size
    dataRange.cellStyle.hAlign = xlsio.HAlignType.center;
    dataRange.cellStyle.vAlign = xlsio.VAlignType.center;
    
    sheet.getRangeByIndex(i + 2, 1).setText(amount.toString());
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
