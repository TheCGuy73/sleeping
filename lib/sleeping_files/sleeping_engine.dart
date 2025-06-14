class SleepCalculator {
  static const int _sleepCycleDuration = 90; // minutes
  static const int _fallAsleepTime = 15; // minutes
  static const List<double> recommendedCycles = [4.5, 6, 7.5];

  static List<DateTime> calculateBedtimes(DateTime wakeUpTime) {
    return recommendedCycles.map((cycles) {
      final totalSleep = Duration(
        minutes: (cycles * _sleepCycleDuration).round(),
      );
      final fallAsleepDuration = Duration(minutes: _fallAsleepTime);
      return wakeUpTime.subtract(totalSleep + fallAsleepDuration);
    }).toList();
  }

  static List<DateTime> calculateWakeUpTimes(DateTime bedtime) {
    return recommendedCycles.map((cycles) {
      final totalSleep = Duration(
        minutes: (cycles * _sleepCycleDuration).round(),
      );
      return bedtime.add(totalSleep);
    }).toList();
  }

  static String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  static String formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
