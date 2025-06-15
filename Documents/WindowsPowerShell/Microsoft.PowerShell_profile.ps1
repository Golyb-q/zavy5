Set-Alias open explorer
Set-Alias make mingw32-make

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

function tomp3 {
    param (
        [string]$inputFile
    )
    if (-not $inputFile) {
        Write-Output "Использование: tomp3 <путь к файлу>"
        return
    }
    $outputFile = [System.IO.Path]::ChangeExtension($inputFile, ".mp3")
    $outputFile = Get-UniqueFilename $outputFile
    ffmpeg -i "$inputFile" -b:a 320k "$outputFile"
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
