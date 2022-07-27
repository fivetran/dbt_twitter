with accounts as (

    select *
    from {{ var('account_history') }}
    where is_latest_version
),

promoted_tweet_report as (
-- roll this up to the account -> or should we use highest grain like campaign?
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

{# join_reports as (

    select 
        coalesce(account_report.date_day, rollup_report.date_day) as date_day,
        coalesce(account_report.account_id, rollup_report.account_id) as account_id,
        coalesce(account_report.placement, rollup_report.placement) as placement,
        coalesce(rollup_report.clicks, 0) as clicks,
        coalesce(account_report.impressions, rollup_report.impressions) as impressions, -- this indeed ties out, maybe we don't need the account_report
        coalesce(rollup_report.spend, 0) as spend,
        coalesce(rollup_report.spend_micro, 0) as spend_micro,
        coalesce(rollup_report.url_clicks, 0) as url_clicks

        -- these won't be coalesced with 0 
        {{ fivetran_utils.persist_pass_through_columns('twitter_ads__promoted_tweet_report_passthrough_metrics') }}

    from account_report
    full outer join rollup_report
        on account_report.account_id = rollup_report.account_id
        and account_report.date_day = rollup_report.date_day
        and account_report.placement = rollup_report.placement

), #}

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