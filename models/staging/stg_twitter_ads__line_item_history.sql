{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with source as (

    select *
    from {{ ref('stg_twitter_ads__line_item_history_tmp') }}

),

fields as (

    select
    
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_ads__line_item_history_tmp')),
                staging_columns=get_line_item_history_columns()
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
        advertiser_domain,
        advertiser_user_id,
        automatically_select_bid,
        bid_amount_local_micro,
        bid_type,
        bid_unit,
        campaign_id,
        charge_by,
        created_at as created_timestamp,
        creative_source,
        currency,
        deleted as is_deleted,
        end_time as end_timestamp,
        entity_status,
        id as line_item_id,
        name,
        objective,
        optimization,
        primary_web_event_tag,
        product_type,
        start_time as start_timestamp,
        target_cpa_local_micro,
        total_budget_amount_local_micro,
        updated_at as updated_timestamp,
        round(bid_amount_local_micro / 1000000.0,2) as bid_amount,
        round(total_budget_amount_local_micro / 1000000.0,2) as total_budget_amount,
        round(target_cpa_local_micro / 1000000.0,2) as target_cpa,
        row_number() over (partition by source_relation, id order by updated_at desc) = 1 as is_latest_version
    
    from fields 
)

select * from final