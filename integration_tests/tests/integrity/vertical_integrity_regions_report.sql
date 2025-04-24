{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('twitter_ads__using_campaign_regions_report', false)
) }}

with source as (

    select 
        campaign_id,
        region,
        count(*) as row_count,
        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(spend) as spend,
        sum(spend_micro) as spend_micro,
        sum(url_clicks) as url_clicks,
        sum({{ var('twitter_ads__conversion_fields') | join(' + ') if var('twitter_ads__conversion_fields') else 0 }}) as total_conversions,
        sum({{ var('twitter_ads__conversion_sale_amount_fields') | join(' + ') if var('twitter_ads__conversion_sale_amount_fields') else 0 }}) as total_conversions_sale_amount

    from {{ ref('stg_twitter_ads__campaign_regions_report') }}
    group by 1,2
),

model as (

    select 
        campaign_id,
        region,
        count(*) as row_count,
        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(spend) as spend,
        sum(spend_micro) as spend_micro,
        sum(url_clicks) as url_clicks,
        sum(total_conversions) as total_conversions,
        sum(total_conversions_sale_amount) as total_conversions_sale_amount
    from {{ ref('twitter_ads__campaign_region_report') }}
    group by 1,2
),

final as (

    select 
        source.campaign_id,
        source.region,
        source.row_count as source_row_count,
        model.row_count as model_row_count,
        source.impressions as source_impressions,
        model.impressions as model_impressions,
        source.clicks as source_clicks,
        model.clicks as model_clicks,
        source.spend as source_spend,
        model.spend as model_spend,
        source.spend_micro as source_spend_micro,
        model.spend_micro as model_spend_micro,
        source.url_clicks as source_url_clicks,
        model.url_clicks as model_url_clicks,
        source.total_conversions as source_total_conversions,
        model.total_conversions as model_total_conversions,
        source.total_conversions_sale_amount as source_total_conversions_sale_amount,
        model.total_conversions_sale_amount as model_total_conversions_sale_amount
    from source
    full outer join model
        on source.campaign_id = model.campaign_id
        and source.region = model.region
)

select *
from final
where
    abs(source_row_count - model_row_count) > 0
    or abs(source_impressions - model_impressions) > 0.0001
    or abs(source_clicks - model_clicks) > 0.0001
    or abs(source_spend - model_spend) > 0.0001
    or abs(source_spend_micro - model_spend_micro) > 0.0001
    or abs(source_url_clicks - model_url_clicks) > 0.0001
    or abs(source_total_conversions - model_total_conversions) > 0.0001
    or abs(source_total_conversions_sale_amount - model_total_conversions_sale_amount) > 0.0001