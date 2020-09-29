with adapter as (

    select *
    from {{ ref('twitter__ad_adapter') }}

), aggregated as (

    select
        date_day,
        line_item_name,
        line_item_id,
        campaign_name,
        campaign_id,
        sum(spend) as spend,
        sum(clicks) as clicks,
        sum(url_clicks) as url_clicks,
        sum(impressions) as impressions
    from adapter
    {{ dbt_utils.group_by(5) }}

), unique_id as (

    select  
        *,
        {{ dbt_utils.surrogate_key(['date_day','line_item_id']) }} as daily_line_item_id
    from aggregated

)

select *
from unique_id