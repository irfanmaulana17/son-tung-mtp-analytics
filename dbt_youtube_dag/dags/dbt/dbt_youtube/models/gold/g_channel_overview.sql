{{ config(materialized='table' ,
    tags=['gold']) }}

with ch as (
  select
    channel_id
    , title as "CHANNEL_TITLE"
    , customUrl as "CHANNEL_CUSTOM_URL"
    , published_at as "CHANNEL_PUBLISHED_AT"
    , country
    , subscriber_count
    , view_count AS "CHANNEL_VIEW_COUNT"
    , video_count AS "CHANNEL_VIDEO_COUNT"
    , channel_thumbnail_url 
  from {{ ref('stg_channels') }}
),
v as (
  -- 1 dòng/video để tính Avg Length, Avg Rate
  select
    video_id
    ,any_value(duration_seconds) as "DURATION_SECONDS"
    ,any_value(view_count)       as "VIEW_COUNT"
    ,any_value(like_count)       as "LIKE_COUNT"
    ,any_value(comment_count)    as "COMMENT_COUNT"
  from {{ ref('stg_videos') }}
  group by video_id
)
select
  ch.*,
  avg(v.duration_seconds)                             as avg_video_length_sec,
  avg(v.like_count / nullif(v.view_count, 0))         as avg_like_per_view,
  avg(v.comment_count / nullif(v.view_count, 0))      as avg_comment_per_view
from ch
left join v on 1=1 -- cross join để lấy avg trên toàn bộ video
group by
  ch.channel_id, ch.channel_title, ch.channel_custom_url, ch.channel_published_at, ch.country,
  ch.subscriber_count, ch.channel_view_count, ch.channel_video_count, ch.channel_thumbnail_url