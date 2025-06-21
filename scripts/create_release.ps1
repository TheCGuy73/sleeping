# Script per creare una nuova release e aggiornare releases.json
param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$true)]
    [string]$BuildNumber,
    
    [Parameter(Mandatory=$true)]
    [string]$ReleaseNotes,
    
    [string]$MinRequiredVersion = "0.0.1-alpha1"
)

# Colori per output
$Green = "`e[32m"
$Yellow = "`e[33m"
$Red = "`e[31m"
$Reset = "`e[0m"

Write-Host "${Green}=== Creazione Release per Sleeping App ===$Reset" -ForegroundColor Green

# Verifica che il file APK esista
$apkPath = "build/app/outputs/flutter-apk/sleeping.apk"
if (-not (Test-Path $apkPath)) {
    Write-Host "${Red}ERRORE: File APK non trovato in $apkPath$Reset" -ForegroundColor Red
    Write-Host "${Yellow}Esegui prima: flutter build apk --release$Reset" -ForegroundColor Yellow
    exit 1
}

# Crea la cartella releases se non esiste
$releasesDir = "releases"
if (-not (Test-Path $releasesDir)) {
    New-Item -ItemType Directory -Path $releasesDir
    Write-Host "${Green}Creata cartella releases$Reset" -ForegroundColor Green
}

# Copia l'APK nella cartella releases
$releaseApkPath = "$releasesDir/sleeping-$Version.apk"
Copy-Item $apkPath $releaseApkPath
Write-Host "${Green}APK copiato in: $releaseApkPath$Reset" -ForegroundColor Green

# Crea o aggiorna releases.json
$releasesJsonPath = "releases.json"
$currentDate = Get-Date -Format "yyyy-MM-dd"
$downloadUrl = "https://github.com/TheCGuy73/sleeping/releases/download/v$Version/sleeping.apk"

# Se il file esiste, leggi il contenuto esistente
$releasesData = @{}
if (Test-Path $releasesJsonPath) {
    $releasesData = Get-Content $releasesJsonPath | ConvertFrom-Json
} else {
    # Crea struttura iniziale
    $releasesData = @{
        latest = @{}
        releases = @()
    }
}

# Crea la nuova release
$newRelease = @{
    version = $Version
    build_number = $BuildNumber
    download_url = $downloadUrl
    release_notes = $ReleaseNotes
    release_date = $currentDate
    min_required_version = $MinRequiredVersion
}

# Aggiorna latest
$releasesData.latest = $newRelease

# Aggiungi alla lista releases (se non esiste già)
$existingRelease = $releasesData.releases | Where-Object { $_.version -eq $Version }
if (-not $existingRelease) {
    $releasesData.releases = @($newRelease) + $releasesData.releases
} else {
    # Aggiorna la release esistente
    $existingIndex = [array]::IndexOf($releasesData.releases, $existingRelease)
    $releasesData.releases[$existingIndex] = $newRelease
}

# Salva il file JSON
$releasesData | ConvertTo-Json -Depth 10 | Set-Content $releasesJsonPath
Write-Host "${Green}File releases.json aggiornato$Reset" -ForegroundColor Green

# Mostra riepilogo
Write-Host "${Green}=== Riepilogo Release ===$Reset" -ForegroundColor Green
Write-Host "Versione: $Version" -ForegroundColor White
Write-Host "Build Number: $BuildNumber" -ForegroundColor White
Write-Host "Release Notes: $ReleaseNotes" -ForegroundColor White
Write-Host "Download URL: $downloadUrl" -ForegroundColor White
Write-Host "APK Path: $releaseApkPath" -ForegroundColor White
Write-Host "JSON Path: $releasesJsonPath" -ForegroundColor White

Write-Host "${Yellow}=== Prossimi Passi ===$Reset" -ForegroundColor Yellow
Write-Host "1. Commit e push di releases.json" -ForegroundColor White
Write-Host "2. Crea una release su GitHub con il file APK" -ForegroundColor White
Write-Host "3. Aggiorna la versione in pubspec.yaml" -ForegroundColor White

Write-Host "${Green}Release creata con successo!$Reset" -ForegroundColor Green 