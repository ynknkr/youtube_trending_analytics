-- 3. Mart Tables
USE DATABASE YOUTUBE_TRENDING_ANALYTICS;
USE SCHEMA MART;

-- 3.a KPI Summary
CREATE OR REPLACE VIEW MART.KPI_SUMMARY AS
SELECT
    COUNT(*) AS total_trending_records,
    SUM(view_count) AS total_views,
    SUM(likes) AS total_likes,
    SUM(comment_count) AS total_comments,
    ROUND(AVG(engagement_rate), 4) AS avg_eng_rate
FROM STAGING.STG_YOUTUBE_DERIVED;

-- Validate KPI Summary View
SELECT * FROM MART.KPI_SUMMARY;

-- 3.b Monthly Trend
CREATE OR REPLACE VIEW MART.MONTHLY_TREND AS
SELECT 
    trending_month,
    COUNT (*) AS total_trending_records,
    SUM(view_count) AS total_views,
    SUM(likes) AS total_likes,
    SUM(comment_count) AS total_comments,
    ROUND(AVG(engagement_rate), 4) AS avg_eng_rate
FROM STAGING.STG_YOUTUBE_DERIVED
GROUP BY trending_month
ORDER BY trending_month;

-- Validate Monthly Trend View
SELECT * FROM MART.MONTHLY_TREND;

-- 3.c Category Performance
CREATE OR REPLACE VIEW MART.CATEGORY_ANALYSIS AS
SELECT
    category_title,
    COUNT(*) AS total_trending_records,
    COUNT(DISTINCT video_id) AS total_videos, 
    SUM(view_count) AS total_views,
    SUM(likes) AS total_likes,
    SUM(comment_count) AS total_comments,
    ROUND(AVG(engagement_rate), 4) AS avg_eng_rate,
    ROUND(AVG(days_to_trend), 2) AS avg_days_to_trend
FROM STAGING.STG_YOUTUBE_DERIVED
GROUP BY category_title
ORDER BY total_views DESC;

-- Validate Category Performance View
SELECT * FROM MART.CATEGORY_ANALYSIS;

-- 3.d Country Analysis
CREATE OR REPLACE VIEW MART.COUNTRY_ANALYSIS AS
SELECT
    country,
    COUNT(*) AS total_trending_records,
    COUNT(DISTINCT video_id) AS total_videos, 
    SUM(view_count) AS total_views,
    SUM(likes) AS total_likes,
    SUM(comment_count) AS total_comments,
    ROUND(AVG(engagement_rate), 4) AS avg_eng_rate,
    ROUND(AVG(days_to_trend), 2) AS avg_days_to_trend
FROM STAGING.STG_YOUTUBE_DERIVED
GROUP BY country
ORDER BY total_views DESC;

-- Validate Country Anlysis View
SELECT * FROM MART.COUNTRY_ANALYSIS;

-- 3.e Country x Category
CREATE OR REPLACE VIEW MART.COUNTRY_CATEGORY_ANALYSIS AS
SELECT
    country,
    category_title,
    COUNT(*) AS total_trending_records,
    COUNT(DISTINCT video_id) AS total_videos, 
    SUM(view_count) AS total_views,
    SUM(likes) AS total_likes,
    SUM(comment_count) AS total_comments,
    ROUND(AVG(engagement_rate), 4) AS avg_eng_rate,
    ROUND(AVG(days_to_trend), 2) AS avg_days_to_trend
FROM STAGING.STG_YOUTUBE_DERIVED
GROUP BY country, category_title
ORDER BY country, total_views DESC;

-- Validate Country x Category Analysis
SELECT * FROM MART.COUNTRY_CATEGORY_ANALYSIS LIMIT 20;

-- 3.f Top Channels
CREATE OR REPLACE VIEW MART.CHANNEL_RANKING AS
SELECT
    country,
    channel_id,
    channel_title,
    COUNT(*) AS total_trending_records,
    COUNT(DISTINCT video_id) AS total_videos, 
    SUM(view_count) AS total_views,
    SUM(likes) AS total_likes,
    SUM(comment_count) AS total_comments,
    ROUND(AVG(engagement_rate), 4) AS avg_eng_rate
FROM STAGING.STG_YOUTUBE_DERIVED
GROUP BY country, channel_id, channel_title
ORDER BY total_views DESC;

-- Validate Channel Ranking View
SELECT * FROM MART.CHANNEL_RANKING LIMIT 20;

-- 3.g Top Videos
CREATE OR REPLACE VIEW MART.VIDEO_RANKING AS
SELECT
    country,
    video_id,
    title,
    channel_title,
    category_title,
    COUNT(*) AS total_trending_records, 
    SUM(view_count) AS total_views,
    SUM(likes) AS total_likes,
    SUM(comment_count) AS total_comments,
    ROUND(AVG(engagement_rate), 4) AS avg_eng_rate,
    ROUND(AVG(days_to_trend), 2) AS avg_days_to_trend
FROM STAGING.STG_YOUTUBE_DERIVED
GROUP BY country, video_id, title, channel_title, category_title
ORDER BY total_views DESC;

-- Validate Video Ranking View
SELECT * FROM MART.VIDEO_RANKING LIMIT 20;