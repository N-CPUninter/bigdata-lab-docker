<#
.SYNOPSIS
  Atalhos para a sandbox Big Data (Windows / PowerShell).
.EXAMPLE
  .\lab.ps1 up            # sobe a sandbox
  .\lab.ps1 aula 7        # prepara a aula 7 (liga só os serviços necessários)
  .\lab.ps1 shell         # abre um terminal como maria_dev dentro da sandbox
  .\lab.ps1 status
  .\lab.ps1 nosql         # sobe MongoDB + Cassandra (aulas 8c/8d)
  .\lab.ps1 down          # para tudo (dados ficam nos volumes)
  .\lab.ps1 reset         # apaga TUDO (volumes) e volta ao estado inicial
#>
param(
  [Parameter(Position = 0)] [string] $Command = "help",
  [Parameter(Position = 1, ValueFromRemainingArguments = $true)] [string[]] $Args
)
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot
if (-not (Test-Path ".env") -and (Test-Path ".env.example")) { Copy-Item ".env.example" ".env" }

function Invoke-Sandbox { param([string[]] $Cmd) docker compose exec sandbox lab @Cmd }

switch ($Command) {
  "up"     { docker compose up -d; Write-Host "Aguardando o Ambari..."; Invoke-Sandbox @("wait-ambari"); Invoke-Sandbox @("urls") }
  "down"   { docker compose --profile nosql down }
  "nosql"  { docker compose --profile nosql up -d mongo cassandra }
  "aula"   { Invoke-Sandbox (@("aula") + $Args) }
  "status" { Invoke-Sandbox @("status") }
  "stop-all" { Invoke-Sandbox @("stop-all") }
  "mem"    { Invoke-Sandbox (@("mem") + $Args) }
  "urls"   { Invoke-Sandbox @("urls") }
  "shell"  { docker compose exec -u maria_dev -w /home/maria_dev sandbox bash -l }
  "root"   { docker compose exec sandbox bash -l }
  "logs"   { docker compose logs -f sandbox }
  "build"  { docker compose build sandbox }
  "reset"  {
    $ok = Read-Host "Isto apaga HDFS, bancos e o home da maria_dev. Digite SIM para confirmar"
    if ($ok -eq "SIM") { docker compose --profile nosql down -v }
  }
  default  { Get-Help $PSCommandPath -Examples }
}
