param(
  [Parameter(Mandatory = $true)]
  [string]$TomlTest,
  [string]$Decoder,
  [string]$Encoder
)

$ErrorActionPreference = 'Stop'
if (-not $Decoder) {
  $Decoder = Join-Path $PSScriptRoot 'TOMLTestDecoder.exe'
}
if (-not $Encoder) {
  $Encoder = Join-Path $PSScriptRoot 'TOMLTestEncoder.exe'
}
$knownFailures = Get-Content "$PSScriptRoot\known-failures.txt" |
  Where-Object { $_ -and -not $_.StartsWith('#') }
$skipArguments = $knownFailures | ForEach-Object { "-skip=$_" }

& $TomlTest test -toml 1.1 -skip-must-err @skipArguments `
  -decoder $Decoder -encoder $Encoder -color never
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
