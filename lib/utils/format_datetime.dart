import 'package:intl/intl.dart';

String formatDateTime(DateTime date) {
  final formatter = DateFormat('dd/MM/yyyy HH:mm');
  return formatter.format(date);
}
