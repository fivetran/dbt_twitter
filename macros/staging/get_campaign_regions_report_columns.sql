{% macro get_campaign_regions_report_columns() %}

{% set columns = [
    {"name": "location_name", "datatype": dbt.type_string()},
    {"name": "location_type", "datatype": dbt.type_string()},
    {"name": "segment", "datatype": dbt.type_string()},
    {"name": "segment_name", "datatype": dbt.type_string()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "billed_charge_local_micro", "datatype": dbt.type_int()},
    {"name": "campaign_id", "datatype": dbt.type_string()},
    {"name": "clicks", "datatype": dbt.type_int()},
    {"name": "date", "datatype": dbt.type_timestamp()},
    {"name": "impressions", "datatype": dbt.type_int()},
    {"name": "placement", "datatype": dbt.type_string()},
    {"name": "url_clicks", "datatype": dbt.type_int()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('twitter_ads__conversion_fields')) }}

{{ fivetran_utils.add_pass_through_columns(columns, var('twitter_ads__conversion_sale_amount_fields')) }}

{{ twitter_ads_add_pass_through_columns(base_columns=columns, pass_through_fields=var('twitter_ads__campaign_regions_report_passthrough_metrics')) }}

{{ return(columns) }}

{% endmacro %}
