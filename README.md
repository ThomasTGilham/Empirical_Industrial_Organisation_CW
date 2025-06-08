# Econometric Analysis of Firm Productivity

This project estimates **firm-level productivity** using panel data, addressing key econometric challenges including **firm heterogeneity**, **measurement error**, **endogenous exit**, and **simultaneity bias** with advanced methods.

---

## 🔍 Key Findings

### 1.A. **Firm Survival**

- **Surviving firms** (balanced sub-panel):
  - Higher capital: *mean log(k_it) = 9.16*
  - Younger: *mean age a_it = 7.32*

- **Exiting firms**:
  - Lower capital: *k_it = 8.78*
  - Older: *a_it = 10.03*
  - **Higher output**: *22.77 vs. 22.57*, suggesting inefficiencies

> **Insight:** Capital drives survival. Older firms may face adaptability challenges.

---

### 1.B. **Estimators & Heterogeneity**

- **Fixed effects (FE)** favored over random effects:
  - *Hausman test: χ² = 154.01, p < 0.001*
  - Confirms correlation between firm-specific effects and inputs

- **FE Coefficients**:
  - Labor: *1.238*, Capital: *1.162*
- **Pooled Coefficients**:
  - Labor: *1.265*, Capital: *1.172*

> Simpler models overstate input elasticities due to heterogeneity bias.

---

### 1.C. **Measurement Error**

- **Difference estimators (1–3 years)**:
  - Labor coefficient increases: *1.184 → 1.224*
  - Capital increases: *1.056 → 1.157*

> Supports Goolsbee (2000): Longer differences reduce measurement error.

---

### 1.D. **Endogenous Exit**

- **Balanced panel** underestimates age effect:
  - *0.206 (balanced) vs. 0.219 (unbalanced pooled)*

- **Probit model with inverse Mills ratio (IMR)**:
  - Adjusts age upward: *0.219 → 0.231*

> Confirms **selection bias** from firm exit.

---

### 1.E. **Olley-Pakes (OP) Approach**

- Controls **simultaneity bias**
- **Results**:
  - Labor: *1.264*
  - Capital: *1.043–1.058* (lower than in other models)
  - Age: *0.190–0.213* (possibly misspecified)

> OP corrects input bias; age variable may require rethinking.

---

### 1.F. **Standard Errors**

- **Clustered bootstrap** improves precision:
  - Capital SE: *0.019 → 0.007* (without exit correction)

> Offers tighter confidence intervals than conventional methods.

---

### 1.G. **Model Comparison**

- OP capital results align with **Griliches & Mairesse (1995)** expectations.
- Labor coefficients and **returns to scale** still high: *2.307–2.322*

> Suggests remaining specification or endogeneity issues.

---

## 📊 Methods

- **Data**: Panel dataset with:
  - Output (*y_it*), Labor (*l_it*), Capital (*k_it*), Investment (*i_it*), Age (*a_it*)

- **Econometric Techniques**:
  - Pooled OLS
  - Fixed Effects (FE)
  - Difference Estimators
  - Olley-Pakes Control Function
  - Probit for Exit
  - Clustered Bootstrap for SEs

---

## 📚 Article Discussion (Section 2)

**De Loecker (2011)**

- Explores **price bias** in productivity estimation post-trade liberalization.
- Finds **2% productivity gain** vs. **8%** using standard methods.
- Emphasizes importance of **price effects** in productivity measurement.

> **Strengths**: Integration of demand-side effects  
> **Limitations**: High data requirements for implementation

---

## ✅ Conclusion

- **Capital** is key to firm survival.
- **Bias corrections** (OP, IMR, bootstrapping) are essential for accurate productivity estimates.
- **Labor** and **age** effects remain challenging, calling for **refined specifications** in future work.
