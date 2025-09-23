{{ config(materialized='table' ,
    tags=['gold']) }}

with v as (
  select
    video_id
    , any_value(video_title)        as "VIDEO_TITLE"
    , any_value(video_desc)         as "VIDEO_DESC"
    , any_value(video_published_at) as "VIDEO_PUBLISHED_AT"
    , any_value(duration_seconds)   as "DURATION_SECONDS"
    , any_value(view_count)         as "VIEW_COUNT"
    , any_value(like_count)         as "LIKE_COUNT"
    , any_value(comment_count)      as "COMMENT_COUNT"
  from {{ ref('stg_videos') }}
  where video_title is not null
  group by video_id
)
select
  v.video_id
  , v."VIDEO_TITLE"
  , v."VIDEO_DESC"
  , v."VIDEO_PUBLISHED_AT"::date as published_date
  , v."DURATION_SECONDS"
  , coalesce(v."VIEW_COUNT",0) as "VIEW_COUNT"
  , coalesce(v."LIKE_COUNT",0) as "LIKE_COUNT"
  , coalesce(v."COMMENT_COUNT",0) as "COMMENT_COUNT"
  , v."LIKE_COUNT"   / nullif(v."VIEW_COUNT", 0) as like_per_view
  , v."COMMENT_COUNT"/ nullif(v."VIEW_COUNT", 0) as comment_per_view
  , row_number() over (order by v."VIEW_COUNT" desc)         as rn_by_views
  , row_number() over (order by v."LIKE_COUNT"/nullif(v."VIEW_COUNT",0) desc)    as rn_by_like_rate
  , row_number() over (order by v."COMMENT_COUNT"/nullif(v."VIEW_COUNT",0) desc) as rn_by_comment_rate
  , row_number() over (order by v."VIDEO_PUBLISHED_AT" desc) as rn_newest
from v