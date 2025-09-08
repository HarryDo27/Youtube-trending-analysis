--- Create database
CREATE DATABASE assignment_1;

--- 3. Use database
USE DATABASE assignment_1;

--- Connect data from Azure Storage Account 
CREATE OR REPLACE STAGE stage_assignment
URL='azure://bdeassignment1.blob.core.windows.net/bdeassignment1'
CREDENTIALS=(AZURE_SAS_TOKEN='sv=2022-11-02&ss=bfqt&srt=co&sp=rwdlacupiytfx&se=2024-12-31T11:09:21Z&st=2024-08-16T04:09:21Z&spr=https&sig=j3c0Trhdji3%2BU2qcJFV3E6Jtw3osvTX2EdCf2EbFF7I%3D')
;

list @stage_assignment;

--- 4. Create external table youtube trending
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending
WITH LOCATION = @stage_assignment
FILE_FORMAT = (TYPE=CSV)
PATTERN = '.*\\.csv';

--- Create external table youtube category
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_category
WITH LOCATION = @stage_assignment
FILE_FORMAT = (TYPE=JSON)
PATTERN = '.*[.]json';

--- Change all the data type of external table youtube trending to varchar
SELECT
value:c1::varchar,
value:c2::varchar,
value:c3::varchar,
value:c4::varchar,
value:c5::varchar,
value:c6::varchar,
value:c7::varchar,
value:c8::varchar,
value:c9::varchar,
value:c10::varchar,
value:c11::varchar
FROM ex_table_youtube_trending
LIMIT 1;

--- Format external table youtube trending
CREATE OR REPLACE FILE FORMAT file_format_csv
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
NULL_IF = ('\\N', 'NULL', 'NUL', '')
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

--- Replace external table youtube trending
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending
WITH LOCATION = @stage_assignment
FILE_FORMAT = file_format_csv
PATTERN = '.*\\.csv';

--- 5. Create table youtube trending and correct the data type
DROP TABLE IF EXISTS table_youtube_trending; -- use for after check
CREATE TABLE table_youtube_trending AS
SELECT 
    value:c1::varchar as video_id,
    value:c2::varchar as title,
    CAST(value:c3 AS date) as publishedAt, -- change to date
    value:c4::varchar as channelId,
    value:c5::varchar as channelTitle,
    value:c6::int as categoryId,
    value:c7::date as trending_date,
    value:c8::int as view_count,
    value:c9::int as likes,
    value:c10::int as dislikes,
    value:c11::int as comment_count,
    REGEXP_SUBSTR(METADATA$FILENAME, '([^/]+)_youtube_trending_data\\.csv', 1, 1, 'e') AS country -- take the first 2 letters of each file as country name
FROM ex_table_youtube_trending;

--- Create table youtube category with correct data type
DROP TABLE IF EXISTS table_youtube_category; -- use for after check
CREATE TABLE table_youtube_category AS
SELECT
    SPLIT_PART(SPLIT_PART(METADATA$FILENAME, '/', 2), '_', 1) AS country, -- take the first 2 letters of each file as country name
    l.value:id::int AS categoryid,
    l.value:snippet.title::string AS category_title
FROM
    ex_table_youtube_category,
    LATERAL FLATTEN(input => ex_table_youtube_category.value:items) l; -- flatten the items array, allowing to extract "id" and "title".

--- 6. Create table youtube final
DROP TABLE IF EXISTS table_youtube_final;
CREATE TABLE table_youtube_final AS
SELECT
    UUID_STRING() AS id, -- primary key
    yt.video_id,
    yt.title,
    yt.publishedat,
    yt.channelid,
    yt.channeltitle,
    yt.categoryid,
    yc.category_title,
    yt.trending_date,
    yt.view_count,
    yt.likes,
    yt.dislikes,
    yt.comment_count,
    yt.country
    
FROM
    table_youtube_trending yt
LEFT JOIN
    table_youtube_category yc
ON
    yt.country = yc.country
    AND yt.categoryid = yc.categoryid;

    
--- Check the number of rows in table youtube final
SELECT Count(*) FROM table_youtube_final; 