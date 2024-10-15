{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (
    select
        promoted_tweet_id,
        sum(clicks) as clicks, 
        sum(impressions) as impressions,
        sum(spend) as spend,
        sum(spend_micro) as spend_micro,
        sum(url_clicks) as url_clicks
        {# sum(total_conversions) as total_conversions,
        sum(total_conversions_sale_amount) as total_conversions_sale_amount #}
    from {{ target.schema }}_twitter_ads_prod.twitter_ads__url_report
    group by 1
),

dev as (
    select
        promoted_tweet_id,
        sum(clicks) as clicks, 
        sum(impressions) as impressions,
        sum(spend) as spend,
        sum(spend_micro) as spend_micro,
        sum(url_clicks) as url_clicks
        {# sum(total_conversions) as total_conversions,
        sum(total_conversions_sale_amount) as total_conversions_sale_amount #}
    from {{ target.schema }}_twitter_ads_dev.twitter_ads__url_report
    group by 1
),

final as (
    select 
        prod.promoted_tweet_id,
        prod.clicks as prod_clicks,
        dev.clicks as dev_clicks,
        prod.url_clicks as prod_url_clicks,
        dev.url_clicks as dev_url_clicks,
        prod.impressions as prod_impressions,
        dev.impressions as dev_impressions,
        prod.spend as prod_spend,
        dev.spend as dev_spend,
        prod.spend_micro as prod_spend_micro,
        dev.spend_micro as dev_spend_micro
        {# prod.total_conversions as prod_total_conversions,
        dev.total_conversions as dev_total_conversions,
        prod.total_conversions_sale_amount as prod_total_conversions_sale_amount,
        dev.total_conversions_sale_amount as dev_total_conversions_sale_amount #}
    from prod
    full outer join dev 
        on dev.promoted_tweet_id = prod.promoted_tweet_id
)

select *
from final
where
    abs(prod_clicks - dev_clicks) >= .01
    or abs(prod_url_clicks - dev_url_clicks) >= .01
    or abs(prod_impressions - dev_impressions) >= .01
    or abs(prod_spend - dev_spend) >= .01
    or abs(prod_spend_micro - dev_spend_micro) >= .01
    {# or abs(prod_total_conversions - dev_total_conversions) >= .01
    or abs(total_conversions_sale_amount - dev_total_conversions_sale_amount) >= .01 #}