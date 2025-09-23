{{ config(materialized='table' ,
    tags=['gold']) }}

with v as (
  select
    video_id
    , any_value(duration_seconds) as "DURATION_SECONDS"
    , any_value(case
        when duration_seconds <   60 then '0-1m'
        when duration_seconds <  300 then '1-5m'
        when duration_seconds <  900 then '5-15m'
        when duration_seconds < 1800 then '15-30m'
        when duration_seconds < 3600 then '30-60m'
        else '60m+'
      end) as "DURATION_BUCKET"
  from {{ ref('stg_videos') }}
  group by video_id
)
select
  "DURATION_BUCKET" as duration_bucket
  , count(*)        as videos_count
  , avg("DURATION_SECONDS") as avg_duration_sec
from v
group by 1
order by
  case duration_bucket
    when '0-1m'  then 1
    when '1-5m'  then 2
    when '5-15m' then 3
    when '15-30m' then 4
    when '30-60m' then 5
    else 6
  end
