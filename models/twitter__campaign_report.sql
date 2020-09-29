with adapter as (

    select *
    from {{ ref('twitter__ad_adapter') }}

), aggregated as (

    select
        date_day,
        campaign_name,
        campaign_id,
        sum(spend) as spend,
        sum(clicks) as clicks,
        sum(url_clicks) as url_clicks,
        sum(impressions) as impressions
    from adapter
    {{ dbt_utils.group_by(3) }}

), unique_id as (

    select  
        *,
        {{ dbt_utils.surrogate_key(['date_day','campaign_id']) }} as daily_campaign_id
    from aggregated

)

select *
from unique_id