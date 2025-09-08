---- Part 4
--- 1. Question: What is the top category in each country has the most trending videos globally (excluding "Music" and "Entertainment")?
SELECT 
    country,
    category_title,
    number_of_trending_videos
FROM (
    SELECT 
        country,
        category_title,
        COUNT(*) AS number_of_trending_videos,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY COUNT(*) DESC) AS rn
    FROM 
        table_youtube_final
    WHERE 
        category_title NOT IN ('Music', 'Entertainment')
    GROUP BY 
        country, category_title
) AS RankedCategories
WHERE 
    rn = 1
ORDER BY 
    number_of_trending_videos DESC;
--- 2. Engagement of top categories 
SELECT 
    category_title,
    SUM(likes) AS total_likes,
    SUM(view_count) AS total_views,
    SUM(comment_count) AS total_comments
FROM 
    table_youtube_final
WHERE 
    category_title IN ('Gaming', 'People & Blogs', 'Sports')
GROUP BY 
    category_title
ORDER BY 
    category_title;