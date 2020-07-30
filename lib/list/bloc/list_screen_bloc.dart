import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coin_app/data/ItemModel.dart';
import 'package:meta/meta.dart';

part 'list_screen_event.dart';
part 'list_screen_state.dart';

class ListScreenBloc extends Bloc<ListScreenEvent, ListScreenState> {
  final CollectionReference goals = Firestore.instance.collection('goals');
  StreamSubscription _listSubscription = null;

  ListScreenBloc() : super(Init()) {
    _actionInitializeEvent();
  }

  @override
  Stream<ListScreenState> mapEventToState(
    ListScreenEvent event,
  ) async* {
    if (event is InitializeEvent) {
      yield* _actionInitializeEvent();
    } else if (event is CreateItemEvent) {
      yield* _actionCreateItemEvent(event.value);
    } else if (event is DeleteItemEvent) {
      yield* _actionDeleteItemEvent(event.value);
    } else if (event is UpdateItemEvent) {
      yield* _actionUpdateItemEvent(event.value);
    } else if (event is UpdateListEvent) {
      yield* _actionUpdateListEvent(event.value);
    }
  }

  Stream<ListScreenState> _actionInitializeEvent() {
    _listSubscription?.cancel();
    _listSubscription = goals
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((event) => event.map((e) => ItemModel.fromJson(e)).toList())
        .listen((event) => add(UpdateListEvent(event)));
  }

  Stream<Success> _actionUpdateListEvent(List<ItemModel> data) async* {
    yield Success(data);
  }

  Stream<ListScreenState> _actionCreateItemEvent(ItemModel data) async* {
    goals.add(data.toJson());
  }

  Stream<ListScreenState> _actionDeleteItemEvent(ItemModel value) async* {
    goals.document(value.documentID).delete();
  }

  Stream<ListScreenState> _actionUpdateItemEvent(ItemModel value) {
    goals.document(value.documentID).updateData(value.toJson());
  }

  @override
  Future<void> close() {
    _listSubscription.cancel();
    return super.close();
  }
}
