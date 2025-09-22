https://developers.google.com/youtube/v3/getting-started#example-1


source .venv/bin/activate

uv add dbt-core dbt-snowflake
uv add pandas google_auth_oauthlib google-api-python-client ipykernel

dbt init dbt_youtube
dbt deps