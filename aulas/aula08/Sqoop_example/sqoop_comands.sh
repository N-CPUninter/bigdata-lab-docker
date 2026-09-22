#!/bin/bash

#connecta em uma instancia mysql atraves de um conector jdbc utilizando o driver especificado para dada tabela
#sqoop import --connect jdbc:mysql://localhost/database --driver com.mysql.jdbc.Driver --table data

#mesma coisa importando para o hive
#sqoop import --connect jdbc:mysql://localhost/database --driver com.mysql.jdbc.Driver --table data --hive-import

#opcoes de importacao incremental
# --check-column
# --last-value

#exporta dados do hive para o mysql
#sqoop export --connect jdbc:mysql://localhost/database --driver com.mysql.jdbc.Driver --table exported_data --export-dir /apps/hive/warehouse/data --input-fields-terminated-by '\0001'

# lembrar que os dados em hive estao armazenados como um arquivo em HDFS que recebe um schema para ser manipulado

# determina a quantidade de mappers
# -m <number>
