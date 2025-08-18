{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with source as (

    select *
    from {{ ref('stg_twitter_ads__account_history_tmp') }}

),

fields as (

    select
    
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_ads__account_history_tmp')),
                staging_columns=get_account_history_columns()
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
        approval_status,
        business_id,
        business_name,
        created_at as created_timestamp,
        deleted as is_deleted,
        id as account_id,
        industry_type,
        name,
        salt,
        timezone,
        timezone_switch_at as timezone_switched_timestamp,
        updated_at as updated_timestamp,
        row_number() over (partition by source_relation, id order by updated_at desc) = 1 as is_latest_version
    
    from fields 
)

select * from final