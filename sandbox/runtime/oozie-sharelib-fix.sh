#!/usr/bin/env bash
# Completa a sharelib do Oozie no HDFS (idempotente). Imprime "changed" na última linha se alterou algo.
#  - sqoop/: driver MySQL (jdbc:mysql://localhost/movielens nos roteiros)
#  - sqoop/ e hive/: jars hadoop-mapreduce-client-* (Oozie 5 em Hadoop 3: NoClassDefFoundError org/apache/hadoop/mapred/JobConf)
set -uo pipefail
MR=/usr/odp/current/hadoop-mapreduce-client
changed=0
put() { # put <arquivo local> <dir hdfs>
  local f="$1" d="$2" n; n=$(basename "$f")
  su - hdfs -c "hdfs dfs -test -e $d/$n" 2>/dev/null && return 0
  su - hdfs -c "hdfs dfs -put -f $f $d/ && hdfs dfs -chown oozie:hadoop $d/$n" >/dev/null 2>&1 && changed=1
}
for d in $(su - hdfs -c "hdfs dfs -ls -d /user/oozie/share/lib/lib_*/sqoop /user/oozie/share/lib/lib_*/hive" 2>/dev/null | awk '{print $NF}'); do
  case "$d" in */sqoop) put /usr/share/java/mysql-connector-java.jar "$d" ;; esac
  for j in "$MR"/hadoop-mapreduce-client-core-*.jar "$MR"/hadoop-mapreduce-client-common-*.jar "$MR"/hadoop-mapreduce-client-jobclient-*.jar "$MR"/hadoop-mapreduce-client-shuffle-*.jar; do
    [ -f "$j" ] && [[ "$j" != *tests* ]] && put "$j" "$d"
  done
done
[ "$changed" = 1 ] && echo changed || echo unchanged
