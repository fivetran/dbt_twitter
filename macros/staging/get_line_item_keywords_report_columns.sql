{% macro get_line_item_keywords_report_columns() %}

{% set columns = [
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "billed_charge_local_micro", "datatype": dbt.type_int()},
    {"name": "clicks", "datatype": dbt.type_int()},
    {"name": "date", "datatype": dbt.type_timestamp()},
    {"name": "impressions", "datatype": dbt.type_int()},
    {"name": "line_item_id", "datatype": dbt.type_string()},
    {"name": "placement", "datatype": dbt.type_string()},
    {"name": "segment", "datatype": dbt.type_string()},
    {"name": "url_clicks", "datatype": dbt.type_int()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('twitter_ads__conversion_fields')) }}

{{ fivetran_utils.add_pass_through_columns(columns, var('twitter_ads__conversion_sale_amount_fields')) }}

{# Doing it this way in case users were bringing in conversion metrics via passthrough columns prior to us adding them by default #}
{{ twitter_ads_add_pass_through_columns(base_columns=columns, pass_through_fields=var('twitter_ads__line_item_keywords_report_passthrough_metrics'), except_fields=(var('twitter_ads__conversion_fields') + var('twitter_ads__conversion_sale_amount_fields'))) }}

{{ return(columns) }}

{% endmacro %}