{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with accounts as (

    select *
    from {{ ref('stg_twitter_ads__account_history') }}
    where is_latest_version
),

account_currency as (

    {# Twitter accounts have no currency field. Every campaign carries the account's currency,
       so take it from the latest version of each campaign (deleted ones included, since an
       account's currency does not change). If an account's campaigns disagree, leave it null
       rather than guess. #}
    select
        source_relation,
        account_id,
        case when count(distinct currency) = 1 then max(currency) end as currency
    from {{ ref('stg_twitter_ads__campaign_history') }}
    where is_latest_version
        and currency is not null
    group by 1, 2
),

promoted_tweet_report as (
    
    select 
        *,
        {# Let's sum up conversions into general fields for ease of use #}
        {{ var('twitter_ads__conversion_fields') | join(' + ') if var('twitter_ads__conversion_fields') else 0 }} as total_conversions,
        {{ var('twitter_ads__conversion_sale_amount_fields') | join(' + ') if var('twitter_ads__conversion_sale_amount_fields') else 0 }} as total_conversions_sale_amount

    from {{ ref('stg_twitter_ads__promoted_tweet_report') }}
),

rollup_report as (

    select 
        source_relation,
        date_day,
        account_id,
        placement,
        sum(clicks) as clicks, 
        sum(impressions) as impressions,
        sum(spend) as spend,
        sum(spend_micro) as spend_micro,
        sum(url_clicks) as url_clicks,
        sum(total_conversions) as total_conversions,
        sum(total_conversions_sale_amount) as total_conversions_sale_amount

        {# Persist all of the customizable fields #}
        {{ twitter_ads_persist_pass_through_columns(pass_through_variable='twitter_ads__conversion_fields', transform='sum', coalesce_with=0, except_variable='twitter_ads__promoted_tweet_report_passthrough_metrics') }}
        {{ twitter_ads_persist_pass_through_columns(pass_through_variable='twitter_ads__conversion_sale_amount_fields', transform='sum', coalesce_with=0, except_variable='twitter_ads__promoted_tweet_report_passthrough_metrics') }}
        {{ fivetran_utils.persist_pass_through_columns('twitter_ads__promoted_tweet_report_passthrough_metrics', transform='sum') }}
    
    from promoted_tweet_report
    {{ dbt_utils.group_by(4) }}

),

final as (

    select 
        report.source_relation,
        report.date_day,
        report.placement, 
        report.account_id,
        accounts.name as account_name,
        account_currency.currency,
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
        sum(report.url_clicks) as url_clicks,
        sum(report.total_conversions) as total_conversions,
        sum(report.total_conversions_sale_amount) as total_conversions_sale_amount

        {# Persist all of the customizable fields #}
        {{ twitter_ads_persist_pass_through_columns(pass_through_variable='twitter_ads__conversion_fields', transform='sum', coalesce_with=0, except_variable='twitter_ads__promoted_tweet_report_passthrough_metrics') }}
        {{ twitter_ads_persist_pass_through_columns(pass_through_variable='twitter_ads__conversion_sale_amount_fields', transform='sum', coalesce_with=0, except_variable='twitter_ads__promoted_tweet_report_passthrough_metrics') }}
        {{ fivetran_utils.persist_pass_through_columns('twitter_ads__promoted_tweet_report_passthrough_metrics', transform='sum') }}

    from rollup_report as report
    left join accounts 
        on report.account_id = accounts.account_id
        and report.source_relation = accounts.source_relation
    left join account_currency
        on report.account_id = account_currency.account_id
        and report.source_relation = account_currency.source_relation

    {{ dbt_utils.group_by(15) }}
)

select *
from final