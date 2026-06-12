# Bluestock Mutual Fund Analytics Dashboard

### Project Documentation

# 1. Project Objective

The objective of this project is to build an end-to-end Mutual Fund Analytics platform capable of:

* Processing mutual fund datasets from multiple sources.
* Cleaning and validating financial data.
* Computing fund performance metrics.
* Performing advanced risk analytics.
* Building an interactive Power BI dashboard.
* Creating a simple recommendation engine based on investor risk appetite.

---

# 2. Project Architecture

```text
Raw Data
    ↓
Data Ingestion
    ↓
Data Cleaning & Validation
    ↓
Feature Engineering
    ↓
SQLite Database Creation
    ↓
Performance Analytics
    ↓
Advanced Analytics
    ↓
Power BI Dashboard
    ↓
Recommendation Engine
```

---

# 3. Folder Structure

```text
bluestock_mf_capstone/
│
├── data/
│   ├── raw/
│   ├── processed/
│   └── db/
│
├── notebooks/
│   ├── 01_data_ingestion.ipynb
│   ├── 02_data_cleaning.ipynb
│   ├── 03_eda_analysis.ipynb
│   ├── 04_performance_analytics.ipynb
│   └── 05_advanced_analytics.ipynb
│
├── scripts/
│   ├── etl_pipeline.py
│   ├── compute_metrics.py
│   ├── live_nav_fetch.py
│   └── recommender.py
│
├── sql/
│   ├── schema.sql
│   └── queries.sql
│
├── dashboard/
│   └── bluestock_mf_dashboard.pbix
│
├── reports/
│   ├── Dashboard.pdf
│   ├── var_cvar_report.csv
│   ├── rolling_sharpe_chart.png
│   └── dashboard screenshots
│
└── README.md
```

---

# 4. Data Sources

The project integrates multiple datasets related to the Indian Mutual Fund industry.

| Dataset               | Purpose                          |
| --------------------- | -------------------------------- |
| NAV History           | Historical fund prices           |
| Scheme Performance    | Expense ratios and fund rankings |
| AUM Data              | Industry growth analysis         |
| SIP Inflows           | Retail participation trends      |
| Investor Transactions | Investor behaviour analytics     |
| Benchmark Indices     | Fund comparison                  |
| Folio Counts          | Investor penetration metrics     |
| Fund Master           | Scheme metadata                  |

---

# 5. Data Processing Workflow

## Stage 1: Data Ingestion

Performed in:

```text
01_data_ingestion.ipynb
```

### Activities:

* Imported raw CSV datasets.
* Standardized column names.
* Converted dates to datetime format.
* Saved processed versions.

---

## Stage 2: Data Cleaning

Performed in:

```text
02_data_cleaning.ipynb
```

### Utilities Used

```python
pandas
numpy
pathlib
```

### Cleaning Procedures

### NAV Data

```text
✓ Date conversion
✓ Duplicate removal
✓ Missing NAV handling
✓ Daily returns calculation
```

---

### Scheme Performance

```text
✓ Expense ratio validation

SEBI Range:
0.1% – 2.5%
```

Negative Sharpe ratios were flagged for review.

---

### Transaction Data

```text
✓ Missing value handling
✓ Category standardization
✓ Transaction type validation
```

---

# 6. Database Design

Database:

```text
SQLite
```

File:

```text
bluestock_mf.db
```

Location:

```text
data/db/
```

---

## Database Tables

### Fund Master

```text
Primary Key:
amfi_code
```

Contains:

```text
scheme_name
fund_house
category
plan
```

---

### NAV History

Contains:

```text
date
amfi_code
nav
daily_return_pct
daily_return
```

---

### Fund Scorecard

Contains:

```text
amfi_code
cagr_1yr
cagr_3yr
cagr_5yr
sharpe_ratio
alpha
beta
max_drawdown
expense_ratio_pct
fund_score
risk_grade
scheme_name
category
```

---

### Transactions

Contains:

```text
investor_id
transaction_date
amount_inr
transaction_type
state
age_group
```

---

### Benchmark Data

Contains:

```text
date
index_name
close_value
```

---

# 7. Performance Metrics Computed

Performed in:

```text
04_performance_analytics.ipynb
compute_metrics.py
```

---

## CAGR

Used to estimate annualized returns.

Formula:

```text
CAGR =
(Ending Value / Beginning Value)^(252/trading_days) − 1
```

---

## Sharpe Ratio

Measures risk-adjusted returns.

Formula:

```text
Sharpe =
(Return − Risk Free Rate)
/ Standard Deviation
```

---

## Alpha

Measures excess return over benchmark.

```text
Alpha =
Fund Return − Expected Return
```

---

## Beta

Measures market sensitivity.

Interpretation:

```text
Beta > 1:
More volatile than market

Beta < 1:
Less volatile than market
```

---

## Maximum Drawdown

Measures worst historical decline.

Formula:

```text
(Peak − Trough) / Peak
```

---

## Fund Score

Composite score based on:

```text
Return Rank
Sharpe Rank
Alpha Rank
Expense Rank
Drawdown Rank
```

---

# 8. Advanced Analytics

Performed in:

```text
05_advanced_analytics.ipynb
```

---

## Historical VaR

95% confidence level.

Measures maximum expected loss.

Formula:

```text
VaR95 =
5th percentile of returns
```

Output:

```text
reports/var_cvar_report.csv
```

---

## Conditional VaR

Measures expected loss beyond VaR.

Formula:

```text
CVaR =
Average(Returns ≤ VaR)
```

---

## Rolling Sharpe Ratio

Window:

```text
90 Trading Days
```

Annualization:

```text
√252
```

Output:

```text
rolling_sharpe_chart.png
```

---

## Investor Cohort Analysis

Investors grouped by:

```text
First Investment Year
```

Metrics:

```text
Average Investment
Total Invested Amount
```

---

## SIP Continuity Analysis

Objective:

```text
Identify investors likely to discontinue SIPs.
```

Rule:

```text
Gap > 35 days
```

---

# 9. Recommendation Engine

Implemented in:

```text
scripts/recommender.py
```

---

## Input

```text
Low Risk
Moderate Risk
High Risk
```

---

## Methodology

Recommendations filtered using:

```text
risk_grade
```

Funds ranked using:

```text
Sharpe Ratio
Fund Score
```

---

## Output

Displays:

```text
Scheme Name
Category
Sharpe Ratio
Fund Score
```

---

# 10. Power BI Dashboard

File:

```text
dashboard/bluestock_mf_dashboard.pbix
```

---

## Page 1: Industry Overview

KPIs:

```text
Total AUM
SIP Inflows
Folios
Schemes
```

Visuals:

```text
Industry AUM Trend
AUM by AMC
```

---

## Page 2: Fund Performance

KPIs:

```text
Average Sharpe
Average CAGR
Average Alpha
Average Beta
```

Visuals:

```text
Risk vs Return Scatter
Fund Scorecard Table
NAV vs Benchmark
```

Slicers:

```text
Fund House
Category
Plan
```

---

## Page 3: Investor Analytics

Visuals:

```text
Investment by State
Transaction Type Distribution
Age Group Analysis
Monthly Transactions
```

---

## Page 4: SIP & Market Trends

KPIs:

```text
Latest SIP Inflow
Total SIP Inflows
Total Folios
Equity Folios
```

Visuals:

```text
SIP Growth Trend
Benchmark Performance
Category Inflows
Top Categories
```

---

# 11. Utilities and Libraries Used

## Python Libraries

```text
pandas
numpy
matplotlib
sqlite3
pathlib
os
```

---

## BI Tool

```text
Power BI Desktop
```

Used for:

```text
Dashboard development
Interactive filtering
DAX calculations
Data modelling
```

---

## Database

```text
SQLite
```

Used for:

```text
Centralized storage
Efficient querying
Schema management
```

---

# 12. Key Challenges Encountered

```text
• Benchmark and NAV relationship mismatches

• Empty scorecard outputs

• Scatter plot aggregation issues in Power BI

• Missing metadata columns during recommendation engine development

• Managing duplicate columns after dataframe merges

• DAX measure debugging
```

---

# 13. Project Outcomes

The project successfully delivered:

```text
✓ End-to-end ETL pipeline

✓ Mutual fund performance analytics framework

✓ Advanced risk analytics module

✓ Interactive Power BI dashboard

✓ Investor behaviour insights

✓ Fund recommendation engine

✓ SQLite-backed data architecture
```

---

# 14. Future Enhancements

```text
• Live AMFI NAV integration

• Machine Learning-based recommendation engine

• Streamlit dashboard deployment

• Automated ETL scheduling

• Portfolio optimization models

• Predictive SIP discontinuation analysis
```

---

## Conclusion

This project demonstrates the complete lifecycle of a financial analytics solution, beginning with raw mutual fund datasets and culminating in an interactive business intelligence dashboard and analytical recommendation system. The implementation integrates data engineering, exploratory analysis, financial risk modelling, database management, and visualization techniques to provide actionable insights into the Indian mutual fund ecosystem.
