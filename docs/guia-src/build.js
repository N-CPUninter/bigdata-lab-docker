// Gera docs/Guia-do-Aluno.docx — guia único da Sandbox Big Data (UNINTER).
const fs = require("fs");
const path = require("path");
const L = require("./lib");
const { d, FONT, MONO, BLUE, TEXT_W, PAGE_W, MARGIN, P, H1, H1n, H2, H3, Code, Bullet, Num, Note, TblS, Spacer, Break, runs } = L;
const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, AlignmentType, TableOfContents, Header, Footer,
  PageNumber, LevelFormat, BorderStyle, ShadingType,
} = d;

const OUT = process.argv[2] || "Guia-do-Aluno.docx";
const VERSAO = "1.0 — setembro de 2026";

// ---------------------------------------------------------------- capa
const capa = [
  Spacer(2400),
  new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "UNINTER — Tecnologia em Ciência de Dados (EaD)", font: FONT, size: 26, color: "555555" })], spacing: { after: 120 } }),
  new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Disciplina de Big Data", font: FONT, size: 28, color: "555555" })], spacing: { after: 900 } }),
  new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Sandbox Big Data", font: FONT, size: 64, bold: true, color: BLUE })], spacing: { after: 160 } }),
  new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Guia do Aluno", font: FONT, size: 44, color: BLUE })], spacing: { after: 400 } }),
  new Paragraph({ alignment: AlignmentType.CENTER, border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: BLUE, space: 1 } }, children: [new TextRun({ text: " ", size: 8 })], spacing: { after: 400 } }),
  new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Ambiente Hadoop completo em Docker para as aulas práticas 7 a 12 e para a Atividade Prática, em substituição à máquina virtual HDP 2.6.5.", font: FONT, size: 24, italics: true, color: "444444" })], spacing: { after: 2400 } }),
  new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Versão " + VERSAO, font: FONT, size: 22, color: "555555" })] }),
  new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Prof. Guilherme Ditzel Patriota", font: FONT, size: 22, color: "555555" })] }),
  Break(),
];

// ---------------------------------------------------------------- sumário
const sumario = [
  new Paragraph({ children: [new TextRun({ text: "Sumário", font: FONT, size: 34, bold: true, color: BLUE })], spacing: { after: 200 }, border: { bottom: { style: BorderStyle.SINGLE, size: 8, color: BLUE, space: 4 } } }),
  new TableOfContents("Sumário", { hyperlink: true, headingStyleRange: "1-2" }),
  P("Este sumário é atualizado automaticamente pelo Word. Se aparecer vazio, clique com o botão direito sobre ele e escolha “Atualizar campo”.", { run: { italics: true, color: "666666", size: 20 } }),
];

// ---------------------------------------------------------------- 1. introdução
const intro = [
  H1("1. Introdução"),
  P("A disciplina de Big Data usa, nas aulas práticas, a máquina virtual Hortonworks HDP 2.6.5. Essa máquina foi descontinuada: o download não está mais disponível, os repositórios de pacotes deixaram de existir, o boot leva de trinta a sessenta minutos (e cerca de doze horas em computadores Apple com chip M1/M2/M3) e ela exige 8 GB de memória só para si."),
  P("A **Sandbox Big Data** substitui essa máquina virtual por um ambiente Docker. Ela mantém o que os vídeos das aulas mostram (o Ambari, o usuário `maria_dev`, o nome `sandbox.hortonworks.com`, as mesmas portas e senhas) usando componentes atuais e mantidos: Apache Ambari 2.7.11 e a distribuição ODP 1.2.4, que é a continuação em código aberto do HDP."),
  P("A diferença mais importante para quem tem um computador modesto: em vez de ligar todos os serviços de uma vez, a sandbox liga **somente os serviços que cada aula usa**. Por isso ela roda em computadores com 8 GB de RAM, embora 12 a 16 GB tornem o uso mais confortável."),
  H2("1.1 O que você vai encontrar neste guia"),
  Bullet("Como instalar o Docker e a sandbox no Windows, macOS ou Linux (capítulo 2)."),
  Bullet("Como ligar a sandbox, preparar uma aula e acessar o Ambari, o terminal e as demais interfaces (capítulos 3 e 4)."),
  Bullet("Um roteiro para cada aula prática, indicando exatamente o que muda em relação ao vídeo (capítulo 5)."),
  Bullet("Como fazer a Atividade Prática dentro da sandbox (capítulo 6)."),
  Bullet("Orientações sobre memória, boas práticas e solução de problemas (capítulos 7 e 8)."),
  Bullet("Apêndices com a tabela de versões, a errata dos materiais originais e a lista de diferenças para a VM HDP."),
  H2("1.2 Convenções usadas no texto"),
  P("Comandos e nomes de arquivos aparecem em fonte monoespaçada, como `lab aula 7`. Blocos de comando aparecem em caixas cinza; digite-os linha a linha. Comandos que começam com `.\\lab.ps1` são executados no PowerShell do **seu computador**, dentro da pasta do projeto. Comandos como `lab`, `hdfs`, `pig` ou `spark-submit` são executados **dentro da sandbox** (no terminal web ou por SSH), como usuário `maria_dev`."),
  Spacer(60),
  Note("Windows, macOS e Linux", "Nos exemplos usamos o PowerShell do Windows (`.\\lab.ps1`). No macOS e no Linux o script equivalente é `./lab.sh`, com os mesmos subcomandos."),
];

// ---------------------------------------------------------------- 2. instalação
const instal = [
  H1("2. Requisitos e instalação"),
  H2("2.1 Requisitos"),
  ...TblS(["Item", "Mínimo", "Recomendado"], [
    ["Memória RAM", "8 GB", "16 GB"],
    ["Processador", "2 núcleos, 64 bits, com virtualização ativada", "4 núcleos ou mais"],
    ["Espaço em disco livre", "40 GB (a imagem ocupa cerca de 22 GB)", "60 GB"],
    ["Sistema operacional", "Windows 10/11 com WSL2, macOS 12 ou superior, Linux", "—"],
    ["Internet", "Download único da imagem (vários GB)", "—"],
  ], [2, 3, 2]),
  P("Computadores Apple com chip M1, M2 ou M3 funcionam por emulação (Rosetta). A sandbox fica mais lenta nesses aparelhos, mas leva minutos para subir, e não as doze horas da máquina virtual antiga."),
  H2("2.2 Windows 10 e 11"),
  Num("Ative a virtualização na BIOS/UEFI do computador (Intel VT-x ou AMD-V), caso ainda não esteja ativa. A maioria dos notebooks recentes já vem com ela ligada."),
  Num("Instale o WSL2: abra o PowerShell **como administrador** e execute `wsl --install`. Reinicie o computador ao final."),
  Num("Instale o Docker Desktop a partir de docker.com/products/docker-desktop. Na instalação, mantenha marcada a opção “Use WSL 2 based engine”."),
  Num("Limite a memória que o WSL2 pode usar. Sem esse limite ele pode tomar metade da RAM do computador e travar o Windows. Crie o arquivo `C:\\Users\\<seu usuário>\\.wslconfig` com o conteúdo abaixo (ajuste `memory` para `10GB` se tiver 16 GB de RAM):"),
  ...Code(["[wsl2]", "memory=6GB", "swap=6GB", "processors=2", "autoMemoryReclaim=gradual"]),
  Num("Execute `wsl --shutdown` no PowerShell e abra o Docker Desktop novamente para o limite valer."),
  Num("Baixe o projeto da sandbox (arquivo ZIP disponibilizado na plataforma) e extraia em uma pasta **sem acentos e sem espaços**, por exemplo `C:\\bigdata-lab`."),
  Num("Abra o PowerShell dentro dessa pasta e execute `.\\lab.ps1 up`. Se o Windows bloquear o script com a mensagem “execução de scripts foi desabilitada”, execute uma única vez `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` e tente de novo."),
  H2("2.3 macOS"),
  Num("Instale o Docker Desktop. Em Settings > Resources, reserve pelo menos 6 GB de memória (10 GB se o Mac tiver 16 GB).", "steps2"),
  Num("Mac com chip Apple: em Settings > General marque “Use Rosetta for x86_64/amd64 emulation”. A imagem da sandbox é x86_64.", "steps2"),
  Num("Extraia o projeto em uma pasta sem espaços e, no Terminal, execute `./lab.sh up`.", "steps2"),
  H2("2.4 Linux"),
  Num("Instale o Docker Engine e o plugin Compose (o comando `docker compose version` precisa funcionar) e adicione seu usuário ao grupo `docker`.", "steps3"),
  Num("Extraia o projeto e execute `./lab.sh up`.", "steps3"),
  H2("2.5 A primeira subida"),
  P("Na primeira execução de `.\\lab.ps1 up` o Docker baixa a imagem da sandbox. O tempo depende da sua conexão. Em seguida o Ambari leva de dois a quatro minutos para responder; o script espera por isso e, ao final, mostra as URLs de acesso. A partir da segunda vez a sandbox sobe em cerca de um minuto."),
  Note("Atualizações", "Quando o professor publicar uma nova versão da imagem, execute `docker compose pull` dentro da pasta do projeto e depois `.\\lab.ps1 up`. Seus dados (HDFS, bancos, arquivos da `maria_dev`) ficam em volumes do Docker e sobrevivem à atualização."),
];

// ---------------------------------------------------------------- 3. uso
const uso = [
  H1("3. Uso no dia a dia"),
  H2("3.1 Os três comandos"),
  ...Code([".\\lab.ps1 up            # sobe a sandbox e espera o Ambari responder", ".\\lab.ps1 aula 7        # prepara a aula 7 (liga só os serviços dela)", ".\\lab.ps1 shell         # abre um terminal dentro da sandbox, como maria_dev"]),
  P("O subcomando `aula` é o coração da sandbox: ele **desliga** os serviços que a aula não usa e **liga** os que ela usa, esperando cada um ficar de pé. Os perfis disponíveis estão na tabela a seguir."),
  ...TblS(["Perfil", "Serviços ligados", "Conteúdo"], [
    ["7", "ZooKeeper, HDFS, YARN, MapReduce2, Hive, Oozie", "Pig e Oozie"],
    ["7a", "ZooKeeper, HDFS, YARN, MapReduce2, Hive", "Só Pig (mais leve)"],
    ["8a", "ZooKeeper, HDFS, YARN, MapReduce2, Hive", "Hive, Sqoop/MariaDB, MapReduce com mrjob"],
    ["8b", "ZooKeeper, HDFS, YARN, MapReduce2, HBase", "HBase (e Pig com HBaseStorage)"],
    ["8c", "ZooKeeper, HDFS + containers Mongo e Cassandra", "MongoDB, Cassandra e Spark 2"],
    ["8d", "ZooKeeper, HDFS, Hive + Mongo/Cassandra", "Drill e Presto"],
    ["9a", "ZooKeeper, HDFS", "Flume"],
    ["9b", "ZooKeeper, Kafka", "Kafka e Kafka Connect"],
    ["9c", "ZooKeeper (+ Storm por `lab storm start`)", "Storm"],
    ["9d", "nenhum", "Flink (standalone)"],
    ["10, 11", "ZooKeeper, HDFS", "PySpark: RDD, DataFrame, Spark SQL, MLlib"],
    ["12", "ZooKeeper, HDFS", "Spark Streaming e Structured Streaming"],
    ["trabalho", "ZooKeeper, HDFS", "Atividade Prática (upload + spark-submit)"],
    ["none", "nenhum", "Desliga tudo; só o Ambari fica no ar"],
  ], [1.2, 4, 3.5]),
  H2("3.2 Outros subcomandos"),
  ...TblS(["Comando", "O que faz"], [
    ["`.\\lab.ps1 status`", "Serviços ligados no Ambari e memória em uso"],
    ["`.\\lab.ps1 stop-all`", "Desliga todos os serviços (o container continua)"],
    ["`.\\lab.ps1 down`", "Para o container; dados preservados nos volumes"],
    ["`.\\lab.ps1 nosql`", "Sobe os containers MongoDB e Cassandra (aulas 8c e 8d)"],
    ["`.\\lab.ps1 mem 16g`", "Perfil de memória para máquinas com 16 GB (padrão: `8g`)"],
    ["`.\\lab.ps1 logs`", "Mostra o log da sandbox"],
    ["`.\\lab.ps1 reset`", "Apaga tudo (HDFS, bancos, arquivos) e volta ao estado inicial. Pede confirmação"],
  ], [2, 5]),
  P("Dentro da sandbox o mesmo utilitário existe como `lab`: `lab aula 8a`, `lab status`, `lab storm start`, `lab urls` e assim por diante."),
  Note("Ao terminar de estudar", [
    "Execute `.\\lab.ps1 stop-all` ou `.\\lab.ps1 down`. Os serviços consomem cada vez mais memória se ficarem ligados por muitas horas, mesmo sem uso, e o computador fica lento. O capítulo 7 explica o motivo.",
  ]),
  H2("3.3 Onde ficam os arquivos"),
  P("A pasta do projeto no seu computador tem duas subpastas que aparecem dentro da sandbox:"),
  Bullet("`aulas/` — os arquivos de cada aula (scripts Pig, Python, configurações do Flume etc.), já com os erros de digitação do material original corrigidos. Dentro da sandbox: `/home/maria_dev/aulas`."),
  Bullet("`data/` — os conjuntos de dados (`ml-100k`, `customer-orders.csv`, `access_log.txt`, `movielens.sql`). Dentro da sandbox: `/home/maria_dev/data-host`. Uma cópia dos dados pequenos já existe em `/home/maria_dev/data`, e o `ml-100k` já está carregado no HDFS em `/user/maria_dev/ml-100k`."),
  P("Arquivos que você criar no home da `maria_dev` dentro da sandbox ficam guardados em um volume do Docker e persistem entre reinicializações, até um `reset`."),
];

// ---------------------------------------------------------------- 4. ambiente
const amb = [
  H1("4. O ambiente"),
  H2("4.1 Acessos e senhas"),
  ...TblS(["Acesso", "Endereço", "Usuário / senha"], [
    ["Ambari", "http://localhost:8080", "`admin/admin`, `raj_ops/raj_ops` ou `maria_dev/maria_dev`"],
    ["Terminal no navegador", "http://localhost:4200", "`maria_dev/maria_dev`"],
    ["SSH (PuTTY ou terminal)", "`ssh -p 2222 maria_dev@localhost`", "`maria_dev`"],
    ["Página com todos os links", "http://localhost:8888", "—"],
    ["MariaDB (o MySQL das aulas)", "`mysql -u root -phadoop` dentro da sandbox", "`root/hadoop`"],
    ["Root do Linux da sandbox", "`.\\lab.ps1 root`", "`root/hadoop`"],
  ], [2.5, 3, 3]),
  P("O nome do host continua sendo `sandbox.hortonworks.com`, o HDFS responde em `hdfs://sandbox.hortonworks.com:8020` e o ResourceManager na porta 8050. Por isso os arquivos de configuração das aulas (como o `job.properties` do Oozie) funcionam sem alteração."),
  H2("4.2 Interfaces web"),
  ...TblS(["Interface", "Endereço", "Quando está disponível"], [
    ["Ambari (serviços, Files View, Workflow Manager)", "http://localhost:8080", "Sempre"],
    ["HDFS — NameNode", "http://localhost:9870", "Perfis com HDFS"],
    ["YARN — ResourceManager", "http://localhost:8088", "Perfis com YARN"],
    ["MapReduce — histórico de jobs", "http://localhost:19888", "Perfis com MapReduce2"],
    ["HiveServer2", "http://localhost:10002", "Perfis com Hive"],
    ["Oozie", "http://localhost:11000/oozie", "Perfil 7"],
    ["HBase Master", "http://localhost:16010", "Perfil 8b"],
    ["Storm UI", "http://localhost:8744", "Após `lab storm start`"],
    ["Flink", "http://localhost:8082", "Após `start-cluster.sh` (aula 9)"],
    ["Drill / Presto", "http://localhost:8756 / http://localhost:8090", "Após iniciá-los (aula 8d)"],
    ["Spark UI do job em execução", "http://localhost:4040", "Enquanto um `spark-submit` roda"],
    ["Zeppelin (notebooks)", "http://localhost:9995", "Após `lab start ZEPPELIN`"],
  ], [3.2, 3, 2.3]),
  Note("Porta do NameNode", "Nos vídeos a interface do NameNode aparece na porta 50070. Dentro da sandbox ela continua nessa porta, mas no seu navegador o endereço é `localhost:9870`, porque o Windows reserva a faixa 50000–50959 para uso interno."),
  H2("4.3 O Ambari"),
  P("O Ambari é o mesmo painel dos vídeos: mostra o estado de cada serviço, permite ligar e desligar pelo menu “Service Actions” e traz o **Files View** (menu de nove pontos no canto superior direito), usado para enviar arquivos ao HDFS. Duas views que existiam no HDP 2.6.5 não estão mais disponíveis: o **Hive View** (o Ambari 2.7 o removeu) e o **Pig View** (depende de um componente que a distribuição ODP não inclui). Nos dois casos o guia de cada aula mostra como fazer a mesma coisa pelo terminal."),
  P("Você pode ligar e desligar serviços pelo Ambari, exatamente como o professor faz nos vídeos. O comando `lab aula` apenas automatiza essa sequência e cuida da ordem correta."),
  H2("4.4 Os dois Sparks"),
  P("Como no HDP, a sandbox tem duas versões do Spark, escolhidas pela variável `SPARK_MAJOR_VERSION`. O Python correto é selecionado automaticamente."),
  ...TblS(["", "Spark 2", "Spark 3"], [
    ["Versão", "2.4.8 (Scala 2.12)", "3.5.1 (Scala 2.12)"],
    ["Selecionar", "`export SPARK_MAJOR_VERSION=2`", "`export SPARK_MAJOR_VERSION=3` (padrão)"],
    ["Python", "3.7 (automático)", "3.9 (automático)"],
    ["Quando usar", "Aula 12 (Spark Streaming com Flume) e para reproduzir o vídeo", "Aulas 10 e 11 e a Atividade Prática"],
  ], [1.5, 3.5, 3.5]),
  P("Os scripts das aulas rodam nas duas versões. Atenção a um detalhe herdado do HDP: `sc.textFile(\"u.data\")` sem caminho absoluto lê do **HDFS** (`/user/maria_dev/u.data`), não da pasta atual. Para ler um arquivo local use o prefixo `file://`, por exemplo `file:///home/maria_dev/aulas/aula10/01-RatingsCounter/u.data`."),
];

// ---------------------------------------------------------------- 5. aulas
const aulas = [
  H1("5. Roteiro das aulas práticas"),
  P("Cada seção começa pelo comando que prepara a sandbox e depois segue a ordem do vídeo, apontando o que mudou. Os arquivos citados estão em `~/aulas/aulaNN` dentro da sandbox."),

  H2("5.1 Aula 7 — Pig e Oozie"),
  ...Code([".\\lab.ps1 aula 7       # ou  aula 7a  (só Pig, mais leve)"]),
  P("O `ml-100k` já está no HDFS em `/user/maria_dev/ml-100k`. O vídeo mostra o envio pelo Files View; você pode repetir para praticar, a pasta é a mesma."),
  H3("Pig"),
  P("O Pig View não está disponível; use o terminal, como o vídeo faz na segunda parte. O `pig` roda no Tez sobre o YARN lendo do HDFS. Existe também o modo local (`pig -x local`), que lê do disco: nesse caso troque `/user/maria_dev/ml-100k` por `/home/maria_dev/data/ml-100k` no script."),
  ...Code(["cd ~/aulas/aula07/Pig_exercise", "pig MostRatedFiveStarMovie.pig", "pig OldestFiveStarMovie.pig"]),
  P("Correções feitas no material original: `ORDER finalResults BY numRatings DESC` (a forma `... AS numRatings DESC` não é Pig Latin válido) e `videoRelease` (estava `videoRealese`)."),
  H3("Oozie"),
  P("Os arquivos `job.properties`, `workflow.xml` e `oldmovies.sql` funcionam sem alteração. O banco `movielens` já está carregado no MariaDB, então a ação Sqoop do workflow encontra a tabela `movies`."),
  ...Code(["cd ~/aulas/aula07/Oozie_exercise", "hdfs dfs -put -f workflow.xml oldmovies.sql /user/maria_dev/", "oozie job -oozie http://localhost:11000/oozie -config job.properties -run", "oozie job -oozie http://localhost:11000/oozie -info <ID retornado>", "hdfs dfs -cat /user/maria_dev/oldmovies/*"]),
  P("Acompanhe em `http://localhost:11000/oozie` ou no Ambari, em **Workflow Manager** (uma view nova, que não existia no HDP 2.6.5). O workflow leva de três a cinco minutos. No log aparece um aviso de que a classe `com.mysql.jdbc.Driver` está obsoleta; pode ignorar."),

  H2("5.2 Aula 8 — Hive, Sqoop, MapReduce, HBase, NoSQL, Drill e Presto"),
  P("A aula 8 usa muitos serviços e não cabe inteira em 8 GB. Ela foi dividida em quatro perfis; prepare um de cada vez."),
  ...TblS(["Perfil", "Comando", "Temas"], [
    ["8a", "`.\\lab.ps1 aula 8a`", "Hive, Sqoop e MariaDB, MapReduce com mrjob"],
    ["8b", "`.\\lab.ps1 aula 8b`", "HBase e Pig com HBaseStorage"],
    ["8c", "`.\\lab.ps1 nosql` e depois `.\\lab.ps1 aula 8c`", "MongoDB, Cassandra e Spark 2"],
    ["8d", "`.\\lab.ps1 nosql` e depois `.\\lab.ps1 aula 8d`", "Drill e Presto"],
  ], [1, 3.5, 4]),
  H3("8a — Hive"),
  P("No HDP as tabelas eram criadas pelo “Upload Table” do Hive View, que não existe mais. O `lab aula 8a` cria automaticamente as tabelas `ratings` e `names` com o mesmo layout do vídeo. Para consultar, use o `beeline` (o comando `hive` também o abre):"),
  ...Code(["beeline -u jdbc:hive2://localhost:10000 -n maria_dev", "SHOW TABLES;", "SELECT * FROM ratings LIMIT 5;", "!run /home/maria_dev/aulas/aula08/Hive_example/MostPopularMovie.sql"]),
  P("Alternativa com interface web: o Zeppelin (`lab start ZEPPELIN`, depois `http://localhost:9995`), com o interpretador `%jdbc(hive)`. Ele consome cerca de 1 GB de RAM."),
  H3("8a — Sqoop e MariaDB"),
  P("O MySQL do HDP virou MariaDB, com o mesmo usuário `root` e senha `hadoop`. O banco `movielens` já está carregado. O acesso anônimo ao banco está liberado, como no HDP, então os comandos do vídeo, sem usuário e senha, também funcionam."),
  ...Code(["sqoop import --connect jdbc:mysql://localhost/movielens \\", "  --driver com.mysql.jdbc.Driver --username root --password hadoop \\", "  --table movies -m 1", "", "sqoop import --connect jdbc:mysql://localhost/movielens \\", "  --driver com.mysql.jdbc.Driver --username root --password hadoop \\", "  --table movies -m 1 --hive-import"]),
  P("O material original trazia o erro de digitação `.com.mysql.jdbc.Driver` (um ponto a mais no início)."),
  H3("8a — MapReduce com mrjob"),
  P("O `mrjob 0.7.4` já está instalado no Python 3. O código do exercício é o mesmo do vídeo."),
  ...Code(["cd ~/aulas/aula08", "# local:", "python MapReduce_exercise.py ~/data/ml-100k/u.data", "# no YARN:", "python MapReduce_exercise.py -r hadoop \\", "  --hadoop-streaming-jar \\", "  /usr/odp/current/hadoop-mapreduce-client/hadoop-streaming.jar \\", "  hdfs:///user/maria_dev/ml-100k/u.data"]),
  H3("8b — HBase"),
  ...Code(["hbase shell", "  create 'users', 'userinfo'", "  list", "  exit", "cd ~/aulas/aula08/HBase_example && pig hbase.pig", "hbase shell", "  count 'users'", "  scan 'users', {LIMIT => 5}"]),
  Note("Phoenix — limitação conhecida", "O Phoenix 5.1.3 que vem na distribuição ODP 1.2.4 não é compatível com o HBase 2.5.6 da mesma distribuição: a conexão falha tanto no `sqlline.py` quanto no Query Server. Enquanto não houver um client compatível, estude o Phoenix pela leitura do `Phoenix.txt` (com o DDL corrigido) e pratique o acesso ao HBase pelo `hbase shell`, pelo Pig e pelo Spark."),
  H3("8c — MongoDB e Cassandra"),
  P("No HDP o Mongo era instalado como serviço do Ambari e o Cassandra por `yum`; os dois repositórios não existem mais. Na sandbox eles são dois containers oficiais que compartilham a rede da sandbox e continuam respondendo em `127.0.0.1`, de modo que os scripts `MongoSpark.py` e `CassandraSpark.py` rodam sem alteração."),
  ...Code([".\\lab.ps1 nosql        # no seu computador: sobe mongo e cassandra"]),
  P("Dentro da sandbox, com o Spark 2 (os pacotes já estão em cache, nada é baixado):"),
  ...Code(["export SPARK_MAJOR_VERSION=2", "cd ~/aulas/aula08/MongoDB", "spark-submit --packages org.mongodb.spark:mongo-spark-connector_2.12:2.4.4 MongoSpark.py", "cd ~/aulas/aula08/Cassandra", "spark-submit \\", "  --packages com.datastax.spark:spark-cassandra-connector_2.12:2.5.2 \\", "  CassandraSpark.py"]),
  P("Antes do `CassandraSpark.py` crie o keyspace e a tabela (comandos do `installing.txt`). Os shells rodam **no seu computador**, não dentro da sandbox:"),
  ...Code(["docker compose exec mongo mongo          # shell do Mongo", "docker compose exec cassandra cqlsh      # cqlsh"]),
  P("No log do `CassandraSpark.py` aparece um erro `NoClassDefFoundError: jnr/posix/POSIXHandler`; ele vem de um componente opcional do driver e não impede a gravação. Confira com `SELECT COUNT(*) FROM movielens.users` no `cqlsh`."),
  H3("8d — Drill e Presto"),
  P("Os pacotes já estão baixados em `~/downloads`, não é preciso `wget`. As versões são Drill 1.21.2 (a 1.12 do vídeo não conversa com o Hive 3) e Presto 0.235.1 (a mesma do vídeo)."),
  ...Code(["cd ~ && tar -xzf downloads/apache-drill-1.21.2.tar.gz && cd apache-drill-1.21.2", "bin/drillbit.sh start -Ddrill.exec.port=8756      # UI: http://localhost:8756", "bin/drillbit.sh stop"]),
  P("No Drill, em Storage > hive > Update, informe `\"hive.metastore.uris\": \"thrift://localhost:9083\"`, como no vídeo."),
  ...Code(["cd ~ && tar -xzf downloads/presto-server-0.235.1.tar.gz && cd presto-server-0.235.1", "cp -r ~/downloads/presto-etc/etc .                 # config da aula, heap reduzido", "cp ~/downloads/presto-cli-0.235.1-executable.jar bin/presto && chmod +x bin/presto", "bin/launcher start                                 # UI: http://localhost:8090", "bin/presto --server 127.0.0.1:8090 --catalog hive", "bin/launcher stop"]),

  H2("5.3 Aula 9 — Flume, Kafka, Storm e Flink"),
  ...TblS(["Perfil", "Comando", "Tema"], [
    ["9a", "`.\\lab.ps1 aula 9a`", "Flume"],
    ["9b", "`.\\lab.ps1 aula 9b`", "Kafka"],
    ["9c", "`.\\lab.ps1 aula 9c` e, na sandbox, `lab storm start`", "Storm"],
    ["9d", "`.\\lab.ps1 aula 9d`", "Flink"],
  ], [1, 4, 3.5]),
  P("Os temas de Hive, HBase, Mongo, Cassandra, Drill e Presto da aula 9 são os mesmos da aula 8; o Spark Streaming está na aula 12."),
  H3("Flume (9a)"),
  P("O Flume 1.11 está em `/usr/hdp/current/flume-server`, como no vídeo. As pastas `~/spool` e `~/checkpoint` já existem."),
  ...Code(["cp ~/aulas/aula09/Flume/*.conf ~/", "cd /usr/hdp/current/flume-server/", "bin/flume-ng agent --conf conf --conf-file ~/example.conf --name a1 -Dflume.root.logger=INFO,console", "# em outro terminal:", "nc localhost 44444        # ou: telnet localhost 44444"]),
  P("Para o exemplo spooldir → HDFS (`flumelogs.conf`), crie a pasta `/user/maria_dev/flume` pelo Files View (ou `hdfs dfs -mkdir /user/maria_dev/flume`) e copie `cp ~/data/access_log_small.txt ~/spool/log.txt`."),
  H3("Kafka (9b)"),
  P("O Kafka é o 3.6 (o HDP tinha o 1.0). A porta do broker continua 6667. A mudança que importa: as ferramentas não aceitam mais `--zookeeper`; use `--bootstrap-server`."),
  ...TblS(["No vídeo", "Na sandbox"], [
    ["`kafka-topics.sh --create --zookeeper sandbox.hortonworks.com:2181 ...`", "`kafka-topics.sh --create --bootstrap-server localhost:6667 --replication-factor 1 --partitions 1 --topic Teste`"],
    ["`kafka-topics.sh --list --zookeeper ...`", "`kafka-topics.sh --list --bootstrap-server localhost:6667`"],
    ["`kafka-console-producer.sh --broker-list ...:6667 --topic Teste`", "Igual (`--broker-list` ainda funciona)"],
    ["`kafka-console-consumer.sh --bootstrap-server ...:6667 --zookeeper localhost:2181 --topic Teste --from-beginning`", "Remova `--zookeeper localhost:2181`"],
    ["`./kafka-standalone.sh ...`", "`./connect-standalone.sh ~/connect-standalone.properties ~/connect-file-source.properties ~/connect-file-sink.properties`"],
  ], [1, 1]),
  P("Os scripts ficam em `/usr/hdp/current/kafka-broker/bin` e os arquivos `.properties` de exemplo em `/usr/hdp/current/kafka-broker/config` (no HDP a pasta chamava `conf`)."),
  H3("Storm (9c)"),
  P("O Storm 2.8.9 é instalado à parte do Ambari. Em vez de “Ambari > Storm > Start”, use o comando abaixo dentro da sandbox. O restante é igual ao vídeo."),
  ...Code(["lab storm start          # nimbus, supervisor e UI (http://localhost:8744); aguarde ~30 s", "storm jar /usr/hdp/current/storm-client/contrib/storm-starter/storm-starter-topologies-*.jar \\", "  org.apache.storm.starter.WordCountTopology wordcount", "storm list", "storm kill wordcount", "lab storm stop"]),
  P("O código-fonte do exemplo está em `/usr/hdp/current/storm-client/examples/storm-starter/src/jvm/org/apache/storm/starter/WordCountTopology.java`; `contrib` é um atalho para `examples`. Os logs ficam em `/var/log/storm/workers-artifacts`."),
  H3("Flink (9d)"),
  P("O Flink 1.20 já está em `~/downloads` (o 1.10 do vídeo não roda no Java atual). Dois comandos mudaram de nome: `start-local.sh` virou `start-cluster.sh` e a porta da interface passa a ser definida por `rest.port` no arquivo `conf/config.yaml`."),
  ...Code(["cd ~ && tar -xzf downloads/flink-1.20.5-bin-scala_2.12.tgz && cd flink-1.20.5", "grep -q '^rest.port' conf/config.yaml \\", "  && sed -i 's/^rest.port: .*/rest.port: 8082/' conf/config.yaml \\", "  || echo 'rest.port: 8082' >> conf/config.yaml", "./bin/start-cluster.sh                      # UI: http://localhost:8082", "./bin/flink run examples/streaming/SocketWindowWordCount.jar --port 9000", "# em outro terminal:  nc -l 9000   e digite palavras", "tail -f log/flink-*-taskexecutor-*.out", "./bin/stop-cluster.sh"]),

  H2("5.4 Aulas 10 e 11 — PySpark"),
  ...Code([".\\lab.ps1 aula 10"]),
  P("Liga apenas ZooKeeper e HDFS; o Spark roda em modo local. Como no HDP, os scripts leem `u.data`, `u.item` e `customer-orders.csv` do **HDFS** (`/user/maria_dev`). No vídeo o professor envia esses arquivos pelo Files View; na sandbox eles já estão lá, e você pode repetir o envio para praticar. Os `open(\"u.item\")` do Python leem o arquivo local da pasta do script."),
  ...Code(["cd ~/aulas/aula10/01-RatingsCounter && spark-submit ratings-counter.py", "cd ~/aulas/aula10/02-CustomerOrder", "spark-submit customer-orders.py && spark-submit customer-orders-ordered.py", "cd ~/aulas/aula10/03-MostPopularMovies", "spark-submit popular-movies.py && spark-submit popular-movies-names.py", "spark-submit popular-movies-dataframe.py", "cd ~/aulas/aula10/04-SparkSQL && spark-submit spark-sql.py", "cd ~/aulas/aula10/05-MLLib && spark-submit movie-recommendations-als.py 50"]),
  Bullet("Os scripts rodam no Spark 3 (padrão) e no Spark 2 (`export SPARK_MAJOR_VERSION=2`)."),
  Bullet("`04-SparkSQL` lê `customer-order.csv`, no singular; a pasta já traz o arquivo com esse nome (no material da aula 10 o nome estava no plural e o script falhava; a aula 11 corrigiu)."),
  Bullet("`05-MLLib` cria a pasta `checkpoint` no diretório atual."),
  Bullet("A aula 11 repete a aula 10; a pasta `aula11` tem os mesmos arquivos."),

  H2("5.5 Aula 12 — Spark Streaming e Structured Streaming"),
  ...Code([".\\lab.ps1 aula 12"]),
  P("O exercício Flume → Spark exige o **Spark 2**: o pacote `spark-streaming-flume` não existe no Spark 3. A sandbox mantém o Spark 2.4.8 justamente para isso. Abra três terminais (o terminal web abre quantas abas quiser)."),
  ...Code(["# terminal 1 — Spark", "cd ~/aulas/aula12/SparkStreaming", "export SPARK_MAJOR_VERSION=2", "spark-submit --packages org.apache.spark:spark-streaming-flume_2.12:2.4.8 SparkFlume.py"]),
  ...Code(["# terminal 2 — Flume com sink Avro na porta 9092", "cp ~/aulas/aula12/SparkStreaming/sparkstreamingflume.conf ~/", "cd /usr/hdp/current/flume-server/", "bin/flume-ng agent --conf conf --conf-file ~/sparkstreamingflume.conf --name a1"]),
  ...Code(["# terminal 3 — alimentar o spool", "cp ~/data/access_log.txt ~/spool/log.txt", "cp ~/data/access_log.txt ~/spool/log2.txt      # a contagem dobra"]),
  P("Diferença do vídeo: o pacote `spark-streaming-flume_2.11:2.0.0` virou `spark-streaming-flume_2.12:2.4.8`. O `SparkFlume2.py` (contagem por status HTTP) roda do mesmo jeito. Para o Structured Streaming, a pasta `logs` lida por `spark.readStream.text(\"logs\")` fica no HDFS:"),
  ...Code(["cd ~/aulas/aula12/SparkStreaming", "hdfs dfs -mkdir -p logs", "spark-submit structured-streaming.py", "# em outro terminal:  hdfs dfs -put ~/data/access_log.txt logs/   (ou pelo Files View)"]),
];

// ---------------------------------------------------------------- 6. trabalho
const trab = [
  H1("6. A Atividade Prática na sandbox"),
  P("O Roteiro da Atividade Prática aceita várias formas de execução (Google Colab, máquina virtual, Docker, nuvem). Esta seção descreve a forma Docker. As regras do roteiro continuam valendo: sem pandas, prints com o seu RU visível, entrega em PDF."),
  ...Code([".\\lab.ps1 aula trabalho      # liga ZooKeeper e HDFS"]),
  H2("6.1 Colocar o dataset na sandbox"),
  Num("Baixe o arquivo `imdb-reviews-pt-br.csv` pelo link do roteiro e copie-o para a pasta `data/` do projeto no seu computador. Ele aparece dentro da sandbox em `/home/maria_dev/data-host/`.", "trab"),
  Num("No Ambari (`http://localhost:8080`, usuário `maria_dev`), abra o **Files View**, entre em `user` > `maria_dev` e clique em **Upload** para enviar o CSV ao HDFS. O equivalente por comando é `hdfs dfs -put ~/data-host/imdb-reviews-pt-br.csv /user/maria_dev/`.", "trab"),
  Num("No terminal da sandbox, confira e traga o arquivo para o disco local, como no roteiro:", "trab"),
  ...Code(["hadoop fs -ls                                              # lista /user/maria_dev", "hdfs dfs -copyToLocal /user/maria_dev/imdb-reviews-pt-br.csv .", "grep -A1 fs.defaultFS /etc/hadoop/conf/core-site.xml   # ...:8020"]),
  H2("6.2 Executar o script"),
  P("Use o Spark 3 (é o padrão; é a mesma versão do PySpark do Colab). Há um esqueleto pronto em `~/aulas/trabalho/trabalho_RU.py`:"),
  ...Code(["cp ~/aulas/trabalho/trabalho_RU.py ~/trabalho_SEU_RU.py   # renomeie com o seu RU", "nano ~/trabalho_SEU_RU.py                                  # preencha as funções", "spark-submit ~/trabalho_SEU_RU.py                          # print com o RU visível"]),
  Note("Onde o Spark procura o arquivo", "`spark.read.csv('imdb-reviews-pt-br.csv')` lê do **HDFS** (`/user/maria_dev`), como no HDP; por isso o passo do Files View. Para ler o arquivo local trazido pelo `copyToLocal`, use `file:///home/maria_dev/imdb-reviews-pt-br.csv`."),
  P("Também é possível usar o `pyspark` interativo: `imdb_df = spark.read.csv('imdb-reviews-pt-br.csv', header=True, quote='\"', escape='\"', encoding='UTF-8')`. Os parâmetros `quote` e `escape` são obrigatórios: sem eles o texto em português “vaza” para a coluna `sentiment`, o erro mais comum nas entregas."),
  H2("6.3 Conferir"),
  P("O script abaixo executa o seu programa e verifica se as respostas caem na faixa esperada. Ele não substitui as regras do roteiro; serve para você ter certeza de que a leitura do CSV está correta."),
  ...Code(["bash ~/aulas/trabalho/verifica.sh ~/trabalho_SEU_RU.py"]),
];

// ---------------------------------------------------------------- 7. memória
const mem = [
  H1("7. Memória e boas práticas"),
  P("A máquina virtual HDP precisava de 8 GB só para ela. Na sandbox o Ambari liga apenas os serviços de cada aula, e serviço parado não consome memória. A tabela mostra o consumo aproximado do container em cada perfil, com o perfil de memória padrão (`8g`)."),
  ...TblS(["Perfil", "Serviços", "Memória aproximada"], [
    ["base (sempre)", "Ambari, PostgreSQL, MariaDB, sshd, terminal web", "1,0 a 1,3 GB"],
    ["9d", "nenhum (Flink standalone)", "2 GB"],
    ["10, 11, 12, trabalho, 9a", "ZooKeeper, HDFS (+ Spark local)", "2,5 GB"],
    ["9b", "ZooKeeper, Kafka", "2,3 GB"],
    ["9c", "ZooKeeper + Storm", "3 GB"],
    ["8c", "ZooKeeper, HDFS + Mongo (0,5 GB) + Cassandra (1,5 GB)", "4,5 GB"],
    ["8d", "ZooKeeper, HDFS, Hive + Mongo/Cassandra", "4,5 GB"],
    ["8a, 7a, 8b", "ZooKeeper, HDFS, YARN, MapReduce2, Hive ou HBase", "4,8 GB"],
    ["7", "8a + Oozie", "5,5 GB"],
  ], [2, 4.5, 2]),
  H2("7.1 Perfis de memória 8g e 16g"),
  P("Com 8 GB no computador, mantenha o perfil padrão (`8g`) e o `.wslconfig` com `memory=6GB`. Os perfis 7, 8a e 8d ficam lentos, mas funcionam; feche o navegador com muitas abas. Com 12 a 16 GB, dê 10 GB ao Docker e execute `.\\lab.ps1 mem 16g`: os serviços ganham heaps maiores e os jobs ficam mais rápidos."),
  ...TblS(["", "Perfil `8g`", "Perfil `16g`"], [
    ["Heap do Oozie", "384 MB", "512 MB"],
    ["Timeline Server e Timeline Reader do YARN", "Ficam parados (o `lab aula` os desliga após ligar o YARN)", "Ligados"],
  ], [2.5, 3, 3]),
  P("O que se perde sem o Timeline no perfil `8g`: a interface do YARN (`localhost:8088`) não lista as aplicações **concluídas** que rodaram em Tez (Pig e Hive). O comando `yarn logs -applicationId` e o histórico do MapReduce (`localhost:19888`) continuam funcionando. No Ambari esses dois componentes aparecem como “Stopped”; é o esperado."),
  H2("7.2 Não deixe os serviços ligados por horas a fio"),
  P("Medição real com o perfil 7: logo após ligar, o container usa cerca de 5,4 GB; depois de um dia inteiro ligado, mesmo sem uso, chega a 7 GB (o limite), o processador fica ocupado e o Ambari para de responder. Os processos Java (Oozie, HiveServer2, Metastore) crescem lentamente com o tempo, e o cache de disco do HDFS também conta no limite do container."),
  Note("Regra prática", [
    "Ao terminar a sessão de estudo, execute `lab aula none` (para todos os serviços e mantém o Ambari) ou `.\\lab.ps1 down` (para o container; os dados ficam nos volumes).",
    "Se o Ambari deixar de responder (`.\\lab.ps1 status` trava), execute `docker restart sandbox-hdp`. Em cerca de três minutos tudo volta, sem perda de dados.",
  ]),
  H2("7.3 Sinais de falta de memória"),
  Bullet("Um serviço fica vermelho no Ambari logo depois de ligar: veja `lab status` (coluna de memória por processo) e o log em `/var/log/<serviço>`."),
  Bullet("Mensagem `Container killed on request. Exit code is 137` em um job do YARN: aumente o `swap` no `.wslconfig` ou use um perfil menor (`7a` em vez de `7`)."),
  Bullet("O Docker Desktop trava o Windows: o valor de `memory` no `.wslconfig` está alto demais para a máquina."),
];

// ---------------------------------------------------------------- 8. problemas
const prob = [
  H1("8. Problemas comuns"),
  ...TblS(["Sintoma", "O que fazer"], [
    ["`.\\lab.ps1` não roda (“execução de scripts foi desabilitada”)", "Execute uma vez `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` no PowerShell."],
    ["`docker: error during connect` ou “Docker Desktop is not running”", "Abra o Docker Desktop e espere o ícone ficar estável. No Windows, confira o WSL2 com `wsl --status`."],
    ["Ambari não abre em `localhost:8080` após alguns minutos", "Veja `.\\lab.ps1 logs`. Se a porta 8080 estiver em uso por outro programa, troque-a no `docker-compose.yml` (por exemplo `\"8081:8080\"`)."],
    ["Serviço fica vermelho no Ambari ao ligar", "Ambari > Background Operations > clique na operação e leia o `stderr`. Causas comuns: memória (capítulo 7) e disco cheio do Docker (`docker system df`; limpe com `docker system prune`)."],
    ["`lab aula` falha com “requisição falhou”", "Repita o comando: o Ambari às vezes falha no primeiro start do NameNode após um restart. Persistindo, `lab stop-all` e tente de novo."],
    ["HDFS em “safe mode”", "Aguarde um minuto. Se continuar: `sudo -u hdfs hdfs dfsadmin -safemode leave` dentro da sandbox."],
    ["`Permission denied` ao gravar no HDFS", "Você está como `root`. Use `su - maria_dev` ou o terminal web com `maria_dev`."],
    ["Esqueci a senha do `admin` do Ambari", "É `admin`. Se a trocou e perdeu: `ambari-admin-password-reset` dentro da sandbox, como root."],
    ["Spark reclama da versão do Python", "Em shells de login a variável `SPARK_MAJOR_VERSION` escolhe o Python certo. Em um shell aberto por `docker exec` sem `-l`, execute `source /etc/profile.d/spark-python.sh`."],
    ["Mongo ou Cassandra não conectam em 127.0.0.1", "Os containers precisam estar de pé: `.\\lab.ps1 nosql`. O Cassandra leva cerca de um minuto para aceitar conexões."],
    ["Mac com chip Apple está muito lento", "Confirme “Use Rosetta for x86_64/amd64 emulation” no Docker Desktop. Prefira os perfis leves (10, 11, 12, trabalho). Para a Atividade Prática o Colab continua sendo a opção mais leve."],
    ["Quero começar do zero", "`.\\lab.ps1 reset` apaga HDFS, bancos e os arquivos da `maria_dev`."],
  ], [3, 5.5]),
];

// ---------------------------------------------------------------- apêndices
const apA = [
  H1("Apêndice A — Versões dos componentes"),
  ...TblS(["Componente", "HDP 2.6.5 (vídeos)", "Sandbox"], [
    ["Ambari", "2.6.2", "2.7.11 (Clemlab); sem Hive View, Tez View e Pig View; com Files View e Workflow Manager"],
    ["Hadoop (HDFS, YARN, MapReduce)", "2.7.3", "3.3.6"],
    ["Hive", "1.2 / 2.1", "3.1.3 (`hive` abre o beeline)"],
    ["Tez", "0.7", "0.10.2"],
    ["Pig", "0.16", "0.18 (terminal)"],
    ["Sqoop", "1.4.6", "1.4.7"],
    ["Oozie", "4.2", "5.2.1"],
    ["HBase / Phoenix", "1.1 / 4.7", "2.5.6 / 5.1.3 (Phoenix não conecta; ver 5.2)"],
    ["Kafka", "1.0", "3.6.2 (porta 6667 mantida; sem `--zookeeper`)"],
    ["Spark", "2.3 (Scala 2.11)", "2.4.8 e 3.5.1 (ambos Scala 2.12; `spark.master=local[*]`)"],
    ["Python", "2.7", "3.9 (Spark 3, mrjob) e 3.7 (Spark 2)"],
    ["Zeppelin", "0.7", "0.11"],
    ["Flume", "1.5", "1.11"],
    ["Storm", "1.1 (serviço Ambari)", "2.8.9 (`lab storm start`)"],
    ["Flink", "1.10", "1.20 (em `~/downloads`)"],
    ["Drill", "1.12", "1.21.2 (em `~/downloads`)"],
    ["Presto", "0.235.1", "0.235.1 (em `~/downloads`, heap 1,5 GB)"],
    ["MongoDB", "3.2 (serviço Ambari)", "4.4 (container `mongo`)"],
    ["Cassandra", "3.0", "3.11 (container `cassandra`)"],
    ["MySQL", "MySQL 5 (root sem senha)", "MariaDB 10 (`root`/`hadoop`)"],
    ["Sistema operacional", "CentOS 7", "Rocky Linux 9 (`dnf`; `yum` continua como atalho)"],
  ], [2.2, 2.3, 4]),
];

const apB = [
  H1("Apêndice B — Errata dos materiais originais"),
  P("Os arquivos em `aulas/` já vêm com estas correções aplicadas. A lista serve para quem comparar com o material original dos vídeos."),
  ...TblS(["Onde", "Antes", "Agora"], [
    ["Kafka", "`--zookeeper host:2181`", "`--bootstrap-server localhost:6667`"],
    ["Kafka Connect", "`kafka-standalone.sh` (erro no material)", "`connect-standalone.sh`"],
    ["Flink", "`start-local.sh`; `jobmanager.web.port`", "`start-cluster.sh`; `rest.port` em `conf/config.yaml`"],
    ["Sqoop", "`--driver .com.mysql.jdbc.Driver` (ponto a mais)", "`--driver com.mysql.jdbc.Driver`"],
    ["Spark + Mongo", "`mongo-spark-connector_2.11:2.0.0`", "`mongo-spark-connector_2.12:2.4.4` (Spark 2) ou `_2.12:10.4.1` (Spark 3)"],
    ["Spark + Cassandra", "`datastax:spark-cassandra-connector:2.0.0-M2-s_2.11`", "`com.datastax.spark:spark-cassandra-connector_2.12:2.5.2` (Spark 2) ou `_2.12:3.5.1` (Spark 3)"],
    ["Spark + Flume", "`spark-streaming-flume_2.11:2.0.0`", "`spark-streaming-flume_2.12:2.4.8` (somente Spark 2)"],
    ["Pig", "`ORDER ... BY numRatings AS numRatings DESC`; `videoRealese`; `numRatigs`", "`ORDER ... BY numRatings DESC`; `videoRelease`; `numRatings`"],
    ["Phoenix (DDL)", "`PRIMARY_KEY (state,city)`; `CONTRAINT`; parêntese faltando", "`PRIMARY KEY (estado, cidade)`; `CONSTRAINT`; DDL completo"],
    ["Presto", "`connector.name=cassadra`; `bin/laucher`; `limited 10`; `where ratings = 5`", "`cassandra`; `launcher`; `limit 10`; `where rating = 5`"],
    ["Cassandra (CQL)", "`{'class'; 'SimpleStrategy'`", "`{'class': 'SimpleStrategy'`"],
    ["Aula 10, SparkSQL", "script lia `customer-order.csv`, arquivo chamava `customer-orders.csv`", "arquivo renomeado para `customer-order.csv` (como na aula 11)"],
    ["Oozie `job.properties`", "espaço sobrando no fim de `queueName=default`", "removido"],
    ["Hive View “Upload Table”", "interface do Ambari", "tabelas criadas por `lab aula 8a` (ou beeline/Zeppelin)"],
    ["Storm / MongoDB no Ambari", "Service Actions > Start", "`lab storm start` / `.\\lab.ps1 nosql`"],
  ], [1.8, 3.3, 3.9]),
];

const apC = [
  H1("Apêndice C — O que é igual e o que é diferente da VM HDP"),
  H2("Igual"),
  Bullet("Ambari em `localhost:8080`; usuários `admin/admin`, `raj_ops/raj_ops`, `maria_dev/maria_dev`."),
  Bullet("Terminal web em `localhost:4200`; SSH `maria_dev@localhost -p 2222`."),
  Bullet("Host `sandbox.hortonworks.com`; HDFS `hdfs://sandbox.hortonworks.com:8020`; ResourceManager na porta 8050."),
  Bullet("Home `/home/maria_dev`; `/user/maria_dev` no HDFS com o `ml-100k` já carregado."),
  Bullet("Layout `/usr/hdp/current/<componente>` (atalho para `/usr/odp/current`)."),
  Bullet("`export SPARK_MAJOR_VERSION=2` para o Spark 2."),
  Bullet("Files View no Ambari; MySQL/MariaDB `root/hadoop` com o banco `movielens`."),
  H2("Diferente"),
  ...TblS(["Assunto", "VM HDP 2.6.5", "Sandbox"], [
    ["Distribuição", "Hortonworks HDP (descontinuada)", "ODP 1.2.4 (Clemlab) + Ambari 2.7.11"],
    ["Sistema", "CentOS 7, repositórios desativados", "Rocky Linux 9"],
    ["Hive View, Tez View, Pig View", "Existiam", "Removidos ou sem suporte; use beeline, Zeppelin e `pig` no terminal"],
    ["Storm, Flume, MongoDB", "Serviços do Ambari", "Storm e Flume à parte (`lab storm start`); Mongo e Cassandra em containers ao lado"],
    ["Ligar serviços", "Service Actions > Start (até 60 min para tudo)", "`lab aula <perfil>` liga só os da aula (ou pelo Ambari, como no vídeo)"],
    ["Python", "2.7", "3.9 (e 3.7 para o Spark 2)"],
    ["Tempo de boot", "30 a 60 min (12 h em Apple Silicon)", "2 a 4 min"],
    ["Onde ficam os dados", "Dentro do disco da VM", "Volumes do Docker (apagáveis com `.\\lab.ps1 reset`)"],
    ["Ambari Metrics, Ranger, Knox, Atlas, NiFi", "Presentes (pesados)", "Não instalados (não são usados nas aulas)"],
  ], [2.2, 3, 3.8]),
];

// ---------------------------------------------------------------- documento
const header = new Header({ children: [new Paragraph({
  alignment: AlignmentType.RIGHT, border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: "BFBFBF", space: 4 } },
  children: [new TextRun({ text: "Sandbox Big Data — Guia do Aluno", font: FONT, size: 18, color: "666666" })],
})] });
const footer = new Footer({ children: [new Paragraph({
  alignment: AlignmentType.CENTER,
  children: [new TextRun({ text: "Big Data — UNINTER  ·  Página ", font: FONT, size: 18, color: "666666" }), new TextRun({ children: [PageNumber.CURRENT], font: FONT, size: 18, color: "666666" }), new TextRun({ text: " de ", font: FONT, size: 18, color: "666666" }), new TextRun({ children: [PageNumber.TOTAL_PAGES], font: FONT, size: 18, color: "666666" })],
})] });

const bulletLevel = (lvl) => ({ level: lvl, format: LevelFormat.BULLET, text: lvl === 0 ? "•" : "–", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 720 + lvl * 360, hanging: 360 } } } });
const numLevel = () => ({ level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 720, hanging: 360 } } } });

const doc = new Document({
  creator: "Prof. Guilherme Ditzel Patriota",
  title: "Sandbox Big Data — Guia do Aluno",
  description: "Guia de instalação e uso da sandbox Docker que substitui a VM HDP 2.6.5 na disciplina de Big Data (UNINTER).",
  styles: {
    default: { document: { run: { font: FONT, size: 22 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true, run: { font: FONT, size: 34, bold: true, color: BLUE }, paragraph: { spacing: { before: 360, after: 200 }, outlineLevel: 0, border: { bottom: { style: BorderStyle.SINGLE, size: 8, color: BLUE, space: 4 } } } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true, run: { font: FONT, size: 27, bold: true, color: BLUE }, paragraph: { spacing: { before: 280, after: 140 }, outlineLevel: 1 } },
      { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true, run: { font: FONT, size: 23, bold: true, color: "2E5A88" }, paragraph: { spacing: { before: 200, after: 100 }, outlineLevel: 2 } },
    ],
  },
  numbering: { config: [
    { reference: "bullets", levels: [bulletLevel(0), bulletLevel(1)] },
    { reference: "steps", levels: [numLevel()] },
    { reference: "steps2", levels: [numLevel()] },
    { reference: "steps3", levels: [numLevel()] },
    { reference: "trab", levels: [numLevel()] },
  ] },
  features: { updateFields: true },
  sections: [
    { properties: { page: { size: { width: PAGE_W, height: 16838 }, margin: { top: MARGIN, bottom: MARGIN, left: MARGIN, right: MARGIN } } }, children: capa },
    { properties: { page: { size: { width: PAGE_W, height: 16838 }, margin: { top: MARGIN, bottom: MARGIN, left: MARGIN, right: MARGIN } } }, headers: { default: header }, footers: { default: footer },
      children: [...sumario, ...intro, ...instal, ...uso, ...amb, ...aulas, ...trab, ...mem, ...prob, ...apA, ...apB, ...apC] },
  ],
});

Packer.toBuffer(doc).then(buf => { fs.writeFileSync(OUT, buf); console.log("escrito", OUT, buf.length, "bytes"); });
