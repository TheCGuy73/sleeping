// File: lib/sleeping_files/sleeping_ui.dart
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleeping/sleeping_files/sleeping_engine.dart';
import 'dart:ui';

class SleepingUi extends StatefulWidget {
  const SleepingUi({super.key});

  @override
  State<SleepingUi> createState() => _SleepingUiState();
}

class _SleepingUiState extends State<SleepingUi> {
  TimeOfDay? _selectedTime;
  List<TimeOfDay> _bedtimeSuggestions = [];
  List<TimeOfDay> _wakeUpSuggestions = [];
  int _calculationMode = 0;

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
        _resetSuggestions();
      });
      _showToast(
        "Orario selezionato: ${SleepCalculator.formatTimeOfDay(picked)}",
      );
    }
  }

  void _resetSuggestions() {
    _bedtimeSuggestions = [];
    _wakeUpSuggestions = [];
    _calculationMode = 0;
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
      _showToast("Seleziona un orario di risveglio prima");
      return;
    }

    setState(() {
      if (_calculationMode == 1) {
        _resetSuggestions();
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
      _showToast("Seleziona un orario di andare a dormire prima");
      return;
    }

    setState(() {
      if (_calculationMode == 2) {
        _resetSuggestions();
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
            "Calcola gli orari ideali per dormire/svegliarti basandoti sui cicli di sonno",
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.black87),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            "Sviluppato con Flutter",
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
      appBar: _buildAppBar(),
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                _buildTitle(),
                const SizedBox(height: 10),
                _buildSubtitle(),
                const SizedBox(height: 40),
                _buildTimeSelectionButton(),
                const SizedBox(height: 30),
                _buildActionButtons(),
                const SizedBox(height: 30),
                _buildResultsDisplay(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: GlassmorphismContainer(
        borderRadius: 0.0,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: GFAppBar(
          title: _buildPremiumText(
            "Calcolatore del Sonno",
            GoogleFonts.poppins(
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
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
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
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
        stops: [0.1, 0.5, 0.9],
      ),
    );
  }

  Widget _buildTitle() {
    return _buildPremiumText(
      "Pianifica il Tuo Sonno Perfetto",
      GoogleFonts.openSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSubtitle() {
    return _buildPremiumText(
      "Scegli un orario e lascia che i cicli di sonno ti guidino",
      GoogleFonts.robotoMono(fontSize: 16, fontStyle: FontStyle.italic),
    );
  }

  Widget _buildPremiumText(String text, TextStyle style) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: style.copyWith(
        color: GFColors.WHITE.withOpacity(0.95),
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(1, 1),
          ),
          Shadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(-1, -1),
          ),
        ],
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
          Icon(
            Icons.access_time,
            size: 32,
            color: GFColors.WHITE.withOpacity(0.95),
            shadows: _buildIconShadows(),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: _buildPremiumText(
              _selectedTime == null
                  ? "Seleziona un Orario"
                  : "Orario Selezionato: ${SleepCalculator.formatTimeOfDay(_selectedTime!)}",
              GoogleFonts.poppins(
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

  List<Shadow> _buildIconShadows() {
    return [
      Shadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 6,
        offset: const Offset(1, 1),
      ),
      Shadow(
        color: Colors.white.withOpacity(0.2),
        blurRadius: 3,
        offset: const Offset(-1, -1),
      ),
    ];
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.bedtime_outlined,
          text: "Quando Andare a Dormire?",
          onPressed: _toggleBedtimeCalculation,
        ),
        const SizedBox(width: 15),
        _buildActionButton(
          icon: Icons.wb_sunny_outlined,
          text: "Quando Svegliarsi?",
          onPressed: _toggleWakeUpTimeCalculation,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: HoverElevatedGlassButton(
        height: 100,
        onPressed: onPressed,
        buttonChild: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: GFColors.WHITE.withOpacity(0.95),
              shadows: _buildIconShadows(),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: _buildPremiumText(
                text,
                GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
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
    final title = _calculationMode == 1
        ? "Suggerimenti per Andare a Dormire (per risvegliarsi a ${SleepCalculator.formatTimeOfDay(_selectedTime!)})"
        : "Suggerimenti per Svegliarsi (se vai a dormire alle ${SleepCalculator.formatTimeOfDay(_selectedTime!)})";

    return GlassmorphismContainer(
      key: ValueKey(_calculationMode),
      borderRadius: 20.0,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumText(
            title,
            GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
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
                    color: GFColors.INFO.withOpacity(0.9),
                    size: 20,
                    shadows: _buildIconShadows(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPremiumText(
                      "${SleepCalculator.formatTimeOfDay(suggestedTime)} (${cycles.toStringAsFixed(1)} cicli, $durationText)",
                      GoogleFonts.robotoMono(fontSize: 16),
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
          child: Icon(
            Icons.nights_stay,
            size: 80,
            color: GFColors.INFO,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(2, 2),
              ),
              Shadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(-1, -1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildPremiumText(
          "Preparati a sognare...",
          GoogleFonts.indieFlower(fontSize: 18, fontStyle: FontStyle.italic),
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
