import 'package:coin_app/data/ItemModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@immutable
class ItemCard extends StatelessWidget {
  final ItemModel _data;
  final Function(ItemModel) removeListener;
  final Function(ItemModel) editListener;

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
      onDismissed: (direction) => {},
      confirmDismiss: (direction) => removeListener(_data),
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
