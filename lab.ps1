<#
.SYNOPSIS
  Atalhos para a sandbox Big Data (Windows). Chame pelo lab.cmd, que evita o
  bloqueio de scripts .ps1 baixados da internet: .\lab.cmd up
.EXAMPLE
  .\lab.cmd up            # sobe a sandbox
  .\lab.cmd aula 7        # prepara a aula 7 (liga só os serviços necessários)
  .\lab.cmd shell         # abre um terminal como maria_dev dentro da sandbox
  .\lab.cmd status
  .\lab.cmd nosql         # sobe MongoDB + Cassandra (aulas 8c/8d)
  .\lab.cmd down          # para tudo (dados ficam nos volumes)
  .\lab.cmd reset         # apaga TUDO (volumes) e volta ao estado inicial
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
  "up"     {
    docker compose up -d
    Write-Host "Aguardando o Ambari responder (2 a 4 minutos na primeira vez)..."
    Invoke-Sandbox @("wait-ambari"); Invoke-Sandbox @("urls")
    Write-Host ""
    Write-Host "Ambari no ar. Proximo passo: .\lab.cmd aula <perfil>   (ex.: aula 10, aula trabalho, aula 7)"
    Write-Host "Espere a mensagem PRONTO desse comando antes de usar o terminal, o SSH ou os comandos das aulas."
  }
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
