{{ config(materialized='view' ,
    tags=['bronze']) }}


with base as (
  select
    video_id
    , video_title
    , video_desc
    , try_to_timestamp_ntz(video_published_at) as "VIDEO_PUBLISHED_AT"
    , duration_iso8601
    , try_to_number(view_count) as "VIEW_COUNT"
    , try_to_number(like_count) as "LIKE_COUNT"
    , try_to_number(comment_count) as "COMMENT_COUNT"
    , try_to_timestamp_ntz(live_actual_start) as "LIVE_ACTUAL_START"
    , try_to_timestamp_ntz(live_actual_end)   as "LIVE_ACTUAL_END"
    , try_to_timestamp_ntz(live_scheduled_start) as "LIVE_SCHEDULED_START"
  from {{ ref('video_stats') }}
),
parsed as (
  select
    *,
      coalesce(to_number(regexp_substr(duration_iso8601, '(\\d+)H', 1, 1, 'e', 1)), 0) * 3600
    + coalesce(to_number(regexp_substr(duration_iso8601, '(\\d+)M', 1, 1, 'e', 1)), 0) * 60
    + coalesce(to_number(regexp_substr(duration_iso8601, '(\\d+)S', 1, 1, 'e', 1)), 0)
      as "DURATION_SECONDS"
  from base
)
select * from parsed