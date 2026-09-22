# Instalação

## Windows 10/11

1. Ative a virtualização na BIOS/UEFI (Intel VT-x / AMD-V) se ainda não estiver.
2. Instale o WSL2: abra o PowerShell **como administrador** e rode `wsl --install`. Reinicie.
3. Instale o [Docker Desktop](https://www.docker.com/products/docker-desktop/) (marque "Use WSL 2 based engine").
4. Limite a memória do WSL2 (senão ele pode tentar usar metade da RAM e o Windows trava). Crie o arquivo `C:\Users\<seu usuário>\.wslconfig` com:
   ```ini
   [wsl2]
   memory=6GB
   swap=6GB
   processors=2
   ```
   Para 16 GB de RAM use `memory=10GB`. Depois rode `wsl --shutdown` e abra o Docker Desktop de novo.
5. Baixe este projeto (botão **Code > Download ZIP** no GitHub, ou `git clone`) e extraia em uma pasta **sem acentos e sem espaços** (ex.: `C:\bigdata-lab`).
6. No PowerShell, dentro da pasta: `.\lab.ps1 up`. Se o Windows bloquear o script: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

## macOS

1. Instale o Docker Desktop. Em Settings > Resources, dê pelo menos 6 GB de memória (10 GB se tiver 16 GB).
2. Mac com chip Apple: em Settings > General, marque **"Use Rosetta for x86_64/amd64 emulation"** (a imagem é x86_64).
3. `./lab.sh up`.

## Linux

1. Instale o Docker Engine e o plugin Compose (`docker compose version` deve funcionar) e adicione seu usuário ao grupo `docker`.
2. `./lab.sh up`.

## Primeira subida

- A imagem tem ~8 GB; o download depende da sua internet.
- Na primeira vez o Ambari leva 2–4 minutos para responder; `.\lab.ps1 up` espera por isso.
- Depois, `.\lab.ps1 aula <perfil>`; o Ambari mostra o progresso em "Background Operations".

## Atualizar

`docker compose pull` e depois `.\lab.ps1 up`. Os dados (HDFS, bancos, home da `maria_dev`) ficam em volumes e sobrevivem à atualização.
