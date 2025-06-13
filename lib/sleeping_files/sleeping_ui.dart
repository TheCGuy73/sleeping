import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleeping/sleeping_files/sleeping_engine.dart'; // Assicurati che il percorso sia corretto
import 'dart:ui'; // Importa per BackdropFilter

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

  final String _appVersion = "0.0.1"; // Esempio di versione

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        // Applica il tema "Liquid Glass" al TimePicker
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFBBDEFB), // Colore primario per l'interfaccia
              onPrimary: Colors.black,
              surface: Color(
                0xFF1E293B,
              ), // Colore di sfondo dei selettori (scuro per contrasto)
              onSurface: Colors.white, // Colore del testo sui selettori
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(
                  0xFF64B5F6,
                ), // Colore dei pulsanti di testo (OK/CANCEL)
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors
                  .transparent, // Rende il background del dialog trasparente
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              surfaceTintColor:
                  Colors.transparent, // Rimuove il tint surface predefinito
            ),
          ),
          // Avvolge il TimePicker in un GlassmorphismContainer per l'effetto vetro
          child: GlassmorphismContainer(
            borderRadius: 20.0,
            padding: const EdgeInsets.all(
              20.0,
            ), // Aggiungi padding interno per il contenuto del TimePicker
            child: child!, // Il TimePicker originale
          ),
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
        // Colore di successo: Un blu vibrante che si abbina ai bottoni
        backgroundColor: const Color(0xFF64B5F6).withOpacity(0.9),
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
        // Colore di warning: Azzurro chiaro come il colore primario del tema
        backgroundColor: const Color(0xFFBBDEFB).withOpacity(0.9),
        // Testo nero per un buon contrasto sullo sfondo azzurro chiaro
        textStyle: GoogleFonts.montserrat(color: Colors.black, fontSize: 14),
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
        // Colore di warning: Azzurro chiaro come il colore primario del tema
        backgroundColor: const Color(0xFFBBDEFB).withOpacity(0.9),
        // Testo nero per un buon contrasto sullo sfondo azzurro chiaro
        textStyle: GoogleFonts.montserrat(color: Colors.black, fontSize: 14),
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GlassmorphismContainer(
          // La AppBar ora è un container di vetro
          borderRadius: 0.0, // Non arrotondata per l'appbar
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ), // Per gestire il notch
          child: GFAppBar(
            title: Text(
              "Calcolatore del Sonno",
              style: GoogleFonts.poppins(
                color: GFColors.WHITE,
                fontWeight: FontWeight.w700,
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
            backgroundColor:
                Colors.transparent, // Trasparente per mostrare l'effetto vetro
            elevation: 0,
            centerTitle: true,
            // Spostiamo il PopupMenuButton da 'actions' a 'leading'
            leading: PopupMenuButton<String>(
              icon: const Icon(
                Icons.menu,
                color: GFColors.WHITE,
              ), // Un'icona più appropriata per un menu
              color: const Color(
                0xFF1E293B,
              ).withOpacity(0.9), // Sfondo del menu a tendina
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.0,
                ),
              ),
              onSelected: (String result) {
                if (result == 'info') {
                  _showAppInfo();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'info',
                  child: Text(
                    'Informazioni sull\'App',
                    style: GoogleFonts.montserrat(color: GFColors.WHITE),
                  ),
                ),
              ],
            ),
            // Rimuoviamo la proprietà 'actions' o la lasciamo vuota se non ci sono altri elementi a destra
            actions: const [], // Non ci sono più azioni a destra
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Blu molto scuro, quasi nero
              Color(0xFF1E293B), // Blu scuro intermedio
              Color(0xFF0F172A), // Torna al blu scuro per un effetto avvolgente
            ],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
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
                    color: GFColors.LIGHT.withOpacity(0.9),
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Scegli un orario e lascia che i cicli di sonno ti guidino.",
                  style: GoogleFonts.robotoMono(
                    fontSize: 16,
                    color: GFColors.LIGHT.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                GlassmorphismContainer(
                  borderRadius: 50.0,
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 100,
                  child: ElevatedButton(
                    onPressed: _pickTime,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: BorderSide.none,
                      ),
                      elevation: 0,
                      foregroundColor: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time, size: 32),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            _selectedTime == null
                                ? "Seleziona un Orario"
                                : "Orario Selezionato: ${SleepCalculator.formatTimeOfDay(_selectedTime!)}",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: GFColors.WHITE.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GlassmorphismContainer(
                        borderRadius: 50.0,
                        height: 100,
                        child: ElevatedButton(
                          onPressed: _toggleBedtimeCalculation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                              side: BorderSide.none,
                            ),
                            elevation: 0,
                            foregroundColor: Colors.white,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bedtime_outlined, size: 28),
                              const SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                ),
                                child: Text(
                                  "Quando Andare a Dormire?",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: GFColors.WHITE.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: GlassmorphismContainer(
                        borderRadius: 50.0,
                        height: 100,
                        child: ElevatedButton(
                          onPressed: _toggleWakeUpTimeCalculation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                              side: BorderSide.none,
                            ),
                            elevation: 0,
                            foregroundColor: Colors.white,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wb_sunny_outlined, size: 28),
                              const SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                ),
                                child: Text(
                                  "Quando Svegliarsi?",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: GFColors.WHITE.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
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
      return GlassmorphismContainer(
        key: ValueKey(_calculationMode),
        borderRadius: 20.0,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _calculationMode == 1
                  ? "Suggerimenti per Andare a Dormire (per risvegliarsi a ${SleepCalculator.formatTimeOfDay(_selectedTime!)})"
                  : "Suggerimenti per Svegliarsi (se vai a dormire alle ${SleepCalculator.formatTimeOfDay(_selectedTime!)})",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GFColors.WHITE.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            Divider(
              color: GFColors.LIGHT.withOpacity(0.3),
            ), // Divider più trasparente
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
                          color: GFColors.INFO.withOpacity(
                            0.8,
                          ), // Icone leggermente più trasparenti
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "${SleepCalculator.formatTimeOfDay(suggestedTime)} (${cycles.toStringAsFixed(1)} cicli, ${durationText})",
                            style: GoogleFonts.robotoMono(
                              fontSize: 16,
                              color: GFColors.WHITE.withOpacity(0.8),
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

// Widget riutilizzabile per l'effetto Glassmorphism (Liquid Glass Enhanced)
class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurStrength;
  final Color backgroundColor;
  final Color borderColor;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.blurStrength = 8.0, // Sfocatura più morbida per liquid glass
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.white,
    this.boxShadow,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(
              0.08,
            ), // Opacità molto bassa per trasparenza liquida
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor.withOpacity(
                0.1,
              ), // Bordo quasi impercettibile, per un bagliore
              width: 1.0,
            ),
            boxShadow:
                boxShadow ??
                [
                  // Box Shadow per profondità e "bagliore"
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.2,
                    ), // Ombra scura principale
                    blurRadius: 20,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    // Ombra più chiara per l'effetto luce
                    color: Colors.white.withOpacity(0.05),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, -5),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}
