# Atividade Prática (Trabalho)

O Roteiro da Atividade Prática aceita várias formas de execução (Google Colab, máquina virtual, Docker, nuvem, Spark local). **A escolha da plataforma é do aluno.** As regras do roteiro valem para todas: sem pandas, prints com o RU visível, entrega em PDF.

| | Google Colab | Sandbox Docker |
|---|---|---|
| Instalação | Nenhuma; só uma conta Google | Docker Desktop + esta sandbox |
| Onde roda | Servidor do Google, pelo navegador | No seu computador |
| HDFS e Ambari | Não há | Sim (upload pelo Files View, como nos vídeos) |
| Spark | PySpark 3.5 via `pip` | Spark 3.5.1 (`SPARK_MAJOR_VERSION=3`) |

## Opção A — Google Colab

- Notebook pronto: [trabalho_big_data.ipynb no Colab](https://colab.research.google.com/github/N-CPUninter/Big_Data/blob/main/trabalho_big_data.ipynb). Faça **Arquivo > Salvar uma cópia no Drive** antes de editar.
- Repositório da disciplina: [github.com/N-CPUninter/Big_Data](https://github.com/N-CPUninter/Big_Data).
- Dataset: [imdb-reviews-pt-br.zip](https://raw.githubusercontent.com/N-CPUninter/Big_Data/main/data/imdb-reviews-pt-br.zip) (o notebook já baixa sozinho).

O notebook baixa o dataset, instala o PySpark e cria a `SparkSession`; você preenche as funções `map`/`reduceByKey` de cada questão. Se a sessão do Colab expirar, execute as células iniciais de novo.

## Opção B — Sandbox Docker

**Preparar:** `.\lab.cmd aula trabalho` (liga ZooKeeper e HDFS, para o upload pelo Files View).

### 1. Colocar o dataset na sandbox

Baixe o [imdb-reviews-pt-br.zip](https://raw.githubusercontent.com/N-CPUninter/Big_Data/main/data/imdb-reviews-pt-br.zip), extraia e copie o `imdb-reviews-pt-br.csv` (~127 MB) para a pasta `data/` do projeto no seu computador. Ela aparece dentro da sandbox em `/home/maria_dev/data-host/`.

Para reproduzir os passos do roteiro com HDFS:
1. Ambari ([http://localhost:8080](http://localhost:8080), usuário `maria_dev`) > menu de nove pontos > **Files View** > `user` > `maria_dev` > **Upload** > escolha o CSV. (Equivale a: `hdfs dfs -put ~/data-host/imdb-reviews-pt-br.csv /user/maria_dev/`.)
2. No terminal ([http://localhost:4200](http://localhost:4200) ou `ssh -p 2222 maria_dev@localhost`):
   ```bash
   hadoop fs -ls                                         # lista /user/maria_dev
   hdfs dfs -copyToLocal /user/maria_dev/imdb-reviews-pt-br.csv .
   grep -A1 fs.defaultFS /etc/hadoop/conf/core-site.xml  # hdfs://sandbox.hortonworks.com:8020
   ```

### 2. Rodar o script

Use o **Spark 3** (PySpark 3.5, o mesmo do Colab): `export SPARK_MAJOR_VERSION=3` (já é o padrão).

```bash
cp ~/aulas/trabalho/trabalho_RU.py ~/trabalho_SEU_RU.py     # renomeie com o seu RU
nano ~/trabalho_SEU_RU.py                                    # preencha as funções (Ctrl+O salva, Ctrl+X sai)
spark-submit ~/trabalho_SEU_RU.py                            # print da tela com o comando e o RU visível
```
Atenção: `spark.read.csv('imdb-reviews-pt-br.csv')` lê do **HDFS** (`/user/maria_dev`), como no HDP — por isso o passo do Files View. Para ler o arquivo local baixado com `copyToLocal`, use `file:///home/maria_dev/imdb-reviews-pt-br.csv`.

Também dá para usar `pyspark` interativo (`imdb_df = spark.read.csv('imdb-reviews-pt-br.csv', header=True, quote="\"", escape="\"", encoding="UTF-8")`). Os parâmetros `quote` e `escape` são obrigatórios nas duas plataformas.

### 3. Conferir

`bash ~/aulas/trabalho/verifica.sh ~/trabalho_SEU_RU.py` roda o script e confere se as respostas caem na faixa esperada (não substitui as regras do roteiro; serve para você ter certeza de que o `quote`/`escape` do CSV está certo — o erro mais comum).
