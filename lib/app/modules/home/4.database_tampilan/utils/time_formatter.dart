import 'package:intl/intl.dart';

String formatTimestamp(String isoString) {
  try {
    final date = DateTime.parse(isoString);
    return DateFormat('dd MMM yyyy, HH:mm:ss').format(date);
  } catch (e) {
    return isoString;
  }
}
