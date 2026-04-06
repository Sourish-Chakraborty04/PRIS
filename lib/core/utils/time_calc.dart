import 'package:flutter/material.dart';

class TimeCalc {
  /// Converts a [TimeOfDay] into a decimal double.
  /// Example: 10:30 PM -> 22.5
  static double timeToDecimal(TimeOfDay time) {
    return time.hour + (time.minute / 60.0);
  }

  /// Calculates total hours between start and end.
  /// Handles shifts that cross midnight (e.g., 10 PM to 4 AM).
  static double calculateShiftHours(TimeOfDay start, TimeOfDay end) {
    double startDec = timeToDecimal(start);
    double endDec = timeToDecimal(end);

    if (endDec < startDec) {
      // Shift crossed midnight, add 24 hours to the end time
      return (endDec + 24) - startDec;
    }

    return endDec - startDec;
  }

  /// Formats decimal hours back into a string for the UI.
  /// Example: 8.5 -> "8h 30m"
  static String formatDecimalDuration(double hours) {
    int h = hours.truncate();
    int m = ((hours - h) * 60).round();
    return "${h}h ${m}m";
  }

  /// Calculates earnings based on hours worked.
  /// [rate] is the hourly pay defined in your PRIS settings.
  static double calculateEarnings(double hours, double rate) {
    return hours * rate;
  }
}