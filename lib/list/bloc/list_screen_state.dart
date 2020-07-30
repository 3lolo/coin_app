part of 'list_screen_bloc.dart';

@immutable
abstract class ListScreenState {}

class Init extends ListScreenState {}

class Loading extends ListScreenState {}

class Success extends ListScreenState {
  final List<ItemModel> data;
  Success(this.data);
}

class Empty extends ListScreenState {}
