# Instalação

## Windows 10/11

1. Confira no Gerenciador de Tarefas (aba Desempenho > CPU) se "Virtualização" está habilitada. Se não, ative na BIOS/UEFI: [Habilitar a virtualização no Windows](https://support.microsoft.com/pt-br/windows/habilitar-a-virtualiza%C3%A7%C3%A3o-no-windows-c5578302-6e43-4b4b-a449-8ced115f58e1).
2. Instale o WSL2: abra o PowerShell **como administrador** e rode `wsl --install`. Reinicie. Guia oficial: [Instalar o WSL](https://learn.microsoft.com/pt-br/windows/wsl/install).
3. Instale o [Docker Desktop para Windows](https://docs.docker.com/desktop/setup/install/windows-install/) (marque "Use WSL 2 instead of Hyper-V"). Não é necessário criar conta.
4. Limite a memória do WSL2 (senão ele pode tentar usar metade da RAM e o Windows trava). Crie o arquivo `C:\Users\<seu usuário>\.wslconfig` com:
   ```ini
   [wsl2]
   memory=6GB
   swap=6GB
   processors=2
   ```
   Para 16 GB de RAM use `memory=10GB`. Salve com "Tipo: Todos os arquivos" para não virar `.wslconfig.txt`. Depois rode `wsl --shutdown` e abra o Docker Desktop de novo. Referência: [Configurações do WSL](https://learn.microsoft.com/pt-br/windows/wsl/wsl-config).
5. Baixe o ZIP do projeto (plataforma da disciplina, ou **Code > Download ZIP** no GitHub) e extraia (botão direito > Extrair Tudo) em uma pasta **sem acentos e sem espaços** (ex.: `C:\bigdata-lab`).
6. Abra a pasta no Explorador, digite `powershell` na barra de endereço e Enter; então `.\lab.ps1 up`. Se o Windows bloquear o script: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

## macOS

1. Instale o [Docker Desktop para Mac](https://docs.docker.com/desktop/setup/install/mac-install/). Em Settings > Resources, dê pelo menos 6 GB de memória (10 GB se tiver 16 GB).
2. Mac com chip Apple: em Settings > General, marque **"Use Rosetta for x86_64/amd64 emulation"** (a imagem é x86_64). Detalhes: [Docker no Apple Silicon](https://docs.docker.com/desktop/setup/install/mac-install/#mac-with-apple-silicon).
3. `./lab.sh up`.

## Linux

1. Instale o Docker Engine e o plugin Compose pelo guia da sua distribuição ([Install Docker Engine](https://docs.docker.com/engine/install/)); `docker compose version` deve funcionar. Adicione seu usuário ao grupo `docker` ([post-installation](https://docs.docker.com/engine/install/linux-postinstall/)).
2. `./lab.sh up`.

## Primeira subida

- A imagem tem ~8 GB; o download depende da sua internet.
- Na primeira vez o Ambari leva 2–4 minutos para responder; `.\lab.ps1 up` espera por isso.
- Depois, `.\lab.ps1 aula <perfil>`; o Ambari mostra o progresso em "Background Operations".

## Atualizar

`docker compose pull` e depois `.\lab.ps1 up`. Os dados (HDFS, bancos, home da `maria_dev`) ficam em volumes e sobrevivem à atualização.
