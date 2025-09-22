{{ config(materialized='view') }}

select
    * 
from {{ ref('br_channels') }}
