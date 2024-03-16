import 'package:flutter_bloc/flutter_bloc.dart';

class IsAudioListening extends Cubit<bool> {
  IsAudioListening() : super(false);
  void changeValue(bool v) {
    emit(v);
  }
}
