{{ config(enabled=fivetran_utils.enabled_vars(['ad_reporting__twitter_ads_enabled','twitter_ads__using_keywords'])) }}

{% if var('twitter_union_schemas', []) | length > 0 or var('twitter_union_databases', []) | length > 0 %}

{{
    fivetran_utils.union_data(
        table_identifier='line_item_keywords_report', 
        database_variable='twitter_database', 
        schema_variable='twitter_schema', 
        default_database=target.database,
        default_schema='twitter',
        default_variable='line_item_keywords_report',
        union_schema_variable='twitter_union_schemas',
        union_database_variable='twitter_union_databases'
    )
}}

{% else %}

{{
    fivetran_utils.union_connections(
        connection_dictionary='twitter_sources',
        single_source_name='twitter',
        single_table_name='line_item_keywords_report'
    )
}}

{% endif %}