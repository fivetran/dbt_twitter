{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with report as (

    select *
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

tweet_url as (

    select *
    from {{ var('tweet_url') }}
    where index = 0
),

final as (

    select 
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
        tweets.full_text as tweet_full_text,
        tweet_url.base_url,
        tweet_url.url_host,
        tweet_url.url_path,
        tweet_url.utm_source,
        tweet_url.utm_medium,
        tweet_url.utm_campaign,
        tweet_url.utm_content,
        tweet_url.utm_term,
        tweet_url.expanded_url,
        tweet_url.display_url,
        campaigns.currency,
        sum(report.clicks) as clicks, 
        sum(report.impressions) as impressions,
        sum(report.spend) as spend,
        sum(report.spend_micro) as spend_micro,
        sum(report.url_clicks) as url_clicks

        {{ fivetran_utils.persist_pass_through_columns('twitter_ads__promoted_tweet_report_passthrough_metrics', transform='sum') }}

    from report 
    left join promoted_tweets 
        on report.promoted_tweet_id = promoted_tweets.promoted_tweet_id
    left join tweet_url 
        on promoted_tweets.tweet_id = tweet_url.tweet_id
    left join tweets
        on promoted_tweets.tweet_id = tweets.tweet_id
    left join line_items
        on promoted_tweets.line_item_id = line_items.line_item_id
    left join campaigns 
        on line_items.campaign_id = campaigns.campaign_id
    left join accounts
        on report.account_id = accounts.account_id
    
    {% if var('ad_reporting__url_report__using_null_filter', True) %}
        where tweet_url.expanded_url is not null
    {% endif %}

    {{ dbt_utils.group_by(n=23) }}

    
)

select *
from final