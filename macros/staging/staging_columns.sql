{% macro get_account_history_columns() %}

{% set columns = [
    {"name": "approval_status", "datatype": dbt.type_string()},
    {"name": "business_id", "datatype": dbt.type_string()},
    {"name": "business_name", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "deleted", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "industry_type", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "salt", "datatype": dbt.type_string()},
    {"name": "timezone", "datatype": dbt.type_string()},
    {"name": "timezone_switch_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}

{% macro get_campaign_history_columns() %}

{% set columns = [
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "daily_budget_amount_local_micro", "datatype": dbt.type_int()},
    {"name": "deleted", "datatype": "boolean"},
    {"name": "duration_in_days", "datatype": dbt.type_int()},
    {"name": "end_time", "datatype": dbt.type_timestamp()},
    {"name": "entity_status", "datatype": dbt.type_string()},
    {"name": "frequency_cap", "datatype": dbt.type_int()},
    {"name": "funding_instrument_id", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "servable", "datatype": "boolean"},
    {"name": "standard_delivery", "datatype": "boolean"},
    {"name": "start_time", "datatype": dbt.type_timestamp()},
    {"name": "total_budget_amount_local_micro", "datatype": dbt.type_int()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}

{% macro get_line_item_history_columns() %}

{% set columns = [
    {"name": "advertiser_domain", "datatype": dbt.type_string()},
    {"name": "advertiser_user_id", "datatype": dbt.type_int()},
    {"name": "automatically_select_bid", "datatype": "boolean"},
    {"name": "bid_amount_local_micro", "datatype": dbt.type_int()},
    {"name": "bid_type", "datatype": dbt.type_string()},
    {"name": "bid_unit", "datatype": dbt.type_string()},
    {"name": "campaign_id", "datatype": dbt.type_string()},
    {"name": "charge_by", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "creative_source", "datatype": dbt.type_string()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "deleted", "datatype": "boolean"},
    {"name": "end_time", "datatype": dbt.type_timestamp()},
    {"name": "entity_status", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "objective", "datatype": dbt.type_string()},
    {"name": "optimization", "datatype": dbt.type_string()},
    {"name": "primary_web_event_tag", "datatype": dbt.type_string()},
    {"name": "product_type", "datatype": dbt.type_string()},
    {"name": "start_time", "datatype": dbt.type_timestamp()},
    {"name": "target_cpa_local_micro", "datatype": dbt.type_int()},
    {"name": "total_budget_amount_local_micro", "datatype": dbt.type_int()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}

{% macro get_promoted_tweet_history_columns() %}

{% set columns = [
    {"name": "approval_status", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "deleted", "datatype": "boolean"},
    {"name": "entity_status", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "line_item_id", "datatype": dbt.type_string()},
    {"name": "tweet_id", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}

{% macro get_tweet_url_columns() %}

{% set columns = [
    {"name": "display_url", "datatype": dbt.type_string()},
    {"name": "expanded_url", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "indices", "datatype": dbt.type_string()},
    {"name": "tweet_id", "datatype": dbt.type_string()},
    {"name": "url", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}

{% macro get_promoted_tweet_report_columns() %}

{% set columns = [
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "billed_charge_local_micro", "datatype": dbt.type_int()},
    {"name": "clicks", "datatype": dbt.type_int()},
    {"name": "date", "datatype": dbt.type_timestamp()},
    {"name": "impressions", "datatype": dbt.type_int()},
    {"name": "placement", "datatype": dbt.type_string()},
    {"name": "promoted_tweet_id", "datatype": dbt.type_string()},
    {"name": "url_clicks", "datatype": dbt.type_int()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('twitter_ads__conversion_fields')) }}

{{ fivetran_utils.add_pass_through_columns(columns, var('twitter_ads__conversion_sale_amount_fields')) }}

{# Doing it this way in case users were bringing in conversion metrics via passthrough columns prior to us adding them by default #}
{{ twitter_ads_add_pass_through_columns(base_columns=columns, pass_through_fields=var('twitter_ads__promoted_tweet_report_passthrough_metrics'), except_fields=(var('twitter_ads__conversion_fields') + var('twitter_ads__conversion_sale_amount_fields'))) }}

{{ return(columns) }}

{% endmacro %}