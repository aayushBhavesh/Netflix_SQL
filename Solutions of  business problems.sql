-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems
-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020


-- 4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5


-- 5. Identify the longest movie

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC


-- 6. Find content added in the last 5 years
SELECT
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM
(

SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM 
netflix
)
WHERE 
	director_name = 'Rajiv Chilaka'



-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5


-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !


SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5


-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'



-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2


-- 16. Find the year-over-year growth rate of Netflix content additions.

WITH yearly AS (
    SELECT YEAR(date_added) AS year, COUNT(*) AS total
    FROM netflix_titles
    WHERE date_added IS NOT NULL
    GROUP BY YEAR(date_added)
)
SELECT 
    year,
    total,
    ROUND(
        (total - LAG(total) OVER (ORDER BY year)) * 100.0 
        / LAG(total) OVER (ORDER BY year), 2
    ) AS yoy_growth_percent
FROM yearly;

	
-- 17. Identify which month has the highest number of content additions historically.

SELECT 
    MONTHNAME(date_added) AS month,
    COUNT(*) AS total
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY MONTHNAME(date_added)
ORDER BY total DESC
LIMIT 1;


-- 18. Determine whether Netflix is shifting more towards TV Shows or Movies over time.

SELECT 
    YEAR(date_added) AS year,
    type,
    COUNT(*) AS total
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY YEAR(date_added), type
ORDER BY year;


19. Find the average gap (in days) between release year and date added for content.

SELECT 
    ROUND(AVG(DATEDIFF(date_added, MAKEDATE(release_year, 1))), 0) AS avg_days_gap
FROM netflix_titles
WHERE date_added IS NOT NULL;

	
-- 20. Identify years where TV Shows surpassed Movies in total additions.

SELECT year
FROM (
    SELECT 
        YEAR(date_added) AS year,
        SUM(type='TV Show') AS tv_count,
        SUM(type='Movie') AS movie_count
    FROM netflix_titles
    GROUP BY YEAR(date_added)
) t
WHERE tv_count > movie_count;


-- 21. Find the top 3 content-producing countries per year.

SELECT year, country, total
FROM (
    SELECT 
        YEAR(date_added) AS year,
        TRIM(country) AS country,
        COUNT(*) AS total,
        RANK() OVER (PARTITION BY YEAR(date_added) ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix_titles
    WHERE country IS NOT NULL
    GROUP BY year, country
) x
WHERE rnk <= 3;


-- 22. Calculate the percentage contribution of India’s content to total Netflix content each year.

WITH yearly AS (
    SELECT YEAR(date_added) AS year, COUNT(*) AS total
    FROM netflix_titles
    GROUP BY YEAR(date_added)
),
india AS (
    SELECT YEAR(date_added) AS year, COUNT(*) AS india_total
    FROM netflix_titles
    WHERE country LIKE '%India%'
    GROUP BY YEAR(date_added)
)
SELECT 
    y.year,
    ROUND(i.india_total * 100.0 / y.total, 2) AS india_percentage
FROM yearly y
JOIN india i ON y.year = i.year;
	
-- 23. Identify countries whose content presence declined year-over-year.

WITH yearly AS (
    SELECT 
        YEAR(date_added) AS year,
        country,
        COUNT(*) AS total
    FROM netflix_titles
    WHERE country IS NOT NULL
    GROUP BY year, country
)
SELECT *
FROM (
    SELECT *,
           total - LAG(total) OVER (PARTITION BY country ORDER BY year) AS diff
    FROM yearly
) x
WHERE diff < 0;


-- 24. Find countries that only produce Movies but no TV Shows.

SELECT country
FROM netflix_titles
GROUP BY country
HAVING SUM(type='TV Show') = 0;

-- 25. Rank countries by average movie duration.

SELECT 
    country,
    ROUND(AVG(CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)), 1) AS avg_duration
FROM netflix_titles
WHERE type = 'Movie'
GROUP BY country
ORDER BY avg_duration DESC;


-- 26.Find the median movie duration instead of average.

SELECT AVG(duration_minutes) AS median_duration
FROM (
    SELECT 
        CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS duration_minutes,
        ROW_NUMBER() OVER (ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)) AS rn,
        COUNT(*) OVER () AS cnt
    FROM netflix_titles
    WHERE type='Movie'
) t
WHERE rn IN (FLOOR((cnt+1)/2), CEIL((cnt+1)/2));


-- 27. Identify TV shows with irregular season gaps (non-continuous season counts).

SELECT title
FROM netflix_titles
WHERE type='TV Show'
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) NOT BETWEEN 1 AND 10;


-- 28. Find movies that are outliers in duration (too long or too short using percentile logic).

SELECT *
FROM netflix_titles
WHERE type='Movie'
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) >
(
    SELECT PERCENTILE_CONT(0.95)
    WITHIN GROUP (ORDER BY CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED))
    FROM netflix_titles
    WHERE type='Movie'
);


-- 29. Compare average duration of Indian movies vs Non-Indian movies.

SELECT 
    CASE WHEN country LIKE '%India%' THEN 'India' ELSE 'Non-India' END AS category,
    ROUND(AVG(CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED)),1) AS avg_duration
FROM netflix_titles
WHERE type='Movie'
GROUP BY category;


-- 30. Find directors whose movies consistently exceed average duration.

SELECT director
FROM netflix_titles
WHERE type='Movie' AND director IS NOT NULL
GROUP BY director
HAVING AVG(CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED)) >
       (SELECT AVG(CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED))
        FROM netflix_titles WHERE type='Movie');


-- 31. dentify directors who worked across multiple countries.

SELECT director, COUNT(DISTINCT country) AS country_count
FROM netflix_titles
WHERE director IS NOT NULL AND country IS NOT NULL
GROUP BY director
HAVING country_count > 1;


-- 32. Find actors who transitioned from movies to TV shows over time.

SELECT DISTINCT cast
FROM netflix_titles
WHERE cast IS NOT NULL
GROUP BY cast
HAVING SUM(type='Movie') > 0 AND SUM(type='TV Show') > 0;


-- 33. Rank actors by career longevity on Netflix (first appearance to latest).

SELECT 
    cast,
    MIN(release_year) AS first_year,
    MAX(release_year) AS last_year,
    MAX(release_year) - MIN(release_year) AS career_span
FROM netflix_titles
WHERE cast IS NOT NULL
GROUP BY cast
ORDER BY career_span DESC;


-- 34. Find directors who frequently collaborate with the same actors.

SELECT director, cast, COUNT(*) AS collaborations
FROM netflix_titles
WHERE director IS NOT NULL AND cast IS NOT NULL
GROUP BY director, cast
HAVING collaborations >= 3;


-- 35. Identify actors whose content is evenly split between movies and TV shows.

SELECT cast
FROM netflix_titles
GROUP BY cast
HAVING ABS(SUM(type='Movie') - SUM(type='TV Show')) <= 1;


-- 36.Find genres that are growing fastest in the last 5 years.

SELECT listed_in, COUNT(*) AS total
FROM netflix_titles
WHERE YEAR(date_added) >= YEAR(CURDATE()) - 5
GROUP BY listed_in
ORDER BY total DESC;


-- 37. Identify genres that are declining or stagnant.

SELECT listed_in
FROM netflix_titles
GROUP BY listed_in
HAVING COUNT(CASE WHEN YEAR(date_added) >= YEAR(CURDATE())-2 THEN 1 END) <
       COUNT(CASE WHEN YEAR(date_added) < YEAR(CURDATE())-2 THEN 1 END);


-- 38. Find content descriptions that contain more than 3 genre-related keywords.

SELECT title
FROM netflix_titles
WHERE LENGTH(description) - LENGTH(REPLACE(description, ' ', '')) > 20;


-- 39. Compare average duration per genre.

SELECT listed_in,
       ROUND(AVG(CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED)),1) AS avg_duration
FROM netflix_titles
WHERE type='Movie'
GROUP BY listed_in;

-- 40. Identify genres that are country-specific (exist in one country only).

SELECT listed_in
FROM netflix_titles
GROUP BY listed_in
HAVING COUNT(DISTINCT country) = 1;


-- End of reports
