{% snapshot snp_video %}
{{
  config(
    target_schema='YOUTUBE_SNAP',
    unique_key='VIDEO_ID',
    strategy='check',
    check_cols=[
      'VIDEO_TITLE',
      'VIDEO_DESC',
      'VIDEO_PUBLISHED_AT',
      'VIEW_COUNT',
      'LIKE_COUNT',
      'COMMENT_COUNT',
      'DURATION_SECONDS'
    ]
  )
}}
select
  video_id,
  video_title,
  video_desc,
  video_published_at,
  view_count,
  like_count,
  comment_count,
  duration_seconds
from YOUTUBE_DB.YOUTUBE_DEV_SCHEMA.STG_VIDEOS
{% endsnapshot %}
