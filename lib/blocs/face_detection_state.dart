
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

class FaceDetectionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FaceDetectionLoadedState extends FaceDetectionState {
  final XFile file;

  FaceDetectionLoadedState({required this.file});
}

class FaceDetectionLoadingState extends FaceDetectionState {}

class FaceDetectionErrorState extends FaceDetectionState {}

class FaceDetectionInitialState extends FaceDetectionState {}
