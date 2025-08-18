{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True) and var('twitter_ads__using_campaign_regions_report', False)) }}

{{
    fivetran_utils.union_data(
        table_identifier='campaign_regions_report', 
        database_variable='twitter_ads_database', 
        schema_variable='twitter_ads_schema', 
        default_database=target.database,
        default_schema='twitter_ads',
        default_variable='campaign_regions_report',
        union_schema_variable='twitter_ads_union_schemas',
        union_database_variable='twitter_ads_union_databases'
    )
}}
