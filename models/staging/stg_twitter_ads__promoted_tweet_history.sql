{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with source as (

    select *
    from {{ ref('stg_twitter_ads__promoted_tweet_history_tmp') }}

),

fields as (

    select
    
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_ads__promoted_tweet_history_tmp')),
                staging_columns=get_promoted_tweet_history_columns()
            )
        }}
    
        {{ fivetran_utils.apply_source_relation(package_name='twitter_ads') }}

    from source

), 

final as (

    select
        source_relation,
        approval_status,
        created_at as created_timestamp,
        deleted as is_deleted,
        entity_status,
        id as promoted_tweet_id,
        line_item_id,
        tweet_id,
        updated_at as updated_timestamp,
        row_number() over (partition by id {{ fivetran_utils.partition_by_source_relation(package_name='twitter_ads') }} order by updated_at desc) = 1 as is_latest_version
    from fields 
)

select * from final