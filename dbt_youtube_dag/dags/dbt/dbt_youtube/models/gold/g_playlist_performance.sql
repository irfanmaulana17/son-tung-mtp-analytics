{{ config(materialized='table' ,
    tags=['gold']) }}

with pi as (
  -- số video thực tế theo playlist
  select
    playlist_id
    , count(distinct video_id) as items_detected
  from {{ ref('stg_videos') }}
  group by playlist_id
),
best as (
  -- top 1 video theo view trong từng playlist
  select
    v.playlist_id
    , v.video_id
    , any_value(v.video_title) as "VIDEO_TITLE"
    , any_value(v.view_count)  as "VIEW_COUNT"
    , row_number() over (partition by v.playlist_id order by any_value(v.view_count) desc) as rn
  from {{ ref('stg_videos') }} v
  group by v.playlist_id, v.video_id
)
select
  p.playlist_id
  , p.playlist_title               as "PLAYLIST_TITLE"
  , p."ITEM_COUNT"                 as item_count_declared
  , pi.items_detected
  , p.channel_id
  , p.channel_title                as "CHANNEL_TITLE"
  , p."PLAYLIST_THUMBNAIL_URL"     as playlist_thumbnail_url
  , b.video_id                     as top_video_id
  , b."VIDEO_TITLE"                as top_video_title
  , b."VIEW_COUNT"                 as top_video_views
from {{ ref('stg_playlists') }} p
left join pi   on pi.playlist_id = p.playlist_id
left join best b on b.playlist_id = p.playlist_id and b.rn = 1
