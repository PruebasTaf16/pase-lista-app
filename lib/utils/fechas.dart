import 'package:intl/intl.dart';

DateTime obtenerHorarioLocal(dynamic dateAPI) {
  DateTime horario = DateTime.parse(dateAPI);
  return DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    horario.hour,
    horario.minute,
  );
}

String formatTimeTo24Hours(DateTime dateTime) {
  var formatter = DateFormat('HH:mm:ss');
  return formatter.format(dateTime);
}

bool sameHourAndMinutes(DateTime dateTime1, int aditionalDT1,
    DateTime dateTime2, int aditionalDT2) {
  return dateTime1.hour == dateTime2.hour &&
      (dateTime1.minute + aditionalDT1) == (dateTime2.minute + aditionalDT2);
}
