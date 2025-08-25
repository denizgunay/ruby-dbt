{{ config(materialized="table") }}


select 
    event_date,
    country_code,
    platform,
    product_name, 
    count(distinct player_id) as payer_count,
    sum(iap_price) as revenue
from raw.purchases
group by 1,2,3,4