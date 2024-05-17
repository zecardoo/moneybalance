// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moneybalance/components/text_fild_add.dart';
import 'package:moneybalance/pages/home_page.dart';

class AddRecord extends StatefulWidget {
  const AddRecord({super.key});
  
  @override
  State<AddRecord> createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  late DateTime _dueDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _dueDate = DateTime.now();
  }

  File? _image;

  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // display the input 
            const Row(children: [
              Flexible(child: TextFormFildAdd(hinttext: 'المبلغ', inputnumber: true, keyboardtype: TextInputType.number, padding: 20.00,)),
              Flexible(child: TextFormFildAdd(hinttext: 'الأسم', inputnumber: false, keyboardtype: TextInputType.text, padding: 20.00)),
            ]),
            const TextFormFildAdd(hinttext: 'التفاصيل', inputnumber: false, keyboardtype: TextInputType.text, padding: 20.00,),
            const SizedBox(height: 20),


            //display the date and image
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 
                _image == null ? const Text('') : clickableImage(),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => showOptions(),
            
                  icon: const Icon(Icons.add_a_photo),
                ),
                _buildDueDateButton(),
              ],
            ),
        
            const SizedBox(height: 30),
        
            //display the submit button 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconButton('مدين', Colors.red, Icons.keyboard_arrow_down_rounded),
                const SizedBox(width: 20),
                _buildIconButton('دائن', Colors.green, Icons.keyboard_arrow_up_rounded),
              ],
            )
            
        
          ],
        ),
      )
    );

    
  }

  // button icon
  Widget _buildIconButton (String name, Color? color,  IconData? icon) {
    return ElevatedButton.icon(
        onPressed: () {
          if(_formKey.currentState!.validate()){
            Navigator.pop(context, '/');
          }
        },
        icon: Icon(icon, size: 30, color: color),
        label: Text(name, 
          style: GoogleFonts.readexPro(
              textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),

        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blue[900]!),
        ),
                
      );  
  }

  //button that hold the result of date
  Widget _buildDueDateButton() {
    return TextButton(
      onPressed: () => _selectDate(),
      
      child: Text(
        'التاريخ : ${_dueDate.year} - ${_dueDate.month} - ${_dueDate.day}',
        style: GoogleFonts.readexPro(
          textStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.5
          )
        ),
      ),
    );
  }
  
  // function to set the date 
  Future<void> _selectDate() async{
    final selectDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100)
    );
    if(selectDate!= null){
      setState(() {
        _dueDate = selectDate;
      });
    }
  }

  //Image Picker function to get image from gallery
  Future pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  //Image Picker function to get image from camera
  Future pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  //Show options to get image from camera or gallery
  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              pickImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              pickImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  //dispaly image on big screen 
  Widget clickableImage () {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: InteractiveViewer(
                child: Image.file(_image!),
              ),
            );
          },
        );
      },
      child: Image.file(_image!, width: 30),
    );
  }

  


}