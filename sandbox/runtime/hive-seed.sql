-- Tabelas usadas na Aula 8 (Hive_example/MostPopularMovie.sql).
-- No HDP elas eram criadas pelo "Upload Table" do Hive View (removido no Ambari 2.7).
CREATE EXTERNAL TABLE IF NOT EXISTS ratings (
  userID INT, movieID INT, rating INT, ratingTime INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/user/maria_dev/hive/ratings';

CREATE EXTERNAL TABLE IF NOT EXISTS names (
  movieID INT, title STRING, releaseDate STRING, videoRelease STRING, imdbLink STRING,
  unknown INT, action INT, adventure INT, animation INT, childrens INT, comedy INT, crime INT,
  documentary INT, drama INT, fantasy INT, filmNoir INT, horror INT, musical INT, mystery INT,
  romance INT, sciFi INT, thriller INT, war INT, western INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/maria_dev/hive/names';
