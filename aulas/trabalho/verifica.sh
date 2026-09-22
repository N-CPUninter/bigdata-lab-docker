#!/usr/bin/env bash
# Roda o script do trabalho e confere se as respostas estão na faixa esperada.
# Uso: bash verifica.sh trabalho_SEU_RU.py [caminho_do_csv]
set -uo pipefail
script="${1:?informe o script .py}"; csv="${2:-$HOME/imdb-reviews-pt-br.csv}"
[ -f "$csv" ] || csv="$HOME/data-host/imdb-reviews-pt-br.csv"
[ -f "$csv" ] || { echo "CSV não encontrado. Copie imdb-reviews-pt-br.csv para a pasta data/ do projeto ou para ~/"; exit 1; }
# caminho local: prefixo file:// (sem ele o Spark procura no HDFS, como no HDP)
csv="file://$(readlink -f "$csv")"
out=$(SPARK_MAJOR_VERSION=3 spark-submit "$script" "$csv" 2>/dev/null)
echo "$out" | grep -E 'Questão'
q1=$(echo "$out" | grep -oE "'neg', *[0-9]+" | head -1 | grep -oE '[0-9]+$')
q2=$(echo "$out" | grep -A0 'Questão 2' | grep -oE "'neg', *\(([0-9]+), *([0-9]+)\)" | head -1)
ok=1
if [ "$q1" = "459568555" ]; then echo "Questão 1: OK"; else echo "Questão 1: esperado 459568555, obtido '${q1:-nada}'"; ok=0; fi
if [ -n "$q2" ]; then
  a=$(echo "$q2" | grep -oE '[0-9]+' | sed -n 1p); b=$(echo "$q2" | grep -oE '[0-9]+' | sed -n 2p)
  d=$(( b - a )); [ $d -lt 0 ] && d=$(( -d ))
  if [ $d -ge 54000 ] && [ $d -le 55000 ]; then echo "Questão 2: OK (diferença $d)"; else echo "Questão 2: diferença $d fora da faixa 54000–55000"; ok=0; fi
else
  echo "Questão 2: não achei o par (palavras_pt, palavras_en) para 'neg' na saída"; ok=0
fi
[ $ok = 1 ] && echo "Tudo certo." || { echo "Confira quote=\"\\\"\" e escape=\"\\\"\" no read.csv e o filtro sentiment == 'neg'."; exit 1; }
