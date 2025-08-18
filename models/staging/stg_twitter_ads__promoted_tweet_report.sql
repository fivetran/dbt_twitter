{{ config(enabled=var('ad_reporting__twitter_ads_enabled', True)) }}

with source as (

    select *
    from {{ ref('stg_twitter_ads__promoted_tweet_report_tmp') }}

),

renamed as (

    select
    
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_ads__promoted_tweet_report_tmp')),
                staging_columns=get_promoted_tweet_report_columns()
            )
        }}
    
        {{ fivetran_utils.source_relation(
            union_schema_variable='twitter_ads_union_schemas', 
            union_database_variable='twitter_ads_union_databases') 
        }}

    from source

), spend_calc as (

    select
        source_relation,
        {{ dbt.date_trunc('day', 'date') }} as date_day,
        account_id,
        promoted_tweet_id,
        placement,
        clicks as clicks,
        impressions as impressions,
        billed_charge_local_micro as spend_micro,
        round(billed_charge_local_micro / 1000000.0,2) as spend,
        url_clicks as url_clicks

        {% for conversion in var('twitter_ads__conversion_fields', []) %}
            , coalesce(cast({{ conversion }} as {{ dbt.type_bigint() }}), 0) as {{ conversion }}
        {% endfor %}

        {% for conversion_value in var('twitter_ads__conversion_sale_amount_fields', []) %}
            , coalesce(cast({{ conversion_value }} as {{ dbt.type_float() }}), 0) as {{ conversion_value }}
        {% endfor %}

        {{ twitter_ads_fill_pass_through_columns(pass_through_fields=var('twitter_ads__promoted_tweet_report_passthrough_metrics'), except=(var('twitter_ads__conversion_fields') + var('twitter_ads__conversion_sale_amount_fields'))) }}

    from renamed

)

select * from spend_calc