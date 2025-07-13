# $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# $PROFILE

if ($env:DOT_HOME) {
  $dotfilesProfile = Join-Path $env:DOT_HOME ".win/Microsoft.PowerShell_profile.ps1"
  if (Test-Path $dotfilesProfile) {
    . $dotfilesProfile
  }
}
