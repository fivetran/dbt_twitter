{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True) and var('twitter_ads__using_campaign_locations_report', False)) }}

with base as (

    select * 
    from {{ ref('stg_twitter_ads__campaign_locations_report_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_ads__campaign_locations_report_tmp')),
                staging_columns=get_campaign_locations_report_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='twitter_ads_union_schemas', 
            union_database_variable='twitter_ads_union_databases') 
        }}
    from base
),

final as (
    
    select 
        source_relation, 
        {{ dbt.date_trunc('day', 'date') }} as date_day,
        -- Most people have country stored in segment_name, but some will have it in segment still
        coalesce(segment_name, segment) as country,
        account_id,
        campaign_id,
        placement,
        clicks,
        impressions,
        billed_charge_local_micro as spend_micro,
        round(billed_charge_local_micro / 1000000.0,2) as spend,
        url_clicks

        {% for conversion in var('twitter_ads__conversion_fields', []) %}
            , coalesce(cast({{ conversion }} as {{ dbt.type_bigint() }}), 0) as {{ conversion }}
        {% endfor %}

        {% for conversion_value in var('twitter_ads__conversion_sale_amount_fields', []) %}
            , coalesce(cast({{ conversion_value }} as {{ dbt.type_float() }}), 0) as {{ conversion_value }}
        {% endfor %}

        {{ twitter_ads_fill_pass_through_columns(pass_through_fields=var('twitter_ads__campaign_locations_report_passthrough_metrics')) }}

    from fields
)

select *
from final
