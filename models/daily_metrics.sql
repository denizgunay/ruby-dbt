
{{ config(materialized="table") }}

with imps as (
    select 
        event_date, 
        player_id,
        count(case when ad_type = 'REWARDED' then 1 end) as rw_imp_count,
        count(case when ad_type = 'INTERSTITIAL' then 1 end) as int_imp_count
    from raw.ad_events
    where ad_type != 'BANNER'
    group by 1,2
),

uas as (
    select 
        date,
        campaign,
        country_name,
        platform,
        sum(spend) as daily_spend
    from raw.ua_spend
    group by 1,2,3,4
),


launch as (
    select
        country_name,
        platform,
        campaign,
        min(date) as launch_date
    from uas
    group by 1,2,3
),

players as (
    select
        player_id, 
        install_date,
        country_name, 
        platform, 
        ua_category,
        ua_network, 
        campaign
    from raw.players
    group by 1,2,3,4,5,6,7
),

base as (
    select
        p.player_id,
        p.install_date,
        p.country_name,
        p.platform,
        p.ua_category,
        p.ua_network,
        p.campaign,
        d.event_date,
        d.iap_count,
        d.iap_revenue,
        d.ad_revenue_tracked,
        d.ad_revenue_reported,
        d.time_spent_seconds,
        coalesce(i.rw_imp_count,0) as rw_imp_count,
        coalesce(i.int_imp_count,0) as int_imp_count,
        u.date as ua_date,
        u.daily_spend
    from raw.players_daily d
    left join players p using(player_id)
    left join imps i using(player_id, event_date)
    left join uas u 
        on u.campaign = p.campaign
       and u.country_name = p.country_name
       and u.platform = p.platform
       and u.date <= p.install_date
),

ranked as (
    select * ,
        row_number() over (
            partition by player_id, event_date
            order by ua_date desc
        ) as rn
    from base
),

daily as (
    select
        install_date,
        country_name,
        platform,
        ua_category,
        ua_network,
        campaign,
        ua_date,
        event_date,
        date_diff(event_date, install_date, day) as cohort_day,
        count(distinct player_id) as dau,
        count(distinct case when iap_revenue > 0 then player_id end) as iap_dau,
        sum(iap_count) as iap_count,
        sum(iap_revenue) as iap_revenue,
        sum(rw_imp_count) as rw_imp_count,
        sum(int_imp_count) as int_imp_count,
        sum(coalesce(ad_revenue_tracked,0)) as ad_revenue_tracked,
        sum(coalesce(ad_revenue_reported,0)) as ad_revenue_reported,
        sum(iap_revenue + coalesce(ad_revenue_reported,0)) as total_revenue,
        sum(time_spent_seconds)/60 as playtime,
        max(daily_spend) as spend
    from ranked
    where rn = 1
    group by 1,2,3,4,5,6,7,8,9
),

final as (
    select
        l.launch_date,
        d.*,
        sum(total_revenue) over (
            partition by install_date, country_name, platform, ua_category, ua_network, campaign, ua_date
            order by event_date
            rows between unbounded preceding and current row
        ) as cum_total_revenue
    from daily d
    left join launch l
      using (country_name, platform, campaign)
)

select 
    * except(ua_date)
from final

