# Script per rinominare gli APK generati da Flutter
$releaseApk = "build/app/outputs/flutter-apk/app-release.apk"
$debugApk = "build/app/outputs/flutter-apk/app-debug.apk"
$releaseTarget = "build/app/outputs/flutter-apk/sleeping.apk"
$debugTarget = "build/app/outputs/flutter-apk/sleeping-debug.apk"

if (Test-Path $releaseApk) {
    Rename-Item -Path $releaseApk -NewName "sleeping.apk" -Force
    Write-Host "APK release rinominato in sleeping.apk"
} else {
    Write-Host "APK release non trovato."
}

if (Test-Path $debugApk) {
    Rename-Item -Path $debugApk -NewName "sleeping-debug.apk" -Force
    Write-Host "APK debug rinominato in sleeping-debug.apk"
} else {
    Write-Host "APK debug non trovato."
} 