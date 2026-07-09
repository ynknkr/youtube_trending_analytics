-- 4. Analysis Queries
USE DATABASE YOUTUBE_TRENDING_ANALYTICS;
USE SCHEMA MART;

-- 4.a Top Categories by Views
SELECT
    category_title,
    total_trending_records,
    total_videos,
    total_views
FROM MART.CATEGORY_ANALYSIS
ORDER BY total_views DESC;

-- 4.b Countries with Highest Engagement Rate
SELECT
    country,
    avg_eng_rate,
    total_trending_records,
    total_views
FROM MART.COUNTRY_ANALYSIS
ORDER BY avg_eng_rate DESC;

-- 4.c Top Channels by Total Views
SELECT
    country,
    channel_title,
    total_trending_records,
    total_videos,
    total_views
FROM MART.CHANNEL_RANKING
ORDER BY total_views DESC LIMIT 10;

-- 4.d Fastest Trending Categories
SELECT
    category_title,
    avg_days_to_trend
FROM MART.CATEGORY_ANALYSIS
ORDER BY avg_days_to_trend;

-- 4.e Country x Category Performance
SELECT
    country,
    category_title,
    total_views
FROM (
    SELECT
        country,
        category_title,
        total_views,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_views DESC) AS ranking    
    FROM MART.COUNTRY_CATEGORY_ANALYSIS
)
WHERE ranking = 1
ORDER BY country;

