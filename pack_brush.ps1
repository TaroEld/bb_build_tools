$utilsPath = $PSScriptRoot
$bbrusherPath = Join-Path $utilsPath \modtools\bbrusher.exe
$modPath = $args[0]
Set-Location $args[0]
$folderPath = Join-Path $modPath "unpacked"
$brushesPath = Join-Path $modPath "brushes"
$output = 0

if (Test-Path -Path $folderPath)
{
  Foreach ($f in Get-ChildItem -Path $folderPath)
  {
    $packResult = & $bbrusherPath pack "$f.brush" "$folderPath\$f"
    if ($LASTEXITCODE -eq 2)
    {
        Write-Output $packResult
        Write-Output "Failed to write brush $f.brush!"
        exit -2
    }
    if(!(Test-Path -Path $brushesPath))
    {
        mkdir $brushesPath
    }
    copy $modPath\$f.brush $brushesPath | out-null
    del $modPath\$f.brush
    Write-Output "Packed brush $f.brush"
    $output = 1
  }
}
$modFoldersPath = Join-Path $modPath ".."
if (Test-Path -Path $modFoldersPath/gfx)
{
  copy -r -force $modFoldersPath/gfx $modPath
  del -r $modFoldersPath/gfx
}
exit 1
