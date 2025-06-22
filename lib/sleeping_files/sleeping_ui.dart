import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'version_utils.dart';

class ThisTheme {
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.blueGrey[600],
        foregroundColor: Colors.white,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey[600],
      foregroundColor: Colors.white,
      elevation: 2,
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blueGrey,
      brightness: Brightness.dark,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[850],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.blueGrey[600],
        foregroundColor: Colors.white,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );
}

void main() {
  runApp(const SleepCalculatorApp());
}

class SleepCalculatorApp extends StatefulWidget {
  const SleepCalculatorApp({super.key});

  @override
  State<SleepCalculatorApp> createState() => _SleepCalculatorAppState();
}

class _SleepCalculatorAppState extends State<SleepCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      switch (_themeMode) {
        case ThemeMode.system:
          _themeMode = ThemeMode.light;
          break;
        case ThemeMode.light:
          _themeMode = ThemeMode.dark;
          break;
        case ThemeMode.dark:
          _themeMode = ThemeMode.system;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calcolatore del Sonno',
      debugShowCheckedModeBanner: false,
      theme: ThisTheme.lightTheme,
      darkTheme: ThisTheme.darkTheme,
      themeMode: _themeMode,
      home: SleepCalculatorScreen(
        onThemeToggle: _toggleTheme,
        themeMode: _themeMode,
      ),
      builder: (context, child) {
        // Rilevamento avanzato del tema del sistema per Windows
        final mediaQuery = MediaQuery.of(context);
        final platformBrightness = mediaQuery.platformBrightness;

        // Se il tema è impostato su "sistema", usa il rilevamento automatico
        if (_themeMode == ThemeMode.system) {
          final isDark = platformBrightness == Brightness.dark;
          return Theme(
            data: isDark ? ThisTheme.darkTheme : ThisTheme.lightTheme,
            child: child!,
          );
        }

        return child!;
      },
    );
  }
}

class SleepCalculatorScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;

  const SleepCalculatorScreen({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
  });

  @override
  State<SleepCalculatorScreen> createState() => _SleepCalculatorScreenState();
}

class _SleepCalculatorScreenState extends State<SleepCalculatorScreen> {
  DateTime? _selectedTime;
  List<DateTime> _suggestions = [];
  bool _isBedtimeMode = true;
  bool _updateAvailable = false;
  String _currentVersion = 'Caricamento...';
  String _latestVersion = '';
  String _updateUrl = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      // Usa VersionUtils per caricare la versione
      _currentVersion = await VersionUtils.getVersion();

      // Carica anche altre informazioni per debug
      final versionInfo = await VersionUtils.getVersionInfo();
      final fullVersion = await VersionUtils.getFullVersion();

      setState(() {});
    } catch (e) {
      setState(() {
        _currentVersion = 'Errore caricamento';
      });
    }
  }

  // Metodo per mostrare informazioni di debug sulla versione
  void _showVersionDebug() async {
    try {
      final versionInfo = await VersionUtils.getVersionInfo();
      final fullVersion = await VersionUtils.getFullVersion();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Debug Versione'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDebugInfoRow("Versione", versionInfo['version'] ?? "N/A"),
                _buildDebugInfoRow(
                  "Build Number",
                  versionInfo['buildNumber'] ?? "N/A",
                ),
                _buildDebugInfoRow("App Name", versionInfo['appName'] ?? "N/A"),
                _buildDebugInfoRow(
                  "Package Name",
                  versionInfo['packageName'] ?? "N/A",
                ),
                _buildDebugInfoRow("Versione Completa", fullVersion),
                _buildDebugInfoRow("Versione Corrente", _currentVersion),
                _buildDebugInfoRow("Tema", _getThemeModeText()),
                _buildDebugInfoRow(
                  "Piattaforma",
                  Theme.of(context).platform.toString(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showMessage('Errore nel caricamento informazioni versione');
    }
  }

  Widget _buildDebugInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    try {
      const releasesUrl =
          'https://raw.githubusercontent.com/TheCGuy73/sleeping/master/releases.json';
      final response = await http.get(Uri.parse(releasesUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latest = data['latest'];
        final latestVersion = latest['version'];

        // Confronto semplice: se la versione remota è diversa dalla corrente
        if (latestVersion != _currentVersion) {
          setState(() {
            _latestVersion = latestVersion;
            _updateUrl = latest['download_url'];
            _updateAvailable = true;
          });
          _showUpdateDialog();
        } else {
          _showMessage('Hai già la versione più recente');
        }
      } else {
        _showMessage('Errore nel controllo aggiornamenti');
      }
    } catch (e) {
      _showMessage('Errore nel controllo aggiornamenti');
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      final selected = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      setState(() {
        _selectedTime = selected;
        _suggestions = [];
      });
    }
  }

  void _calculateTimes() {
    if (_selectedTime == null) {
      _showMessage('Seleziona prima un orario');
      return;
    }

    setState(() {
      _suggestions = _isBedtimeMode
          ? _calculateBedtimes(_selectedTime!)
          : _calculateWakeUpTimes(_selectedTime!);
    });
  }

  List<DateTime> _calculateBedtimes(DateTime wakeUpTime) {
    const cycleDuration = 90; // minuti
    const fallAsleepTime = 15; // minuti
    const cycles = [4.5, 6, 7.5];

    return cycles.map((cycle) {
      final totalSleep = Duration(minutes: (cycle * cycleDuration).round());
      final timeToFallAsleep = Duration(minutes: fallAsleepTime);
      return wakeUpTime.subtract(totalSleep + timeToFallAsleep);
    }).toList();
  }

  List<DateTime> _calculateWakeUpTimes(DateTime bedtime) {
    const cycleDuration = 90; // minuti
    const cycles = [4.5, 6, 7.5];

    return cycles.map((cycle) {
      final totalSleep = Duration(minutes: (cycle * cycleDuration).round());
      return bedtime.add(totalSleep);
    }).toList();
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String _getThemeModeText() {
    switch (widget.themeMode) {
      case ThemeMode.system:
        // Rileva il tema effettivo del sistema
        final mediaQuery = MediaQuery.of(context);
        final platformBrightness = mediaQuery.platformBrightness;
        return platformBrightness == Brightness.dark
            ? 'Sistema (Scuro)'
            : 'Sistema (Chiaro)';
      case ThemeMode.light:
        return 'Chiaro';
      case ThemeMode.dark:
        return 'Scuro';
    }
  }

  void _showAppInfo() async {
    // Carica informazioni dettagliate sulla versione
    final versionInfo = await VersionUtils.getVersionInfo();
    final fullVersion = await VersionUtils.getFullVersion();

    showAboutDialog(
      context: context,
      applicationName: versionInfo['appName'] ?? "Calcolatore del Sonno",
      applicationVersion: fullVersion,
      applicationIcon: const Icon(Icons.nights_stay, size: 50),
      children: [
        const SizedBox(height: 20),
        Text(
          "Calcola gli orari ideali per dormire/svegliarti basandoti sui cicli di sonno",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Text(
          "Sviluppato con Flutter",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        Text(
          "Tema attuale: ${_getThemeModeText()}",
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        Text(
          "Piattaforma: ${Theme.of(context).platform}",
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        // Informazioni dettagliate sulla versione
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Informazioni Versione:",
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildVersionInfoRow("Versione", versionInfo['version'] ?? "N/A"),
              _buildVersionInfoRow(
                "Build",
                versionInfo['buildNumber'] ?? "N/A",
              ),
              _buildVersionInfoRow(
                "Package",
                versionInfo['packageName'] ?? "N/A",
              ),
              _buildVersionInfoRow("Versione Completa", fullVersion),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiornamento Disponibile'),
        content: Text(
          'Versione $_latestVersion disponibile. Vuoi scaricarla ora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Più tardi'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUpdateUrl();
            },
            child: const Text('Scarica'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUpdateUrl() async {
    if (await canLaunchUrl(Uri.parse(_updateUrl))) {
      await launchUrl(Uri.parse(_updateUrl));
    } else {
      _showMessage('Impossibile aprire il link di download');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final platformBrightness = mediaQuery.platformBrightness;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Calcolatore del Sonno'),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.arrow_drop_down),
              tooltip: 'Menu',
              onSelected: (value) {
                if (value == 'info') _showAppInfo();
                if (value == 'theme') widget.onThemeToggle();
                if (value == 'debug') _showVersionDebug();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Text(
                        'Informazioni',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'theme',
                  child: Row(
                    children: [
                      Icon(
                        widget.themeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tema: ${_getThemeModeText()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'debug',
                  child: Row(
                    children: [
                      const Icon(Icons.bug_report),
                      const SizedBox(width: 8),
                      Text(
                        'Debug Versione',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.update),
            onPressed: _checkForUpdates,
            tooltip: 'Controlla aggiornamenti',
          ),
          if (_updateAvailable)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.new_releases, color: Colors.yellow),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      _isBedtimeMode
                          ? 'Quando andare a dormire?'
                          : 'Quando svegliarsi?',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickTime,
                      child: Text(
                        _selectedTime == null
                            ? 'Seleziona Orario'
                            : 'Orario: ${_formatTime(_selectedTime!)}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isBedtimeMode = !_isBedtimeMode;
                        _suggestions = [];
                      });
                    },
                    child: Text(
                      _isBedtimeMode ? 'Modalità Sveglia' : 'Modalità Dormire',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _calculateTimes,
                    child: const Text('Calcola'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_suggestions.isNotEmpty)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isBedtimeMode
                              ? 'Orari per dormire (sveglia alle ${_formatTime(_selectedTime!)})'
                              : 'Orari per svegliarsi (dormire alle ${_formatTime(_selectedTime!)})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final time = _suggestions[index];
                              final cycles = [4.5, 6, 7.5][index];
                              final duration = _isBedtimeMode
                                  ? _formatDuration(time, _selectedTime!)
                                  : _formatDuration(_selectedTime!, time);

                              return ListTile(
                                leading: Icon(
                                  _isBedtimeMode
                                      ? Icons.nights_stay
                                      : Icons.wb_sunny,
                                  color: isDarkMode
                                      ? Colors.blueGrey[300]
                                      : Colors.blueGrey[600],
                                ),
                                title: Text(_formatTime(time)),
                                subtitle: Text('$cycles cicli ($duration)'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Sezione versione sempre visibile
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Versione: $_currentVersion',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (_updateAvailable)
                      Icon(
                        Icons.new_releases,
                        size: 16,
                        color: Colors.yellow[700],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
