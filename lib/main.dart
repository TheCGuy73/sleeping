import 'package:flutter/material.dart'; // Importa i widget e le funzionalità di Material Design
import 'package:google_fonts/google_fonts.dart'; // Necessario se GoogleFonts è usato nel tema principale
import 'package:file_picker/file_picker.dart'; // Anche se usato in SleepingUi, è una buona prassi importarlo qui se la logica di inizializzazione lo richiede o per chiarezza.

import 'package:sleeping/sleeping_files/sleeping_ui.dart'; // Sostituisci 'flutter_app_name' con il nome reale del tuo progetto
import 'package:sleeping/sleeping_files/sleeping_engine.dart';

/// File: lib/main.dart

// Importa la tua UI principale
/// La funzione principale che avvia l'applicazione Flutter.
void main() {
  runApp(const MyApp());
}

/// Il widget radice della tua applicazione.
/// Contiene la configurazione del tema e imposta SleepingUi come schermata iniziale.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Calculator', // Titolo dell'applicazione
      debugShowCheckedModeBanner: true, // Nasconde il banner di debug
      theme: ThemeData(
        primarySwatch: Colors.blueGrey, // Colore primario per l'applicazione
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Applica un tema di testo globale usando Google Fonts
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
      ),
      // Imposta SleepingUi come la schermata iniziale dell'applicazione
      home: const SleepingUi(),
    );
  }
}
