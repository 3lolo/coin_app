import 'package:coin_app/data/ItemModel.dart';
import 'package:coin_app/list/bloc/list_screen_bloc.dart';
import 'package:coin_app/list/widgets/item_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _bloc = ListScreenBloc();
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListScreenBloc>(
      create: (_) => _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text("widget.title"),
        ),
        body: BlocConsumer<ListScreenBloc, ListScreenState>(
            cubit: _bloc,
            listener: (context, state) {
              if (state is Init) {
                _bloc.add(InitializeEvent());
              }
            },
            builder: (context, state) {
              if (state is Init) {
                _bloc.add(InitializeEvent());
                return Center(child: CircularProgressIndicator());
              } else if (state is Loading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is Success) {
                return ListWidgete(state.data);
              } else {
                return Center(child: Text("List is empty"));
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showEditDialogue(context, ItemModel("", "", 0, 0))
                .then((value) => _bloc.add(CreateItemEvent(value)));
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

class ListWidgete extends StatelessWidget {
  final List<ItemModel> data;

  const ListWidgete(
    this.data, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    ListScreenBloc bloc = BlocProvider.of(context);

    return ListView.builder(
      itemBuilder: (context, index) => ItemCard(
        data[index],
        (value) => _showDeleteDialog(context, value).then((value) {
          if (value == null) return;
          bloc.add(DeleteItemEvent(value));
        }),
        (value) => _showEditDialogue(context, value)
            .then((value) => bloc.add(UpdateItemEvent(value))),
      ),
      itemCount: data.length,
    );
  }
}

Future<ItemModel> _showDeleteDialog(
    BuildContext context, ItemModel itemModel) async {
  return showDialog<ItemModel>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Do you wan to remove?'),
        actions: <Widget>[
          FlatButton(
              onPressed: () => Navigator.of(context).pop(itemModel),
              child: const Text("DELETE")),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text("CANCEL"),
          ),
        ],
      );
    },
  );
}

Future<ItemModel> _showEditDialogue(
    BuildContext context, ItemModel data) async {
  final _formKey = GlobalKey<FormState>();
  final formatter = NumberFormat("#,###");

  String name;
  String maxValue;
  String value;
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit item'),
          content: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: data.name,
                        decoration:
                            const InputDecoration(labelText: 'Enter name'),
                        keyboardType: TextInputType.text,
                        onSaved: (newValue) => name = newValue,
                      ),
                      TextFormField(
                        initialValue: formatter.format(data.maxValue),
                        decoration:
                            const InputDecoration(labelText: 'Max value'),
                        validator: (value) {
                          return (value.isEmpty)
                              ? 'Please enter max value'
                              : null;
                        },
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                          _UsNumberTextInputFormatter()
                        ],
                        keyboardType: TextInputType.number,
                        onSaved: (newValue) => maxValue = newValue,
                      ),
                      TextFormField(
                        initialValue: formatter.format(data.value),
                        decoration:
                            const InputDecoration(labelText: 'Current value'),
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                          _UsNumberTextInputFormatter()
                        ],
                        keyboardType: TextInputType.number,
                        onSaved: (newValue) => value = newValue,
                      )
                    ],
                  ))),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  _formKey.currentState.save();
                  if (_formKey.currentState.validate()) {
                    Navigator.of(context).pop(ItemModel(
                        data.documentID,
                        name,
                        maxValue.isEmpty
                            ? 0
                            : formatter.parse(maxValue).round(),
                        value.isEmpty ? 0 : formatter.parse(value).round()));
                  }
                },
                child: const Text("SAVE")),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text("CANCEL"),
            ),
          ],
        );
      });
}

class CurrencyInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      print(true);
      return newValue;
    }

    double value = double.parse(newValue.text);

    final formatter = NumberFormat.simpleCurrency(locale: "en_US");

    String newText = formatter.format(value / 100);

    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}

class _UsNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final formatter = new NumberFormat("#,###");
    int selectionIndex = newValue.selection.end;
    String text = newValue.text;
    String result = formatter.format(text == null ? 0 : int.parse(text));
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
