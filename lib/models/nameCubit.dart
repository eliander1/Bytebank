import 'package:flutter_bloc/flutter_bloc.dart';


// O estado é uma única String, poderia ser um perfil com diversos valores
class NameCubit extends Cubit<String> {
  NameCubit(String name) : super(name);
  void change(String name) => emit(name);
}