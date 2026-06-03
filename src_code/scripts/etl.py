from sqlalchemy import create_engine, text
from pathlib import Path
import pandas as pd

DB_PATH = Path("data/db/bluestock_mf.db")
DB_PATH.parent.mkdir(parents=True, exist_ok=True)
engine = create_engine(f"sqlite:///{DB_PATH}")

# Create schema from sql file
schema_sql = (Path(__file__).parent.parent / "sql" / "schema.sql").read_text()
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