
# Global Unicorn Arbitrage: Ecosystem Efficiency Dashboard
Identifying high-ROI "Emerging Efficiency Hubs" vs. saturated "Premium Markets" for venture capital allocation

## Project Overview
This Power BI project analyzes the landscape of "Unicorn" companies **(startups valued at $1B+)** to identify optimal investment strategies. Moving beyond simple counts, this dashboard uses a "Geography Arbitrage" framework to classify global ecosystems into "Emerging Efficiency Hubs" (Low Entry Price, High Opportunity) versus "Premium Saturated Hubs" (High Entry Price, High Stability)

---
### DASHBOARD
![PowerBI Dashboard](Unicorn_PowerBI_Dashboard1.png)

---

## 📌 Project Objectives

- Perform **Exploratory Data Analysis (EDA)** on unicorn companies.
- Identify key countries, cities, and industries driving unicorn creation.
- Analyze **investor patterns** and leading contributors to high-valuation unicorns.
- Examine the impact of global events (e.g., COVID-19) on unicorn growth.
- Explore **valuation-to-funding efficiency** and timelines to unicorn status.
- Derive actionable **business insights** from trends in the data.

---

## 🗂 Dataset

| Column        | Description |
|---------------|-------------|
| Company       | Company name |
| Valuation2    | Company valuation ($B) |
| Date Joined   | Date company achieved unicorn status |
| Industry      | Industry sector |
| Year Founded  | Year company was founded |
| Funding2      | Total funding raised |
| Country       | Company HQ country |
| City          | Company HQ city |
| Continent     | Company continent |
| Investor 1-4  | Top 4 investors |

---

## 👨‍💻 Tools Used

- **Microsoft SQL Server** — Data querying & analysis
- **Power BI** — Visualization & dashboard (optional)
- **Excel** — Data cleaning (Investor fields)

---

## 🗂 EDA & Analysis Steps
[`Unicorn companies.sql`](./Unicorn%20companies.sql) 
### 1️⃣ General Overview

- Total unicorn companies in dataset
- Min, max, average valuations
- Companies valued **above average**

```sql
--General overview of the Unicorn Companies
SELECT 
    COUNT(*) AS total_companies,
    MIN(Valuation2) AS min_valuation,
    MAX(Valuation2) AS max_valuation,
    AVG(Valuation2) AS avg_valuation
FROM Unicorn_C;
```

### 2️⃣ Geographical Insights

- Top **countries** and **cities** by number of unicorns
```sql
-- Top 10 Countries by Number of Unicorns
SELECT Country, COUNT(*) AS unicorn_count
FROM Unicorn_C
GROUP BY Country
ORDER BY unicorn_count DESC;

-- Top 10 Cities by Number of Unicorns
SELECT City, Country, COUNT(*) AS unicorn_count
FROM Unicorn_C
GROUP BY City, Country
ORDER BY unicorn_count DESC
;
```
- % share of unicorns by country & city
```sql
-- Percentage of unicorn in TOTAL by City and Country
SELECT TOP 10 
    City, 
    Country, 
    COUNT(*) AS unicorn_count,
    ROUND(CAST(COUNT(*) AS FLOAT) / 
          (SELECT COUNT(*) FROM Unicorn_C) * 100, 2) AS percentage_of_total
FROM Unicorn_C
GROUP BY City, Country
ORDER BY unicorn_count DESC;
```
- Emerging **innovation hubs** for unicorn creation

### 3️⃣ Industry Trends

- Top industries globally and by continent
```sql
-- Top Industries by Continent
SELECT Continent, Industry, COUNT(*) AS industry_count
FROM Unicorn_C
GROUP BY Continent, Industry
ORDER BY industry_count DESC;

-- By Country
SELECT Country, Industry, COUNT(*) AS industry_count
FROM Unicorn_C
GROUP BY Country, Industry
ORDER BY industry_count DESC;
```
- Industries driving the most unicorn creation
```sql
-- Industries have the most or highest-valued unicorns
SELECT 
    Industry, 
    COUNT(*) AS total_companies,
    SUM(Valuation2) AS total_valuation
FROM Unicorn_C
GROUP BY Industry
ORDER BY total_valuation DESC;
```
- Valuation growth patterns by industry (pre/post 2021)


### 4️⃣ Investor Analysis

- Top investors by number of unicorns funded
```sql
--TOP 10 INVESTORS
SELECT TOP 10 investor, COUNT(*) AS num_investments
FROM (
    SELECT [Investor 1] AS investor FROM Unicorn_C WHERE [Investor 1] IS NOT NULL
    UNION ALL
    SELECT [Investor 2] FROM Unicorn_C WHERE [Investor 2] IS NOT NULL
    UNION ALL
    SELECT [Investor 3] FROM Unicorn_C WHERE [Investor 3] IS NOT NULL
    UNION ALL
    SELECT [Investor 4] FROM Unicorn_C WHERE [Investor 4] IS NOT NULL
) AS all_investors
GROUP BY investor
ORDER BY num_investments DESC
```
- Investor influence by country & city
```sql
-- Cities and Countries with Top investors
WITH invest AS (
    SELECT [Investor 1] AS investor, City, Country FROM Unicorn_C WHERE [Investor 1] IS NOT NULL
    UNION ALL
    SELECT [Investor 2], City, Country FROM Unicorn_C WHERE [Investor 2] IS NOT NULL
    UNION ALL
    SELECT [Investor 3], City, Country FROM Unicorn_C WHERE [Investor 3] IS NOT NULL
    UNION ALL
    SELECT [Investor 4], City, Country FROM Unicorn_C WHERE [Investor 4] IS NOT NULL
)

SELECT TOP 10
    investor,
	City,
    Country, 
    COUNT(*) AS num_investments
FROM invest
GROUP BY investor, City, Country
ORDER BY num_investments DESC;

```

### 5️⃣ Speed to Unicorn

- **Years to unicorn** by company
```sql
-- Time to Unicorn per Company
SELECT 
    Company, Industry,
    YEAR([Date Joined]) - [Year Founded] AS years_to_unicorn
FROM Unicorn_C
ORDER BY years_to_unicorn ASC;

```
- Average time to unicorn by industry
```sql
-- Average Time to Unicorn by Industry
SELECT 
    Industry,
    ROUND(AVG((YEAR ([Date Joined]) - [Year Founded])), 0) AS Avg_Years_To_Unicorn
FROM Unicorn_C
WHERE [Year Founded] IS NOT NULL AND [Date Joined] IS NOT NULL
GROUP BY Industry
ORDER BY Avg_Years_To_Unicorn;
```
- Valuation-to-funding efficiency
```sql
--how many dollars in valuation the company achieved for every $1 of investor funding
SELECT 
    Company, 
    Valuation2, 
    Funding2,
    ROUND((Valuation2 / Funding2),1) AS valuation_to_funding_ratio
FROM Unicorn_C
WHERE Funding2 > 0
ORDER BY valuation_to_funding_ratio DESC;
```

### 6️⃣ Temporal Trends

- Yearly growth in unicorn creation
```sql
-- Yearly Average Time to Unicorn
SELECT 
	YEAR ([Date Joined]) AS Year_joined,
    ROUND(AVG((YEAR ([Date Joined]) - [Year Founded])), 0) AS Avg_Years_To_Unicorn
FROM Unicorn_C
WHERE [Year Founded] IS NOT NULL AND [Date Joined] IS NOT NULL
GROUP BY YEAR ([Date Joined])
ORDER BY Year_joined;
```
- **2021 spike** → COVID-driven digital transformation
```sql
-- Number of unicorns per year across industries
SELECT Industry, YEAR([Date Joined]) Year_joined, COUNT(*) AS industry_count
FROM Unicorn_C
WHERE Industry = 'Fintech'
GROUP BY Industry, YEAR([Date Joined])
ORDER BY YEAR([Date Joined]);

-- Unicorn Count by industry in 2021
SELECT 
    Industry,
    COUNT(*) AS unicorns_in_year_2021
FROM Unicorn_C
WHERE Industry IS NOT NULL AND [Date Joined] IS NOT NULL AND YEAR([Date Joined])=2021
GROUP BY Industry, YEAR([Date Joined])
ORDER BY unicorns_in_year_2021 DESC;

-- Which investors contribute to the spike in unicorn companies in 2021
-- Top Investors Behind 2021 Unicorns Spike
WITH investor_cte AS (
    SELECT [Investor 1] AS Investor FROM Unicorn_C WHERE YEAR([Date Joined]) = 2021 AND [Investor 1] IS NOT NULL
    UNION ALL
    SELECT [Investor 2] FROM Unicorn_C WHERE YEAR([Date Joined]) = 2021 AND [Investor 2] IS NOT NULL
    UNION ALL
    SELECT [Investor 3] FROM Unicorn_C WHERE YEAR([Date Joined]) = 2021 AND [Investor 3] IS NOT NULL
    UNION ALL
    SELECT [Investor 4] FROM Unicorn_C WHERE YEAR([Date Joined]) = 2021 AND [Investor 4] IS NOT NULL
)

SELECT TOP 10 
    Investor, 
    COUNT(*) AS Unicorn_Count_2021
FROM investor_cte
GROUP BY Investor
ORDER BY Unicorn_Count_2021 DESC;

-- =============================================
-- One major factor that contributed to the significant number of Unicorn in 2021 is the Global Pandemic (COVID-19) which restricted movement and instigated a lockdown
-- COVID-19 accelerated digital adoption in 2021, boosting Fintech and Internet Software & Services.
-- Lockdowns increased demand for digital payments, online banking, and remote tools,
-- leading to a surge in unicorns in these sectors due to rapid growth and investor interest.
```
- Pre-2021 trends (normalization)
```sql
-- The significant emergence of Unicorn Companies in 2021 can be traced down to the COVID-19 pandemic. 
-- Events like the COVID-19 pandemic are not regular occurences, hence 2021 was excluded from this analysis helps avoid skewed data, 
-- which could introduce bias and misrepresent trends in industry investment. 
-- Focusing on 2012–2020 ensures consistency and reliability of insights.


-- Yearly Valuation Growth by Industry (Before 2021)
WITH YearlyIndustryValuation AS (
    SELECT 
        Industry,
        YEAR([Date Joined]) AS Year_Joined,
        SUM(Valuation2) AS Total_Valuation
    FROM Unicorn_C
    WHERE 
        [Date Joined] IS NOT NULL
        AND Valuation2 IS NOT NULL
        AND YEAR([Date Joined]) < 2021
        AND Industry IS NOT NULL
    GROUP BY Industry, YEAR([Date Joined])
),

GrowthCalculation AS (
    SELECT 
        Industry,
        Year_Joined,
        Total_Valuation,
        LAG(Total_Valuation) OVER (PARTITION BY Industry ORDER BY Year_Joined) AS Prev_Valuation
    FROM YearlyIndustryValuation
)

SELECT 
    Industry,
    Year_Joined,
    Total_Valuation,
    Prev_Valuation,
    ROUND(
        CASE 
            WHEN Prev_Valuation IS NULL THEN NULL
            ELSE ((Total_Valuation - Prev_Valuation) / Prev_Valuation) * 100
        END, 2
    ) AS YoY_Growth_Percentage
FROM GrowthCalculation
ORDER BY Industry, Year_Joined;
```

## 📈 Key Insights

### 📌 High-level Summary

- Total unicorn companies in dataset: **~1074**
- Companies valued above average: **240**
- Strong **upward trend** in unicorn creation until **2021**, followed by a normalization.
- **US** leads globally with **562 unicorns**; **San Francisco** is the #1 city (148 unicorns).

### 📌 Industry Growth Patterns

| Industry         | Trend |
|------------------|-------|
| Fintech          | 🚀 Explosive growth (11% → 26.7%) |
| AI/Big Data      | 📈 Strong growth |
| SaaS             | 📈 Steady relevance |
| HealthTech       | 🩺 COVID-driven peak in 2020, decline after |
| Biotech          | 🧬 Similar COVID-driven spike |
| E-Commerce       | 🛍️ Pandemic spike, returning to baseline |
| Real Estate Tech | ⬇️ Decline in recent years |
| Manufacturing    | ⬇️ Decline in VC appeal |
| Web3/Blockchain  | 🚀 Hype-driven growth → stabilized |

### 📌 Investor Insights

- Top investors are concentrated in **US and China**.
- Investor funding efficiency varies widely.
- Certain investors consistently back **high-performing industries** (e.g., Fintech, AI).

---

## 🚀 Business Impact

👍 Helps **VC firms** identify rising sectors and investor trends  
👍 Informs **governments and accelerators** about emerging innovation hubs  
👍 Supports **corporate strategy** for market entry and partnership decisions  
👍 Highlights **COVID-19’s impact** on startup ecosystem  
👍 Provides **timeline benchmarks** for founders (time to unicorn)  

---

## 📚 Project Files

- [`Unicorn companies.sql`](./Unicorn%20companies.sql) → Main SQL Analysis Script  
- [`link to Unicorn companies dashboard`](https://app.powerbi.com/groups/me/reports/fbf97eb0-1b52-4837-9bf0-d491b775fd20?ctid=319a61c8-ee1e-4161-8f35-b9553227afd7&pbi_source=linkShare)

---

## 💬 Contact

For questions or collaboration opportunities, feel free to connect!

---
