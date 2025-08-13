{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with source as (

    select *
    from {{ ref('stg_twitter_ads__tweet_url_tmp') }}

),

fields as (

    select
    
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_ads__tweet_url_tmp')),
                staging_columns=get_tweet_url_columns()
            )
        }}
    
        {{ fivetran_utils.source_relation(
            union_schema_variable='twitter_ads_union_schemas', 
            union_database_variable='twitter_ads_union_databases') 
        }}

    from source

), 

final as (

    select
        source_relation,
        display_url,
        expanded_url,
        index,
        indices,
        tweet_id,
        url,
        {{ dbt.split_part('expanded_url', "'?'", 1) }} as base_url,
        {{ dbt_utils.get_url_host('expanded_url') }} as url_host,
        '/' || {{ dbt_utils.get_url_path('expanded_url') }} as url_path,
        {{ twitter_ads_source.twitter_ads_extract_url_parameter('expanded_url', 'utm_source') }} as utm_source,
        {{ twitter_ads_source.twitter_ads_extract_url_parameter('expanded_url', 'utm_medium') }} as utm_medium,
        {{ twitter_ads_source.twitter_ads_extract_url_parameter('expanded_url', 'utm_campaign') }} as utm_campaign,
        {{ twitter_ads_source.twitter_ads_extract_url_parameter('expanded_url', 'utm_content') }} as utm_content,
        {{ twitter_ads_source.twitter_ads_extract_url_parameter('expanded_url', 'utm_term') }} as utm_term
    
    from fields

)

select * from final