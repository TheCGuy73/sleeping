# Guida Completa per Aggiornare l'Applicazione Sleeping

## 📋 Indice
1. [Prerequisiti](#prerequisiti)
2. [Preparazione dell'Ambiente](#preparazione-dellambiente)
3. [Processo di Aggiornamento](#processo-di-aggiornamento)
4. [Build dell'Applicazione](#build-dellapplicazione)
5. [Creazione della Release](#creazione-della-release)
6. [Pubblicazione su GitHub](#pubblicazione-su-github)
7. [Verifica dell'Aggiornamento](#verifica-dellaggiornamento)
8. [Troubleshooting](#troubleshooting)

---

## 🔧 Prerequisiti

### Software Richiesto
- **Flutter SDK** (versione 3.8.1 o superiore)
- **Dart SDK** (incluso con Flutter)
- **Android Studio** o **VS Code**
- **Git** per il controllo versione
- **PowerShell** (per gli script di automazione)

### Account e Repository
- **GitHub Account** con accesso al repository `TheCGuy73/sleeping`
- **Android Developer Account** (opzionale, per firma APK)

---

## 🛠️ Preparazione dell'Ambiente

### 1. Clona il Repository
```bash
git clone https://github.com/TheCGuy73/sleeping.git
cd sleeping
```

### 2. Installa le Dipendenze
```bash
flutter pub get
```

### 3. Verifica l'Ambiente Flutter
```bash
flutter doctor
```

### 4. Configura l'Emulatore o Dispositivo
```bash
# Lista dispositivi disponibili
flutter devices

# Avvia emulatore Android (se disponibile)
flutter emulators --launch <nome_emulatore>
```

---

## 🔄 Processo di Aggiornamento

### 1. Aggiorna la Versione

#### Modifica `pubspec.yaml`
```yaml
# Esempio di aggiornamento versione
version: 0.0.1-alpha7+4  # Incrementa versione e build number
```

**Formato Versione:**
- `0.0.1-alpha7` = Versione semantica (major.minor.patch-alpha)
- `+4` = Build number (incrementa ad ogni build)

#### Regole per l'Incremento:
- **Patch** (0.0.1 → 0.0.2): Bug fixes
- **Minor** (0.0.1 → 0.1.0): Nuove funzionalità
- **Major** (0.0.1 → 1.0.0): Breaking changes
- **Build Number**: Incrementa sempre

### 2. Testa le Modifiche
```bash
# Test unitari
flutter test

# Test di integrazione
flutter test integration_test/

# Test su dispositivo
flutter run --release
```

---

## 🏗️ Build dell'Applicazione

### 1. Build per Android (APK)
```bash
# Build di release
flutter build apk --release

# Build di debug (per test)
flutter build apk --debug
```

### 2. Verifica del File APK
Il file APK sarà creato in:
```
build/app/outputs/flutter-apk/sleeping.apk
```

### 3. Test dell'APK
```bash
# Installa su dispositivo connesso
flutter install --release

# Oppure installa manualmente
adb install build/app/outputs/flutter-apk/sleeping.apk
```

---

## 📦 Creazione della Release

### Metodo 1: Script Automatico (Raccomandato)

#### Usa lo Script di Creazione Release
```powershell
# Carica il modulo Release Manager
. .\scripts\release_manager.ps1

# Crea una nuova release
.\scripts\create_release.ps1 -ReleaseNotes "Descrizione delle modifiche" -UseReleaseManager
```

#### Parametri dello Script:
- `-Version`: Versione specifica (opzionale, legge da pubspec.yaml)
- `-BuildNumber`: Build number specifico (opzionale)
- `-ReleaseNotes`: Note di rilascio (obbligatorio)
- `-MinRequiredVersion`: Versione minima richiesta
- `-UseReleaseManager`: Usa il sistema avanzato

#### Esempio Completo:
```powershell
.\scripts\create_release.ps1 -ReleaseNotes "Miglioramenti al sistema di temi e correzioni bug" -UseReleaseManager
```

### Metodo 2: Manuale

#### 1. Copia l'APK
```bash
# Crea cartella releases se non esiste
mkdir releases

# Copia l'APK
cp build/app/outputs/flutter-apk/sleeping.apk releases/sleeping-0.0.1-alpha7.apk
```

#### 2. Aggiorna `releases.json`
```json
{
    "releases": [
        {
            "min_required_version": "0.0.1-alpha1",
            "version": "0.0.1-alpha7",
            "release_notes": "Miglioramenti al sistema di temi",
            "build_number": "4",
            "download_url": "https://github.com/TheCGuy73/sleeping/releases/download/v0.0.1-alpha7/sleeping.apk",
            "release_date": "2025-01-27"
        }
    ],
    "latest": {
        "min_required_version": "0.0.1-alpha1",
        "version": "0.0.1-alpha7",
        "release_notes": "Miglioramenti al sistema di temi",
        "build_number": "4",
        "download_url": "https://github.com/TheCGuy73/sleeping/releases/download/v0.0.1-alpha7/sleeping.apk",
        "release_date": "2025-01-27"
    }
}
```

---

## 🚀 Pubblicazione su GitHub

### 1. Commit delle Modifiche
```bash
# Aggiungi tutti i file modificati
git add .

# Commit con messaggio descrittivo
git commit -m "Release v0.0.1-alpha7: Miglioramenti al sistema di temi"

# Push su GitHub
git push origin main
```

### 2. Crea Release su GitHub

#### Metodo Web:
1. Vai su [GitHub Releases](https://github.com/TheCGuy73/sleeping/releases)
2. Clicca "Create a new release"
3. Tag: `v0.0.1-alpha7`
4. Title: `Sleeping v0.0.1-alpha7`
5. Description: Note di rilascio
6. Upload: `releases/sleeping-0.0.1-alpha7.apk`

#### Metodo CLI (GitHub CLI):
```bash
# Installa GitHub CLI se non presente
# https://cli.github.com/

# Crea release
gh release create v0.0.1-alpha7 releases/sleeping-0.0.1-alpha7.apk --title "Sleeping v0.0.1-alpha7" --notes "Miglioramenti al sistema di temi"
```

### 3. Verifica la Release
- Controlla che l'APK sia scaricabile
- Verifica che `releases.json` sia aggiornato
- Testa il download dell'APK

---

## ✅ Verifica dell'Aggiornamento

### 1. Test dell'App Aggiornata
```bash
# Installa la nuova versione
flutter install --release

# Avvia l'app
flutter run --release
```

### 2. Verifica del Sistema di Aggiornamento
1. Apri l'app
2. Vai su Menu → Controlla aggiornamenti
3. Verifica che mostri la nuova versione
4. Testa il download dell'APK

### 3. Test su Dispositivi Diversi
- **Android**: Diverse versioni API
- **Emulatori**: Test su emulatori diversi
- **Dispositivi fisici**: Test su dispositivi reali

---

## 🔧 Strumenti di Gestione Release

### Release Manager (PowerShell)
```powershell
# Carica il modulo
. .\scripts\release_manager.ps1

# Comandi disponibili
Get-Releases                    # Lista tutte le release
Show-ReleaseInfo "0.0.1-alpha7" # Info su release specifica
Add-Release -Version "0.0.1-alpha8" -BuildNumber "5" -ReleaseNotes "Nuove funzionalità"
Backup-ReleasesJson             # Crea backup
Test-ReleasesJson               # Valida struttura JSON
Show-ReleaseManagerHelp         # Mostra aiuto
```

### Funzionalità Avanzate
- **Backup automatici** delle release
- **Validazione JSON** per evitare errori
- **Gestione versioni** semantica
- **Rollback** delle release

---

## 🐛 Troubleshooting

### Problemi Comuni

#### 1. Build Fallisce
```bash
# Pulisci cache
flutter clean
flutter pub get

# Verifica dipendenze
flutter doctor
```

#### 2. APK Non Trovato
```bash
# Verifica percorso
ls build/app/outputs/flutter-apk/

# Ricostruisci
flutter build apk --release
```

#### 3. Errore di Firma APK
```bash
# Usa debug signing per test
# Per produzione, configura keystore
flutter build apk --release --split-per-abi
```

#### 4. Problemi di Network
```bash
# Verifica connessione GitHub
curl https://raw.githubusercontent.com/TheCGuy73/sleeping/master/releases.json

# Test download APK
curl -I https://github.com/TheCGuy73/sleeping/releases/download/v0.0.1-alpha7/sleeping.apk
```

### Log di Debug
```bash
# Abilita log dettagliati
flutter run --verbose

# Log specifici per build
flutter build apk --verbose
```

---

## 📚 Risorse Utili

### Documentazione
- [Flutter Build Guide](https://docs.flutter.dev/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [GitHub Releases API](https://docs.github.com/en/rest/releases)

### Comandi Utili
```bash
# Informazioni versione
flutter --version
dart --version

# Stato repository
git status
git log --oneline -5

# Dipendenze
flutter pub deps
flutter pub outdated
```

---

## 🎯 Checklist Finale

Prima di pubblicare una release, verifica:

- [ ] Versione aggiornata in `pubspec.yaml`
- [ ] Build number incrementato
- [ ] Test passati (`flutter test`)
- [ ] APK buildato correttamente
- [ ] APK testato su dispositivo
- [ ] `releases.json` aggiornato
- [ ] Release creata su GitHub
- [ ] APK caricato su GitHub
- [ ] Download APK testato
- [ ] Sistema aggiornamento testato

---

## 📞 Supporto

Per problemi o domande:
1. Controlla i log di errore
2. Verifica la documentazione Flutter
3. Crea issue su GitHub
4. Contatta il team di sviluppo

---

*Ultimo aggiornamento: Gennaio 2025* 