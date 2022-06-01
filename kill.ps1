$bb = Get-Process BattleBrothers -ErrorAction SilentlyContinue
if ($bb) {
  $bb | Stop-Process -Force
}
