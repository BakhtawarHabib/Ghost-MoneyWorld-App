import 'package:intl/intl.dart';

class AppFormat {
  static String dateDDMMYY(DateTime date) {
    String formattedDate = DateFormat('dd-MM-yy, hh:mm').format(date);
    return formattedDate;
  }

  static String dateYYMMDD(DateTime date) {
    String formattedDate = DateFormat('yy-MM-dd').format(date);
    return formattedDate;
  }

  static String dateYYYYMMDDHHMM24(DateTime? date) {
    if (date == null) return '';
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
    return formattedDate;
  }

  static String dateyyyyMMddHHmmss(DateTime? date) {
    if (date == null) return '';
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    return formattedDate;
  }

  static String dateOnly(DateTime? date) {
    String formattedDate =
        DateFormat('dd/MM/yy').format(date ?? DateTime.now());
    return formattedDate;
  }

  static String dateOnlyWithDot(DateTime? date) {
    String formattedDate =
        DateFormat('yyyy.MM.dd').format(date ?? DateTime.now());
    return formattedDate;
  }

  static String dateOnlyDDMMYY(DateTime? date) {
    String formattedDate =
        DateFormat('dd-MM-yyyy').format(date ?? DateTime.now());
    return formattedDate;
  }

  static String dateOnlyDDMMYYWithSlash(DateTime? date) {
    String formattedDate =
        DateFormat('dd/MM/yyyy').format(date ?? DateTime.now());
    return formattedDate;
  }

  static String timeOnly(DateTime? date) {
    String formattedDate = DateFormat('hh:mm a').format(date ?? DateTime.now());
    return formattedDate;
  }

  static String? doubleToStringUpTo2(String? number) {
    if (number == null) return null;
    return double.tryParse(number)?.toStringAsFixed(2);
  }
}
