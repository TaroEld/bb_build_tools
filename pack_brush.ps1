$utilsPath = $PSScriptRoot
$bbrusherPath = Join-Path $utilsPath \modtools\bbrusher.exe

Set-Location $args[0]
$folderPath = Join-Path $args[0] "unpacked"

if (Test-Path -Path $folderPath)
{
  Foreach ($f in Get-ChildItem -Path '.\unpacked')
  {
    & $bbrusherPath pack "$f.brush" ".\unpacked\$f"  
    copy .\$f.brush .\brushes
  }
}


Set-Location $utilsPath
