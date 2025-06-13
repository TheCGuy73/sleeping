import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleeping/sleeping_files/sleeping_engine.dart';
import 'dart:ui';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: SleepingUi()),
  );
}

class SleepingUi extends StatefulWidget {
  const SleepingUi({super.key});

  @override
  State<SleepingUi> createState() => _SleepingUiState();
}

class _SleepingUiState extends State<SleepingUi> {
  TimeOfDay? _selectedTime;
  List<TimeOfDay> _bedtimeSuggestions = [];
  List<TimeOfDay> _wakeUpSuggestions = [];
  int _calculationMode = 0; // 0 = None, 1 = Bedtime, 2 = Wake-up

  final String _appVersion = "1.0.0";

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
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64B5F6),
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          child: GlassmorphismContainer(
            borderRadius: 20.0,
            padding: const EdgeInsets.all(20.0),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _bedtimeSuggestions = [];
        _wakeUpSuggestions = [];
        _calculationMode = 0;
      });
      _showToast(
        "Orario selezionato: ${SleepCalculator.formatTimeOfDay(picked)}",
      );
    }
  }

  void _showToast(String message) {
    GFToast.showToast(
      message,
      context,
      toastPosition: GFToastPosition.BOTTOM,
      backgroundColor: const Color(0xFF64B5F6).withOpacity(0.9),
      textStyle: GoogleFonts.montserrat(color: GFColors.WHITE, fontSize: 14),
      toastBorderRadius: 10.0,
    );
  }

  void _toggleBedtimeCalculation() {
    if (_selectedTime == null) {
      _showToast("Per favore, seleziona un orario di risveglio prima.");
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
      _showToast("Per favore, seleziona un orario di andare a dormire prima.");
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
      applicationIcon: const Icon(
        Icons.nights_stay,
        size: 60,
        color: GFColors.INFO,
      ),
      children: [
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
          borderRadius: 0.0,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: GFColors.WHITE),
              color: const Color(0xFF1E293B).withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.0,
                ),
              ),
              onSelected: (String result) => _showAppInfo(),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'info',
                  child: Text('Informazioni sull\'App'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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

                // Time Selection Button
                _buildTimeSelectionButton(),
                const SizedBox(height: 30),

                // Action Buttons
                _buildActionButtons(),
                const SizedBox(height: 30),

                // Results Display
                _buildResultsDisplay(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelectionButton() {
    return HoverElevatedGlassButton(
      width: MediaQuery.of(context).size.width * 0.75,
      height: 100,
      onPressed: _pickTime,
      buttonChild: Column(
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: HoverElevatedGlassButton(
            height: 100,
            onPressed: _toggleBedtimeCalculation,
            buttonChild: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bedtime_outlined, size: 28),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
        const SizedBox(width: 15),
        Expanded(
          child: HoverElevatedGlassButton(
            height: 100,
            onPressed: _toggleWakeUpTimeCalculation,
            buttonChild: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 28),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
      ],
    );
  }

  Widget _buildResultsDisplay() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _calculationMode != 0
          ? _buildSuggestionsList()
          : _buildPlaceholder(),
    );
  }

  Widget _buildSuggestionsList() {
    final suggestions = _calculationMode == 1
        ? _bedtimeSuggestions
        : _wakeUpSuggestions;

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
          Divider(color: GFColors.LIGHT.withOpacity(0.3)),
          ...suggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestedTime = entry.value;
            final cycles = SleepCalculator.recommendedCycles[index];
            final durationText = SleepCalculator.formatDurationFromTimes(
              _calculationMode == 1 ? suggestedTime : _selectedTime!,
              _calculationMode == 1 ? _selectedTime! : suggestedTime,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: [
                  Icon(
                    _calculationMode == 1
                        ? Icons.nights_stay
                        : Icons.brightness_5,
                    color: GFColors.INFO.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${SleepCalculator.formatTimeOfDay(suggestedTime)} (${cycles.toStringAsFixed(1)} cicli, $durationText)",
                      style: GoogleFonts.robotoMono(
                        fontSize: 16,
                        color: GFColors.WHITE.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      key: const ValueKey(0),
      children: [
        GFLoader(
          type: GFLoaderType.custom,
          child: const Icon(Icons.nights_stay, size: 80, color: GFColors.INFO),
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

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurStrength;
  final double backgroundOpacity;
  final double borderOpacity;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color baseBackgroundColor;
  final Color baseBorderColor;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.blurStrength = 8.0,
    this.backgroundOpacity = 0.08,
    this.borderOpacity = 0.1,
    this.boxShadow,
    this.width,
    this.height,
    this.padding,
    this.baseBackgroundColor = Colors.white,
    this.baseBorderColor = Colors.white,
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
            color: baseBackgroundColor.withOpacity(backgroundOpacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: baseBorderColor.withOpacity(borderOpacity),
              width: 1.0,
            ),
            boxShadow:
                boxShadow ??
                [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
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

class HoverElevatedGlassButton extends StatefulWidget {
  final Widget buttonChild;
  final VoidCallback? onPressed;
  final double borderRadius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Duration animationDuration;
  final double hoverScale;
  final double clickScale;

  const HoverElevatedGlassButton({
    super.key,
    required this.buttonChild,
    this.onPressed,
    this.borderRadius = 50.0,
    this.width,
    this.height,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 200),
    this.hoverScale = 1.03,
    this.clickScale = 0.98,
  });

  @override
  State<HoverElevatedGlassButton> createState() =>
      _HoverElevatedGlassButtonState();
}

class _HoverElevatedGlassButtonState extends State<HoverElevatedGlassButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _isPressed
        ? widget.clickScale
        : (_isHovered ? widget.hoverScale : 1.0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          duration: widget.animationDuration,
          scale: scale,
          curve: _isPressed ? Curves.easeInOut : Curves.easeOutBack,
          child: AnimatedContainer(
            duration: widget.animationDuration,
            curve: Curves.easeOut,
            child: GlassmorphismContainer(
              borderRadius: widget.borderRadius,
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    _isPressed ? 0.4 : (_isHovered ? 0.3 : 0.2),
                  ),
                  blurRadius: _isPressed ? 20 : (_isHovered ? 25 : 20),
                  spreadRadius: -5,
                  offset: Offset(0, _isPressed ? 5 : 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(
                    _isPressed ? 0.05 : (_isHovered ? 0.08 : 0.05),
                  ),
                  blurRadius: _isPressed ? 15 : (_isHovered ? 20 : 15),
                  spreadRadius: _isPressed ? 1 : (_isHovered ? 3 : 2),
                  offset: const Offset(0, -5),
                ),
              ],
              baseBackgroundColor: Colors.white,
              baseBorderColor: Colors.white,
              child: ElevatedButton(
                onPressed: widget.onPressed,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>((
                    states,
                  ) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.white.withOpacity(0.25);
                    }
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.white.withOpacity(0.15);
                    }
                    return Colors.transparent;
                  }),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                  ),
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  elevation: MaterialStateProperty.all(0),
                ),
                child: widget.buttonChild,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
