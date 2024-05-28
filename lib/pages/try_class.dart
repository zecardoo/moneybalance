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
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class DisplayRecord extends StatefulWidget {
  final Map<String, dynamic> recordID;

  const DisplayRecord({super.key, required this.recordID});

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
  bool addrecordHided = true;

  @override
  void initState() {
    super.initState();
    _recordDataSource = RecordDataSource(records: []);
    _dueDate = DateTime.now();
  }

  @override
  void dispose() {
    detailsController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordID = widget.recordID;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<RecordBloc, RecordState>(
        bloc: BlocProvider.of<RecordBloc>(context),
        listener: (BuildContext context, state) {
          if (state is RecordSuccess) {
            // Handle success
          } else if (state is RecordFailure) {
            // Handle failure
            showSnackbar(context, state.error, Colors.red);
          } else if (state is RecordImagePicked) {
            // Handle image picked
            setState(() {
              _image = state.image;
              saveImage(_image!);
              _imagePath = state.image.path;
            });
          }
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            buildSliverAppBar(recordID),
          ],
          body: userData(recordID['id']),
        ),
      ),
      floatingActionButton: buildFloatingActionButton(recordID),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: const BottomAppBar(shape: CircularNotchedRectangle(), height: 50),
    );
  }

  // ########################## Data Gride ##########################
  Widget userData(String recordID) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('record')
          .doc(recordID)
          .collection('balance')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return buildCenterText('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SpinKitFadingCircle(color: Colors.indigo[700]));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return buildCenterText('');
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
            allowSwiping: true,
            swipeMaxOffset: 100.0,
            endSwipeActionsBuilder: buildEndSwipeActions,
            allowSorting: true,
            allowPullToRefresh: true,
            columnWidthMode: ColumnWidthMode.fill,
            showColumnHeaderIconOnHover: true,
            columns: buildGridColumns(),
          ),
        );
      },
    );
  }

  // ########################## Export Excel ##########################
  Future<void> exportToExcel() async {
    final recordID = widget.recordID;
    double amount = 0;
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('record').doc(recordID['id']).collection('balance').get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1').setText('الرصيد');
    sheet.getRangeByName('B1').setText('مدين');
    sheet.getRangeByName('C1').setText('دائن');
    sheet.getRangeByName('D1').setText('التفاصيل');
    sheet.getRangeByName('E1').setText('التاريخ');

    for (int i = 0; i < documents.length; i++) {
      final Map<String, dynamic> data = documents[i].data() as Map<String, dynamic>;
      final DateTime date = data['date'].toDate();
      final time = DateFormat('h:mm a').format(date);
      final dateTime = '${date.day}-${date.month}-${date.year} \n $time';
      amount += data['forhim'];
      amount = data['onhim'];
      sheet.getRangeByIndex(i + 2, 1).setText(amount.toString());
      sheet.getRangeByIndex(i + 2, 2).setText(data['onhim'].toString());
      sheet.getRangeByIndex(i + 2, 3).setText(data['forhim'].toString());
      sheet.getRangeByIndex(i + 2, 4).setText(data['details'].toString());
      sheet.getRangeByIndex(i + 2, 5).setText(dateTime.toString());
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getApplicationDocumentsDirectory();
    const folderName = 'money_balance';
    final path = '${directory.path}/$folderName/Excel';

    final folder = Directory(path);
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }
    final String fileName = '$path/Records.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);

    final result = await OpenFile.open(fileName);
    logger.i(result.message);
  }

  // ########################## Select phone or camera ##########################
  Future<void> showOptions(BuildContext context, StateSetter setState) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('الهاتف', style: GoogleFonts.readexPro()),
            onPressed: () {
              onPickImageGallery(setState);
              Navigator.of(context).pop();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('الكاميرا', style: GoogleFonts.readexPro()),
            onPressed: () {
              onPickImageCamera(setState);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // ########################## Image Gallery ##########################
  Future<void> onPickImageGallery(StateSetter setState) async {
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
  Future<void> onPickImageCamera(StateSetter setState) async {
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
                    onPressed: () => deleteImage(setState),
                    style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 10))),
                    child: const Icon(Icons.delete),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: CircleAvatar(radius: 30, backgroundImage: FileImage(_image!)),
    );
  }

  // ########################## Save Image ##########################
  Future<void> saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final folderName = 'money_balance/images';
    final path = '${directory.path}/$folderName';
    final folder = Directory(path);

    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final file = File('$path/$fileName.jpg');
    await image.copy(file.path);

    setState(() {
      _imagePath = file.path;
    });
  }

  // ########################## Delete Image ##########################
  void deleteImage(StateSetter setState) {
    setState(() {
      _image = null;
      _imagePath = null;
    });
    Navigator.of(context).pop();
  }

  // Helper Methods
  void showSnackbar(BuildContext context, String message, Color backgroundColor) {
    final snackBar = SnackBar(content: Text(message), backgroundColor: backgroundColor);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget buildCenterText(String text) => Center(child: Text(text, style: GoogleFonts.readexPro(fontSize: 20)));

  SliverAppBar buildSliverAppBar(Map<String, dynamic> recordID) {
    return SliverAppBar(
      expandedHeight: 70,
      elevation: 0.5,
      pinned: true,
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(recordID['name'], style: GoogleFonts.readexPro(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: exportToExcel,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget buildFloatingActionButton(Map<String, dynamic> recordID) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: FloatingActionButton(
        onPressed: () => setState(() => addrecordHided = !addrecordHided),
        child: Icon(addrecordHided ? Icons.add : Icons.close),
      ),
    );
  }

  List<GridColumn> buildGridColumns() {
    return <GridColumn>[
      GridColumn(columnName: 'amount', label: buildColumnLabel('الرصيد')),
      GridColumn(columnName: 'debit', label: buildColumnLabel('مدين')),
      GridColumn(columnName: 'credit', label: buildColumnLabel('دائن')),
      GridColumn(columnName: 'details', label: buildColumnLabel('التفاصيل')),
      GridColumn(columnName: 'date', label: buildColumnLabel('التاريخ')),
    ];
  }

  Container buildColumnLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.center,
      child: Text(text, overflow: TextOverflow.ellipsis, style: GoogleFonts.readexPro(color: Colors.white)),
    );
  }

  Widget buildEndSwipeActions(BuildContext context, DataGridRow row, int rowIndex) {
    return GestureDetector(
      onTap: () {
        _recordDataSource.deleteRow(rowIndex);
      },
      child: Container(
        color: Colors.red,
        alignment: Alignment.center,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
    );
  }
}
