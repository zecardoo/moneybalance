// ignore_for_file: unnecessary_null_comparison, non_constant_identifier_names

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:moneybalance/bloc/record_bloc.dart';
import 'package:moneybalance/bloc/record_event.dart';
import 'package:moneybalance/bloc/record_state.dart';
import 'package:moneybalance/components/text_fild_add.dart';
import 'package:path_provider/path_provider.dart';

class AddRecord extends StatefulWidget {
  const AddRecord({super.key});

  @override
  State<AddRecord> createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  final Logger logger = Logger();
  final nameController = TextEditingController(); 
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
    _dueDate = DateTime.now();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    detailsController.dispose();
    amountController.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        // backgroundColor: Colors.indigo[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<RecordBloc, RecordState>(
          bloc: BlocProvider.of<RecordBloc>(context),
          listener: (context, state) {
            if(state is RecordSuccess){
              // On success, pop the current screen
      
              Navigator.pop(context, '/');
      
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
                _saveImage(_image!);
                _imagePath = state.image.path;
              });
            }
          },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // display the input
                  Row(children: [
                    Flexible(child: TextFormFildAdd(hinttext: 'المبلغ',controller: amountController , inputnumber: true, keyboardtype: TextInputType.number, padding: 20.00)),
                    Flexible(child: TextFormFildAdd(hinttext: 'الأسم',controller: nameController ,inputnumber: false, keyboardtype: TextInputType.text, padding: 20.00)),
                  ]),
                  TextFormFildAdd(hinttext: 'التفاصيل',controller: detailsController ,inputnumber: false, keyboardtype: TextInputType.text, padding: 20.00),
                  const SizedBox(height: 20),
                  
                  // display the date and image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _image == null ? const Text('') : clickableImage(),
                      const SizedBox(width: 10),
                      IconButton(onPressed: () => showOptions(), icon: const Icon(Icons.add_a_photo)),
                      dateButton(),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // display the submit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconButtonOnhim('مدين', Colors.red, Icons.keyboard_arrow_down_rounded),
                      const SizedBox(width: 20),
                      iconButtonForhim('دائن', Colors.green, Icons.keyboard_arrow_up_rounded),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //##################################################################################################################################

  // button icon
  Widget iconButtonForhim(String title, Color? color, IconData? icon) {
    return ElevatedButton.icon(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          context.read<RecordBloc>().add(
            AddRecordEvent(
              name: nameController.text,
              details: detailsController.text,
              amount: double.parse(amountController.text),
              date: _dueDate,
              createdAt: DateTime.now(),
              imagePath: _imagePath,
              forhim: double.parse(amountController.text),
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



  Widget iconButtonOnhim(String title, Color? color, IconData? icon) {
    return ElevatedButton.icon(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
         context.read<RecordBloc>().add(
            AddRecordEvent(
              name: nameController.text,
              details: detailsController.text,
              amount: double.parse(amountController.text),
              date: _dueDate,
              createdAt: DateTime.now(),
              imagePath: _imagePath,
              forhim: 0,
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



  // button that holds the result of date
  Widget dateButton() {
    return TextButton(
      onPressed: () => selectDate(),
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



  // function to set the date
  Future<void> selectDate() async {
    final selectDate = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (selectDate != null) {
      setState(() {
        _dueDate = selectDate;
      });
    }
  }



  Future<void> _saveImage(File image) async {
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



  // Show options to get image from camera or gallery
  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('الهاتف', style: GoogleFonts.readexPro()),
            onPressed: () {
              // get image from gallery form record_bloc
              context.read<RecordBloc>().add(PickImageFromGalleryEvent());
              // close the options modal
              Navigator.of(context).pop();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('الكاميرا', style: GoogleFonts.readexPro()),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              
              // get image from camera form record_bloc
             context.read<RecordBloc>().add(PickImageFromCameraEvent());
            },
          ),
        ],
      ),
    );
  }



  // display image on big screen
  Widget clickableImage() {
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
                      _deleteImage();
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



  // Delete image function
  Future<void> _deleteImage() async {
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
}
