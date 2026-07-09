-- 2. Staging Tables
USE DATABASE YOUTUBE_TRENDING_ANALYTICS;
USE SCHEMA STAGING;

-- 2.a Create Category Lookup Table
CREATE OR REPLACE TABLE STAGING.STG_YOUTUBE_CATEGORY AS
SELECT 
    country,
    flattened.value:id::Number AS category_id,
    flattened.value:snippet:title::String AS category_title
FROM RAW.RAW_YOUTUBE_CATEGORY,
LATERAL FLATTEN(input => raw_category:items) AS flattened;

-- Validate Category Lookup Table
SELECT COUNT (*) FROM STAGING.STG_YOUTUBE_CATEGORY;
SELECT * FROM STAGING.STG_YOUTUBE_CATEGORY LIMIT 10;

-- 2.b Create Enriched Trending Table (Category + Trending)
CREATE OR REPLACE TABLE STAGING.STG_YOUTUBE_ENRICHED AS
SELECT
    t.video_id,
    t.title,
    t.published_at,
    t.channel_id,
    t.channel_title,
    t.category_id,
    c.category_title,
    t.trending_date,
    t.view_count,
    t.likes,
    t.dislikes,
    t.comment_count,
    t.country
FROM RAW.RAW_YOUTUBE_TRENDING t
LEFT JOIN STAGING.STG_YOUTUBE_CATEGORY c
    ON t.category_id = c.category_id
    AND t.country = c.country;

-- Validate Enriched Table
SELECT COUNT (*) FROM STAGING.STG_YOUTUBE_ENRICHED;
SELECT * FROM STAGING.STG_YOUTUBE_ENRICHED LIMIT 10;

-- 2.c Clean Enriched Table
-- Check duplicates
SELECT COUNT(*)
FROM (
    SELECT video_id, country, trending_date, COUNT(*)
    FROM STAGING.STG_YOUTUBE_ENRICHED
    GROUP BY video_id, country, trending_date
    HAVING COUNT(*) > 1
);

-- Create Clean Table 
CREATE OR REPLACE TABLE STAGING.STG_YOUTUBE_CLEANED AS
SELECT * FROM STAGING.STG_YOUTUBE_ENRICHED
WHERE video_id IS NOT NULL 
    AND title IS NOT NULL
    AND published_at IS NOT NULL
    AND channel_id IS NOT NULL
    AND channel_title IS NOT NULL
    AND trending_date IS NOT NULL
    AND country IS NOT NULL
    AND category_id IS NOT NULL
    AND category_title IS NOT NULL
    AND view_count >= 0
    AND likes >= 0
    AND dislikes >= 0
    AND comment_count >= 0
QUALIFY ROW_NUMBER() OVER (PARTITION BY video_id, country, trending_date ORDER BY view_count DESC) = 1;

-- Validate Cleaned table
SELECT COUNT (*) FROM STAGING.STG_YOUTUBE_CLEANED;
SELECT * FROM STAGING.STG_YOUTUBE_CLEANED LIMIT 10;

-- 2.d Create Derived Columns
CREATE OR REPLACE TABLE STAGING.STG_YOUTUBE_DERIVED AS
SELECT
    *,
    ROUND((likes + comment_count) / NULLIF(view_count, 0), 4) AS engagement_rate,
    DATEDIFF(day, published_at, trending_date) AS days_to_trend,
    DATE_TRUNC('month', trending_date) AS trending_month
FROM STAGING.STG_YOUTUBE_CLEANED;

-- Validate Derived Table
SELECT * FROM STAGING.STG_YOUTUBE_DERIVED LIMIT 10;

-- 2.e Data Quality Checks
-- Check Total Rows
SELECT COUNT(*) FROM STAGING.STG_YOUTUBE_DERIVED;

-- Check Duplicate Records
SELECT video_id, country, trending_date,
COUNT(*) FROM STAGING.STG_YOUTUBE_DERIVED
GROUP BY ALL
HAVING COUNT(*) > 1;

-- Check Missing Fields & Invalid Metrics
SELECT COUNT (*) FROM STAGING.STG_YOUTUBE_DERIVED
WHERE video_id IS NULL 
    OR title IS NULL
    OR published_at IS NULL
    OR channel_id IS NULL
    OR channel_title IS NULL
    OR trending_date IS NULL
    OR country IS NULL
    OR category_id IS NULL
    OR category_title IS NULL
    OR view_count < 0
    OR likes < 0
    OR dislikes < 0
    OR comment_count < 0;