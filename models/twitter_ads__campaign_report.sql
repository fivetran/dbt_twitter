{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with report as (

    select *
    from {{ var('campaign_report') }}
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
        report.campaign_id,
        campaigns.campaign_name,
        campaigns.is_deleted,
        campaigns.entity_status as campaign_status,
        campaigns.currency,
        campaigns.is_servable,
        campaigns.is_standard_delivery,
        campaigns.frequency_cap,
        campaigns.start_timestamp,
        campaigns.end_timestamp,
        campaigns.created_timestamp,
        campaigns.updated_timestamp,
        campaigns.funding_instrument_id,
        campaigns.daily_budget_amount,
        campaigns.total_budget_amount,
        sum(report.clicks) as clicks, 
        sum(report.impressions) as impressions,
        sum(report.spend) as spend,
        sum(report.spend_micro) as spend_micro,
        sum(report.url_clicks) as url_clicks

        {{ fivetran_utils.persist_pass_through_columns('twitter_ads__campaign_report_passthrough_metrics', transform='sum') }}

    from report 
    left join campaigns 
        on report.campaign_id = campaigns.campaign_id
    left join accounts
        on report.account_id = accounts.account_id

    {{ dbt_utils.group_by(n=19) }}
)

select *
from final