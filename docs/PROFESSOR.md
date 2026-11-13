# Manutenção (professor)

Esta página reúne o que o aluno não precisa: estrutura do repositório, construção da imagem, publicação e automação. O material do aluno está no [README](../README.md) e no [Guia do Aluno](Guia-do-Aluno.pdf).

## Estrutura

```
docker-compose.yml   sandbox + sidecars (mongo, cassandra)
lab.cmd              ponto de entrada no Windows (chama o lab.ps1)
lab.ps1 / lab.sh     atalhos no computador do aluno
publish.ps1          publicação da imagem (registry ou arquivo .tar.gz)
sandbox/             Dockerfile e scripts de build/runtime da imagem
  build/             10-os, 20-repos, 30-ambari, 40-blueprint, 50-extras, 55-downloads,
                     60-python, 70-ivy-cache, prefetch.sh, blueprint e perfis de memória
  runtime/           entrypoint.sh, CLI lab, aulas.map, ambari-config.py, splash
aulas/               arquivos das aulas 7–12 e do trabalho + GUIA.md por aula
data/                ml-100k, customer-orders, access_log, movielens.sql
docs/                instalação, memória, diferenças para o HDP, validação, problemas, FAQ, guia em PDF
docs/guia-src/       fonte do Guia do Aluno (docx-js): build.js e lib.js
tests/               testes de fumaça por aula + ci.sh
```

## Construir a imagem

Leva de 60 a 90 minutos e baixa cerca de 5 GB de RPMs do ODP e 3 GB de tarballs.

```powershell
bash sandbox/build/prefetch.sh   # baixa os tarballs uma vez; evita os limites de taxa dos mirrors
.\lab.cmd build
```

Mudanças só em `sandbox/runtime/` reconstroem apenas o estágio final, em poucos minutos.

## Testes

```powershell
bash tests/ci.sh aula10                      # um perfil
bash tests/ci.sh aula07 aula08 aula09 aula10 aula12 trabalho
```

O resultado da última validação completa, com as limitações conhecidas, está em [VALIDACAO.md](VALIDACAO.md).

## Publicar a imagem

A imagem fica no **GitHub Container Registry** (`ghcr.io`), como pacote da organização dona do repositório. Não é preciso conta em outro serviço: o login é a mesma conta do GitHub, com um token que tenha o escopo `write:packages`.

```powershell
# 1. token com escopo de pacotes (abre o navegador uma vez)
gh auth refresh -h github.com -s write:packages
gh auth token | docker login ghcr.io -u <seu-usuario-github> --password-stdin

# 2. marcar e enviar (vários GB de upload)
.\publish.ps1 -Mode registry -Version 1.0.1 -Registry ghcr.io/n-cpuninter/bigdata-sandbox
```

Depois do primeiro envio, abra [os pacotes da organização](https://github.com/orgs/N-CPUninter/packages), escolha `bigdata-sandbox` e, em *Package settings*, mude a visibilidade para **Public**. Com o pacote público, o aluno baixa sem login e sem cota; enquanto ele estiver privado, cada aluno precisaria de um token próprio e a cota do plano gratuito não atende uma turma.

O `LABEL org.opencontainers.image.source` do `sandbox/Dockerfile` liga o pacote a este repositório. Ajuste-o se publicar em outra organização.

Alternativa sem registro, para pendrive ou drive compartilhado:

```powershell
.\publish.ps1 -Mode save -Version 1.0.1      # gera bigdata-sandbox-1.0.1.tar.gz
# no computador do aluno: docker load -i bigdata-sandbox-1.0.1.tar.gz
```

## Build automático (GitHub Actions)

O workflow [`build-sandbox`](../.github/workflows/build.yml) roda no GitHub, sem ocupar a sua máquina.

**Quando dispara.** Só quando muda algo que entra na imagem: `sandbox/**`, `docker-compose.yml`, `tests/**` ou o próprio workflow. Alterar README, `docs/`, `aulas/` ou `data/` **não** dispara build, porque esse conteúdo é montado da pasta do aluno em tempo de execução e não faz parte da imagem.

**O que ele publica.** Todo build publica duas marcas: `:edge` (último build da `main`) e `:sha-<commit>` (rastreável). Em seguida roda o teste de fumaça da aula 10 contra a imagem recém-publicada.

**A marca `:latest` não é movida automaticamente.** É ela que os alunos baixam, e um build quebrado no meio do semestre pararia a turma inteira. Para promover, depois de conferir que o build passou:

1. Aba **Actions** do repositório, workflow **build-sandbox**, botão **Run workflow**.
2. Preencha o campo **versao** (por exemplo `1.0.2`) e confirme.
3. Ao final, a imagem testada é copiada para `:<versao>` e `:latest`, sem reconstruir nada.

**Limite conhecido.** O runner gratuito tem cerca de 45 GB livres depois da limpeza de disco, e a imagem passa de 20 GB. Se o build falhar por falta de espaço, publique a partir da sua máquina com o `publish.ps1`, que é o caminho usado até aqui.

## Atualizar o Guia do Aluno

O PDF e o DOCX em `docs/` são gerados por script, não editados à mão.

```bash
cd docs/guia-src && npm install docx@9      # só na primeira vez
node build.js Guia-do-Aluno.docx
```

A exportação para PDF usa o Word (COM), que também atualiza o sumário. O texto do guia fica em `build.js`; a formatação, em `lib.js`.

## Textos para a rota e para a tutoria

Textos curtos prontos para copiar: [TEXTOS-ROTA.md](TEXTOS-ROTA.md).

## Licença

Scripts deste repositório: MIT. Os componentes (Hadoop, Hive, Spark, Ambari/ODP e demais) seguem a licença Apache 2.0 de cada projeto.
