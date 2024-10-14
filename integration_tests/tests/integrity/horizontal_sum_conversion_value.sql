{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with account_report as (

    select 
        sum(total_conversions) as total_conversions,
        sum(total_conversions_sale_amount) as total_conversions_sale_amount
    from {{ ref('twitter_ads__account_report') }}
),

campaign_report as (

    select 
        sum(total_conversions) as total_conversions,
        sum(total_conversions_sale_amount) as total_conversions_sale_amount
    from {{ ref('twitter_ads__campaign_report') }}
),

keyword_report as (

    select 
        sum(total_conversions) as total_conversions,
        sum(total_conversions_sale_amount) as total_conversions_sale_amount
    from {{ ref('twitter_ads__keyword_report') }}
),

line_item_report as (

    select 
        sum(total_conversions) as total_conversions,
        sum(total_conversions_sale_amount) as total_conversions_sale_amount
    from {{ ref('twitter_ads__line_item_report') }}
),

promoted_tweet_report as (

    select 
        sum(total_conversions) as total_conversions,
        sum(total_conversions_sale_amount) as total_conversions_sale_amount
    from {{ ref('twitter_ads__promoted_tweet_report') }}
),

url_report as (

    select 
        sum(total_conversions) as total_conversions,
        sum(total_conversions_sale_amount) as total_conversions_sale_amount
    from {{ ref('twitter_ads__url_report') }}
)

select 
    'promoted tweet vs account' as comparison
from promoted_tweet_report
join account_report on true
where promoted_tweet_report.total_conversions != account_report.total_conversions
    or promoted_tweet_report.total_conversions_sale_amount != account_report.total_conversions_sale_amount

union all 

select 
    'promoted tweet vs campaign' as comparison
from promoted_tweet_report
join campaign_report on true
where promoted_tweet_report.total_conversions != campaign_report.total_conversions
    or promoted_tweet_report.total_conversions_sale_amount != campaign_report.total_conversions_sale_amount

union all 

select 
    'promoted tweet vs keyword' as comparison
from promoted_tweet_report
join keyword_report on true
where promoted_tweet_report.total_conversions != keyword_report.total_conversions
    or promoted_tweet_report.total_conversions_sale_amount != keyword_report.total_conversions_sale_amount

union all 

select 
    'promoted tweet vs line item' as comparison
from promoted_tweet_report
join line_item_report on true
where promoted_tweet_report.total_conversions != line_item_report.total_conversions
    or promoted_tweet_report.total_conversions_sale_amount != line_item_report.total_conversions_sale_amount

union all 

select 
    'promoted tweet vs url' as comparison
from promoted_tweet_report
join url_report on true
where promoted_tweet_report.total_conversions != url_report.total_conversions
    or promoted_tweet_report.total_conversions_sale_amount != url_report.total_conversions_sale_amount
