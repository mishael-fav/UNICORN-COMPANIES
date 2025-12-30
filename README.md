
# Global Unicorn Arbitrage: Ecosystem Efficiency Dashboard
Identifying high-ROI "Emerging Efficiency Hubs" vs. saturated "Premium Markets" for venture capital allocation

## 📄Project Overview
This Power BI project analyzes the landscape of "Unicorn" companies **(startups valued at $1B+)** to identify optimal investment strategies. Moving beyond simple counts, this dashboard uses a "Geography Arbitrage" framework to classify global ecosystems into "Emerging Efficiency Hubs" (Low Entry Price, High Opportunity) versus "Premium Saturated Hubs" (High Entry Price, High Stability)

---

### 📊Dashboard Preview and insight 
#### A PowerBI dashboard used to visualize the analysis can be found here →[Link to Global Unicorn Arbitrage: Ecosystem Efficiency Dashboard](https://app.powerbi.com/links/NDQXqXVVke?ctid=319a61c8-ee1e-4161-8f35-b9553227afd7&pbi_source=linkShare&bookmarkGuid=6aa14441-554f-4a07-b90e-b58e37eac958)

### 💰CAPITAL EFFICIENCY (The Moneyball Matrix)
- The analysis reveals a stark dichotomy in the unicorn ecosystem. On one end, we see **'Capital Efficient'** outliers like Zapier and Canva, which leveraged product-led growth to generate massive valuations **(up to 4,000x)** with minimal external funding. On the other end, we identified a cluster of **'Cash Burners'** (Ratio < 2x) primarily in the Auto & Transportation sectors, where high operational costs require companies like Magic Leap and Ola Cabs to raise capital exceeding their current valuations—signaling potential value destruction for late-stage investors.
  
![CAPITAL EFFICIENCY](dashboard_pic/CAPITAL_EFFICIENCY.PNG)

#### SQL-QUERY Snippet
```sql
-- -------------------------------------------------------------------------------------------------
-- STRATEGY 1: CAPITAL EFFICIENCY (The Moneyball Matrix)
-- Who generates the most value per dollar funded?
-- -------------------------------------------------------------------------------------------------
SELECT 
    Company,
    Industry,
    Valuation_Num,
    Funding_Num,
    ROUND((Valuation_Num / NULLIF(Funding_Num, 0)), 2) AS Capital_Efficiency_Ratio,
    CASE 
        WHEN (Valuation_Num / NULLIF(Funding_Num, 0)) >= 10 THEN 'Elite Efficiency (10x+)'
        WHEN (Valuation_Num / NULLIF(Funding_Num, 0)) < 2 THEN 'Cash Burner (<2x)'
        ELSE 'Standard Growth'
    END AS Efficiency_Category
FROM #Unicorn_Analysis
WHERE Funding_Num IS NOT NULL AND Funding_Num > 0 
ORDER BY Capital_Efficiency_Ratio DESC;

/*
The analysis reveals a stark dichotomy in the unicorn ecosystem. On one end, we see 'Capital Efficient' outliers like Zapier and Canva, 
which leveraged product-led growth to generate massive valuations (up to 4,000x) with minimal external funding. On the other end, 
we identified a cluster of 'Cash Burners' (Ratio < 2x) primarily in the Auto & Transportation sectors, where high operational costs require 
companies like Magic Leap and Ola Cabs to raise capital exceeding their current valuations—signaling potential value destruction for late-stage investors.
*/
```

### ⚡THE "HYPER-GROWTH" DETECTOR (Velocity)
- The Velocity Analysis highlights a clear sector rotation. Artificial Intelligence has emerged as the true 'Hyper-Growth' leader, achieving unicorn status in just 5.9 years with a value creation rate of $1.1B per year. In contrast, Auto & Transportation is the fastest to $1B (5.03 years), largely due to capital-intensive early funding rounds. Meanwhile, traditional Internet Software appears to be maturing; while it produces the highest volume of unicorns (205), it creates value at less than half the speed ($500M/yr) of the top-performing AI and Consumer sectors."

![CAPITAL EFFICIENCY](dashboard_pic/high_growth_velocity.PNG)

#### SQL-QUERY Snippet
```sql
-- -------------------------------------------------------------------------------------------------
-- STRATEGY 2: THE "HYPER-GROWTH" DETECTOR (Velocity)
-- Question: Which industries are accelerating?
-- -------------------------------------------------------------------------------------------------
SELECT 
    Industry,
    COUNT(*) AS Unicorn_Companyount,
    -- Speed Analysis
    AVG(Years_To_Unicorn) AS Avg_Years_To_Unicorn,
    
    -- Value Velocity: Average Valuation created per year of existence
    ROUND(AVG(Valuation_Num / NULLIF(Years_To_Unicorn, 0)), 0) AS Avg_Value_Velocity_Per_Year
FROM #Unicorn_Analysis
GROUP BY Industry
HAVING COUNT(*) > 10 -- Filter for significant sample size
ORDER BY Avg_Value_Velocity_Per_Year DESC;

/*
The Velocity Analysis highlights a clear sector rotation. Artificial Intelligence has emerged as the true 'Hyper-Growth' leader, 
achieving unicorn status in just 5.9 years with a value creation rate of $1.1B per year. In contrast, Auto & Transportation is the 
fastest to $1B (5.03 years), largely due to capital-intensive early funding rounds. Meanwhile, traditional Internet Software appears to be maturing; 
while it produces the highest volume of unicorns (205), it creates value at less than half the speed ($500M/yr) of the top-performing AI and Consumer sectors
*/
```

### 👑THE "KINGMAKER" NETWORK
- The "Kingmaker Network" analysis exposes a stark Power Law distribution within the venture capital landscape, where fewer than 1% of the 1,247 active investors occupy the elite "Kingmaker Zone" of high volume and high valuation. While industry titans like Accel (60 unicorns) and Sequoia Capital China ($473B total valuation) dominate through sheer market coverage and scale, the data reveals a secondary tier of "Capital Efficient" snipers. Most notably, Threshold Ventures emerges as the global ROI leader with a staggering 1,006x return multiple, proving that while the "Kingmakers" control the volume, specialized firms are capable of outperforming the giants on a per-deal efficiency basis.

![CAPITAL EFFICIENCY](dashboard_pic/kingmaker_network.PNG)

#### SQL-QUERY Snippet
```sql
-- -------------------------------------------------------------------------------------------------
-- STRATEGY 3: THE "KINGMAKER" NETWORK (Syndicate Analysis)
-- Who invests together? 
-- -------------------------------------------------------------------------------------------------
SELECT TOP 50
    A.Investor AS Investor_A,
    B.Investor AS Investor_B,
    COUNT(DISTINCT A.Company) AS Joint_Investments,
    STRING_AGG(A.Company, ', ') AS Shared_Portfolio
FROM #Investor_Long A
JOIN #Investor_Long B ON A.Company = B.Company 
    AND A.Investor < B.Investor 
GROUP BY A.Investor, B.Investor
HAVING COUNT(DISTINCT A.Company) >= 3 
ORDER BY Joint_Investments DESC;

/*
The Syndicate Analysis reveals distinct 'Power Blocs' driving unicorn creation. The strongest global alliance is the 'China Axis' 
between Sequoia China and Tencent (9 joint investments), combining traditional VC discipline with massive corporate distribution. 
In the US, the data identifies a clear 'Graduation Pipeline' where Accel frequently leads growth rounds for Y Combinator alumni (6 joint investments). 
Furthermore, Accel emerges as the ecosystem's 'Super-Connector,' appearing in 8 of the top 50 strongest co-investment pairs, 
signaling its role as the central hub of global unicorn capital.
*/
```

### 🌎GEOGRAPHIC ARBITRAGE
- Utilizing a **"Geographical Arbitrage"** framework, this dashboard analyzes the $3.71T global unicorn ecosystem to identify high-yield investment targets. By mapping Valuation against Volume, the analysis isolates **"Emerging Efficiency Hubs"** in the matrix's bottom-right quadrant—such as **Austin ($1.4B)** and **Hangzhou ($1.6B)**—that offer mature innovation at a discount compared to saturated "Premium" markets. While **North America** leads in overall stability as the most efficient continent (6.9x ratio), **South Korea** emerges as the global leader in capital efficiency with a massive **20x ROI multiple**, demonstrating that significant arbitrage opportunities exist outside of traditional, high-cost tech capitals.

![CAPITAL EFFICIENCY](dashboard_pic/CAPITAL_EFFICIENCY.PNG)

#### SQL-QUERY Snippet
```sql
-- -------------------------------------------------------------------------------------------------
-- STRATEGY 4: GEOGRAPHIC ARBITRAGE
-- Where are the "Undervalued" Hubs?
-- -------------------------------------------------------------------------------------------------
SELECT 
    Continent,
    Country,
    City,
    COUNT(*) AS Unicorn_Count,
    ROUND(AVG(Valuation_Num), 2) AS Avg_Valuation,
    
    -- Rank cities within their continent by Average Valuation
    DENSE_RANK() OVER (PARTITION BY Continent ORDER BY AVG(Valuation_Num) DESC) AS Rank_In_Continent
FROM #Unicorn_Analysis
GROUP BY Continent, Country, City
HAVING COUNT(*) > 2
ORDER BY Avg_Valuation DESC;

/*
The Geographic Arbitrage analysis identifies Stockholm and Shenzhen as high-efficiency hubs where average valuations ($10.5B and $7.4B respectively) 
significantly outperform the volume-heavy hubs of London and Beijing. In the US, the data reveals a quality-over-quantity dynamic in Boston, 
which commands the second-highest average valuation ($4.3B)—nearly double that of New York City ($2.2B), suggesting that specialized deep-tech ecosystems
yield higher returns per startup than generalist commercial hubs.
*/
```

---

### **📋 Key Insights & Findings**

#### **1. Macro Market Trends**

* **Total Ecosystem Size:** The dataset tracks **1,074 Unicorn Companies** globally.
* **Valuation Distribution:** Only **240 companies (22%)** hold valuations above the global average, indicating a top-heavy market where a few "Decacorns" drive skewed averages.
* **The 2021 Peak:** There has been a gradual increase in unicorn emergence over the last decade, culminating in a massive spike in **2021 with 520 new unicorns**.
* **The Driver:** This exponential increase can be attributed to the convergence of the **Global Pandemic (COVID-19)**—which accelerated digital transformation—and **unprecedented capital liquidity** (low-interest rates), which flooded the market with venture capital.

#### **2. Geographic Dominance**

* **US Hegemony:** The **United States** leads with **562 Unicorns**, outperforming the next closest country (China) by a margin of more than **5x**.
* **The "Super-Hubs":**
* **San Francisco** is the undisputed capital, home to **148 Unicorns** (26% of the US total and 14% of the global total). In 2021 alone, the city recorded a staggering **303** active high-growth companies.
* **New York** follows as a strong second major hub with **103** unicorns.



---

### **📈 Sector Evolution Analysis**

#### **🚀 High-Growth & Emerging Sectors**

* **Fintech Dominance:** The fastest-growing vertical, surging from **11.0% (2016)** to **26.7% (2022)**, signaling massive investor confidence in financial digitization.
* **AI & Big Data:** Showed steady, mature growth from **9.8% (2020)** to **12.3% (2022)**, reflecting widespread enterprise adoption of analytics and machine learning.
* **SaaS (Software as a Service):** Peaked at **8.6% (2021)** before a slight dip, maintaining consistent relevance as the backbone of B2B infrastructure.

#### **⚠️ The "2021 Anomaly" (Short-Term Spikes)**

*Certain sectors experienced a "Covid Bubble" driven by abundant capital and urgent pandemic needs, followed by a correction.*

* **HealthTech:** Peaked at **7.6% (2020)** → Corrected to **5.1% (2022)**.
* **Biotech:** Peaked at **6.3% (2020)** → Corrected to **3.7% (2022)**.
* **E-Commerce:** Spiked to a high of **15.5% (2020)** during global lockdowns but normalized to **10.4% (2022)**.

#### **🔻 Declining Sectors**

* **Real Estate Tech:** Saw a significant decline from **9.0% (2016)** to **3.4% (2022)**, struggling with market saturation and interest rate headwinds.
* **Manufacturing:** Dropped from **6.0% (2016)** to **2.8% (2022)**, indicating limited Venture Capital appeal compared to software-based scalability.

#### **⚡ Hype-Driven Volatility**

* **Web3 & Blockchain:** Experienced explosive growth from **1.9% (2020)** to **6.7% (2021)**, then stabilized at **5.4% (2022)**. This sector shows strong momentum but remains highly volatile compared to traditional tech.

---

## 🗂 Methodology / Code Snippet

``` sql
-- =================================================================================================
-- STAGE 1: DATA ENGINEERING & PRE-PROCESSING 
-- Create clean Temporary Tables 
-- =================================================================================================

-- A. Create Master Analytics Table (Cleans Valuation, Funding, and Dates)
DROP TABLE IF EXISTS #Unicorn_Analysis;

SELECT 
    Company,
    Industry,
    City,
    Country,
    Continent,
    [Year Founded],
    [Date Joined],
    YEAR([Date Joined]) AS Year_Joined,
    
    -- CLEANING VALUATION (to Valuation_Num)
    CASE 
        WHEN Valuation LIKE '%B' THEN CAST(REPLACE(REPLACE(Valuation, '$', ''), 'B', '') AS DECIMAL(15,2)) * 1000000000
        WHEN Valuation LIKE '%M' THEN CAST(REPLACE(REPLACE(Valuation, '$', ''), 'M', '') AS DECIMAL(15,2)) * 1000000
        ELSE 0 
    END AS Valuation_Num,

    -- CLEANING FUNDING (to Funding_Num)
    CASE 
        WHEN Funding LIKE '%Unknown%' THEN NULL 
        WHEN Funding LIKE '%B' THEN CAST(REPLACE(REPLACE(Funding, '$', ''), 'B', '') AS DECIMAL(15,2)) * 1000000000
        WHEN Funding LIKE '%M' THEN CAST(REPLACE(REPLACE(Funding, '$', ''), 'M', '') AS DECIMAL(15,2)) * 1000000
        ELSE CAST(REPLACE(REPLACE(Funding, '$', ''), ',', '') AS DECIMAL(15,2)) 
    END AS Funding_Num,

    -- CALCULATED METRIC: Years to reach Unicorn Status
    (YEAR([Date Joined]) - [Year Founded]) AS Years_To_Unicorn

INTO #Unicorn_Analysis
FROM Unicorn_Company
WHERE [Date Joined] IS NOT NULL;


-- B. Create Investor Long List (THE NEW STRING_SPLIT METHOD)
DROP TABLE IF EXISTS #Investor_Long;

SELECT DISTINCT 
    Company, 
    Industry, 
    YEAR([Date Joined]) AS Year_Joined, 
    TRIM(value) AS Investor 
INTO #Investor_Long
FROM Unicorn_Company
CROSS APPLY STRING_SPLIT([Select Investors], ',') 
WHERE LEN(TRIM(value)) > 0;

-- Confirm the query
SELECT Investor FROM #Investor_Long
WHERE Company = 'Bytedance';
/*
NOTICE: I split the dataset into two distinct tables, `#Unicorn_Analysis` and `#Investor_Long`. This is in a bid to adhere to standard database design principles
regarding "One-to-Many" relationships and, more critically, to prevent aggregation errors. Since a single company can have multiple investors,
keeping them in the main table would require duplicating the company row for each investor, which causes financial metrics like Valuation to be 
summed multiple times (e.g., counting a $100B company four times); separating them ensures that the main table maintains one row per company for 
accurate financial reporting, while the secondary table handles the multiple investor relationships for network analysis.
*/

SELECT * FROM #Unicorn_Analysis
SELECT * FROM #Investor_Long
```
```sql
-- =================================================================================================
-- STAGE 2: EXPLORATORY DATA ANALYSIS (General Trends)
-- =================================================================================================

-- 2.1 General Overview
SELECT 
    COUNT(*) AS Total_Companies,
    MIN(Valuation_Num) AS Min_Valuation,
    MAX(Valuation_Num) AS Max_Valuation,
    MAX(Global_Avg) AS Avg_Valuation, -- We just pick the average value (it's the same for every row)
    SUM(CASE WHEN Valuation_Num > Global_Avg THEN 1 ELSE 0 END) AS High_Value_Count
FROM (
    SELECT 
        Valuation_Num,
        AVG(Valuation_Num) OVER () AS Global_Avg -- Calculates the average instantly across all data
    FROM #Unicorn_Analysis
) AS Calc_Table;

-- 2.2 Top 10 Countries (With Global Share %)
SELECT TOP 10 
    Country, 
    COUNT(*) AS Unicorn_Count,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM #Unicorn_Analysis) AS DECIMAL(5,2)) AS Global_Share_Pct
FROM #Unicorn_Analysis
GROUP BY Country
ORDER BY Unicorn_Count DESC;

-- 2.3 Top 10 Cities (Using DENSE_RANK to handle ties properly)
WITH CityRank AS (
    SELECT 
        City, 
        Country, 
        COUNT(*) AS Unicorn_Count,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) as Rank
    FROM #Unicorn_Analysis
    GROUP BY City, Country
)
SELECT * FROM CityRank WHERE Rank <= 10;

-- 2.4 Industry Breakdown (Global)
SELECT 
    Industry, 
    COUNT(*) AS Total_Companies,
    SUM(Valuation_Num) AS Total_Valuation
FROM #Unicorn_Analysis
GROUP BY Industry
ORDER BY Total_Valuation DESC;

```
```sql

```
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
