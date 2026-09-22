ratings = LOAD '/user/maria_dev/ml-100k/u.data' AS (userID:int, movieID:int, rating:int, ratingTime:int);
metadata = LOAD '/user/maria_dev/ml-100k/u.item' USING PigStorage('|')
	AS (movieID:int, movieTitle:chararray, releaseDate:chararray, videoRelease:chararray, imdblink:chararray);
   
nameLookup = FOREACH metadata GENERATE movieID, movieTitle;
groupRatings = GROUP ratings BY movieID;
avgRatings = FOREACH groupRatings GENERATE group as movieID, 
	AVG(ratings.rating) as avgRating, COUNT(ratings.rating) AS numRatings;
fiveStarMovies = FILTER avgRatings BY avgRating > 4.0;
namedMovies = JOIN fiveStarMovies BY movieID, nameLookup BY movieID;

finalResults = FOREACH namedMovies GENERATE nameLookup::movieTitle AS movieName,
	fiveStarMovies::avgRating AS avgRating, fiveStarMovies::numRatings AS numRatings;

finalResultsSorted = ORDER finalResults BY numRatings DESC;
DUMP finalResultsSorted;