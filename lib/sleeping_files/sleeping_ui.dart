import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleeping/sleeping_files/sleeping_engine.dart'; // Assicurati che il percorso sia corretto

class SleepingUi extends StatefulWidget {
  const SleepingUi({super.key});

  @override
  State<SleepingUi> createState() => _SleepingUiState();
}

class _SleepingUiState extends State<SleepingUi> {
  TimeOfDay? _selectedTime;
  List<TimeOfDay> _bedtimeSuggestions = [];
  List<TimeOfDay> _wakeUpSuggestions = [];
  int _calculationMode =
      0; // 0 = Nessuna, 1 = Calcola Orario di Sonno, 2 = Calcola Orario di Sveglia

  // Puoi definire la versione qui o prenderla da un file di configurazione/package_info
  final String _appVersion = "0.0.1"; // Esempio di versione

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFBBDEFB),
              onPrimary: Colors.black,
              surface: Color(0xFF2C3E50),
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64B5F6),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _bedtimeSuggestions = [];
        _wakeUpSuggestions = [];
        _calculationMode = 0; // Resetta la modalità di calcolo
      });
      GFToast.showToast(
        "Orario selezionato: ${SleepCalculator.formatTimeOfDay(picked)}",
        context,
        toastPosition: GFToastPosition.BOTTOM,
        backgroundColor: GFColors.SUCCESS.withOpacity(0.9),
        textStyle: GoogleFonts.montserrat(color: GFColors.WHITE, fontSize: 14),
        toastBorderRadius: 10.0,
      );
    }
  }

  void _toggleBedtimeCalculation() {
    if (_selectedTime == null) {
      GFToast.showToast(
        "Per favore, seleziona un orario di risveglio prima.",
        context,
        toastPosition: GFToastPosition.TOP,
        backgroundColor: GFColors.DANGER.withOpacity(0.9),
        textStyle: GoogleFonts.montserrat(color: GFColors.WHITE, fontSize: 14),
        toastBorderRadius: 10.0,
      );
      return;
    }

    setState(() {
      if (_calculationMode == 1) {
        _calculationMode = 0;
        _bedtimeSuggestions = [];
      } else {
        _bedtimeSuggestions = SleepCalculator.calculateBedtimeSuggestions(
          _selectedTime!,
        );
        _wakeUpSuggestions = [];
        _calculationMode = 1;
      }
    });
  }

  void _toggleWakeUpTimeCalculation() {
    if (_selectedTime == null) {
      GFToast.showToast(
        "Per favore, seleziona un orario di andare a dormire prima.",
        context,
        toastPosition: GFToastPosition.TOP,
        backgroundColor: GFColors.DANGER.withOpacity(0.9),
        textStyle: GoogleFonts.montserrat(color: GFColors.WHITE, fontSize: 14),
        toastBorderRadius: 10.0,
      );
      return;
    }

    setState(() {
      if (_calculationMode == 2) {
        _calculationMode = 0;
        _wakeUpSuggestions = [];
      } else {
        _wakeUpSuggestions = SleepCalculator.calculateWakeUpTimeSuggestions(
          _selectedTime!,
        );
        _bedtimeSuggestions = [];
        _calculationMode = 2;
      }
    });
  }

  // Nuova funzione per mostrare le informazioni sull'app
  void _showAppInfo() {
    showAboutDialog(
      context: context,
      applicationName: "Calcolatore del Sonno",
      applicationVersion: _appVersion,
      applicationIcon: Image.asset(
        'assets/moon_icon.png', // Assicurati che il percorso dell'icona sia corretto
        width: 60,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.nights_stay, size: 60, color: GFColors.INFO);
        },
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            "Questa app ti aiuta a calcolare gli orari ideali per andare a dormire o svegliarti, basandosi sui cicli di sonno.",
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.black87),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            "Sviluppato con Flutter.",
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF1E283A);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GFAppBar(
        title: Text(
          "Calcolatore del Sonno",
          style: GoogleFonts.poppins(
            color: GFColors.WHITE,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          GFIconButton(
            icon: const Icon(Icons.info_outline, color: GFColors.WHITE),
            onPressed: _showAppInfo, // Chiama la nuova funzione qui
            type: GFButtonType.transparent,
            splashColor: GFColors.PRIMARY.withOpacity(0.3),
          ),
        ],
      ),
      body: Container(
        color: backgroundColor,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 80),
                Text(
                  "Pianifica il Tuo Sonno Perfetto",
                  style: GoogleFonts.openSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: GFColors.LIGHT,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Scegli un orario e lascia che i cicli di sonno ti guidino.",
                  style: GoogleFonts.robotoMono(
                    fontSize: 16,
                    color: GFColors.LIGHT.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _pickTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64B5F6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black45,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: GFColors.WHITE,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedTime == null
                            ? "Seleziona un Orario"
                            : "Orario Selezionato: ${SleepCalculator.formatTimeOfDay(_selectedTime!)}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: GFColors.WHITE,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _toggleBedtimeCalculation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GFColors.SUCCESS,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black45,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.bedtime_outlined,
                              color: GFColors.DARK,
                              size: 28,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Quando Andare a Dormire?",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: GFColors.DARK,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _toggleWakeUpTimeCalculation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GFColors.INFO,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black45,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.wb_sunny_outlined,
                              color: GFColors.DARK,
                              size: 28,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Quando Svegliarsi?",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: GFColors.DARK,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                  child: _buildResultWidget(),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultWidget() {
    if (_calculationMode != 0) {
      return GFCard(
        key: ValueKey(_calculationMode),
        color: GFColors.LIGHT.withOpacity(0.95),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _calculationMode == 1
                  ? "Suggerimenti per Andare a Dormire (per risvegliarsi a ${SleepCalculator.formatTimeOfDay(_selectedTime!)})"
                  : "Suggerimenti per Svegliarsi (se vai a dormire alle ${SleepCalculator.formatTimeOfDay(_selectedTime!)})",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GFColors.DARK,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(color: GFColors.LIGHT),
            ...(_calculationMode == 1
                    ? _bedtimeSuggestions
                    : _wakeUpSuggestions)
                .asMap()
                .entries
                .map((entry) {
                  int index = entry.key;
                  TimeOfDay suggestedTime = entry.value;
                  double cycles = SleepCalculator.recommendedCycles[index];
                  TimeOfDay durationStartTime = _calculationMode == 1
                      ? suggestedTime
                      : _selectedTime!;
                  TimeOfDay durationEndTime = _calculationMode == 1
                      ? _selectedTime!
                      : suggestedTime;
                  String durationText = SleepCalculator.formatDurationFromTimes(
                    durationStartTime,
                    durationEndTime,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        Icon(
                          _calculationMode == 1
                              ? Icons.nights_stay
                              : Icons.brightness_5,
                          color: GFColors.FOCUS,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "${SleepCalculator.formatTimeOfDay(suggestedTime)} (${cycles.toStringAsFixed(1)} cicli, ${durationText})",
                            style: GoogleFonts.robotoMono(
                              fontSize: 16,
                              color: GFColors.DARK,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
                .toList(),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        margin: const EdgeInsets.all(10.0),
        elevation: 10,
      );
    } else {
      return Column(
        key: const ValueKey(0),
        children: [
          GFLoader(
            type: GFLoaderType.custom,
            child: Image.asset(
              'assets/moon_icon.png',
              height: 80,
              width: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.nights_stay,
                  size: 80,
                  color: GFColors.INFO,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Preparati a sognare...",
            style: GoogleFonts.indieFlower(
              fontSize: 18,
              color: GFColors.LIGHT.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }
  }
}
