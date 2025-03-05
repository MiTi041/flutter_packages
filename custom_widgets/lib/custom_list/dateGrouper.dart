import 'package:custom_utils/custom_time.dart';

class DateGrouper {
  static Map<String, List<Map<String, dynamic>>> groupByDate(List<Map<String, dynamic>?> data) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (var item in data) {
      if (item == null || item['date'] == null) continue;
      DateTime date = DateTime.parse(item['date']);
      String label = Time().timeStamp(date, noDates: true);

      if (!groupedData.containsKey(label)) {
        groupedData[label] = [];
      }
      groupedData[label]!.add(item);
    }

    return groupedData;
  }
}
