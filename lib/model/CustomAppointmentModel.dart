import 'package:syncfusion_flutter_calendar/calendar.dart';

class CustomAppointmentModel extends Appointment{
  bool? concluso;

  CustomAppointmentModel({
    this.concluso,
    required super.startTime,
    required super.endTime,
    super.isAllDay = false,
    super.subject,
    super.color,
    super.startTimeZone,
    super.endTimeZone,
    super.recurrenceRule,
    super.recurrenceId,
    super.id,
    super.notes,
    super.location,
    super.resourceIds,
    super.recurrenceExceptionDates,
  });
}