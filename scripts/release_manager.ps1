# Modulo per la gestione avanzata delle release
# . .\scripts\release_manager.ps1

# Colori per output
$Green = "`e[32m"
$Yellow = "`e[33m"
$Red = "`e[31m"
$Blue = "`e[34m"
$Reset = "`e[0m"

# Configurazione
$Config = @{
    RepositoryName = "TheCGuy73/sleeping"
    RepositoryUrl = "https://github.com/TheCGuy73/sleeping"
    ReleasesDir = "releases"
    ReleasesJsonPath = "releases.json"
    BackupDir = "backups"
    MaxBackups = 5
}

# Funzione per creare backup del releases.json
function Backup-ReleasesJson {
    param([string]$BackupName = "auto")
    
    if (Test-Path $Config.ReleasesJsonPath) {
        $backupDir = $Config.BackupDir
        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir | Out-Null
        }
        
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = "$backupDir/releases_${BackupName}_${timestamp}.json"
        Copy-Item $Config.ReleasesJsonPath $backupPath
        
        Write-Host "${Blue}Backup creato: $backupPath$Reset" -ForegroundColor Blue
        
        # Mantieni solo gli ultimi MaxBackups
        $backups = Get-ChildItem "$backupDir/releases_*.json" | Sort-Object LastWriteTime -Descending
        if ($backups.Count -gt $Config.MaxBackups) {
            $oldBackups = $backups | Select-Object -Skip $Config.MaxBackups
            foreach ($backup in $oldBackups) {
                Remove-Item $backup.FullName
                Write-Host "${Yellow}Rimosso backup vecchio: $($backup.Name)$Reset" -ForegroundColor Yellow
            }
        }
    }
}

# Funzione per validare la struttura del releases.json
function Test-ReleasesJson {
    param([string]$JsonPath = $Config.ReleasesJsonPath)
    
    if (-not (Test-Path $JsonPath)) {
        Write-Host "${Red}File releases.json non trovato$Reset" -ForegroundColor Red
        return $false
    }
    
    try {
        $content = Get-Content $JsonPath -Raw
        $data = $content | ConvertFrom-Json
        
        # Verifica struttura
        $requiredFields = @('latest', 'releases')
        foreach ($field in $requiredFields) {
            if (-not $data.PSObject.Properties.Name.Contains($field)) {
                Write-Host "${Red}Campo mancante: $field$Reset" -ForegroundColor Red
                return $false
            }
        }
        
        # Verifica latest
        $latestFields = @('version', 'build_number', 'download_url', 'release_notes', 'release_date')
        foreach ($field in $latestFields) {
            if (-not $data.latest.PSObject.Properties.Name.Contains($field)) {
                Write-Host "${Red}Campo mancante in latest: $field$Reset" -ForegroundColor Red
                return $false
            }
        }
        
        Write-Host "${Green}Struttura releases.json valida$Reset" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "${Red}Errore nella validazione JSON: $($_.Exception.Message)$Reset" -ForegroundColor Red
        return $false
    }
}

# Funzione per aggiungere una nuova release
function Add-Release {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Version,
        
        [Parameter(Mandatory=$true)]
        [string]$BuildNumber,
        
        [Parameter(Mandatory=$true)]
        [string]$ReleaseNotes,
        
        [string]$MinRequiredVersion = "0.0.1-alpha1",
        
        [switch]$Force
    )
    
    Write-Host "${Green}=== Aggiunta Release ===$Reset" -ForegroundColor Green
    
    # Backup prima delle modifiche
    Backup-ReleasesJson "before_add"
    
    # Carica releases.json esistente
    $releasesData = @{}
    if (Test-Path $Config.ReleasesJsonPath) {
        $releasesData = Get-Content $Config.ReleasesJsonPath | ConvertFrom-Json
    } else {
        $releasesData = @{
            latest = @{}
            releases = @()
        }
    }
    
    # Verifica se la versione esiste già
    $existingRelease = $releasesData.releases | Where-Object { $_.version -eq $Version }
    if ($existingRelease -and -not $Force) {
        Write-Host "${Yellow}ATTENZIONE: La versione $Version esiste già$Reset" -ForegroundColor Yellow
        $response = Read-Host "Vuoi sovrascriverla? (y/N)"
        if ($response -ne "y" -and $response -ne "Y") {
            Write-Host "${Red}Operazione annullata$Reset" -ForegroundColor Red
            return
        }
    }
    
    # Crea la nuova release
    $currentDate = Get-Date -Format "yyyy-MM-dd"
    $downloadUrl = "https://github.com/$($Config.RepositoryName)/releases/download/v$Version/sleeping.apk"
    
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
    
    # Gestisci la lista releases
    if ($existingRelease) {
        # Aggiorna release esistente
        $existingIndex = [array]::IndexOf($releasesData.releases, $existingRelease)
        $releasesData.releases[$existingIndex] = $newRelease
        Write-Host "${Yellow}Release esistente aggiornata$Reset" -ForegroundColor Yellow
    } else {
        # Aggiungi nuova release in cima
        $releasesData.releases = @($newRelease) + $releasesData.releases
        Write-Host "${Green}Nuova release aggiunta$Reset" -ForegroundColor Green
    }
    
    # Salva il file
    $releasesData | ConvertTo-Json -Depth 10 | Set-Content $Config.ReleasesJsonPath
    
    # Valida il risultato
    if (Test-ReleasesJson) {
        Write-Host "${Green}Release aggiunta con successo!$Reset" -ForegroundColor Green
        Show-ReleaseInfo $Version
    } else {
        Write-Host "${Red}Errore nella validazione$Reset" -ForegroundColor Red
    }
}

# Funzione per mostrare informazioni su una release
function Show-ReleaseInfo {
    param([string]$Version = "latest")
    
    if (-not (Test-Path $Config.ReleasesJsonPath)) {
        Write-Host "${Red}File releases.json non trovato$Reset" -ForegroundColor Red
        return
    }
    
    $data = Get-Content $Config.ReleasesJsonPath | ConvertFrom-Json
    
    if ($Version -eq "latest") {
        $release = $data.latest
    } else {
        $release = $data.releases | Where-Object { $_.version -eq $Version } | Select-Object -First 1
    }
    
    if ($release) {
        Write-Host "${Blue}=== Informazioni Release ===$Reset" -ForegroundColor Blue
        Write-Host "Versione: $($release.version)" -ForegroundColor White
        Write-Host "Build: $($release.build_number)" -ForegroundColor White
        Write-Host "Data: $($release.release_date)" -ForegroundColor White
        Write-Host "Note: $($release.release_notes)" -ForegroundColor White
        Write-Host "Download: $($release.download_url)" -ForegroundColor White
    } else {
        Write-Host "${Red}Release non trovata: $Version$Reset" -ForegroundColor Red
    }
}

# Funzione per listare tutte le release
function Get-Releases {
    if (-not (Test-Path $Config.ReleasesJsonPath)) {
        Write-Host "${Red}File releases.json non trovato$Reset" -ForegroundColor Red
        return
    }
    
    $data = Get-Content $Config.ReleasesJsonPath | ConvertFrom-Json
    
    Write-Host "${Blue}=== Lista Release ===$Reset" -ForegroundColor Blue
    Write-Host "Latest: $($data.latest.version) (Build $($data.latest.build_number))" -ForegroundColor Green
    
    Write-Host "`nTutte le release:" -ForegroundColor Yellow
    foreach ($release in $data.releases) {
        $isLatest = if ($release.version -eq $data.latest.version) { " *" } else { "" }
        Write-Host "  $($release.version) (Build $($release.build_number)) - $($release.release_date)$isLatest" -ForegroundColor White
    }
}

# Funzione per rimuovere una release
function Remove-Release {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Version
    )
    
    Write-Host "${Yellow}=== Rimozione Release ===$Reset" -ForegroundColor Yellow
    
    # Backup prima delle modifiche
    Backup-ReleasesJson "before_remove"
    
    if (-not (Test-Path $Config.ReleasesJsonPath)) {
        Write-Host "${Red}File releases.json non trovato$Reset" -ForegroundColor Red
        return
    }
    
    $data = Get-Content $Config.ReleasesJsonPath | ConvertFrom-Json
    
    # Trova la release
    $release = $data.releases | Where-Object { $_.version -eq $Version } | Select-Object -First 1
    
    if (-not $release) {
        Write-Host "${Red}Release non trovata: $Version$Reset" -ForegroundColor Red
        return
    }
    
    # Conferma rimozione
    Write-Host "${Yellow}Stai per rimuovere la release:$Reset" -ForegroundColor Yellow
    Show-ReleaseInfo $Version
    $response = Read-Host "Confermi? (y/N)"
    
    if ($response -eq "y" -or $response -eq "Y") {
        # Rimuovi dalla lista
        $data.releases = $data.releases | Where-Object { $_.version -ne $Version }
        
        # Se era la latest, aggiorna
        if ($data.latest.version -eq $Version) {
            if ($data.releases.Count -gt 0) {
                $data.latest = $data.releases[0]
                Write-Host "${Yellow}Latest aggiornata a: $($data.latest.version)$Reset" -ForegroundColor Yellow
            } else {
                Write-Host "${Red}Nessuna release rimanente!$Reset" -ForegroundColor Red
                return
            }
        }
        
        # Salva
        $data | ConvertTo-Json -Depth 10 | Set-Content $Config.ReleasesJsonPath
        Write-Host "${Green}Release rimossa con successo!$Reset" -ForegroundColor Green
    } else {
        Write-Host "${Yellow}Operazione annullata$Reset" -ForegroundColor Yellow
    }
}

# Funzione per esportare releases.json
function Export-Releases {
    param(
        [string]$OutputPath = "releases_export.json"
    )
    
    if (Test-Path $Config.ReleasesJsonPath) {
        Copy-Item $Config.ReleasesJsonPath $OutputPath
        Write-Host "${Green}Export completato: $OutputPath$Reset" -ForegroundColor Green
    } else {
        Write-Host "${Red}File releases.json non trovato$Reset" -ForegroundColor Red
    }
}

# Funzione per importare releases.json
function Import-Releases {
    param(
        [Parameter(Mandatory=$true)]
        [string]$InputPath
    )
    
    if (-not (Test-Path $InputPath)) {
        Write-Host "${Red}File di import non trovato: $InputPath$Reset" -ForegroundColor Red
        return
    }
    
    # Backup prima dell'import
    Backup-ReleasesJson "before_import"
    
    # Valida il file di import
    try {
        $importData = Get-Content $InputPath | ConvertFrom-Json
        if (Test-ReleasesJson -JsonPath $InputPath) {
            Copy-Item $InputPath $Config.ReleasesJsonPath
            Write-Host "${Green}Import completato!$Reset" -ForegroundColor Green
            Get-Releases
        }
    }
    catch {
        Write-Host "${Red}Errore nell'import: $($_.Exception.Message)$Reset" -ForegroundColor Red
    }
}

# Funzione per mostrare l'aiuto
function Show-ReleaseManagerHelp {
    Write-Host "${Blue}=== Release Manager - Guida ===$Reset" -ForegroundColor Blue
    Write-Host ""
    Write-Host "${Yellow}Comandi disponibili:$Reset" -ForegroundColor Yellow
    Write-Host "  Add-Release -Version 'x.x.x' -BuildNumber 'n' -ReleaseNotes 'descrizione'" -ForegroundColor White
    Write-Host "  Show-ReleaseInfo -Version 'x.x.x'" -ForegroundColor White
    Write-Host "  Get-Releases" -ForegroundColor White
    Write-Host "  Remove-Release -Version 'x.x.x'" -ForegroundColor White
    Write-Host "  Backup-ReleasesJson" -ForegroundColor White
    Write-Host "  Test-ReleasesJson" -ForegroundColor White
    Write-Host "  Export-Releases -OutputPath 'file.json'" -ForegroundColor White
    Write-Host "  Import-Releases -InputPath 'file.json'" -ForegroundColor White
    Write-Host "  Show-ReleaseManagerHelp" -ForegroundColor White
    Write-Host ""
    Write-Host "${Yellow}Esempi:$Reset" -ForegroundColor Yellow
    Write-Host "  Add-Release -Version '0.0.1-alpha7' -BuildNumber '2' -ReleaseNotes 'Nuove funzionalità'" -ForegroundColor White
    Write-Host "  Show-ReleaseInfo -Version '0.0.1-alpha6'" -ForegroundColor White
    Write-Host "  Get-Releases" -ForegroundColor White
}

# Inizializzazione
Write-Host "${Green}Release Manager caricato!$Reset" -ForegroundColor Green
Write-Host "Usa Show-ReleaseManagerHelp per vedere i comandi disponibili" -ForegroundColor Yellow 