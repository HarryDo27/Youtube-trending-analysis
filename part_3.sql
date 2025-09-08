--- Part 3
--- Question 1: What are the 3 most viewed videos for each country in the Gaming category for the trending_date = ‘2024-04-01'. Order the result by country and the rank,
SELECT 
    country,
    title,
    channelTitle,
    view_count,
    ROW_NUMBER() OVER (
        PARTITION BY country 
        ORDER BY view_count DESC NULLS LAST
    ) AS rk
FROM 
    table_youtube_final
WHERE 
    category_title = 'Gaming'
    AND trending_date = '2024-04-01'
QUALIFY 
    rk <= 3
ORDER BY 
    country,
    rk;
--- Question 2: For each country, count the number of distinct video with a title containing the word “BTS” (case insensitive) and order the result by count in a descending order
SELECT 
    country,
    COUNT(DISTINCT video_id) AS ct
FROM 
    table_youtube_final
WHERE 
    LOWER(title) LIKE '%bts%'
GROUP BY 
    country
ORDER BY 
    ct DESC;
--- Question 3: For each country, year and month (in a single column) and only for the year of 2024, which video is the most viewed and what is its likes_ratio (defined as the percentage of likes against view_count) truncated to 2 decimals. Order the result by year_month and country.
SELECT 
    country,
    TRUNC(trending_date, 'MM') AS year_month,  -- Truncates date to the first day of the month
    title,
    channelTitle,
    category_title,
    view_count,
    TRUNC((likes / view_count::float) * 100, 2) AS likes_ratio
FROM (
    SELECT 
        country,
        trending_date,
        title,
        channelTitle,
        category_title,
        view_count,
        likes,
        ROW_NUMBER() OVER (
            PARTITION BY country, TRUNC(trending_date, 'MM')
            ORDER BY view_count DESC
        ) AS rn
    FROM 
        table_youtube_final
    WHERE 
        EXTRACT(YEAR FROM trending_date) = 2024
) AS RankedVideos
WHERE 
    rn = 1
ORDER BY 
    year_month,
    country;


---- Question 4: For each country, which category_title has the most distinct videos and what is its percentage (2 decimals) out of the total distinct number of videos of that country? Only look at the data from 2022. Order the result by category_title and country
WITH CategoryVideoCount AS ( -- calculate the number of videos for each category
    SELECT 
        country,
        category_title,
        COUNT(DISTINCT video_id) AS total_category_video
    FROM 
        table_youtube_final
    WHERE 
        trending_date >= '2022-01-01'
    GROUP BY 
        country, category_title
),
TotalCountryVideo AS ( -- calculate the distinct videos for each country
    SELECT 
        country,
        COUNT(DISTINCT video_id) AS total_country_video
    FROM 
        table_youtube_final
    WHERE 
        trending_date >= '2022-01-01'
    GROUP BY 
        country
),
CategoryPercentage AS ( -- calculate the percentage
    SELECT 
        cvc.country,
        cvc.category_title,
        cvc.total_category_video,
        tcv.total_country_video,
        ROUND((cvc.total_category_video::float / tcv.total_country_video) * 100, 2) AS percentage
    FROM 
        CategoryVideoCount cvc
    JOIN 
        TotalCountryVideo tcv ON cvc.country = tcv.country
)
SELECT 
    country,
    category_title,
    total_category_video,
    total_country_video,
    percentage
FROM 
    (
        SELECT 
            country,
            category_title,
            total_category_video,
            total_country_video,
            percentage,
            ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_category_video DESC) AS rn
        FROM 
            CategoryPercentage
    ) AS RankedCategories
WHERE 
    rn = 1
ORDER BY 
    category_title,
    country;

--- Question 5: Which channeltitle has produced the most distinct videos and what is this number?
SELECT 
    channeltitle,
    COUNT(DISTINCT video_id) AS distinct_video_count
FROM 
    table_youtube_final
GROUP BY 
    channeltitle
ORDER BY 
    distinct_video_count DESC
LIMIT 1;