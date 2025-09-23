{{ config(materialized='view' ,
    tags=['silver']) }}

-- Một video có thể nằm trong nhiều playlist → ta vẫn giữ granular theo (playlist_id, video_id)
select
  pi.playlist_item_id
  , pi.playlist_id
  , pi.channel_id
  , pi.video_id
  , s.video_title
  , s.video_desc
  , s.video_published_at
  , s.view_count
  , s.like_count
  , s.comment_count
  , s.duration_seconds
  , DATEDIFF('day', s.video_published_at, current_timestamp()) as "VIDEO_AGE_DAYS" 
  , CASE 
        WHEN s.live_scheduled_start is not null THEN 'Live'
        WHEN s.duration_seconds < 60 THEN 'Shorts'
        WHEN s.duration_seconds is null THEN 'Private videos'
        ELSE 'Normal videos'
    END AS "VIDEO_TYPE"
  , CASE
      WHEN duration_seconds <   60 THEN '0-1m'
      WHEN duration_seconds <  300 THEN '1-5m'
      WHEN duration_seconds <  900 THEN '5-15m'
      WHEN duration_seconds < 1800 THEN '15-30m'
      WHEN duration_seconds < 3600 THEN '30-60m'
      ELSE '60m+'
    END AS "DURATION_BUCKET"
  , pi.added_to_playlist_at AS "VIDEO_ADDED_TO_PLAYLIST_AT"
  , pi.position_in_playlist AS "VIDEO_POSITION_IN_PLAYLIST"
  , pi.video_thumbnail_url_in_playlist AS "VIDEO_THUMBNAIL_URL"
from {{ ref('br_playlist_items') }} pi
left join {{ ref('br_video_stats') }} s
  on pi.video_id = s.video_id