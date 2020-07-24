import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'data/ItemModel.dart';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CollectionReference goals = Firestore.instance.collection('goals');

  void _addNewItem(BuildContext context) {
    _showEditDialogue(context, ItemModel("", "", 0, 0))
        .then((value) => goals.add(value.toJson()));
  }

  void _clickEdit(BuildContext context, ItemModel model) {
    _showEditDialogue(context, model).then(
        (value) => goals.document(model.documentID).updateData(value.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder(
          stream: goals.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            if (snapshot.data.documents.isEmpty)
              return Center(child: Text('No data'));

            return ListView.builder(
              itemBuilder: (context, index) => ItemCard(
                  ItemModel.fromJson(snapshot.data.documents[index]),
                  (value) => goals.document(value.documentID).delete(),
                  (model) => _clickEdit(context, model)),
              itemCount: snapshot.data.documents.length,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewItem(context),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ItemCard extends StatelessWidget {
  final ItemModel _data;
  final Function(ItemModel) removeListener;
  Function(ItemModel data) editListener;

  final decimalFormat = NumberFormat.compact(locale: "en_US");

  ItemCard(
    this._data,
    this.removeListener,
    this.editListener, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => removeListener(_data),
      confirmDismiss: (direction) => _showItemRemoveDialog(context),
      background: Container(
          color: Colors.red,
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ))),
      key: Key(_data.toString()),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(flex: 1, child: Text(_data.name)),
                MaterialButton(
                  height: 32,
                  minWidth: 32,
                  padding: EdgeInsets.all(0),
                  onPressed: () => editListener(_data),
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Icon(
                    Icons.edit,
                    size: 16,
                  ),
                  shape: CircleBorder(),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: LinearProgressIndicator(
                value: _data.getProgress(),
                backgroundColor: Colors.black12,
                valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),
              ),
            ),
            Text(
                "${decimalFormat.format(_data.value)}/${decimalFormat.format(_data.maxValue)}")
          ],
        ),
      ),
    );
  }
}

Future<ItemModel> _showEditDialogue(
    BuildContext context, ItemModel data) async {
  final _formKey = GlobalKey<FormState>();
  final formatter = NumberFormat("#,###");

// ItemModel()
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

Future<bool> _showItemRemoveDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Do you wan to remove?'),
        actions: <Widget>[
          FlatButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("DELETE")),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("CANCEL"),
          ),
        ],
      );
    },
  );
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
