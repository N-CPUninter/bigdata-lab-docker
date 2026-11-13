@echo off
rem Atalho da sandbox Big Data no Windows. Use sempre esta forma:
rem
rem     .\lab.cmd up
rem     .\lab.cmd aula 10
rem
rem Funciona igual no cmd.exe e no PowerShell. Ele apenas chama o lab.ps1,
rem que tem toda a logica, sem esbarrar na politica de execucao do PowerShell:
rem o Windows bloqueia scripts .ps1 baixados da internet, e e por isso que
rem chamar o .\lab.ps1 diretamente costuma falhar na primeira vez.
rem
rem %~dp0 e a pasta deste arquivo, entao funciona mesmo chamado de outra pasta.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0lab.ps1" %*
exit /b %ERRORLEVEL%
