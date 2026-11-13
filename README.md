# Sandbox Big Data — ambiente das aulas práticas

Este é o ambiente que substitui a **máquina virtual Hortonworks HDP 2.6.5** usada nos vídeos das aulas práticas. Ele traz o mesmo Ambari, o mesmo usuário `maria_dev`, o mesmo endereço `sandbox.hortonworks.com` e as mesmas portas que você vê nas gravações, mas roda em **um container Docker** que liga só os serviços de cada aula. Por isso funciona em computadores com 8 GB de memória.

Se você nunca usou Docker, terminal ou SSH, siga esta página na ordem. Não é preciso saber nada disso antes: cada passo está escrito por extenso.

> **Guia completo em PDF: [docs/Guia-do-Aluno.pdf](docs/Guia-do-Aluno.pdf)** — o mesmo conteúdo desta página, formatado para leitura e impressão, com índice e capítulo por aula. Baixe uma cópia antes de começar, porque ele também serve quando algo dá errado e você está sem internet.

---

## Sumário

1. [O que você precisa](#1-o-que-você-precisa)
2. [Instalar o Docker](#2-instalar-o-docker)
3. [Baixar e subir a sandbox](#3-baixar-e-subir-a-sandbox)
4. [Os três comandos e o que é um "perfil"](#4-os-três-comandos-e-o-que-é-um-perfil)
5. [Como entrar no ambiente](#5-como-entrar-no-ambiente)
6. [Aula a aula](#6-aula-a-aula)
7. [Atividade Prática](#7-atividade-prática)
8. [Desligar ao terminar](#8-desligar-ao-terminar)
9. [Quando algo dá errado](#9-quando-algo-dá-errado)

---

## 1. O que você precisa

| Item | Mínimo | Confortável |
|---|---|---|
| Memória RAM | 8 GB | 16 GB ou mais |
| Espaço livre em disco | 40 GB | 60 GB |
| Processador | 2 núcleos, 64 bits, com virtualização ativada | 4 núcleos ou mais |
| Sistema | Windows 10/11, macOS 12 ou superior, ou Linux | — |
| Internet | um download único de vários GB | — |

**Docker** é um programa que roda um "computador dentro do seu computador", só que muito mais leve que uma máquina virtual. A **imagem** é o pacote pronto, com Hadoop, Hive, Spark e tudo o mais já instalado; o **container** é esse pacote em execução. Você não precisa instalar nenhuma dessas ferramentas separadamente: todas já estão dentro da imagem.

Se o seu computador não dá conta (menos de 8 GB, ou um Mac antigo), a Atividade Prática pode ser feita no [Google Colab](https://colab.research.google.com/github/N-CPUninter/Big_Data/blob/main/trabalho_big_data.ipynb), pelo navegador, sem instalar nada. Veja o [capítulo 7](#7-atividade-prática).

---

## 2. Instalar o Docker

### Windows 10 e 11

1. **Confira a virtualização.** Abra o Gerenciador de Tarefas (Ctrl+Shift+Esc), aba **Desempenho**, item **CPU**. No canto direito deve aparecer `Virtualização: Habilitada`. Se aparecer "Desabilitada", é preciso ligá-la na BIOS/UEFI: [guia da Microsoft](https://support.microsoft.com/pt-br/windows/habilitar-a-virtualiza%C3%A7%C3%A3o-no-windows-c5578302-6e43-4b4b-a449-8ced115f58e1).
2. **Instale o WSL2.** Clique no menu Iniciar, digite `powershell`, clique com o botão direito em **Windows PowerShell** e escolha **Executar como administrador**. Na janela preta, digite e pressione Enter:
   ```powershell
   wsl --install
   ```
   Reinicie o computador quando terminar. Passo a passo oficial: [Instalar o WSL](https://learn.microsoft.com/pt-br/windows/wsl/install).
3. **Instale o Docker Desktop.** Baixe em [docs.docker.com/desktop/setup/install/windows-install](https://docs.docker.com/desktop/setup/install/windows-install/), execute o instalador e deixe marcada a opção **Use WSL 2 instead of Hyper-V**. Não é necessário criar conta.
4. **Limite a memória do WSL2.** Sem isso o WSL2 pode tomar metade da RAM e travar o Windows. Abra o Bloco de Notas, cole o texto abaixo e salve como `.wslconfig` (com o ponto na frente) dentro da sua pasta de usuário, por exemplo `C:\Users\SeuNome\.wslconfig`. Na janela de salvar, escolha **Tipo: Todos os arquivos**, senão o Windows acrescenta `.txt` ao nome.
   ```ini
   [wsl2]
   memory=6GB
   swap=4GB
   processors=4
   ```
   Com 16 GB de RAM ou mais, use `memory=10GB`. Depois, no PowerShell: `wsl --shutdown`, e abra o Docker Desktop de novo. Referência: [configurações do WSL](https://learn.microsoft.com/pt-br/windows/wsl/wsl-config).
5. **Abra o Docker Desktop** e espere o ícone da baleia, no canto inferior esquerdo, ficar verde com a palavra *Engine running*.

### macOS

1. Instale o [Docker Desktop para Mac](https://docs.docker.com/desktop/setup/install/mac-install/), escolhendo a versão do seu chip (Apple Silicon ou Intel).
2. Em **Settings > Resources**, coloque a memória em pelo menos 6 GB (10 GB se o Mac tiver 16 GB ou mais) e clique em **Apply**.
3. Mac com chip M1, M2, M3 ou M4: em **Settings > General**, marque **Use Rosetta for x86_64/amd64 emulation**. A imagem é x86_64 e roda por emulação; fica mais lenta, mas sobe em minutos.

### Linux

1. Instale o Docker Engine e o plugin Compose pelo guia da sua distribuição: [Install Docker Engine](https://docs.docker.com/engine/install/). O comando `docker compose version` precisa funcionar.
2. Adicione seu usuário ao grupo `docker` para não precisar de `sudo`: [post-installation](https://docs.docker.com/engine/install/linux-postinstall/).

---

## 3. Baixar e subir a sandbox

1. **Baixe o projeto.** Nesta página do GitHub, clique no botão verde **Code** e depois em **Download ZIP**. Ou baixe o ZIP pela própria rota da disciplina.
2. **Extraia** o ZIP em uma pasta **sem espaços e sem acentos** no caminho. No Windows: botão direito no arquivo baixado > **Extrair Tudo** > digite `C:\bigdata-lab` > Extrair. No macOS ou Linux, algo como `~/bigdata-lab`.
3. **Abra um terminal dentro dessa pasta.**
   - *Windows:* abra a pasta no Explorador de Arquivos, clique na barra de endereço, apague o que estiver escrito, digite `powershell` e pressione Enter.
   - *macOS:* Finder, botão direito na pasta, **Serviços > Novo Terminal na Pasta**.
   - *Linux:* botão direito dentro da pasta, **Abrir no Terminal**.
4. **Suba a sandbox:**
   ```powershell
   .\lab.cmd up      # Windows
   ```
   ```bash
   ./lab.sh up       # macOS e Linux
   ```
   Na primeira vez o Docker baixa a imagem, que tem cerca de 16 GB: pode levar de vinte minutos a algumas horas, conforme a sua internet. Depois disso, subir leva cerca de um minuto.

Repare no `.\` do começo e na terminação `.cmd`: assim o comando funciona tanto no PowerShell quanto no Prompt de Comando. O `lab.cmd` é um atalho de três linhas que chama o `lab.ps1`, onde está toda a lógica; ele existe porque o Windows bloqueia por padrão os scripts `.ps1` baixados da internet, e chamar o `.\lab.ps1` diretamente falha na primeira vez em boa parte dos computadores. Pelo `.\lab.cmd` esse bloqueio não aparece e nada precisa ser mudado nas configurações do Windows.

Se você preferir chamar o `lab.ps1` diretamente e o Windows responder *"a execução de scripts foi desabilitada neste sistema"*, rode uma única vez o comando abaixo, responda `S` e tente de novo:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Quando terminar, o comando mostra a lista de endereços e a frase *"Ambari no ar"*. Isso significa que o painel está funcionando, **mas os serviços das aulas ainda não estão ligados**. Quem liga é o comando do próximo capítulo.

---

## 4. Os três comandos e o que é um "perfil"

| Windows | macOS e Linux | O que faz |
|---|---|---|
| `.\lab.cmd up` | `./lab.sh up` | Sobe a sandbox e espera o Ambari responder |
| `.\lab.cmd aula 7` | `./lab.sh aula 7` | Prepara a aula 7: liga só os serviços dela |
| `.\lab.cmd shell` | `./lab.sh shell` | Abre um terminal **dentro** da sandbox |

O **perfil** é o que vem depois da palavra `aula`. Ele diz quais serviços ligar. Pode ser o número da aula, uma parte de uma aula grande, a palavra `trabalho` ou a palavra `none`:

| Windows | macOS e Linux | Resultado |
|---|---|---|
| `.\lab.cmd aula 10` | `./lab.sh aula 10` | Aula 10 (PySpark): liga ZooKeeper e HDFS |
| `.\lab.cmd aula 11` | `./lab.sh aula 11` | Aula 11: os mesmos serviços da 10 |
| `.\lab.cmd aula trabalho` | `./lab.sh aula trabalho` | Atividade Prática: ZooKeeper e HDFS |
| `.\lab.cmd aula 8a` | `./lab.sh aula 8a` | Primeira parte da aula 8: HDFS, YARN, MapReduce2 e Hive |
| `.\lab.cmd aula none` | `./lab.sh aula none` | Desliga todos os serviços; só o Ambari fica no ar |

**Espere a mensagem `PRONTO`.** Ligar os serviços leva de um a seis minutos. Enquanto isso o comando mostra o que está ligando e, a cada trinta segundos, o tempo decorrido. No final aparece uma faixa assim:

```
[lab] ==================================================================
[lab] PRONTO em 3m05s. Perfil '10' ativo. Serviços de pé: HDFS,ZOOKEEPER.
[lab] Agora você pode abrir o terminal (http://localhost:4200), o SSH e as interfaces web.
[lab] ==================================================================
```

Só depois dessa faixa os comandos das aulas funcionam. Antes dela, `hdfs`, `hive`, `pig` e `spark-submit` falham com erros de conexão, porque os serviços ainda estão subindo.

Outros comandos úteis:

| Windows | macOS e Linux | O que faz |
|---|---|---|
| `.\lab.cmd status` | `./lab.sh status` | Mostra quais serviços estão ligados e quanta memória estão usando |
| `.\lab.cmd nosql` | `./lab.sh nosql` | Sobe o MongoDB e o Cassandra (aulas 8c e 8d) |
| `.\lab.cmd stop-all` | `./lab.sh stop-all` | Desliga todos os serviços, mantendo a sandbox no ar |
| `.\lab.cmd down` | `./lab.sh down` | Para a sandbox; seus arquivos continuam salvos |
| `.\lab.cmd mem 16g` | `./lab.sh mem 16g` | Perfil de memória para máquinas com 16 GB ou mais |
| `.\lab.cmd reset` | `./lab.sh reset` | Apaga tudo e volta ao estado inicial. Pede confirmação |

---

## 5. Como entrar no ambiente

| Para quê | Endereço | Usuário e senha |
|---|---|---|
| **Ambari**, o painel dos vídeos | [http://localhost:8080](http://localhost:8080) | `maria_dev` / `maria_dev`, ou `admin` / `admin` |
| **Terminal pelo navegador** | [http://localhost:4200](http://localhost:4200) | `maria_dev` / `maria_dev` |
| Página com todos os links | [http://localhost:8888](http://localhost:8888) | — |
| **SSH** | `ssh -p 2222 maria_dev@localhost` | senha `maria_dev` |

**Terminal** é a janela onde você digita comandos. O jeito mais simples de abrir um terminal dentro da sandbox é pelo navegador, no endereço [http://localhost:4200](http://localhost:4200): digite `maria_dev` como usuário e `maria_dev` como senha. Ao digitar a senha, nada aparece na tela; isso é normal.

**SSH** é o modo de acessar outro computador pelo terminal. Aqui o "outro computador" é a sandbox. No Windows você pode usar o PowerShell (`ssh -p 2222 maria_dev@localhost`) ou o programa [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html), preenchendo *Host Name* com `localhost`, *Port* com `2222`, marcando SSH e clicando em **Open**. Use SSH apenas se preferir; tudo funciona pelo terminal do navegador.

**Files View**, usado nos vídeos para enviar arquivos ao HDFS: abra o Ambari, clique no quadradinho de nove pontos no canto superior direito e escolha **Files View**. Entre em `user` > `maria_dev` e use o botão **Upload**.

**Onde ficam os arquivos.** Na pasta do projeto, no seu computador, existem duas pastas que aparecem dentro da sandbox:

- `aulas/` — os scripts de todas as aulas, já com os erros de digitação do material original corrigidos. Dentro da sandbox: `~/aulas`.
- `data/` — os conjuntos de dados das aulas. Dentro da sandbox: `~/data-host`; uma cópia dos menores já está em `~/data`, e o `ml-100k` já está carregado no HDFS.

Arquivos que você criar dentro da sandbox continuam lá quando você desliga e liga de novo, até rodar um `reset`.

---

## 6. Aula a aula

Cada aula tem uma pasta em `aulas/` com um arquivo `GUIA.md` que compara, linha a linha, o que o vídeo mostra e o que muda aqui. Abaixo está o resumo de cada uma. Em todas elas, o fluxo é o mesmo: prepare o perfil, espere o `PRONTO`, abra o terminal, rode os comandos.

### Aula 7 — Pig e Oozie · [guia completo](aulas/aula07/GUIA.md)

```powershell
.\lab.cmd aula 7        # ./lab.sh aula 7      (ou "aula 7a", só Pig, mais leve)
```
No terminal da sandbox:
```bash
cd ~/aulas/aula07/Pig_exercise
pig MostRatedFiveStarMovie.pig
pig OldestFiveStarMovie.pig

cd ~/aulas/aula07/Oozie_exercise
hdfs dfs -put -f workflow.xml oldmovies.sql /user/maria_dev/
oozie job -oozie http://localhost:11000/oozie -config job.properties -run
```
O **Pig View** do Ambari não existe mais nesta versão; use o comando `pig` no terminal, que é o que o vídeo faz na segunda parte. O banco `movielens` já está carregado, então a parte do Sqoop no workflow funciona direto. Acompanhe o Oozie em [http://localhost:11000/oozie](http://localhost:11000/oozie).

### Aula 8 — Hive, Sqoop, mrjob, HBase, Drill, Presto, MongoDB e Cassandra · [guia completo](aulas/aula08/GUIA.md)

A aula 8 usa muitas ferramentas, e ligar todas de uma vez não cabe em 8 GB. Por isso ela está dividida em quatro perfis. Faça um de cada vez.

| Perfil | Comando | Conteúdo |
|---|---|---|
| 8a | `.\lab.cmd aula 8a` | Hive, Sqoop com MariaDB, MapReduce com mrjob |
| 8b | `.\lab.cmd aula 8b` | HBase (e Pig lendo do HBase) |
| 8c | `.\lab.cmd nosql` e depois `.\lab.cmd aula 8c` | MongoDB, Cassandra e Spark 2 |
| 8d | `.\lab.cmd nosql` e depois `.\lab.cmd aula 8d` | Drill e Presto |

O **Hive View** também não existe mais. Use o `beeline` ou o Zeppelin, como explica o guia da aula. As tabelas `ratings` e `names` já estão criadas, no lugar do "Upload Table" que o vídeo mostra. O Phoenix é a única ferramenta do material que não funciona nesta versão; o guia explica o motivo e o que usar no lugar.

### Aula 9 — Flume, Kafka, Storm e Flink · [guia completo](aulas/aula09/GUIA.md)

| Perfil | Comando | Conteúdo |
|---|---|---|
| 9a | `.\lab.cmd aula 9a` | Flume lendo do netcat e de uma pasta, gravando no HDFS |
| 9b | `.\lab.cmd aula 9b` | Kafka: criar tópico, produzir e consumir |
| 9c | `.\lab.cmd aula 9c` e, na sandbox, `lab storm start` | Storm, com a interface em [http://localhost:8744](http://localhost:8744) |
| 9d | `.\lab.cmd aula 9d` | Flink, com a interface em [http://localhost:8082](http://localhost:8082) |

Mudança mais visível em relação ao vídeo: os comandos do Kafka não aceitam mais `--zookeeper`; use `--bootstrap-server localhost:6667`. A lista completa de mudanças desse tipo está em [aulas/ERRATA.md](aulas/ERRATA.md).

Vários exercícios desta aula pedem **dois ou três terminais ao mesmo tempo** (um para o serviço, outro para digitar as mensagens). Basta abrir mais abas em [http://localhost:4200](http://localhost:4200).

### Aulas 10 e 11 — PySpark · [guia completo](aulas/aula10/GUIA.md)

```powershell
.\lab.cmd aula 10       # ./lab.sh aula 10   (a aula 11 usa o mesmo perfil)
```
```bash
cd ~/aulas/aula10/01-RatingsCounter && spark-submit ratings-counter.py
cd ~/aulas/aula10/02-CustomerOrder  && spark-submit customer-orders.py
cd ~/aulas/aula10/03-MostPopularMovies && spark-submit popular-movies-names.py
cd ~/aulas/aula10/04-SparkSQL && spark-submit spark-sql.py
cd ~/aulas/aula10/05-MLLib && spark-submit movie-recommendations-als.py 50
```
São as aulas mais leves: ligam apenas ZooKeeper e HDFS. Existem duas versões do Spark, como no HDP: a 3 é a padrão, e `export SPARK_MAJOR_VERSION=2` passa para a 2, que é a dos vídeos.

### Aula 12 — Spark Streaming · [guia completo](aulas/aula12/GUIA.md)

```powershell
.\lab.cmd aula 12       # ./lab.sh aula 12
```
Este exercício precisa de **três terminais**: um roda o Spark, outro roda o Flume, o terceiro copia arquivos para a pasta vigiada. O guia traz os três blocos prontos. É o único exercício que exige o Spark 2, porque o conector com o Flume não existe no Spark 3.

---

## 7. Atividade Prática

**A escolha da plataforma é sua.** O roteiro aceita qualquer ambiente; o que vale são as regras dele (sem pandas, prints com o seu RU visível, entrega em PDF).

| | Google Colab | Sandbox Docker |
|---|---|---|
| Instalação | Nenhuma, só uma conta Google | Docker Desktop e esta sandbox |
| Onde roda | No servidor do Google, pelo navegador | No seu computador |
| HDFS e Ambari | Não há | Sim, com upload pelo Files View, como nos vídeos |

**Opção A — Colab.** Abra o [notebook da disciplina](https://colab.research.google.com/github/N-CPUninter/Big_Data/blob/main/trabalho_big_data.ipynb), faça **Arquivo > Salvar uma cópia no Drive** e preencha as funções de cada questão. Ele já baixa o dataset e instala o PySpark.

**Opção B — Sandbox.** `.\lab.cmd aula trabalho`, envie o CSV pelo Files View e rode `spark-submit`. O passo a passo detalhado está em [aulas/trabalho/GUIA.md](aulas/trabalho/GUIA.md), incluindo o script `verifica.sh`, que confere se os seus números batem com os esperados antes da entrega.

---

## 8. Desligar ao terminar

Ao fim de cada sessão de estudo, rode:

```powershell
.\lab.cmd aula none     # desliga os serviços, mantém o Ambari
.\lab.cmd down          # para a sandbox inteira; nada é perdido
```

Isso não é opcional. Os serviços Java vão ocupando mais memória com o tempo: depois de um dia inteiro ligados, mesmo sem uso, o perfil 7 chega ao limite e o computador fica lento. Detalhes e números medidos em [docs/MEMORIA.md](docs/MEMORIA.md).

---

## 9. Quando algo dá errado

| Sintoma | O que fazer |
|---|---|
| `hdfs`, `hive` ou `spark-submit` dão erro de conexão | Os serviços ainda não terminaram de subir, ou você não rodou o `aula <perfil>`. Espere a faixa `PRONTO` e confira com `status` |
| O Ambari não abre em `localhost:8080` | Veja `.\lab.cmd logs`. Se outro programa já usa a porta 8080, troque-a no `docker-compose.yml` |
| Chamei o `.\lab.ps1` direto e ele não roda | Use `.\lab.cmd`, que não esbarra na política de execução. Para destravar o `.ps1`: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`, uma vez só |
| "O arquivo lab.ps1 não está assinado digitalmente" | O ZIP veio da internet e ficou marcado. Na pasta do projeto: `Get-ChildItem -Recurse \| Unblock-File` |
| O PowerShell recusa o `lab.ps1` mesmo depois de liberar a política | `Unblock-File -Path .\lab.ps1` e depois `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\lab.ps1 up`. Resolve a marca de origem e a política fixada pela instituição de uma vez |
| O Docker Desktop diz que você não está no grupo `docker-users` | Um administrador precisa rodar `net localgroup docker-users "NOME-DO-PC\seu_usuario" /add`; depois saia e entre no Windows |
| Tudo muito lento, computador travando | Reduza o `.wslconfig`, feche o navegador e use os perfis mais leves (`7a` no lugar de `7`) |
| Quero começar do zero | `.\lab.cmd reset` apaga HDFS, bancos e os arquivos criados dentro da sandbox |

**Perguntas frequentes:** [docs/FAQ.md](docs/FAQ.md) — inclui as travas de política do Windows (execução de scripts, arquivos bloqueados, SmartScreen, firewall, portas reservadas, antivírus), que são o obstáculo mais comum na primeira instalação.

Lista completa, com mais casos e as mensagens de erro exatas: [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

Outros documentos úteis:

- [docs/Guia-do-Aluno.pdf](docs/Guia-do-Aluno.pdf) — **o documento completo**: reúne tudo o que está nesta página e em todos os arquivos de `docs/`, com sumário navegável. É o arquivo publicado na rota de estudos; os demais documentos abaixo são as mesmas informações em partes menores.
- [docs/FAQ.md](docs/FAQ.md) — perguntas frequentes, com as travas de política do Windows.
- [aulas/ERRATA.md](aulas/ERRATA.md) — o que mudou nos comandos em relação aos vídeos.
- [docs/DIFERENCAS-HDP.md](docs/DIFERENCAS-HDP.md) — o que é diferente da VM antiga e por quê.
- [docs/INSTALACAO.md](docs/INSTALACAO.md) — instalação em mais detalhe.
- [docs/VALIDACAO.md](docs/VALIDACAO.md) — o que foi testado e as limitações conhecidas.
- [docs/PROFESSOR.md](docs/PROFESSOR.md) — construção, publicação da imagem e manutenção (não é necessário para o aluno).
