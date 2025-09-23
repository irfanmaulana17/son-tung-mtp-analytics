{{ config(materialized='table' ,
    tags=['gold']) }}

with v as (
  select
    video_id
    , any_value(view_count)    as "VIEW_COUNT"
    , any_value(like_count)    as "LIKE_COUNT"
    , any_value(comment_count) as "COMMENT_COUNT"
    , any_value("VIDEO_TYPE")  as "VIDEO_TYPE"
  from {{ ref('stg_videos') }}
  group by video_id
)
select
  "VIDEO_TYPE" as video_type
  , count(*)   as videos_count
  , sum("VIEW_COUNT") as total_views
  , avg("LIKE_COUNT"   / nullif("VIEW_COUNT",0))    as avg_like_per_view
  , avg("COMMENT_COUNT"/ nullif("VIEW_COUNT",0))    as avg_comment_per_view
from v
group by 1
order by videos_count desc