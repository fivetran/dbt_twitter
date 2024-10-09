{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with report as (

    select 
        *,
        {# Let's sum up conversions into general fields for ease of use #}
        {{ var('twitter_ads__conversion_fields') | join(' + ') if var('twitter_ads__conversion_fields') else 0 }} as total_conversions,
        {{ var('twitter_ads__conversion_sale_amount_fields') | join(' + ') if var('twitter_ads__conversion_sale_amount_fields') else 0 }} as total_conversion_sale_amount

    from {{ var('line_item_report') }}
),

line_items as (

    select *
    from {{ var('line_item_history') }}
    where is_latest_version
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
        report.placement, 
        report.account_id,
        accounts.name as account_name,
        line_items.campaign_id,
        campaigns.campaign_name,
        report.line_item_id,
        line_items.name as line_item_name,
        line_items.is_deleted,
        line_items.entity_status as line_item_status,
        campaigns.entity_status as campaign_status,
        line_items.currency,
        line_items.advertiser_domain,
        line_items.advertiser_user_id,
        line_items.bid_type,
        line_items.bid_unit,
        line_items.charge_by,
        line_items.objective,
        line_items.optimization,
        line_items.product_type,
        line_items.primary_web_event_tag,
        line_items.creative_source,
        line_items.start_timestamp,
        line_items.end_timestamp,
        line_items.created_timestamp,
        line_items.updated_timestamp,
        line_items.target_cpa,
        line_items.total_budget_amount,
        line_items.bid_amount,
        sum(report.clicks) as clicks, 
        sum(report.impressions) as impressions,
        sum(report.spend) as spend,
        sum(report.spend_micro) as spend_micro,
        sum(report.url_clicks) as url_clicks,
        sum(report.total_conversions) as total_conversions,
        sum(report.total_conversion_sale_amount) as total_conversion_sale_amount

        {# Persist all of the customizable fields #}
        {{ twitter_ads_persist_pass_through_columns(pass_through_variable='twitter_ads__conversion_fields', transform='sum', coalesce_with=0, except_variable='twitter_ads__line_item_report_passthrough_metrics') }}
        {{ twitter_ads_persist_pass_through_columns(pass_through_variable='twitter_ads__conversion_sale_amount_fields', transform='sum', coalesce_with=0, except_variable='twitter_ads__line_item_report_passthrough_metrics') }}
        {{ fivetran_utils.persist_pass_through_columns('twitter_ads__line_item_report_passthrough_metrics', transform='sum')}}

    from report 
    left join line_items
        on report.line_item_id = line_items.line_item_id
        and report.source_relation = line_items.source_relation
    left join campaigns 
        on line_items.campaign_id = campaigns.campaign_id
        and line_items.source_relation = campaigns.source_relation
    left join accounts
        on report.account_id = accounts.account_id
        and report.source_relation = accounts.source_relation

    {{ dbt_utils.group_by(30) }}
)

select *
from final