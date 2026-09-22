# Sandbox Big Data — UNINTER (substituto da VM HDP 2.6.5)

Ambiente Hadoop completo em **um container Docker**, para as aulas práticas 7–12 e a Atividade Prática da disciplina de Big Data. Mantém o que os vídeos mostram (Ambari, `maria_dev`, `sandbox.hortonworks.com`, portas 8080/4200/2222) usando componentes atuais e mantidos (Ambari 2.7.11 + ODP 1.2.4, o fork aberto do HDP).

Cada aula liga **só os serviços que usa**, por isso roda em computadores com 8 GB de RAM (12–16 GB é o confortável). Veja [docs/MEMORIA.md](docs/MEMORIA.md).

## Requisitos

- Windows 10/11 (com WSL2), macOS ou Linux, 64 bits.
- **Docker Desktop** ([instalação](docs/INSTALACAO.md)) — no Windows, com o arquivo `.wslconfig` ajustado (explicado lá).
- 8 GB de RAM (mínimo), 2 núcleos, ~30 GB livres em disco.
- Mac com chip Apple (M1/M2/M3): funciona por emulação (Rosetta) — mais lento, mas minutos em vez das ~12 h da VM.

## Início rápido

```powershell
# 1. baixe/clone este projeto e abra um PowerShell dentro da pasta
# 2. suba a sandbox (a primeira vez baixa a imagem: vários GB; ~22 GB em disco)
.\lab.ps1 up
# 3. prepare a aula desejada
.\lab.ps1 aula 7          # 7, 7a, 8a, 8b, 8c, 8d, 9a, 9b, 9c, 9d, 10, 11, 12, trabalho
# 4. abra um terminal dentro da sandbox (ou http://localhost:4200)
.\lab.ps1 shell
```
Linux/macOS: use `./lab.sh` com os mesmos comandos.

Acessos: Ambari `http://localhost:8080` (`admin/admin`, `raj_ops/raj_ops`, `maria_dev/maria_dev`), shell web `http://localhost:4200`, página com todos os links `http://localhost:8888`, SSH `ssh -p 2222 maria_dev@localhost`.

Os arquivos de cada aula (já com os erros de digitação corrigidos) ficam em `aulas/` no seu computador e em `~/aulas` dentro da sandbox. **Guia completo para o aluno (Word e PDF): [docs/Guia-do-Aluno.pdf](docs/Guia-do-Aluno.pdf)** — reúne instalação, uso, roteiro das aulas, memória, problemas comuns e errata em um único arquivo.

Cada pasta tem um `GUIA.md` dizendo o que muda em relação ao vídeo; o resumo geral está em [aulas/ERRATA.md](aulas/ERRATA.md). O que foi validado e as limitações conhecidas (Phoenix, Pig View) estão em [docs/VALIDACAO.md](docs/VALIDACAO.md).

## Comandos do dia a dia

| Comando | O que faz |
|---|---|
| `.\lab.ps1 up` / `down` | sobe / para a sandbox (os dados ficam guardados em volumes) |
| `.\lab.ps1 aula <perfil>` | desliga o que não é da aula e liga o que é |
| `.\lab.ps1 status` | serviços ligados e memória em uso |
| `.\lab.ps1 nosql` | sobe MongoDB e Cassandra (aulas 8c/8d) |
| `.\lab.ps1 mem 16g` | perfil de memória para máquinas com 16 GB (padrão: `8g`) |
| `.\lab.ps1 shell` | terminal como `maria_dev` |
| `.\lab.ps1 reset` | apaga tudo e volta ao estado inicial |

Ao terminar de estudar, rode `.\lab.ps1 stop-all` ou `.\lab.ps1 down`: os serviços consomem cada vez mais memória se ficarem ligados por muitas horas (veja [docs/MEMORIA.md](docs/MEMORIA.md)).

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

## Construir a imagem localmente (opcional)

A imagem publicada já vem pronta. Para reconstruir (60–90 min; baixa ~5 GB de RPMs do ODP e ~3 GB de tarballs):
```powershell
bash sandbox/build/prefetch.sh   # opcional: baixa os tarballs uma vez (evita limites de taxa dos mirrors)
.\lab.ps1 build
```

## Licença

Scripts deste repositório: MIT. Os componentes (Hadoop, Hive, Spark, Ambari/ODP etc.) seguem a licença Apache 2.0 de cada projeto.
