-- sql/schema.sql

CREATE TABLE IF NOT EXISTS dim_fund (
    amfi_code        TEXT PRIMARY KEY,
    fund_house       TEXT NOT NULL,
    scheme_name      TEXT NOT NULL,
    category         TEXT,          -- Equity / Debt / Hybrid
    sub_category     TEXT,
    plan             TEXT,
    benchmark        TEXT,
    expense_ratio_pct REAL,
    risk_category    TEXT,
    fund_manager     TEXT,
    launch_date      DATE
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_id   INTEGER PRIMARY KEY,  -- YYYYMMDD integer
    date      DATE    UNIQUE NOT NULL,
    year      INTEGER,
    month     INTEGER,
    quarter   INTEGER,
    is_weekday INTEGER               -- 1=weekday 0=weekend
);

CREATE TABLE IF NOT EXISTS fact_nav (
    amfi_code        TEXT REFERENCES dim_fund(amfi_code),
    date             DATE,
    nav              REAL NOT NULL,
    daily_return_pct REAL,
    PRIMARY KEY (amfi_code, date)
);

CREATE TABLE IF NOT EXISTS fact_transactions (
    tx_id              TEXT PRIMARY KEY,
    investor_id        TEXT,
    amfi_code          TEXT REFERENCES dim_fund(amfi_code),
    transaction_date   DATE,
    transaction_type   TEXT,          -- SIP / Lumpsum / Redemption
    amount_inr         INTEGER,
    state              TEXT,
    city               TEXT,
    city_tier          TEXT,          -- T30 / B30
    age_group          TEXT,
    gender             TEXT,
    annual_income_lakh REAL,
    payment_mode       TEXT,
    kyc_status         TEXT
);

CREATE TABLE IF NOT EXISTS fact_performance (
    amfi_code        TEXT REFERENCES dim_fund(amfi_code),
    as_of_date       DATE,
    return_1yr_pct   REAL,
    return_3yr_pct   REAL,
    return_5yr_pct   REAL,
    benchmark_3yr_pct REAL,
    alpha            REAL,
    beta             REAL,
    sharpe_ratio     REAL,
    sortino_ratio    REAL,
    std_dev_ann_pct  REAL,
    max_drawdown_pct REAL,
    PRIMARY KEY (amfi_code, as_of_date)
);

CREATE TABLE IF NOT EXISTS fact_aum (
    fund_house       TEXT,
    quarter_date     DATE,
    aum_crore        REAL,           -- scheme-level (NOT lakh crore)
    num_schemes      INTEGER,
    PRIMARY KEY (fund_house, quarter_date)
);

CREATE INDEX IF NOT EXISTS idx_nav_code_date ON fact_nav(amfi_code, date);
CREATE INDEX IF NOT EXISTS idx_tx_code       ON fact_transactions(amfi_code);
CREATE INDEX IF NOT EXISTS idx_tx_date       ON fact_transactions(transaction_date);
SQL · SQLite
sql/schema.sql
60 min
5
Load cleaned CSVs into SQLite with SQLAlchemy
Use if_exists='replace' on first run so reruns are idempotent. Load schema.sql first to create tables with correct constraints.
from sqlalchemy import create_engine, text
from pathlib import Path
import pandas as pd

DB_PATH = Path("data/db/bluestock_mf.db")
DB_PATH.parent.mkdir(parents=True, exist_ok=True)
engine = create_engine(f"sqlite:///{DB_PATH}")

# Create schema from sql file
schema_sql = (Path("sql") / "schema.sql").read_text()
with engine.begin() as conn:
    for stmt in schema_sql.split(";"):
        stmt = stmt.strip()
        if stmt:
            conn.execute(text(stmt))

PROC = Path("data/processed")
table_map = {
    "dim_fund":           "clean_fund_master.csv",
    "fact_nav":           "clean_nav.csv",
    "fact_transactions":  "clean_transactions.csv",
    "fact_performance":   "clean_performance.csv",
    "fact_aum":           "clean_aum.csv",
}
for table, fname in table_map.items():
    df = pd.read_csv(PROC / fname)
    df.to_sql(table, engine, if_exists="replace", index=False)
    print(f"Loaded {table}: {len(df):,} rows")
SQLAlchemy · SQLite
data/db/bluestock_mf.db
45 min
10 analytical SQL queries (60 min)
6
Write sql/queries.sql — all 10 analytical queries
These become the foundation for Day 5 Power BI measures. Write them to run correctly against your schema.
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