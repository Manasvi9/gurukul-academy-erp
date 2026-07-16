import 'package:intl/intl.dart';

final class DateFormatter {
  DateFormatter._();

  static final _displayDate = DateFormat('dd MMM yyyy');

  static String displayDate(DateTime value) {
    return _displayDate.format(value);
  }
}
