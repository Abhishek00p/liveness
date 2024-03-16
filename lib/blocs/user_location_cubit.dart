import 'package:flutter_bloc/flutter_bloc.dart';

class UserLocation extends Cubit<String> {
  UserLocation() : super('');
  changeValue(String v) {
    emit(v);
  }
}
