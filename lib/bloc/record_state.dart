
import 'dart:io';
import 'package:equatable/equatable.dart';

// Define the abstract base class for all states
abstract class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object> get props => [];
}

// Initial state
class RecordInitial extends RecordState {}

// Loading state
class RecordLoading extends RecordState {}

// Success state
class RecordSuccess extends RecordState {}

// Failure state with an error message
class RecordFailure extends RecordState {
  final String error;
  const RecordFailure(this.error);

  @override
  List<Object> get props => [error];
}

// State when an image is picked
class RecordImagePicked extends RecordState {
  final File image;

  const RecordImagePicked(this.image);

  @override
  List<Object> get props => [image];
}