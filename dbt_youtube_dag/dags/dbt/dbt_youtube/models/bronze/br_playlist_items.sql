{{ config(materialized='view' ,
    tags=['bronze']) }}


select
  playlistItem_id AS "PLAYLIST_ITEM_ID",
  playlist_id,
  video_id,
  video_title as "VIDEO_TITLE_IN_PLAYLIST",
  video_desc as "VIDEO_DESC_IN_PLAYLIST",
  try_to_timestamp_ntz(added_to_playlist_at) as "ADDED_TO_PLAYLIST_AT",
  try_to_timestamp_ntz(video_published_at) as "VIDEO_PUBLISHED_AT",
  try_to_number(position_in_playlist) as "POSITION_IN_PLAYLIST",
  snippet__thumbnails__maxres__url AS "VIDEO_THUMBNAIL_URL_IN_PLAYLIST",
  channel_id
from {{ ref('playlist_items') }}
