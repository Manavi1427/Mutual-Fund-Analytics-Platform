-- Q1: Top 5 fund houses by total AUM
SELECT fund_house, SUM(aum_crore) AS total_aum_crore
FROM fact_aum
GROUP BY fund_house
ORDER BY total_aum_crore DESC LIMIT 5;

-- Q2: Average NAV per month for each fund (last 12 months)
SELECT amfi_code,
       strftime('%Y-%m', date) AS month,
       ROUND(AVG(nav), 2)     AS avg_nav
FROM fact_nav
WHERE date >= date('now', '-12 months')
GROUP BY amfi_code, month ORDER BY month;

-- Q3: SIP inflow YoY growth
SELECT month,
       sip_inflow_crore,
       LAG(sip_inflow_crore, 12) OVER (ORDER BY month) AS prev_yr,
       ROUND((sip_inflow_crore - LAG(sip_inflow_crore,12)
              OVER (ORDER BY month))
             / LAG(sip_inflow_crore,12) OVER (ORDER BY month) * 100, 1)
       AS yoy_growth_pct
FROM fact_sip_industry;

-- Q4: Total SIP amount by state
SELECT state, SUM(amount_inr) AS total_sip_inr
FROM fact_transactions
WHERE transaction_type = 'Sip'
GROUP BY state ORDER BY total_sip_inr DESC;

-- Q5: Funds with expense ratio below 1%
SELECT scheme_name, fund_house, expense_ratio_pct, category
FROM dim_fund WHERE expense_ratio_pct < 1.0
ORDER BY expense_ratio_pct;

-- Q6: Best 3-year performers per category
SELECT f.category, f.scheme_name,
       p.return_3yr_pct, p.sharpe_ratio
FROM fact_performance p JOIN dim_fund f USING (amfi_code)
WHERE p.return_3yr_pct = (
    SELECT MAX(p2.return_3yr_pct) FROM fact_performance p2
    JOIN dim_fund f2 USING (amfi_code)
    WHERE f2.category = f.category);

-- Q7: Monthly transaction volume by type
SELECT strftime('%Y-%m', transaction_date) AS month,
       transaction_type, COUNT(*) AS num_tx,
       SUM(amount_inr) AS total_amount
FROM fact_transactions
GROUP BY month, transaction_type ORDER BY month;

-- Q8: Funds beating their benchmark (positive alpha)
SELECT f.scheme_name, f.fund_house, p.alpha, p.return_3yr_pct
FROM fact_performance p JOIN dim_fund f USING (amfi_code)
WHERE p.alpha > 0 ORDER BY p.alpha DESC;

-- Q9: Average SIP amount by age group and gender
SELECT age_group, gender,
       ROUND(AVG(amount_inr), 0) AS avg_sip_amount,
       COUNT(*) AS num_transactions
FROM fact_transactions
WHERE transaction_type = 'Sip'
GROUP BY age_group, gender ORDER BY age_group;

-- Q10: T30 vs B30 SIP contribution split
SELECT city_tier,
       SUM(amount_inr)                              AS total_inr,
       ROUND(SUM(amount_inr)*100.0/
             SUM(SUM(amount_inr)) OVER (), 1)       AS pct_share
FROM fact_transactions
WHERE transaction_type = 'Sip'
GROUP BY city_tier;