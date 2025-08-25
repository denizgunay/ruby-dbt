{{ config(materialized="table") }}


select 
    a.event_date, 
    p.campaign,
    a.ad_type,
    count(*) as imp_count,
    sum(a.ad_revenue) as revenue
from raw.ad_events a 
left join raw.players p using(player_id)
group by 1,2,3



