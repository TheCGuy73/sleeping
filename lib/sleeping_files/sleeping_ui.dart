import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const SleepCalculatorApp());
}

class SleepCalculatorApp extends StatelessWidget {
  const SleepCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calcolatore del Sonno',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey),
      ),
      home: const SleepCalculatorScreen(),
    );
  }
}

class SleepCalculatorScreen extends StatefulWidget {
  const SleepCalculatorScreen({super.key});

  @override
  State<SleepCalculatorScreen> createState() => _SleepCalculatorScreenState();
}

class _SleepCalculatorScreenState extends State<SleepCalculatorScreen> {
  DateTime? _selectedTime;
  List<DateTime> _suggestions = [];
  bool _isBedtimeMode = true;
  bool _isDarkMode = false;
  bool _updateAvailable = false;
  String _currentVersion = '1.0.0';
  String _latestVersion = '';
  String _updateUrl = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = packageInfo.version;
    });
  }

  Future<void> _checkForUpdates() async {
    try {
      const releasesUrl =
          'https://raw.githubusercontent.com/tuaccount/turepo/main/releases.json';
      final response = await http.get(Uri.parse(releasesUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latest = data['latest'];

        setState(() {
          _latestVersion = latest['version'];
          _updateUrl = latest['download_url'];
          _updateAvailable = _isVersionNewer(_currentVersion, _latestVersion);
        });

        if (_updateAvailable) {
          _showUpdateDialog();
        } else {
          _showMessage('Hai già la versione più recente');
        }
      }
    } catch (e) {
      _showMessage('Errore nel controllo aggiornamenti');
      debugPrint('Update error: $e');
    }
  }

  bool _isVersionNewer(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
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

  void _showAppInfo() {
    showAboutDialog(
      context: context,
      applicationName: "Calcolatore del Sonno",
      applicationVersion: _currentVersion,
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
      ],
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
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
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
                  if (value == 'theme') _toggleTheme();
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
                        Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                        const SizedBox(width: 8),
                        Text(
                          _isDarkMode ? 'Tema chiaro' : 'Tema scuro',
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
                        _isBedtimeMode
                            ? 'Modalità Sveglia'
                            : 'Modalità Dormire',
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
            ],
          ),
        ),
      ),
    );
  }
}
