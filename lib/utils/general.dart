import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

String env(String name) {
  return dotenv.env[name].toString();
}

String today({String format: ''}) {
  var formatter;

  if (format.isEmpty) {
    formatter = DateFormat(DateFormat.MONTH_WEEKDAY_DAY);
  } else {
    formatter = DateFormat(format);
  }

  return formatter.format(DateTime.now());
}

String parseDefaultDate(date) {
  var formatter;

  formatter = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY);
  return formatter.format(DateTime.parse(date));
}

String parseDefaultTime(date) {
  var formatter;

  formatter = DateFormat(DateFormat.HOUR_MINUTE);
  return formatter.format(DateTime.parse(date));
}

String parseDefaultDateTime(date) {
  return '${parseDefaultDate(date)} @ ${parseDefaultTime(date)}';
}

void jsonPrint(body) {
  if (env('APP_DEBUG') == 'true') {
    var object = json.decode(json.encode(body));
    var prettyString = JsonEncoder.withIndent('  ').convert(object);

    log(prettyString);
  }
}
