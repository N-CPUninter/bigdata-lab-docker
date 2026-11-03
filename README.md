# Sandbox Big Data — UNINTER (substituto da VM HDP 2.6.5)

Ambiente Hadoop completo em **um container Docker**, para as aulas práticas 7–12 e a Atividade Prática da disciplina de Big Data. Mantém o que os vídeos mostram (Ambari, `maria_dev`, `sandbox.hortonworks.com`, portas 8080/4200/2222) usando componentes atuais e mantidos (Ambari 2.7.11 + ODP 1.2.4, o fork aberto do HDP).

Cada aula liga **só os serviços que usa**, por isso roda em computadores com 8 GB de RAM (16 GB ou mais é o confortável). Veja [docs/MEMORIA.md](docs/MEMORIA.md).

## Requisitos

- Windows 10/11 (com WSL2), macOS ou Linux, 64 bits.
- **Docker Desktop** ([instalação](docs/INSTALACAO.md)) — no Windows, com o arquivo `.wslconfig` ajustado (explicado lá).
- 8 GB de RAM (mínimo), 2 núcleos, ~30 GB livres em disco.
- Mac com chip Apple (M1/M2/M3): funciona por emulação (Rosetta) — mais lento, mas minutos em vez das ~12 h da VM.

## Início rápido

```powershell
# Windows (PowerShell, dentro da pasta do projeto)      | Linux / macOS (terminal, dentro da pasta)
.\lab.ps1 up                                           | ./lab.sh up            # sobe a sandbox (1ª vez baixa a imagem)
.\lab.ps1 aula 7                                       | ./lab.sh aula 7        # prepara a aula 7 (liga só os serviços dela)
.\lab.ps1 shell                                        | ./lab.sh shell         # terminal dentro da sandbox (ou http://localhost:4200)
```
O argumento de `aula` é o **perfil**: `7`, `7a`, `8a`, `8b`, `8c`, `8d`, `9a`, `9b`, `9c`, `9d`, `10`, `11`, `12`, `trabalho` ou `none`. Exemplos:

```powershell
.\lab.ps1 aula 10          # ./lab.sh aula 10         PySpark (aula 10); o mesmo perfil serve para a 11
.\lab.ps1 aula 11          # ./lab.sh aula 11         idêntico ao 10 (ZooKeeper + HDFS)
.\lab.ps1 aula trabalho    # ./lab.sh aula trabalho   Atividade Prática (ZooKeeper + HDFS para o Files View)
.\lab.ps1 aula none        # ./lab.sh aula none       desliga todos os serviços; só o Ambari fica no ar
```

**Espere a mensagem `PRONTO`** que o `aula` imprime (com o tempo decorrido) antes de abrir o terminal, conectar por SSH ou rodar qualquer comando das aulas: enquanto os serviços estão subindo, `hdfs`, `hive`, `pig` etc. falham. Ligar um perfil leva de 1 a 6 minutos conforme a aula e o computador.

Acessos: Ambari `http://localhost:8080` (`admin/admin`, `raj_ops/raj_ops`, `maria_dev/maria_dev`), shell web `http://localhost:4200`, página com todos os links `http://localhost:8888`, SSH `ssh -p 2222 maria_dev@localhost`.

Os arquivos de cada aula (já com os erros de digitação corrigidos) ficam em `aulas/` no seu computador e em `~/aulas` dentro da sandbox. **Guia completo para o aluno (Word e PDF): [docs/Guia-do-Aluno.pdf](docs/Guia-do-Aluno.pdf)** — reúne instalação, uso, roteiro das aulas, memória, problemas comuns e errata em um único arquivo.

Cada pasta tem um `GUIA.md` dizendo o que muda em relação ao vídeo; o resumo geral está em [aulas/ERRATA.md](aulas/ERRATA.md). O que foi validado e as limitações conhecidas (Phoenix, Pig View) estão em [docs/VALIDACAO.md](docs/VALIDACAO.md).

A **Atividade Prática** pode ser feita nesta sandbox ou no [notebook do Google Colab](https://colab.research.google.com/github/N-CPUninter/Big_Data/blob/main/trabalho_big_data.ipynb) publicado no [GitHub da disciplina](https://github.com/N-CPUninter/Big_Data); a escolha é do aluno (veja `aulas/trabalho/GUIA.md`).

## Comandos do dia a dia

| Windows | Linux / macOS | O que faz |
|---|---|---|
| `.\lab.ps1 up` / `down` | `./lab.sh up` / `down` | sobe / para a sandbox (os dados ficam guardados em volumes) |
| `.\lab.ps1 aula <perfil>` | `./lab.sh aula <perfil>` | desliga o que não é da aula e liga o que é; termina com `PRONTO` |
| `.\lab.ps1 status` | `./lab.sh status` | serviços ligados e memória em uso |
| `.\lab.ps1 nosql` | `./lab.sh nosql` | sobe MongoDB e Cassandra (aulas 8c/8d) |
| `.\lab.ps1 mem 16g` | `./lab.sh mem 16g` | perfil de memória para máquinas com 16 GB ou mais (padrão: `8g`) |
| `.\lab.ps1 shell` | `./lab.sh shell` | terminal como `maria_dev` |
| `.\lab.ps1 reset` | `./lab.sh reset` | apaga tudo e volta ao estado inicial |

Ao terminar de estudar, rode `.\lab.ps1 stop-all` ou `.\lab.ps1 down` (`./lab.sh stop-all` / `./lab.sh down`): os serviços consomem cada vez mais memória se ficarem ligados por muitas horas (veja [docs/MEMORIA.md](docs/MEMORIA.md)).

Dentro da sandbox o mesmo CLI existe como `lab` (`lab aula 8a`, `lab storm start`, `lab jupyter start`, `lab urls`).

## Estrutura

```
docker-compose.yml   sandbox + sidecars (mongo, cassandra)
lab.ps1 / lab.sh     atalhos no computador
sandbox/             Dockerfile e scripts de build/runtime da imagem
aulas/               arquivos das aulas 7–12 e do trabalho + GUIA.md por aula
data/                ml-100k, customer-orders, access_log, movielens.sql (coloque aqui o imdb-reviews-pt-br.csv)
docs/                instalação, memória, diferenças para o HDP, validação/limitações, problemas comuns
tests/               testes de fumaça por aula
```

## Publicar a imagem (professor)

A imagem fica no **GitHub Container Registry** (`ghcr.io`), como um pacote da organização dona do repositório. Não é preciso conta em outro serviço: o login é a mesma conta do GitHub, com um token que tenha o escopo `write:packages`.

```powershell
# 1. token com escopo de pacotes (abre o navegador uma vez)
gh auth refresh -h github.com -s write:packages
gh auth token | docker login ghcr.io -u <seu-usuario-github> --password-stdin

# 2. marcar e enviar (envia alguns GB; depende da sua banda de upload)
.\publish.ps1 -Mode registry -Version 1.0.1 -Registry ghcr.io/n-cpuninter/bigdata-sandbox
```

Depois do primeiro envio, abra a aba **Packages** da organização, escolha `bigdata-sandbox` e, em *Package settings*, mude a visibilidade para **Public**. Com o pacote público, o aluno baixa sem login e sem cota; enquanto ele estiver privado, cada aluno precisaria de um token próprio e o plano gratuito limita armazenamento e tráfego.

O `LABEL org.opencontainers.image.source` do `sandbox/Dockerfile` liga o pacote a este repositório: ajuste-o se publicar em outra organização.

Alternativa sem registro, para pendrive ou drive compartilhado:
```powershell
.\publish.ps1 -Mode save -Version 1.0.1      # gera bigdata-sandbox-1.0.1.tar.gz
# no computador do aluno: docker load -i bigdata-sandbox-1.0.1.tar.gz
```

O workflow `.github/workflows/build.yml` faz o mesmo build no GitHub Actions a cada push na `main` (o runner precisa de ~40 GB livres; o workflow já limpa o disco). Nesse caminho o pacote nasce com a visibilidade do repositório e o login é automático.

## Construir a imagem localmente (opcional)

A imagem publicada já vem pronta. Para reconstruir (60–90 min; baixa ~5 GB de RPMs do ODP e ~3 GB de tarballs):
```powershell
bash sandbox/build/prefetch.sh   # opcional: baixa os tarballs uma vez (evita limites de taxa dos mirrors)
.\lab.ps1 build
```

## Licença

Scripts deste repositório: MIT. Os componentes (Hadoop, Hive, Spark, Ambari/ODP etc.) seguem a licença Apache 2.0 de cada projeto.
