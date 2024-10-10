{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with report as (

    select 
        *,
        {# Let's sum up conversions into general fields for ease of use #}
        {{ var('twitter_ads__conversion_fields') | join(' + ') if var('twitter_ads__conversion_fields') else 0 }} as total_conversions,
        {{ var('twitter_ads__conversion_sale_amount_fields') | join(' + ') if var('twitter_ads__conversion_sale_amount_fields') else 0 }} as total_conversion_sale_amount

    from {{ var('promoted_tweet_report') }}
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

line_items as (

    select *
    from {{ var('line_item_history') }}
    where is_latest_version
),

promoted_tweets as (

    select *
    from {{ var('promoted_tweet_history') }}
    where is_latest_version
),

tweets as (

    select *
    from {{ var('tweet') }}
),

final as (

    select 
        report.source_relation,
        report.date_day,
        report.placement, 
        accounts.account_id,
        accounts.name as account_name,
        campaigns.campaign_id,
        campaigns.campaign_name,
        line_items.line_item_id,
        line_items.name as line_item_name,
        promoted_tweets.promoted_tweet_id,
        promoted_tweets.tweet_id,
        tweets.name as tweet_name,
        tweets.full_text,
        promoted_tweets.is_deleted,
        promoted_tweets.entity_status as promoted_tweet_status,
        campaigns.entity_status as campaign_status,
        line_items.entity_status as line_item_status,
        tweets.language,
        campaigns.currency,
        promoted_tweets.approval_status,
        promoted_tweets.created_timestamp,
        promoted_tweets.updated_timestamp,
        sum(report.clicks) as clicks, 
        sum(report.impressions) as impressions,
        sum(report.spend) as spend,
        sum(report.spend_micro) as spend_micro,
        sum(report.url_clicks) as url_clicks,
        sum(report.total_conversions) as total_conversions,
        sum(report.total_conversion_sale_amount) as total_conversion_sale_amount

        {# Persist all of the customizable fields #}
        {{ twitter_ads_persist_pass_through_columns(pass_through_variable='twitter_ads__conversion_fields', transform='sum', coalesce_with=0, except_variable='twitter_ads__promoted_tweet_report_passthrough_metrics') }}
        {{ twitter_ads_persist_pass_through_columns(pass_through_variable='twitter_ads__conversion_sale_amount_fields', transform='sum', coalesce_with=0, except_variable='twitter_ads__promoted_tweet_report_passthrough_metrics') }}
        {{ fivetran_utils.persist_pass_through_columns('twitter_ads__promoted_tweet_report_passthrough_metrics', transform='sum') }}

    from report 
    left join promoted_tweets 
        on report.promoted_tweet_id = promoted_tweets.promoted_tweet_id
        and report.source_relation = promoted_tweets.source_relation
    left join tweets
        on promoted_tweets.tweet_id = tweets.tweet_id
        and promoted_tweets.source_relation = tweets.source_relation
    left join line_items
        on promoted_tweets.line_item_id = line_items.line_item_id
        and promoted_tweets.source_relation = line_items.source_relation
    left join campaigns 
        on line_items.campaign_id = campaigns.campaign_id
        and line_items.source_relation = campaigns.source_relation
    left join accounts
        on report.account_id = accounts.account_id
        and report.source_relation = accounts.source_relation

    {{ dbt_utils.group_by(22) }}
)

select *
from final