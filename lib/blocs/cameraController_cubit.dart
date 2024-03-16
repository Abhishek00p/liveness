import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraControllerCubit extends Cubit<CameraController?> {
  CameraControllerCubit() : super(null);

  changeValue(CameraController? v) {
    emit(v);
  }
}
