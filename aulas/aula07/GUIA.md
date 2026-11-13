# Aula 7 — Pig e Oozie

**Preparar a sandbox:** `.\lab.cmd aula 7` (Windows) ou `./lab.sh aula 7`.
Liga ZooKeeper, HDFS, YARN, MapReduce2, Hive (com WebHCat, usado pelo Pig View) e Oozie.
Se a máquina tiver só 8 GB e o objetivo for apenas o Pig, use `aula 7a` (sem Oozie).

Os dados `ml-100k` já estão no HDFS em `/user/maria_dev/ml-100k` (o vídeo mostra o upload pelo Files View; pode repetir o upload se quiser praticar — a pasta é a mesma).

## Pig

| No vídeo (HDP 2.6.5) | Na sandbox |
|---|---|
| Ambari > Pig View > New Script | **Não disponível**: o Pig View precisa do WebHCat, que o stack ODP não inclui. Use o terminal (`pig`), que é o que o vídeo faz na segunda parte |
| `pig` no terminal (grunt) | Igual: `pig` (modo Tez, lê do HDFS). `pig -x local` também existe, mas lê do disco local: troque `/user/maria_dev/ml-100k` por `/home/maria_dev/data/ml-100k` no script |
| Versão Pig 0.16 | Pig 0.18 (mesma sintaxe) |

Rodar pelo terminal (shell web `localhost:4200` ou `ssh -p 2222 maria_dev@localhost`):

```bash
cd ~/aulas/aula07/Pig_exercise
pig MostRatedFiveStarMovie.pig      # roda no Tez/YARN lendo /user/maria_dev/ml-100k do HDFS (como no vídeo)
pig OldestFiveStarMovie.pig
```

Correções em relação ao material original: `ORDER finalResults BY numRatings DESC` (a forma `... AS numRatings DESC` não é Pig Latin válido) e `videoRelease` (estava `videoRealese`).

## Oozie

Os arquivos `job.properties`, `workflow.xml` e `oldmovies.sql` funcionam **sem alteração**: o host da sandbox continua sendo `sandbox.hortonworks.com`, o NameNode responde em `8020` e o ResourceManager em `8050`.

```bash
cd ~/aulas/aula07/Oozie_exercise
hdfs dfs -put -f workflow.xml oldmovies.sql /user/maria_dev/
oozie job -oozie http://localhost:11000/oozie -config job.properties -run
oozie job -oozie http://localhost:11000/oozie -info <ID retornado>
```

Acompanhe em `http://localhost:11000/oozie` ou no Ambari > **Workflow Manager** (view nova, não existia no HDP 2.6.5).

O banco `movielens` (tabela `movies`) já está carregado no MariaDB (`mysql -u root -phadoop movielens`), então a ação Sqoop do workflow funciona direto.
O resultado fica em `/user/maria_dev/oldmovies` (`hdfs dfs -cat /user/maria_dev/oldmovies/*`).

Diferença de versão: o workflow usa `com.mysql.jdbc.Driver`; o driver instalado é o Connector/J 8, que ainda aceita esse nome de classe (com aviso de "deprecated" no log — pode ignorar).
