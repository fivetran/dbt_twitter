{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True) and var('twitter_ads__using_campaign_regions_report', False)) }}

with report as (

    select 
        *,
        {# Let's sum up conversions into general fields for ease of use #}
        {{ var('twitter_ads__conversion_fields') | join(' + ') if var('twitter_ads__conversion_fields') else 0 }} as total_conversions,
        {{ var('twitter_ads__conversion_sale_amount_fields') | join(' + ') if var('twitter_ads__conversion_sale_amount_fields') else 0 }} as total_conversions_sale_amount

    from {{ var('campaign_regions_report') }}
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
        report.source_relation,
        report.date_day,
        report.region,
        report.country,
        report.placement, 
        report.account_id,
        accounts.name as account_name,
        report.campaign_id,
        campaigns.campaign_name,
        campaigns.is_deleted as is_campaign_deleted,
        campaigns.entity_status as campaign_status,
        campaigns.currency as campaign_currency,
        campaigns.is_servable as is_campaign_servable,
        campaigns.is_standard_delivery as is_campaign_standard_delivery,
        campaigns.frequency_cap as campaign_frequency_cap,
        campaigns.start_timestamp as campaign_start_timestamp,
        campaigns.end_timestamp as campaign_end_timestamp,
        campaigns.created_timestamp as campaign_created_timestamp,
        campaigns.updated_timestamp as campaign_updated_timestamp,
        campaigns.funding_instrument_id as campaign_funding_instrument_id,
        campaigns.daily_budget_amount as campaign_daily_budget_amount,
        campaigns.total_budget_amount as campaign_total_budget_amount,
        sum(report.clicks) as clicks, 
        sum(report.impressions) as impressions,
        sum(report.spend) as spend,
        sum(report.spend_micro) as spend_micro,
        sum(report.url_clicks) as url_clicks,
        sum(report.total_conversions) as total_conversions,
        sum(report.total_conversions_sale_amount) as total_conversions_sale_amount

        {# Persist all of the customizable fields #}
        {{ twitter_ads_persist_pass_through_columns(pass_through_variable='twitter_ads__conversion_fields', transform='sum', coalesce_with=0) }}
        {{ twitter_ads_persist_pass_through_columns(pass_through_variable='twitter_ads__conversion_sale_amount_fields', transform='sum', coalesce_with=0) }}
        {{ fivetran_utils.persist_pass_through_columns('twitter_ads__campaign_regions_report_passthrough_metrics', transform='sum') }}

    from report 
    left join campaigns 
        on report.campaign_id = campaigns.campaign_id
        and report.source_relation = campaigns.source_relation
    left join accounts
        on report.account_id = accounts.account_id
        and report.source_relation = accounts.source_relation

    {{ dbt_utils.group_by(22) }}
)

select *
from final