# 📊 Metrics DBT

This project contains a **dbt data model** for analyzing game performance metrics by **install date** and **event date**.  
It helps track **user acquisition (UA)**, **revenue**, and **engagement metrics** at a cohort level.

---

## 🚀 Project Structure

- **`models/`** – contains SQL models and `schema.yml` definitions  
- **`schema.yml`** – documents each model and column with descriptions and tests  
- **`dbt_project.yml`** – configures the dbt project settings  

---

## 📂 Data Model: `daily_metrics`

The model in this project is **`daily_metrics`**, which provides daily KPIs for each campaign and cohort.  
Below are the key fields:

- `launch_date` → Campaign launch date  
- `install_date` → Player install date  
- `country_name` → Country of the player  
- `platform` → iOS / Android  
- `ua_category` → User acquisition category  
- `ua_network` → UA network name  
- `campaign` → Campaign identifier  
- `event_date` → Date of the recorded event  
- `cohort_day` → Days since install (0 = install day)  
- `dau` → Daily active users  
- `iap_dau` → Daily active payers  
- `iap_count` → Number of in-app purchases  
- `iap_revenue` → Revenue from in-app purchases  
- `rw_imp_count` → Rewarded ad impressions  
- `int_imp_count` → Interstitial ad impressions  
- `ad_revenue_tracked` → Ad revenue (tracked)  
- `ad_revenue_reported` → Ad revenue (reported by network)  
- `total_revenue` → Combined revenue (IAP + Ads)  
- `playtime` → Total playtime in minutes  
- `spend` → UA spend for the campaign/date  
- `cum_total_revenue` → Cumulative revenue up to that day  



