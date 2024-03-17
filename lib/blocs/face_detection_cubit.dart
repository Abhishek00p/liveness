import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:liveness/blocs/face_detection_state.dart';

class FaceDetectionCubit extends Cubit<FaceDetectionState> {
  FaceDetectionCubit()
      : super(
          FaceDetectionInitialState(),
        );
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableTracking: true,
      enableClassification: true,
    ),
  );

  Future<void> detectFace({
    required XFile file,
  }) async {
    emit(FaceDetectionLoadingState());
    final File pickedImage = File(file.path);
    InputImage inputImage = InputImage.fromFile(pickedImage);

    final List<Face> faces = await _faceDetector.processImage(inputImage);
    if (faces.isNotEmpty) {
      debugPrint('Face not empty: ${faces.length}');

      emit(FaceDetectionLoadedState(file: file));
    } else {
      debugPrint(' empty faces');

      emit(FaceDetectionErrorState());
    }
  }

  @override
  Future<void> close() {
    _faceDetector.close();
    return super.close();
  }
}
