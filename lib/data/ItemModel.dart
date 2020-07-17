class ItemModel {
  String name;
  int maxValue;
  int value;
  ItemModel(this.name, this.maxValue, this.value);

  double getProgress() {
    return value * 1.0 / maxValue;
  }
}
