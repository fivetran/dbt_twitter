{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

{{
    fivetran_utils.union_data(
        table_identifier='account_history', 
        database_variable='twitter_ads_database', 
        schema_variable='twitter_ads_schema', 
        default_database=target.database,
        default_schema='twitter_ads',
        default_variable='account_history',
        union_schema_variable='twitter_ads_union_schemas',
        union_database_variable='twitter_ads_union_databases'
    )
}}