# $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# $PROFILE

$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
[System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

Invoke-Expression (&starship init powershell)

if (Get-Command lazygit -ErrorAction SilentlyContinue) {
  Set-Alias -Name lg -Value lazygit
  # Write-Host "Alias 'lg' for 'lazygit' created."
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
  function n {
    nvim ./
  }
  # Write-Host "Function 'n' for 'nvim ./' created."
}

# Load secret profile if it exists
if ($env:DOT_HOME) {
  # Write-Host "Loading secret profile from: $secretProfile"
  $dotfilesProfile = Join-Path $env:DOT_HOME ".secret/Microsoft.PowerShell_profile.ps1"
  if (Test-Path $dotfilesProfile) {
    . $secretProfile
  }
}
