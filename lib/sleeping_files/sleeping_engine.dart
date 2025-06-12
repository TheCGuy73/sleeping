/// File: lib/sleeping_engine.dart

import 'package:flutter/material.dart'; // Usato solo per TimeOfDay, che è un tipo di dato di Flutter

/// Una classe statica per calcolare gli orari di sonno ideali basati sui cicli.
class SleepCalculator {
  // Durata di un singolo ciclo di sonno in minuti
  static const int _sleepCycleDurationMinutes = 90;
  // Tempo stimato per addormentarsi in minuti
  static const int _timeToFallAsleepMinutes = 15;

  // Durate di sonno raccomandate in cicli (per fornire più opzioni)
  // Reso pubblico per essere accessibile dalla UI
  static const List<double> recommendedCycles = [
    3.0, // 4 ore e 30 minuti
    4.0, // 6 ore
    5.0, // 7 ore e 30 minuti (molto raccomandato)
    6.0, // 9 ore (molto raccomandato)
    6.5, // 9 ore e 45 minuti (per chi ha bisogno di più riposo)
  ];

  /// Calcola gli orari di sonno suggeriti (quando andare a dormire)
  /// in base all'orario di risveglio desiderato.
  /// Ritorna una lista di TimeOfDay.
  static List<TimeOfDay> calculateBedtimeSuggestions(TimeOfDay wakeUpTime) {
    final List<TimeOfDay> bedtimes = [];

    // Converte TimeOfDay in un DateTime per facilitare i calcoli
    // Usiamo una data arbitraria (es. oggi) per i calcoli
    final now = DateTime.now();
    final wakeUpDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      wakeUpTime.hour,
      wakeUpTime.minute,
    );

    for (final cycles in recommendedCycles) {
      // Usato recommendedCycles
      // Calcola la durata totale di sonno richiesta (cicli * durata ciclo)
      final totalSleepMinutes = (cycles * _sleepCycleDurationMinutes).round();
      // Aggiunge il tempo per addormentarsi
      final effectiveSleepDuration = Duration(
        minutes: totalSleepMinutes + _timeToFallAsleepMinutes,
      );

      // Calcola l'orario di andare a dormire sottraendo la durata effettiva
      final bedtimeDateTime = wakeUpDateTime.subtract(effectiveSleepDuration);

      // Aggiunge l'orario risultante alla lista
      bedtimes.add(TimeOfDay.fromDateTime(bedtimeDateTime));
    }

    return bedtimes;
  }

  /// Calcola gli orari di risveglio suggeriti in base all'orario in cui si va a dormire.
  /// Ritorna una lista di TimeOfDay.
  static List<TimeOfDay> calculateWakeUpTimeSuggestions(TimeOfDay bedtime) {
    final List<TimeOfDay> wakeUpTimes = [];

    // Converte TimeOfDay in un DateTime per facilitare i calcoli
    final now = DateTime.now();
    final bedtimeDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      bedtime.hour,
      bedtime.minute,
    );

    for (final cycles in recommendedCycles) {
      // Usato recommendedCycles
      // Calcola la durata totale di sonno desiderata
      final totalSleepMinutes = (cycles * _sleepCycleDurationMinutes).round();
      final sleepDuration = Duration(minutes: totalSleepMinutes);

      // Calcola l'orario di risveglio aggiungendo la durata di sonno
      final wakeUpDateTime = bedtimeDateTime.add(sleepDuration);

      // Aggiunge l'orario risultante alla lista
      wakeUpTimes.add(TimeOfDay.fromDateTime(wakeUpDateTime));
    }

    return wakeUpTimes;
  }

  /// Formatta un TimeOfDay in una stringa leggibile (es. "HH:MM").
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formatta un TimeOfDay in una stringa che include i minuti passati tra i due orari
  static String formatDurationFromTimes(
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) {
    // Converte TimeOfDay in minuti totali dal midnight
    int startMinutes = startTime.hour * 60 + startTime.minute;
    int endMinutes = endTime.hour * 60 + endTime.minute;

    // Gestisce il caso in cui l'orario di fine sia il giorno successivo
    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60; // Aggiunge 24 ore in minuti
    }

    int durationMinutes = endMinutes - startMinutes;
    int hours = durationMinutes ~/ 60;
    int minutes = durationMinutes % 60;

    return '${hours}h ${minutes}m';
  }
}
