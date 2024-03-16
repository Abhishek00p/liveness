import 'package:flutter_bloc/flutter_bloc.dart';

class SpokenNumber extends Cubit<String> {
  SpokenNumber() : super('');
  changeValue(String v) {
    emit(v);
  }
}
