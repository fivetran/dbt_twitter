{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with report as (

    select *
    from {{ var('line_item_report') }}
),

line_items as (

    select *
    from {{ var('line_item_history') }}
    where is_latest_version
),

campaigns as (

    select *
    from {{ var('campaign_history') }}
    where is_latest_version
),

accounts as (

    select *
    from {{ var('account_history') }}
    where is_latest_version
),

final as (

    select 
        report.date_day,
        report.placement, 
        report.account_id,
        accounts.name as account_name,
        line_items.campaign_id,
        campaigns.campaign_name,
        report.line_item_id,
        line_items.name as line_item_name,
        line_items.is_deleted,
        line_items.entity_status as line_item_status,
        campaigns.entity_status as campaign_status,
        line_items.currency,
        line_items.advertiser_domain,
        line_items.advertiser_user_id,
        line_items.bid_type,
        line_items.bid_unit,
        line_items.charge_by,
        line_items.objective,
        line_items.optimization,
        line_items.product_type,
        line_items.primary_web_event_tag,
        line_items.creative_source,
        line_items.start_timestamp,
        line_items.end_timestamp,
        line_items.created_timestamp,
        line_items.updated_timestamp,
        line_items.target_cpa,
        line_items.total_budget_amount,
        line_items.bid_amount,
        sum(report.clicks) as clicks, 
        sum(report.impressions) as impressions,
        sum(report.spend) as spend,
        sum(report.spend_micro) as spend_micro,
        sum(report.url_clicks) as url_clicks

        {{ fivetran_utils.persist_pass_through_columns('twitter_ads__line_item_report_passthrough_metrics', transform='sum')}}

    from report 
    left join line_items
        on report.line_item_id = line_items.line_item_id
    left join campaigns 
        on line_items.campaign_id = campaigns.campaign_id
    left join accounts
        on report.account_id = accounts.account_id

    {{ dbt_utils.group_by(n=29) }}
)

select *
from final