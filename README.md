# Sistema di Gestione Release - Sleeping App

Questo sistema fornisce strumenti avanzati per gestire le release dell'app Sleeping.

## File Principali

### `create_release.ps1`
Script principale per creare una nuova release. Supporta due modalità:
- **Standard**: Metodo originale semplice
- **Release Manager**: Modalità avanzata con backup e validazione

### `release_manager.ps1`
Modulo PowerShell avanzato per la gestione completa delle release.

## Utilizzo

### 1. Creazione Release Standard
```powershell
.\scripts\create_release.ps1 -ReleaseNotes "Nuove funzionalità"
```

### 2. Creazione Release con Release Manager
```powershell
.\scripts\create_release.ps1 -ReleaseNotes "Nuove funzionalità" -UseReleaseManager
```

### 3. Gestione Avanzata delle Release

Carica il modulo:
```powershell
. .\scripts\release_manager.ps1
```

#### Comandi Disponibili

**Aggiungere una release:**
```powershell
Add-Release -Version "0.0.1-alpha7" -BuildNumber "2" -ReleaseNotes "Nuove funzionalità"
```

**Visualizzare informazioni:**
```powershell
Show-ReleaseInfo -Version "0.0.1-alpha6"
Show-ReleaseInfo  # Mostra la latest
```

**Listare tutte le release:**
```powershell
Get-Releases
```

**Rimuovere una release:**
```powershell
Remove-Release -Version "0.0.1-alpha6"
```

**Backup e validazione:**
```powershell
Backup-ReleasesJson
Test-ReleasesJson
```

**Import/Export:**
```powershell
Export-Releases -OutputPath "backup.json"
Import-Releases -InputPath "backup.json"
```

**Aiuto:**
```powershell
Show-ReleaseManagerHelp
```

## Funzionalità del Release Manager

### 🔄 Backup Automatico
- Crea backup prima di ogni modifica
- Mantiene solo gli ultimi 5 backup
- Timestamp automatico per ogni backup

### ✅ Validazione
- Verifica struttura JSON
- Controlla campi obbligatori
- Gestione errori robusta

### 📋 Gestione Release
- Aggiunta con conferma per versioni duplicate
- Aggiornamento automatico della "latest"
- Rimozione sicura con conferma

### 📊 Informazioni Dettagliate
- Visualizzazione completa delle release
- Storico ordinato cronologicamente
- Informazioni dettagliate per ogni versione

## Workflow Completo

1. **Sviluppo** - Lavora sul codice
2. **Aggiorna versione** in `pubspec.yaml`
3. **Build APK** - `flutter build apk --release`
4. **Crea release** - `.\scripts\create_release.ps1 -ReleaseNotes "..." -UseReleaseManager`
5. **Commit e push** - `git add . && git commit -m "..." && git push`
6. **GitHub Release** - Crea release su GitHub con l'APK
7. **Verifica** - L'app controlla automaticamente gli aggiornamenti

## Struttura releases.json

```json
{
  "latest": {
    "version": "0.0.1-alpha6",
    "build_number": "1",
    "download_url": "https://github.com/TheCGuy73/sleeping/releases/download/v0.0.1-alpha6/sleeping.apk",
    "release_notes": "Descrizione della release",
    "release_date": "2024-01-15",
    "min_required_version": "0.0.1-alpha1"
  },
  "releases": [
    // Lista di tutte le release ordinate per data
  ]
}
```

## Vantaggi del Release Manager

- **Sicurezza**: Backup automatici prima di ogni modifica
- **Validazione**: Controlli di integrità sui dati
- **Flessibilità**: Gestione completa delle release
- **Tracciabilità**: Storico completo delle modifiche
- **Facilità d'uso**: Comandi intuitivi e ben documentati

## Troubleshooting

### Errore "File APK non trovato"
Esegui prima: `flutter build apk --release`

### Errore "Release Manager non trovato"
Verifica che il file `scripts/release_manager.ps1` esista

### Errore di validazione JSON
Usa `Test-ReleasesJson` per diagnosticare il problema

### Backup non creati
Verifica i permessi di scrittura nella cartella `backups/` 