import 'package:intl/intl.dart';

class Time {
  // datum
  String datum(DateTime n) {
    DateTime localDateTime = n.toLocal();
    DateTime currentDate = DateTime.now();
    DateTime today = DateTime(currentDate.year, currentDate.month, currentDate.day);
    DateTime tomorrow = today.add(const Duration(days: 1));
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime nextWeek = today.add(const Duration(days: 7)); // Eine Woche in die Zukunft

    if (localDateTime.isAfter(today) && localDateTime.isBefore(tomorrow)) {
      // Date is today
      return 'Heute, ${DateFormat('HH:mm', 'de_DE').format(localDateTime)}';
    } else if (localDateTime.isAfter(today) && localDateTime.isBefore(tomorrow.add(const Duration(days: 1)))) {
      // Date is tomorrow
      return 'Morgen, ${DateFormat('HH:mm', 'de_DE').format(localDateTime)}';
    } else if (localDateTime.isAfter(tomorrow) && localDateTime.isBefore(tomorrow.add(const Duration(days: 1)))) {
      // Date is the day after tomorrow
      return 'Übermorgen, ${DateFormat('HH:mm', 'de_DE').format(localDateTime)}';
    } else if (localDateTime.isAfter(yesterday) && localDateTime.isBefore(today)) {
      // Date is yesterday
      return 'Gestern, ${DateFormat('HH:mm', 'de_DE').format(localDateTime)}';
    } else if (localDateTime.isAfter(today.subtract(const Duration(days: 6)))) {
      // Date is within the last week but not today
      return DateFormat('EEEE, HH:mm', 'de_DE').format(localDateTime);
    } else if (localDateTime.isAfter(nextWeek)) {
      // Date is in the future beyond this week
      return DateFormat('dd.MM.yyyy, HH:mm').format(localDateTime);
    } else {
      // Date is more than a week ago
      return DateFormat('dd.MM.yyyy, HH:mm').format(localDateTime);
    }
  }

  String timeStamp(DateTime n, {bool noDates = false}) {
    DateTime localDateTime = n.toLocal();
    DateTime currentDate = DateTime.now();
    DateTime today = DateTime(currentDate.year, currentDate.month, currentDate.day);
    DateTime tomorrow = today.add(const Duration(days: 1));
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime nextWeek = today.add(const Duration(days: 7)); // Eine Woche in die Zukunft

    if (localDateTime.isAfter(today) && localDateTime.isBefore(tomorrow)) {
      // Date is today
      return 'Heute';
    } else if (localDateTime.isAfter(today) && localDateTime.isBefore(tomorrow.add(const Duration(days: 1)))) {
      // Date is tomorrow
      return 'Morgen';
    } else if (localDateTime.isAfter(tomorrow) && localDateTime.isBefore(tomorrow.add(const Duration(days: 1)))) {
      // Date is the day after tomorrow
      return 'Übermorgen';
    } else if (localDateTime.isAfter(yesterday) && localDateTime.isBefore(today)) {
      // Date is yesterday
      return 'Gestern';
    } else if (localDateTime.isAfter(today.subtract(const Duration(days: 6)))) {
      // Date is within the last week but not today
      return DateFormat('EEEE', 'de_DE').format(localDateTime);
    } else if (localDateTime.isAfter(nextWeek)) {
      // Date is in the future beyond this week
      return DateFormat('dd.MM.yyyy').format(localDateTime);
    } else {
      // Date is more than a week ago
      if (noDates) {
        return 'Frühere';
      } else {
        return DateFormat('dd.MM.yyyy', 'de_DE').format(localDateTime);
      }
    }
  }
}
