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
  final String amount;
  final DateTime date;
  final String? imagePath;
  final String forhim;
  final String onhim;

   const AddRecordEvent({
    required this.name,
    required this.details,
    required this.amount,
    required this.date,
    this.imagePath,
    required this.forhim,
    required this.onhim,
  });
  
  @override
  List<Object> get props => [name, details, amount, date, imagePath ?? '', forhim, onhim];

}

// Event for picking an image
class PickImageFromGalleryEvent extends RecordEvent{}

class PickImageFromCameraEvent extends RecordEvent{}