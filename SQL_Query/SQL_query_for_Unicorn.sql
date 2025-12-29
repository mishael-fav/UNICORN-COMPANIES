USE Unicorn;

SELECT * FROM Unicorn_Company;
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


-- =================================================================================================
-- STAGE 3: THE 2021 ANOMALY (The Digital Spike)
-- Goal: Investigate the massive spike in 2021
-- =================================================================================================

-- 3.1 Unicorn Count by Year (Visualizing the Spike)
SELECT Year_Joined, COUNT(*) AS New_Unicorns
FROM #Unicorn_Analysis
GROUP BY Year_Joined
ORDER BY Year_Joined;

-- 3.2 Which Industries drove the 2021 Spike?
SELECT TOP 5
    Industry,
    COUNT(*) AS Unicorns_In_2021
FROM #Unicorn_Analysis
WHERE Year_Joined = 2021
GROUP BY Industry
ORDER BY Unicorns_In_2021 DESC;

-- =============================================
/*
The surge in unicorn formations observed in 2021 coincides with a unique global environment
characterized by the COVID-19 pandemic and unprecedented liquidity in capital markets.

While COVID-19 lockdowns accelerated digital adoption, particularly in fintech and
internet-based services such as digital payments, online banking, and remote platforms
the scale of unicorn growth in 2021 was also strongly influenced by abundant venture
capital, low interest rates, and inflated late-stage funding rounds.

Together, pandemic-driven demand acceleration and favorable investment conditions
created an environment where high-growth technology companies reached $1B valuations
more rapidly, especially within Fintech and Internet Software & Services sectors.
*/


-- 3.3 List of Fintech Companies in 2021 (Using Modern STRING_AGG)
SELECT 
    Industry, 
    STRING_AGG(Company, ', ') WITHIN GROUP (ORDER BY Company) AS Fintech_2021_List
FROM #Unicorn_Analysis
WHERE Year_Joined = 2021 AND Industry = 'Fintech'
GROUP BY Industry;

-- 3.4 Who funded the 2021 Boom? (Top Investors just for 2021)
SELECT TOP 10 
    Investor, 
    COUNT(*) AS Investments_2021
FROM #Investor_Long
WHERE Year_Joined = 2021
GROUP BY Investor
ORDER BY Investments_2021 DESC;

-- =================================================================================================
-- STAGE 4: GROWTH & TRENDS (Pre-2021 Analysis)
-- Analyze "Normal" Market Behavior by Excluding the Covid Spike
-- =================================================================================================
/*
The spike in unicorn formations during 2021 reflects an exceptional period influenced
by pandemic-related demand shifts and atypical funding conditions(excess liquidity). To prevent outlier
effects from distorting long-term trends, 2021 data was excluded.

The 2012–2020 window provides a more representative baseline for assessing
consistent industry and investment dynamics.
*/


-- 4.1 Yearly Valuation Growth by Industry (Before 2021)
-- Calculates Year-Over-Year (YoY) growth % to see which industries were heating up naturally.
WITH YearlyIndustryValuation AS (
    SELECT 
        Industry,
        Year_Joined,
        SUM(Valuation_Num) AS Total_Valuation
    FROM #Unicorn_Analysis
    WHERE Year_Joined < 2021 -- Excluding the Anomaly
    GROUP BY Industry, Year_Joined
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


-- 4.2 Industry Market Share Over Time (Pre-2021)
-- Shows how "Dominance" shifted (e.g., from Hardware to Fintech)
WITH IndustryYTD AS (
    SELECT 
        Industry,
        Year_Joined,
        SUM(Valuation_Num) AS Industry_Valuation
    FROM #Unicorn_Analysis
    WHERE Year_Joined <= 2020
    GROUP BY Industry, Year_Joined
),
TotalYTD AS (
    SELECT Year_Joined, SUM(Industry_Valuation) AS Total_Valuation
    FROM IndustryYTD
    GROUP BY Year_Joined
)
SELECT 
    i.Industry,
    i.Year_Joined,
    i.Industry_Valuation,
    t.Total_Valuation,
    ROUND(100.0 * i.Industry_Valuation / t.Total_Valuation, 2) AS Percentage_Share
FROM IndustryYTD i
JOIN TotalYTD t ON i.Year_Joined = t.Year_Joined
ORDER BY i.Year_Joined, Percentage_Share DESC;


-- 4.3 Yearly Growth by Investor (Before 2021)
-- Which investors were scaling up their portfolio value consistently?
WITH InvestorStats AS (
    -- Join Investor List to Main Table to get Valuations
    SELECT 
        i.Investor,
        u.Year_Joined,
        SUM(u.Valuation_Num) AS Total_Valuation
    FROM #Investor_Long i
    JOIN #Unicorn_Analysis u ON i.Company = u.Company
    WHERE u.Year_Joined < 2021
    GROUP BY i.Investor, u.Year_Joined
),
InvestorGrowth AS (
    SELECT 
        Investor,
        Year_Joined,
        Total_Valuation,
        LAG(Total_Valuation) OVER (PARTITION BY Investor ORDER BY Year_Joined) AS Prev_Valuation
    FROM InvestorStats
)
SELECT 
    Investor,
    Year_Joined,
    Total_Valuation,
    Prev_Valuation,
    ROUND(
        CASE 
            WHEN Prev_Valuation IS NULL THEN NULL
            ELSE ((Total_Valuation - Prev_Valuation) / Prev_Valuation) * 100
        END, 2
    ) AS YoY_Growth_Percentage
FROM InvestorGrowth
ORDER BY Investor, Year_Joined;


-- =================================================================================================
-- STAGE 5: POST-SPIKE CORRECTION (The "Hangover" Analysis)
-- Determine if 2022 was a "Crash" or just a "Return to Normal" (Mean Reversion).
-- =================================================================================================

-- 5.1 The "Correction" Magnitude (Drop form Peak)
-- Calculates exactly how hard the market fell from 2021 to 2022.
WITH YearlyCounts AS (
    SELECT 
        Year_Joined, 
        COUNT(*) AS Unicorn_Count
    FROM #Unicorn_Analysis
    WHERE Year_Joined >= 2018 -- Look at the immediate window
    GROUP BY Year_Joined
),
GrowthCalc AS (
    SELECT 
        Year_Joined,
        Unicorn_Count,
        LAG(Unicorn_Count) OVER (ORDER BY Year_Joined) AS Prev_Year_Count
    FROM YearlyCounts
)
SELECT 
    Year_Joined,
    Unicorn_Count,
    Prev_Year_Count,
    -- Calculate the Percentage Drop
    CAST(ROUND((Unicorn_Count - Prev_Year_Count) * 100.0 / NULLIF(Prev_Year_Count, 0), 2) AS DECIMAL(10,2)) AS YoY_Change_Pct,
    
    -- Interpretation Column
    CASE 
        WHEN Year_Joined = 2021 THEN 'The Spike (Covid Liquidity)'
        WHEN Year_Joined = 2022 AND Unicorn_Count < Prev_Year_Count THEN 'Market Correction'
        ELSE 'Normal Trend'
    END AS Market_Status
FROM GrowthCalc
ORDER BY Year_Joined;

/*
While the 77% drop in 2022 looks disastrous at first glance, a deeper look reveals that the market didn't crash below historical norms,
it simply corrected the anomaly of 2021. I can equally say 2022 was a market correction rather than a collapse, as the ecosystem shed the 
excess of the 2021 anomaly but stabilized at a 'new normal' that remains higher than the pre-pandemic baseline.
*/

-- 5.2 The "New Normal" Check (2022 vs Pre-Covid Average)
-- Crucial Query: Is 2022 actually bad? Or is it still better than 2019?
-- If 2022 > 2019, the market is growing. If 2022 < 2019, the market is shrinking.
SELECT 
    '2022 Actuals' AS Period, 
    COUNT(*) AS Unicorn_Count 
FROM #Unicorn_Analysis WHERE Year_Joined = 2022
UNION ALL
SELECT 
    'Pre-Covid Average (2018-2020)' AS Period, 
    COUNT(*) / 3 AS Unicorn_Count -- Divide by 3 years to get the average
FROM #Unicorn_Analysis WHERE Year_Joined BETWEEN 2018 AND 2020;



-- 5.3 Which Sectors "Crashed" the Hardest?
-- Compare 2021 Peak vs 2022 Reality by Industry
WITH IndustryStats AS (
    SELECT 
        Industry,
        SUM(CASE WHEN Year_Joined = 2021 THEN 1 ELSE 0 END) AS Count_2021_Peak,
        SUM(CASE WHEN Year_Joined = 2022 THEN 1 ELSE 0 END) AS Count_2022_Correction
    FROM #Unicorn_Analysis
    GROUP BY Industry
)
SELECT TOP 10
    Industry,
    Count_2021_Peak,
    Count_2022_Correction,
    -- Calculate the "Survival Rate"
    Count_2022_Correction - Count_2021_Peak AS Net_Drop,
    CASE 
        WHEN Count_2021_Peak = 0 THEN 0 
        ELSE CAST(ROUND((Count_2022_Correction - Count_2021_Peak) * 100.0 / Count_2021_Peak, 2) AS DECIMAL(10,2)) 
    END AS Drop_Percentage
FROM IndustryStats
ORDER BY Drop_Percentage ASC; -- Sort by biggest losers (biggest negative %)

/*
The correction disproportionately punished pandemic-era favorites, with Consumer & Retail and Edtech 
experiencing near-total collapses (>90% drop), while deep-tech sectors like Artificial Intelligence 
demonstrated the strongest comparative resilience.

The sustained activity in foundational sectors like Fintech and AI even after the correction, signals
that unlike fleeting consumer trends, these technologies are not just a phase but have come to stay.
*/


-- LET'S TAKE A DEEPDIVE INTO MORE ADVANCED ANALYSIS

-- =================================================================================================
-- STAGE 6: ADVANCED STRATEGY (VC Analysis)
-- =================================================================================================

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

-- -------------------------------------
-- Summary Market Trends
-- -------------------------------------

WITH CleanedYears AS (
    SELECT YEAR([Date Joined]) AS Year_Joined
    FROM Unicorn_C
    WHERE [Date Joined] IS NOT NULL
),
YearlyCounts AS (
    SELECT Year_Joined, COUNT(*) AS Unicorn_Count
    FROM CleanedYears
    WHERE Year_Joined >= 2018
    GROUP BY Year_Joined
),
GrowthCalc AS (
    SELECT 
        Year_Joined,
        Unicorn_Count,
        LAG(Unicorn_Count) OVER (ORDER BY Year_Joined) AS Prev_Year_Count
    FROM YearlyCounts
)
SELECT 
    Year_Joined,
    Unicorn_Count,
    -- The Storytelling Labels for your Chart
    CASE 
        WHEN Year_Joined = 2021 THEN 'The Spike (Liquidity Peak)'
        WHEN Year_Joined = 2022 AND Unicorn_Count < Prev_Year_Count THEN 'The Correction (Rate Hikes)'
        ELSE 'Normal Trend'
    END AS Market_Status
FROM GrowthCalc
ORDER BY Year_Joined;


SELECT * FROM #Unicorn_Analysis
SELECT * FROM #Investor_Long


-- =============================================
-- Key Insights & Findings:
-- =============================================
--The total of Unicorn Companies as registered by this dataset is 1074, of which 240 companies have valuations above the average.
-- there have been a gradual increase in emergence Unicorn Companies over the years, with the peak at 2021 (520). 
--this significant increase from a gradual trend can be attributed to the Global Pandemic (COVID-19), w hich acceerated the digital transformation
-- The United State remains the Country with the highest number of Unicorn Companies (562), leading the preceeding country more that 5 margins.
-- San Francisco tops the list at 148, habouring 26% of the United State Unicorn Companies and 14% world wide, and clocking a wooping 303 Unicorn Companies in 2021
-- This is followed closely by the New York at 103.

-- High-Growth & Emerging Sectors:
-- =============================================
-- Fintech: Grew from 11.0% (2016) to 26.7% (2022) — the fastest-growing vertical with strong investor confidence.
-- AI/Big Data/Analytics: Rose steadily from 9.8% (2020) to 12.3% (2022), reflecting widespread enterprise adoption.
-- SaaS: Increased to 8.6% (2021) before slightly dipping, signaling consistent relevance in B2B software.

-- THE 2021 ANOMALY: The Digital Spike (Short-Term Highs):
-- =============================================
-- HealthTech & Biotech peaked in 2020 due to abundant venture capital, low interest rates, and inflated late-stage funding rounds, but declined in 2022.
-- HealthTech: 7.6% (2020) → 5.1% (2022)
-- Biotech: 6.3% (2020) → 3.7% (2022)
-- E-Commerce: Hit a high in 2020 (15.5%) but fell back to 10.4% in 2022.

-- Declining Sectors:
-- =============================================
-- Real Estate Tech: Decreased from 9.0% (2016) to 3.4% (2022)
-- Manufacturing: Dropped from 6.0% (2016) to 2.8% (2022), showing limited VC appeal.

-- Hype-Driven Growth:
-- =============================================
-- Web3/Blockchain: Jumped from 1.9% (2020) to 6.7% (2021), then stabilized at 5.4% (2022) — strong momentum, but high volatility.