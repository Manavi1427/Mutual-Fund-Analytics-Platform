import pandas as pd
from pathlib import Path

ROOT = Path.cwd().parent if Path.cwd().name == "scripts" else Path.cwd()
PROCESSED = ROOT / "src_code"/"data" / "processed"
scorecard = pd.read_csv(PROCESSED/"fund_scorecard.csv")

risk_map = {
    "Low": "Low",
    "Moderate": "Moderate",
    "High": "High"
}

risk = input("Risk appetite (Low/Moderate/High): ")
recommendations = (
    scorecard[
        scorecard["risk_grade"]
        == risk_map[risk]
    ]
    .sort_values(
        "sharpe_ratio",
        ascending=False
    )
    .head(3)
)

print(
    recommendations[
        [
            "scheme_name",
            "category",
            "sharpe_ratio",
            "fund_score"
        ]
    ]
)