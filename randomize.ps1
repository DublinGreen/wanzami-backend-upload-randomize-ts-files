# PowerShell script to randomize .ts filenames in an HLS playlist (output.m3u8)
# Equivalent to your Bash script, adapted for Windows

$Playlist = "output.m3u8"
$WorkDir = "."
$TempPlaylist = "temp_$Playlist"
$Backup = "$WorkDir\$Playlist.bak"

# Backup original playlist
Copy-Item "$WorkDir\$Playlist" $Backup -Force
Write-Host "📦 Backup created: $Backup"

# Create a hashtable for mapping old -> new filenames
$FileMap = @{}

# 1. Rename .ts files randomly
Get-ChildItem -Path $WorkDir -Filter "*.ts" | ForEach-Object {
    $OldName = $_.Name
    $RandomName = (New-Guid).Guid.Substring(0, 16) + ".ts"
    Rename-Item -Path $_.FullName -NewName $RandomName
    $FileMap[$OldName] = $RandomName
    Write-Host "Renamed $OldName -> $RandomName"
}

# 2. Rebuild playlist preserving #EXTINF and replacing filenames
$TempFile = Join-Path $WorkDir $TempPlaylist
Get-Content "$WorkDir\$Playlist" | ForEach-Object {
    $line = $_
    if ($line -match "\.ts$") {
        $OldName = Split-Path $line -Leaf
        if ($FileMap.ContainsKey($OldName)) {
            $FileMap[$OldName]
        } else {
            $line  # In case a .ts is referenced but not found
        }
    } else {
        $line
    }
} | Set-Content -Encoding UTF8 $TempFile

# 3. Replace old playlist with updated one
Move-Item -Force $TempFile "$WorkDir\$Playlist"

Write-Host "✅ Playlist updated, filenames randomized, and structure preserved!"
