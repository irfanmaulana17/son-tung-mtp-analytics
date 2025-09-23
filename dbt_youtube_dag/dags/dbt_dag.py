import os
from datetime import datetime
from airflow import DAG
from cosmos import DbtTaskGroup, ProjectConfig, ExecutionConfig, ProfileConfig, RenderConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping

# profile_config = ProfileConfig(
#     profile_name="default",
#     target_name="dev",
#     profile_mapping=SnowflakeUserPasswordProfileMapping(
#         conn_id="snowflake_conn",
#         profile_args={"database": "YOUTUBE_DB", "schema": "YOUTUBE_DEV_SCHEMA"},
#     )
# )

# dbt_snowflake_dag = DbtDag(
#     project_config=ProjectConfig("/usr/local/airflow/dags/dbt/dbt_youtube"),
#     operator_args={"install_deps": True},
#     profile_config=profile_config,
#     execution_config=ExecutionConfig(dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/venv/bin/dbt"),
#     schedule="@daily",
#     start_date=datetime(2025, 9, 20),
#     catchup=False,
#     dag_id="dbt_dag",
# )

# Define the DBT project path and executable path
dbt_project_path = "/usr/local/airflow/dags/dbt/dbt_youtube"
dbt_executable_path = f"{os.environ['AIRFLOW_HOME']}/venv/bin/dbt"

project_config = ProjectConfig(dbt_project_path)
execution_config = ExecutionConfig(dbt_executable_path=dbt_executable_path)
profile_config = ProfileConfig(
    profile_name="default",
    target_name="dev",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_conn",
        profile_args={"database": "YOUTUBE_DB", "schema": "YOUTUBE_DEV_SCHEMA"}
    )
)

with DAG(
    dag_id="dbt_youtube_pipeline",
    start_date=datetime(2025, 9, 20),
    schedule="@daily",
    catchup=False,
    tags=["dbt", "dbt_youtube"],
) as dag:


    # Step 1: seeds
    seeds = DbtTaskGroup(
        group_id="seeds",
        project_config=project_config,
        profile_config=profile_config,
        execution_config=execution_config,
        render_config=RenderConfig(
            select=["path:seeds"],
        ),
    )

    # Step 2: bronze
    bronze = DbtTaskGroup(
        group_id="bronze",
        project_config=project_config,
        profile_config=profile_config,
        execution_config=execution_config,
        render_config=RenderConfig(
            select=["tag:bronze"],
        ),
    )

    # Step 3: silver
    silver = DbtTaskGroup(
        group_id="silver",
        project_config=project_config,
        profile_config=profile_config,
        execution_config=execution_config,
        render_config=RenderConfig(
            select=["tag:silver"],
        ),
    )

    # Step 4: gold
    gold = DbtTaskGroup(
        group_id="gold",
        project_config=project_config,
        profile_config=profile_config,
        execution_config=execution_config,
        render_config=RenderConfig(
            select=["tag:gold"],
        ),
    )

    # Pipeline dependencies
    seeds >> bronze >> silver >> gold