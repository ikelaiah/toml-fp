param(
  [Parameter(Mandatory = $true)]
  [string]$TomlTest,
  [string]$Decoder
)

$ErrorActionPreference = 'Stop'
if (-not $Decoder) {
  $Decoder = Join-Path $PSScriptRoot 'TOMLTestDecoder.exe'
}
$knownFailures = Get-Content "$PSScriptRoot\known-failures.txt" |
  Where-Object { $_ -and -not $_.StartsWith('#') }
$skipArguments = $knownFailures | ForEach-Object { "-skip=$_" }

& $TomlTest test -toml 1.0 -skip-must-err @skipArguments -decoder $Decoder -color never
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
