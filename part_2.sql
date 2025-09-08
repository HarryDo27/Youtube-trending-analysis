---------- PART 2
-- Question 1: In “table_youtube_category” which category_title has duplicates if we don’t take into account the categoryid (return only a single row)?
SELECT 
    category_title
FROM 
    table_youtube_category
GROUP BY 
    category_title
HAVING 
    COUNT(DISTINCT(categoryid)) > 1;
    
-- Question 2: In “table_youtube_category” which category_title only appears in one country?
SELECT 
    category_title,
    COUNT(DISTINCT country) AS country_count
FROM 
    table_youtube_category
GROUP BY 
    category_title
HAVING 
    COUNT(DISTINCT country) = 1;
    
-- Question 3 In “table_youtube_final”, what is the categoryid of the missing category_titles?
SELECT 
    DISTINCT (categoryid)
FROM 
    table_youtube_final
WHERE 
    category_title IS NULL;

-- Check the category title of categoryid that have missing category title
SELECT 
    DISTINCT(category_title)
FROM
    table_youtube_final
WHERE
    categoryid= '29';


-- Question 4: Update the table_youtube_final to replace the NULL values in category_title with the answer from the previous question.
UPDATE table_youtube_final
SET category_title = 'Nonprofits & Activism'
WHERE category_title IS NULL;

-- Question 5: In “table_youtube_final”, which video doesn’t have a channeltitle (return only the title)?
SELECT 
    title
FROM 
    table_youtube_final
WHERE 
    channeltitle IS NULL;

-- Question 6: Delete from “table_youtube_final“, any record with video_id = “#NAME?”
DELETE FROM table_youtube_final
WHERE video_id = '#NAME?';

-- Question 7: Create a new table called “table_youtube_duplicates”  containing only the “bad” duplicates
DROP TABLE IF EXISTS table_youtube_duplicates; 
CREATE TABLE table_youtube_duplicates AS
SELECT 
    *
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY video_id, country, trending_date
            ORDER BY view_count DESC
        ) AS rn
    FROM 
        table_youtube_final
) AS RankedVideos
WHERE 
    rn > 1;

SELECT COUNT(*) as Number_of_rows_duplicated FROM table_youtube_duplicates;

--- Question 8: Delete the duplicates in “table_youtube_final“ by using “table_youtube_duplicates”
DELETE FROM table_youtube_final
WHERE EXISTS (
    SELECT *
    FROM table_youtube_duplicates d
    WHERE table_youtube_final.id = d.id
);

--- Question 9: Check the number of rows after cleaning data
SELECT COUNT(*) FROM table_youtube_final;