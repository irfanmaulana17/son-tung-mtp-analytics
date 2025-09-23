{{ config(materialized='view' ,
    tags=['bronze']) }}


select
    playlist_id 
    , playlist_title 
    , playlist_desc 
    , published_at::timestamp AS "PUBLISHED_AT"
    , channel_id 
    , thumb_high AS "PLAYLIST_THUMBNAIL_URL"
    , item_count::bigint AS "ITEM_COUNT"
from {{ ref('playlists') }}