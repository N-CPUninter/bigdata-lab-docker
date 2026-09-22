# Problemas comuns

**`.\lab.ps1` não roda ("execução de scripts foi desabilitada")**
`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` no PowerShell, uma vez.

**`docker: error during connect` / "Docker Desktop is not running"**
Abra o Docker Desktop e espere a baleia ficar estável. No Windows, confira que o WSL2 está instalado (`wsl --status`).

**Ambari não abre em `localhost:8080` após alguns minutos**
`docker compose logs sandbox` — procure "ambari-server start". Se a porta 8080 estiver ocupada por outro programa, mude no `docker-compose.yml` (`"8081:8080"`).

**Serviço fica vermelho no Ambari ao ligar**
Ambari > Background Operations > clique na operação > veja `stderr`. Causas comuns: memória (veja [MEMORIA.md](MEMORIA.md)) e disco cheio no Docker (`docker system df`; limpe com `docker system prune`).

**`lab aula` falha com "requisição falhou"**
Repita o comando (o Ambari às vezes falha no primeiro start do NameNode após restart). Persistindo, `lab stop-all` e tente de novo.

**HDFS em "safe mode"**
Aguarde 1 minuto; se continuar: `sudo -u hdfs hdfs dfsadmin -safemode leave` (dentro da sandbox).

**`Permission denied` ao gravar no HDFS**
Você está como `root`. Use `su - maria_dev` ou o shell web com `maria_dev`.

**Esqueci a senha do `admin` do Ambari**
Ela é `admin`. Se mudou e perdeu: `ambari-admin-password-reset` dentro da sandbox (como root), ou o procedimento do guia "Uso do HDP e reset de senhas" no PostgreSQL (`psql -U ambari -h localhost ambari`, senha `bigdata`, tabela `user_authentication`).

**Spark reclama de versão do Python**
`SPARK_MAJOR_VERSION=2` usa o Python 3.7 e `=3` o Python 3.9 automaticamente em shells de login. Em `docker compose exec` sem `-l`, rode `source /etc/profile.d/spark-python.sh`.

**Mongo/Cassandra não conectam em 127.0.0.1**
Os sidecars precisam estar de pé: `.\lab.ps1 nosql` (ou `docker compose --profile nosql up -d`). Cassandra leva ~1 minuto para aceitar conexões.

**Mac com chip Apple está muito lento**
Confirme "Use Rosetta for x86_64/amd64 emulation" no Docker Desktop. Prefira os perfis leves (10/11/12/trabalho) e, para o Trabalho, o Colab continua sendo a opção mais leve.

**Quero começar do zero**
`.\lab.ps1 reset` (apaga HDFS, bancos e o home da `maria_dev`).
