{{ config(materialized='view' ,
    tags=['silver']) }}

select
  p.*
  , c.title as channel_title
from {{ ref('br_playlists') }} p
left join {{ ref('br_channels') }} c
  on p.channel_id = c.channel_id
