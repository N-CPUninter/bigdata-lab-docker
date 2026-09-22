<#
.SYNOPSIS
  Publica a imagem da sandbox para os alunos (professor).
.DESCRIPTION
  Duas formas, escolha pelo parâmetro -Mode:
    registry : marca a imagem local como <Registry>:<Version> e <Registry>:latest e faz push.
               Requer login prévio: `docker login ghcr.io` (token do GitHub com escopo write:packages)
               ou `docker login` (Docker Hub).
    save     : gera um arquivo .tar.gz (~7 GB) para distribuir por drive/pendrive; o aluno carrega com
               `docker load -i bigdata-sandbox-<versão>.tar.gz`.
.EXAMPLE
  .\publish.ps1 -Mode registry -Version 1.0.1 -Registry ghcr.io/n-cpuninter/bigdata-sandbox
  .\publish.ps1 -Mode save -Version 1.0.1
#>
param(
  [ValidateSet("registry", "save")] [string] $Mode = "registry",
  [string] $Version = "1.0.1",
  [string] $Registry = "ghcr.io/n-cpuninter/bigdata-sandbox",
  [string] $LocalImage = "bigdata-sandbox"
)
$ErrorActionPreference = "Stop"
$src = "${LocalImage}:${Version}"
docker image inspect $src *> $null
if ($LASTEXITCODE -ne 0) { throw "Imagem local $src não existe. Construa com .\lab.ps1 build (ou docker build -t $src ...)." }

switch ($Mode) {
  "registry" {
    docker tag $src "${Registry}:${Version}"
    docker tag $src "${Registry}:latest"
    docker push "${Registry}:${Version}"
    docker push "${Registry}:latest"
    Write-Host "Publicado: ${Registry}:${Version} e :latest"
    Write-Host "No .env.example dos alunos: IMAGE=$Registry  TAG=$Version"
  }
  "save" {
    $out = "bigdata-sandbox-${Version}.tar.gz"
    Write-Host "Gerando $out (leva vários minutos)..."
    docker save $src | & gzip -1 > $out
    Get-Item $out | Select-Object Name, @{n='GB';e={[math]::Round($_.Length/1GB,2)}}
    Write-Host "Aluno: docker load -i $out   (depois ajuste IMAGE=$LocalImage e TAG=$Version no .env)"
  }
}
