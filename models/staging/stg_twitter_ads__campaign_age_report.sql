{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True) and var('twitter_ads__using_campaign_age_report', False)) }}

with base as (

    select * 
    from {{ ref('stg_twitter_ads__campaign_age_report_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_ads__campaign_age_report_tmp')),
                staging_columns=get_campaign_age_report_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='twitter_ads') }}
    from base
),

final as (
    
    select 
        source_relation, 
        {{ dbt.date_trunc('day', 'date') }} as date_day,
        segment as age_range,
        -- Twitter age ranges follow the '<min> to <max>' format. The oldest range is open-ended ('over 65'), which gets a max_age of 100, and 'AGE_UNDER_13' maps to 0 to 12. Other values return null.
        case
            when segment like '% to %' then cast(nullif({{ dbt.split_part('segment', "' to '", 1) }}, '') as {{ dbt.type_int() }})
            when lower(segment) like 'over %' then cast(nullif({{ dbt.replace('lower(segment)', "'over '", "''") }}, '') as {{ dbt.type_int() }})
            when segment = 'AGE_UNDER_13' then 0
        end as min_age,
        case
            when segment like '% to %' then cast(nullif({{ dbt.split_part('segment', "' to '", 2) }}, '') as {{ dbt.type_int() }})
            when lower(segment) like 'over %' then 100
            when segment = 'AGE_UNDER_13' then 12
        end as max_age,
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

        {{ twitter_ads_fill_pass_through_columns(pass_through_fields=var('twitter_ads__campaign_age_report_passthrough_metrics')) }}

    from fields
)

select *
from final
