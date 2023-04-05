import 'package:intl/intl.dart';

String formatDateTime(String dateString) {
  final dateTime = DateTime.parse(dateString);
  final formatter = DateFormat('dd/MM/yyyy HH:mm');
  return formatter.format(dateTime);
}
