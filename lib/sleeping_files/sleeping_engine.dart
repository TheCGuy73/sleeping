/// File: lib/sleeping_engine.dart

import 'package:flutter/material.dart'; // Usato solo per TimeOfDay, che è un tipo di dato di Flutter

// File: lib/sleeping_files/sleeping_engine.dart
class SleepCalculator {
  static const int _sleepCycleDurationMinutes = 90;
  static const int _timeToFallAsleepMinutes = 15;

  static const List<double> recommendedCycles = [4.5, 6, 7.5];

  static List<TimeOfDay> calculateBedtimeSuggestions(TimeOfDay wakeUpTime) {
    final List<TimeOfDay> bedtimes = [];
    final now = DateTime.now();
    final wakeUpDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      wakeUpTime.hour,
      wakeUpTime.minute,
    );

    for (final cycles in recommendedCycles) {
      final totalSleepMinutes = (cycles * _sleepCycleDurationMinutes).round();
      final effectiveSleepDuration = Duration(
        minutes: totalSleepMinutes + _timeToFallAsleepMinutes,
      );
      final bedtimeDateTime = wakeUpDateTime.subtract(effectiveSleepDuration);
      bedtimes.add(TimeOfDay.fromDateTime(bedtimeDateTime));
    }

    return bedtimes;
  }

  static List<TimeOfDay> calculateWakeUpTimeSuggestions(TimeOfDay bedtime) {
    final List<TimeOfDay> wakeUpTimes = [];
    final now = DateTime.now();
    final bedtimeDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      bedtime.hour,
      bedtime.minute,
    );

    for (final cycles in recommendedCycles) {
      final totalSleepMinutes = (cycles * _sleepCycleDurationMinutes).round();
      final sleepDuration = Duration(minutes: totalSleepMinutes);
      final wakeUpDateTime = bedtimeDateTime.add(sleepDuration);
      wakeUpTimes.add(TimeOfDay.fromDateTime(wakeUpDateTime));
    }

    return wakeUpTimes;
  }

  static String formatTimeOfDay(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  static String formatDurationFromTimes(
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) {
    int startMinutes = startTime.hour * 60 + startTime.minute;
    int endMinutes = endTime.hour * 60 + endTime.minute;

    if (endMinutes < startMinutes) endMinutes += 24 * 60;

    int durationMinutes = endMinutes - startMinutes;
    int hours = durationMinutes ~/ 60;
    int minutes = durationMinutes % 60;

    return '${hours}h ${minutes}m';
  }
}
