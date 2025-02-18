-- Project Netflix
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT *
FROM netflix;

SELECT COUNT(*)
FROM netflix;

-- Business Problems and Solutions
-- 1. Count the Number of Movies vs TV Shows
SELECT type ,
	   count(*)
FROM netflix
GROUP BY 1;

-- 2. Find the Most Common Rating for Movies and TV Shows
SELECT type,
	   rating
FROM
(
	SELECT type,
		   rating,
	   	   count(*),
		   RANK() OVER(PARTITION BY type ORDER BY count(*) DESC ) AS ranking
	FROM netflix
	GROUP BY 1,2
)
WHERE ranking = 1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT *
FROM netflix
WHERE 
	type = 'Movie' 
	AND 
	release_year = 2020;

-- 4. Find the Top 5 Countries with the Most Content on Netflix
SELECT 
	UNNEST (STRING_TO_ARRAY(country,',')) AS new_country,
	count(show_id)
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the Longest Movie
SELECT *
FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find All Movies/TV Shows by Director 
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration,' ',1)::INT > 5;

-- 9. Count the Number of Content Items in Each Genre
SELECT 	
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
	COUNT(show_id)
FROM netflix
GROUP BY 1;

-- 10.Find each year and the average numbers of content release in India on netflix.
SELECT 
	SPLIT_PART(date_added,',',2)::INT AS year,
	COUNT(*),
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100 AS average
FROM netflix
WHERE country = 'India'
GROUP BY 1

-- 11. List All Movies that are Documentaries
SELECT *
FROM netflix
WHERE listed_in ILIKE '%Documentaries%'

-- 12. Find All Content Without a Director
SELECT *
FROM netflix
WHERE director IS NULL

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT count(show_id), UNNEST(STRING_TO_ARRAY(casts,',')) AS actors
FROM netflix
WHERE country = 'India'
GROUP BY 2
ORDER BY 1 DESC
LIMIT 10

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT category,COUNT(*)
FROM
(
	SELECT 
		*,
		CASE
		WHEN
			description ILIKE '%kill%'
			OR
			description ILIKE '%violence%' THEN 'Bad Content'
		ELSE 'Good Content'
		END category
	FROM netflix
)
GROUP BY 1
