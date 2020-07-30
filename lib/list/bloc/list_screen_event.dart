part of 'list_screen_bloc.dart';

@immutable
abstract class ListScreenEvent {}

class InitializeEvent extends ListScreenEvent {}

class CreateItemEvent extends ListScreenEvent {
  final ItemModel value;
  CreateItemEvent(this.value);
}

class DeleteItemEvent extends ListScreenEvent {
  final ItemModel value;
  DeleteItemEvent(this.value);
}

class UpdateItemEvent extends ListScreenEvent {
  final ItemModel value;
  UpdateItemEvent(this.value);
}

class UpdateListEvent extends ListScreenEvent {
  final List<ItemModel> value;
  UpdateListEvent(this.value);
}
