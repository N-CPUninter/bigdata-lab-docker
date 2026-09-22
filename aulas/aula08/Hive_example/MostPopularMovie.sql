/* Create view for counting movie ratings */
/* You can use IF NOT EXISTS to avoid conflict with existing tables */
CREATE VIEW IF NOT EXISTS topMovieIDs AS
SELECT movieID, count(movieID) AS ratingsCount
FROM ratings
GROUP BY movieID
ORDER BY ratingsCount DESC;

/*Create view for results*/
SELECT n.title, ratingsCount
FROM topMovieIDs t JOIN names n ON t.movieID = n.movieID;

/* Don't forget to clean the data, if you're not going to use it any more */
/*DROP VIEW topMovieIDs*/
