import 'package:money_tracker/database_helpers.dart';

class SubscriptionEntry {
  // Five items per spending entry
  int id, cycle, day;
  String content;
  double amount;

  SubscriptionEntry();

  // convenience constructor to create a Word object
  SubscriptionEntry.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    day = map[columnDay];
    amount = map[columnAmount];
    content = map[columnContent];
    cycle = map[columnCycle];
  }

  // convenience method to create a Map from this object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDay: day,
      columnAmount: amount,
      columnContent: content,
      columnCycle: cycle,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "{id: $id, cycle: $cycle, day: $day, amount: $amount, content: $content}";
  }
}
