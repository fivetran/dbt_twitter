{% macro get_tweet_columns() %}

{% set columns = [
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "full_text", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "lang", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
] %}

{{ return(columns) }}

{% endmacro %}
