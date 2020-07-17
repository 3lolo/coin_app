import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'data/ItemModel.dart';

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
  List<ItemModel> data = [
    ItemModel("Vehicle", 10000, 100),
    ItemModel("Seconds", 1000, 100)
  ];

  void _incrementCounter() {
    setState(() {
      data.add(ItemModel("Item - ${(data.length + 1)}", 20, 100));
    });
  }

  void _clickEdit(int index, ItemModel model) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemBuilder: (context, index) => ItemCard(
              index, data[index], (index, model) => _clickEdit(index, model)),
          itemCount: data.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ItemCard extends StatelessWidget {
  final ItemModel _data;
  VoidCallback pressListener;

  ItemCard(
    int index,
    this._data,
    Function(int, ItemModel) listener, {
    Key key,
  }) : super(key: key) {
    pressListener = () => listener(index, _data);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                onPressed: pressListener,
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
          Text("${_data.value}/${_data.maxValue}")
        ],
      ),
    );
  }
}
