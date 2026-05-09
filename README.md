# Customer Churn Prediction & Retention Decision System

> Most churn projects stop at a prediction. This one ends with a business decision.

**Live App → [Open in Streamlit](https://end-to-end-customer-churn-prediction-retention-decision-system.streamlit.app/)**

---

## What this is

A production-ready ML system that predicts customer churn **and** tells the business what to do about it.

Instead of outputting a raw probability:

```
Churn probability = 0.77
```

The system outputs a decision:

```
High Risk → Prioritise for retention review
Estimated retention value: $XXX | Campaign cost: $XX | Net impact: $XX
```

Built with a modular pipeline, a configurable decision engine, and a live Streamlit app usable by a business team without any technical setup.

---

## Why it stands out

- **Not just a model** — full pipeline from raw data to deployed app
- **Not just accuracy** — threshold optimization, business scenario simulation, ROI framing
- **Not just notebooks** — modular `src/` structure with clean separation of concerns (38 commits)
- **Intentional design decisions** — documented tradeoffs, not default choices

---

## Results

| Metric | Value |
|--------|-------|
| ROC-AUC | ~0.85 |
| Model | Logistic Regression (production) |
| Class imbalance | Handled via weighted models |
| Decision engine | Configurable threshold (not fixed at 0.5) |

---

## System Design

### 1. Prediction layer
- Logistic Regression selected over XGBoost — intentionally, for interpretability and prediction stability in a business-facing setting
- XGBoost used as benchmark comparison
- Class imbalance handled via class weighting

### 2. Decision layer
- Threshold is configurable in the app — not hardcoded at 0.5
- Risk segmentation: **Low / Moderate / High** — dynamically assigned based on selected threshold
- Each prediction maps to a suggested next action

### 3. Business layer
- Simulates the impact of running a retention campaign across the customer base
- **3-scenario analysis**: Pessimistic / Expected / Optimistic
- Outputs: who gets targeted, campaign cost, expected retained value, net business impact
- Makes the model output directly usable for budget and strategy decisions

---

## Key Design Decisions

| Decision | Reason |
|----------|--------|
| Logistic Regression over XGBoost in production | Interpretable, stable, explainable to stakeholders |
| `Churn Reason` feature excluded | Direct leakage — it reveals the outcome, not a predictor |
| Threshold not fixed at 0.5 | Business cost of false negatives ≠ false positives; threshold should reflect that |
| Confidence score removed from UI | Replaced with clearer risk classification logic |
| Modular `src/` pipeline | Reproducible retraining, clean separation of concerns |

---

## Live App

**[→ Open App](https://end-to-end-customer-churn-prediction-retention-decision-system.streamlit.app/)**

![App Screenshot](screenshots/Screenshot%20(86).png)

[▶️ Watch Demo Video](App_videos/App%20Recording.webm)

What you can do in the app:
- Input a customer profile and get a real-time churn prediction
- Adjust the decision threshold and watch risk classification update live
- Run the business simulation across Pessimistic / Expected / Optimistic scenarios
- Explore feature importance to understand what drives churn predictions
- Compare Logistic Regression vs XGBoost performance

---

## Project Structure

```
telco-churn-decision-system/
├── app/                    # Streamlit UI
├── src/
│   ├── cleaning.py         # Data cleaning
│   ├── preprocessing.py    # Feature preprocessing
│   ├── features.py         # Feature engineering
│   ├── models.py           # Model training & comparison
│   ├── evaluation.py       # Metrics & reporting
│   ├── predict.py          # Inference logic
│   └── run_pipeline.py     # End-to-end pipeline runner
├── models/                 # Saved model artifacts
├── reports/                # Evaluation outputs
├── data/                   # Raw dataset
├── data_processed/         # Cleaned & processed data
├── requirements.txt
└── README.md
```

---

## Running Locally

```bash
pip install -r requirements.txt
python -m src.run_pipeline
streamlit run app/streamlit_app.py
```

---

## Tech Stack

`Python` · `Scikit-learn` · `XGBoost` · `Pandas` · `NumPy` · `Streamlit` · `Matplotlib` · `Seaborn`

---

## Author

**Nihar Nandala**
[GitHub](https://github.com/niharnandala) · [LinkedIn](https://linkedin.com/in/niharnandala)
