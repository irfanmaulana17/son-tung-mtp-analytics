{{ config(materialized='view' ,
    tags=['silver']) }}


select
    * 
from {{ ref('br_channels') }}
