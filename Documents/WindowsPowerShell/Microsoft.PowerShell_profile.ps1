Set-Alias make mingw32-make
Set-Alias open explorer

function torproxy {
    param (
        [ValidateSet("on", "off")]
        [string]$action
    )

    switch ($action) {
        "on" {
            $env:ALL_PROXY = "socks5h://127.0.0.1:9150"
            Write-Host "Tor proxy on"
        }
        "off" {
            Remove-Item Env:ALL_PROXY -ErrorAction SilentlyContinue
            Write-Host "Tor proxy off"
        }
        default {
            Write-Host "Использование: torproxy on|off"
        }
    }
}

function Get-UniqueFilename {
    param (
        [string]$filepath
    )
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($filepath)
    $extension = [System.IO.Path]::GetExtension($filepath)
    $directory = [System.IO.Path]::GetDirectoryName($filepath)
    
    $i = 1
    $uniqueFilepath = $filepath
    while (Test-Path $uniqueFilepath) {
        $uniqueFilepath = [System.IO.Path]::Combine($directory, "$baseName($i)$extension")
        $i++
    }
    return $uniqueFilepath
}

function toflac {
    param (
        [string]$inputFile,
        [string]$coverImage = $null
    )
    if (-not (Test-Path $inputFile)) {
        Write-Host "Использование: toflac <путь к аудиофайлу> [-cover <путь к обложке>]. Конвертер в FLAC"
        return
    }

    $outputFile = [System.IO.Path]::ChangeExtension($inputFile, ".flac")
    $outputFile = Get-UniqueFilename $outputFile

    if ($coverImage -and (Test-Path $coverImage)) {
        ffmpeg -i "$inputFile" -i "$coverImage" -compression_level 12 -map 0 -map 1 `
               -c:a flac -disposition:v:0 attached_pic "$outputFile"
    }
    else {
        ffmpeg -i "$inputFile" -compression_level 12 -c:a flac "$outputFile"
    }
}
function tomp3 {
    param (
        [string]$inputFile,
        [string]$coverImage = $null
    )
    if (-not (Test-Path $inputFile)) {
        Write-Output "Использование: tomp3 <путь к файлу> [-cover <путь к обложке>]"
        return
    }

    $outputFile = [System.IO.Path]::ChangeExtension($inputFile, ".mp3")
    $outputFile = Get-UniqueFilename $outputFile

    if ($coverImage -and (Test-Path $coverImage)) {
        ffmpeg -i "$inputFile" -i "$coverImage" -map 0 -map 1 -c:a libmp3lame -b:a 320k `
               -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" `
               "$outputFile"
    }
    else {
        ffmpeg -i "$inputFile" -b:a 320k "$outputFile"
    }
}

function tomp4 {
    param (
        [string]$inputFile
    )
    if (-not (Test-Path $inputFile)) {
        Write-Host "Использование: tomp4 <путь к файлу>. Конвертер в mp4"
        return
    }
    $outputFile = [System.IO.Path]::ChangeExtension($inputFile, "(compress).mp4")
    $outputFile = Get-UniqueFilename $outputFile
    ffmpeg -i $inputFile -vcodec libx264 -crf 23 -preset slower -c:a copy $outputFile
}
