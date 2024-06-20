import 'package:equatable/equatable.dart';

// Define the abstract base class for all events
abstract class RecordEvent  extends  Equatable{
   const RecordEvent ();

  

  @override
  List<Object> get props => [];
}

// Event for adding a new record
class AddRecordEvent extends RecordEvent {
  final String name;
  final String details;
  final double amount;
  final DateTime date;
  final DateTime createdAt;
  final String? imagePath;
  final double forhim;
  final double onhim;

   const AddRecordEvent({
    required this.name,
    required this.details,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.imagePath,
    required this.forhim,
    required this.onhim,
  });
  
  @override
  List<Object> get props => [name, details, amount, date,createdAt, imagePath ?? '', forhim, onhim];

}

class AddSubRecordEvent extends RecordEvent {
  final String? id;
  final String details;
  final double amount;
  final DateTime date;
  final DateTime createdAt;
  final String? imagePath;
  final double forhim;
  final double onhim;

   const AddSubRecordEvent({
    required this.id,
    required this.details,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.imagePath,
    required this.forhim,
    required this.onhim,
  });
  
  @override
  List<Object> get props => [id ?? '', details, amount, date,createdAt, imagePath ?? '', forhim, onhim];

}

// Event for picking an image
class PickImageFromGalleryEvent extends RecordEvent{}

class PickImageFromCameraEvent extends RecordEvent{}