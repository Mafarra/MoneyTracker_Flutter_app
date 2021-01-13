List<DateTime> calculateDaysInterval(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];
  DateTime tmp = DateTime(startDate.year, startDate.month, startDate.day, 12);
  while (DateTime(tmp.year, tmp.month, tmp.day) != endDate) {
    tmp = tmp.add(Duration(days: 1));
    days.add(DateTime(tmp.year, tmp.month, tmp.day));
  }

  return days;
}
