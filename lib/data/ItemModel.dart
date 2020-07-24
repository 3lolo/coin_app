import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  String documentID;
  String name;
  int maxValue;
  int value;
  ItemModel(this.documentID, this.name, this.maxValue, this.value);

  double getProgress() {
    return (maxValue == 0) ? 0 : value * 1.0 / maxValue;
  }

  ItemModel.fromJson(DocumentSnapshot document)
      : documentID = document.documentID,
        name = document.data['name'] ?? '',
        maxValue = document.data['max_value'] ?? 0,
        value = document.data['value'] ?? 0;

  Map<String, dynamic> toJson() => {
        'name': name,
        'max_value': maxValue,
        'value': value,
      };
}
