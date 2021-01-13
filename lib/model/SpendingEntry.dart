import 'package:money_tracker/database_helpers.dart';

class SpendingEntry {
  // Five items per spending entry
  int id, timestamp, day;
  String content;
  double amount;

  SpendingEntry();

  // convenience constructor to create a Word object
  SpendingEntry.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    timestamp = map[columnTimeStamp];
    day = map[columnDay];
    amount = map[columnAmount];
    content = map[columnContent];
  }

  // convenience method to create a Map from this object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTimeStamp: timestamp,
      columnDay: day,
      columnAmount: amount,
      columnContent: content,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "{id: $id, day: $day, amount: $amount, content: $content}";
  }
}
