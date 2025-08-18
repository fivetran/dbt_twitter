{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with source as (

    select *
    from {{ ref('stg_twitter_ads__campaign_history_tmp') }}

),

fields as (

    select
    
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_ads__campaign_history_tmp')),
                staging_columns=get_campaign_history_columns()
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
        account_id,
        created_at as created_timestamp,
        currency,
        daily_budget_amount_local_micro,
        deleted as is_deleted,
        duration_in_days,
        end_time as end_timestamp,
        entity_status,
        frequency_cap,
        funding_instrument_id,
        id as campaign_id,
        name as campaign_name,
        servable as is_servable,
        standard_delivery as is_standard_delivery,
        start_time as start_timestamp,
        total_budget_amount_local_micro,
        updated_at as updated_timestamp,
        round(daily_budget_amount_local_micro / 1000000.0,2) as daily_budget_amount,
        round(total_budget_amount_local_micro / 1000000.0,2) as total_budget_amount,
        row_number() over (partition by source_relation, id order by updated_at desc) = 1 as is_latest_version
    
    from fields 
)

select * from final