# Telco Customer Churn — Findings Summary

**Project:** End-to-End Customer Churn Prediction & Retention Decision System  
**Dataset:** IBM Telco Customer Churn (7,043 customers)  
**Analysis:** SQL-based business intelligence layer  
**Model:** Logistic Regression (AUC: 0.85)  

---

## Business Question

Where is revenue leaking through churn, which customer segments are responsible, and what specific interventions stop it?

---

## The Situation

The company is losing 1 in 4 customers. Overall churn rate sits at 26.5% against a telecom industry benchmark of under 10%. That gap translates to **$139,130 in recurring monthly revenue already gone** — not a one-time loss, but a recurring hole in revenue every single month.

A further **$104,070 in monthly revenue is currently at risk** from 1,698 active customers showing high churn signals.

---

## Key Findings

### 1. Contract Type Is the Single Biggest Revenue Leak

Month-to-month customers make up 48% of the customer base but are responsible for **87% of total monthly revenue lost.**

| Contract | Churn Rate | Revenue Lost Monthly | % of Total Loss |
|---|---|---|---|
| Month-to-month | 42.7% | $120,847 | 86.9% |
| One year | 11.3% | $14,118 | 10.1% |
| Two year | 2.8% | $4,165 | 3.0% |

The gap between customer share (48%) and revenue loss share (87%) is the core problem. Month-to-month customers are not just churning more — they are the most expensive customers to lose.

---

### 2. The First 10 Months Are the Danger Window

Nearly half of all revenue lost — **45.8%** — comes from customers in their first 10 months.

| Tenure | Churn Rate | Revenue Lost | % of Total Loss |
|---|---|---|---|
| 0-10 months | 49.1% | $63,754 | 45.8% |
| 11-20 months | 31.2% | $21,804 | 15.7% |
| 21-30 months | 22.8% | $14,314 | 10.3% |
| 60+ months | <10% | — | — |

Customers who survive past month 30 are largely safe. The entire retention effort should be front-loaded into the first year.

---

### 3. Fiber Optic Is the Highest Revenue, Highest Risk Segment

Fiber optic customers churn at **42%** — more than double the DSL rate of 19% — despite having the same average number of services (4).

This is not a product gap. It is an expectation gap. Customers paying premium prices expect premium experience. When service quality falls short, they leave faster than any other segment.

| Internet Service | Churn Rate | Revenue Lost Monthly |
|---|---|---|
| Fiber optic | 42% | $114,300 |
| DSL | 19% | $22,529 |
| No service | 7% | $2,301 |

---

### 4. More Services = Lower Churn. Every Single Time.

Customers with 0 services churn at 44%. Customers with 8 services churn at 5%.

Every additional service a customer uses increases switching friction. The product bundle is the most passive retention tool available — it requires no outreach and no discount.

---

### 5. The Worst Combination in the Entire Dataset

Month-to-month contract + Fiber optic + Tenure 0-10 months = **71.5% churn rate.**

834 customers historically sat in this segment. Nearly 3 out of 4 left.

Of the 238 active customers currently in this combination:

- **204 have no online security** → $16,266 monthly revenue at risk
- **34 have online security** → $2,836 monthly revenue at risk

One security add-on separates a 65% churn risk from an 8% churn risk inside the same segment. The intervention cost is a $10/month add-on. The revenue protected is $16,266/month.

---

### 6. The Business Is Losing More to Its Own Failures Than to Competitors

| Churn Category | Customers Lost | Revenue Lost Monthly |
|---|---|---|
| Fixable (internal failures) | 991 | $73,704 |
| Competitor pressure | 665 | $49,785 |
| Not fixable (moved, deceased) | 213 | $15,640 |

**$73,704 every month walked out the door because of bad support attitudes, network reliability failures, and pricing dissatisfaction** — problems entirely within the company's control.

This is 48% more revenue lost than competitor pressure. The data says fix internal problems before competing externally.

---

## Retention Priority List

Ranked by monthly revenue at risk. Based on active customers only.

| Priority | Segment | Active Customers | Revenue at Risk | Intervention | Est. Recovery (20%) |
|---|---|---|---|---|---|
| 1 | Month-to-month + Fiber optic + 0-10 months + No security | 204 | $16,266 | Offer security bundle immediately | $3,253 |
| 2 | Month-to-month + Fiber optic + 10+ months | 728 | $65,595 | Contract upgrade with 3-month discount | $13,119 |
| 3 | Month-to-month + DSL + 0-10 months | 351 | $17,329 | Early loyalty program at month 6 | $3,465 |
| 4 | High churn score (>60) + High charges (>$88) | 430 | $43,256 | Personalised proactive outreach | $8,651 |
| 5 | Fixable churn reasons — active high risk | 1,698 | $104,070 | Support training, network fix, pricing review | $20,814 |

**Total recoverable at conservative 20% retention success: $49,302 every month.**

---

## Data Notes

- Churn score threshold of 60 was derived from data — scores below 60 show 0% historical churn, scores above 60 show 32%+ churn.
- Revenue at risk uses monthly charges of active customers, not total charges. Total charges reflects historical revenue already collected. Monthly charges reflects the recurring revenue hole going forward.
- 20% recovery estimate is based on industry standard telecom retention campaign success rates (15-25%).
- All customers with churn score above 80 have already churned. By the time score reaches 80 it is too late. Early intervention at score 61 is critical.
- churn_reason is NULL for non-churned customers. This is expected — NULL means did not churn, not missing data.

---

## SQL Files Reference

| File | Purpose |
|---|---|
| 01_setup.sql | Raw data load |
| 02_cleaning.sql | Data quality fixes |
| 03_kpis.sql | Six core business KPIs |
| 04_contract.sql | Contract type revenue analysis |
| 05_tenure.sql | Tenure cohort danger window |
| 06_services.sql | Service combination churn patterns |
| 07_intersection.sql | Multi-factor risk intersection |
| 08_churn_reason.sql | Why customers left and revenue by reason |
| 09_retention_roi.sql | Ranked retention action list |