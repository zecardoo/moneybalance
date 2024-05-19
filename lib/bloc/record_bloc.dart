import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import 'package:moneybalance/bloc/record_event.dart';
import 'package:moneybalance/bloc/record_state.dart';

class RecordBloc  extends Bloc<RecordEvent, RecordState> {
  final Logger logger = Logger();

  // Initialize with the initial state
  RecordBloc() : super(RecordInitial()) {
    on<AddRecordEvent>(_onAddRecord); // Handle add record events
    on<PickImageFromGalleryEvent>(_onPickImageGallery); // Handle pick image events
    on<PickImageFromCameraEvent>(_onPickImageCamera); // Handle pick image events
  }

  // Handle add record events
  Future<void> _onAddRecord(AddRecordEvent event, Emitter<RecordState> emit) async{
    
    emit(RecordLoading());  // Emit loading state
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final DocumentReference  record =  await firestore.collection('record').add({
        'name': event.name,
        'amount': event.amount,
      });

      await record.collection('balance').add({
        'details': event.details,
        'date': event.date,
        'image': event.imagePath,
        'forhim': event.forhim,
        'onhim': event.onhim
      });

      emit(RecordSuccess('Successfully Added'.toString())); // Emit success state
    } catch (error) {
      emit(RecordFailure(error.toString())); // Emit failure state with error message
    }
  }

  // Handle pick image events
  Future<void> _onPickImageGallery (PickImageFromGalleryEvent event, Emitter<RecordState> emit) async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      emit(RecordImagePicked(File(pickedFile.path)));  // Emit image picked state
    }
  }

  // Handle pick image events
  Future<void> _onPickImageCamera (PickImageFromCameraEvent event, Emitter<RecordState> emit) async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      emit(RecordImagePicked(File(pickedFile.path)));  // Emit image picked state
    }
  }
}