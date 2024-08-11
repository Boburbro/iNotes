import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String toFormat() => DateFormat('yyyy-MM-dd').format(this);
}
