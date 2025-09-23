{{ config(materialized='table' ,
    tags=['gold']) }}

with v as (
  select distinct
    video_id
    , any_value(video_published_at) as "VIDEO_PUBLISHED_AT"
  from {{ ref('stg_videos') }}
  where video_published_at is not null
  group by video_id
)
select
  extract(dow  from "VIDEO_PUBLISHED_AT") as published_dow   -- 0=Sun
  , extract(hour from "VIDEO_PUBLISHED_AT") as published_hour -- 0..23
  , count(*) as videos_count
from v
group by 1,2
