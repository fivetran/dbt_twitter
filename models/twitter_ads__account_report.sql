{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with accounts as (

    select *
    from {{ var('account_history') }}
    where is_latest_version
),

promoted_tweet_report as (
    
    select *
    from {{ var('promoted_tweet_report') }}
),

rollup_report as (

    select 
        date_day,
        account_id,
        placement,
        sum(clicks) as clicks, 
        sum(impressions) as impressions,
        sum(spend) as spend,
        sum(spend_micro) as spend_micro,
        sum(url_clicks) as url_clicks

        {{ fivetran_utils.persist_pass_through_columns('twitter_ads__promoted_tweet_report_passthrough_metrics', transform='sum') }}

    from promoted_tweet_report
    group by 1,2,3

),

final as (

    select 
        report.date_day,
        report.placement, 
        report.account_id,
        accounts.name as account_name,
        accounts.is_deleted,
        accounts.timezone,
        accounts.industry_type,
        accounts.approval_status,
        accounts.business_name,
        accounts.business_id,
        accounts.created_timestamp,
        accounts.updated_timestamp,
        accounts.timezone_switched_timestamp,
        sum(report.clicks) as clicks, 
        sum(report.impressions) as impressions,
        sum(report.spend) as spend,
        sum(report.spend_micro) as spend_micro,
        sum(report.url_clicks) as url_clicks

        {{ fivetran_utils.persist_pass_through_columns('twitter_ads__promoted_tweet_report_passthrough_metrics', transform='sum') }}

    from rollup_report as report
    left join accounts 
        on report.account_id = accounts.account_id

    {{ dbt_utils.group_by(n=13) }}
)

select *
from final