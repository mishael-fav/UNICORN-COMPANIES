# Global Unicorn Arbitrage: Ecosystem Efficiency Dashboard

**An exploratory data analysis of global unicorn ecosystems, examining
valuation, funding intensity, growth velocity, investor networks and
geographic concentration.**

**Project type:** Independent data analytics portfolio project\
**Analytical approach:** Business-oriented exploratory data analysis
(EDA)\
**Tools:** Microsoft SQL Server (T-SQL), Power BI\
**Focus:** Descriptive market analysis and exploratory investment
screening---not investment-return forecasting

[View the interactive Power BI
dashboard](https://app.powerbi.com/links/NDQXqXVVke?ctid=319a61c8-ee1e-4161-8f35-b9553227afd7&pbi_source=linkShare&bookmarkGuid=6aa14441-554f-4a07-b90e-b58e37eac958)
\| [Explore the SQL analysis](SQL_Query/SQL_query_for_Unicorn.sql)

> **Executive takeaway:** Unicorn valuations, disclosed funding,
> formation speed and investor relationships vary across industries and
> locations. This analysis uses those differences to identify patterns
> and candidates for further investigation. Its valuation-to-funding
> ratio is a descriptive screening measure---not ROI, an investor return
> multiple, or proof that a market is underpriced.

## Table of Contents

-   [1. Project Overview](#1-project-overview)
-   [2. Business Problem & Analytical
    Questions](#2-business-problem--analytical-questions)
-   [3. Dataset Overview & Tools](#3-dataset-overview--tools)
-   [4. EDA Framework & Methodology](#4-eda-framework--methodology)
-   [5. Executive Summary](#5-executive-summary)
-   [6. Key Findings & Visualizations](#6-key-findings--visualizations)
    -   [6.1 Capital Efficiency](#61-capital-efficiency)
    -   [6.2 Industry Growth Velocity](#62-industry-growth-velocity)
    -   [6.3 Investor Networks](#63-investor-networks)
    -   [6.4 Global Ecosystem
        Comparison](#64-global-ecosystem-comparison)
    -   [6.5 Market Structure & Historical
        Trends](#65-market-structure--historical-trends)
-   [7. Recommendations & Business
    Implications](#7-recommendations--business-implications)
-   [8. Limitations & Further
    Investigation](#8-limitations--further-investigation)
-   [9. Project Files & Deliverables](#9-project-files--deliverables)
-   [10. Potential Extensions](#10-potential-extensions)

------------------------------------------------------------------------

## 1. Project Overview

A unicorn is a privately held company with a reported valuation of at
least **US\$1 billion**. This project examines a snapshot of global
unicorn companies to understand how reported valuation, disclosed
funding, time to unicorn status, investor relationships and geographic
distribution differ across the observed ecosystem.

The project is framed as **Global Unicorn Arbitrage**, but "arbitrage"
is used as an exploratory comparison of ecosystems rather than a claim
that an executable investment opportunity has been identified. Markets
with relatively high average unicorn valuations, different company
counts or distinct funding profiles are treated as signals for further
investigation---not direct measures of entry price, expected return or
investment attractiveness.

The project is best understood as a business-oriented EDA. It starts
with a broad question about differences between unicorn ecosystems,
breaks that question into smaller analytical questions, examines the
data's structure and quality, investigates segments and relationships,
and translates observed patterns into qualified business implications.

**Primary deliverable:** A Power BI dashboard supported by SQL Server
data preparation, company-level analysis and a separate
investor-relationship table.

[Back to Table of Contents](#table-of-contents)

## 2. Business Problem & Analytical Questions

Headline unicorn counts and valuations offer only a partial view of a
venture ecosystem. A country may contain many unicorns because it has a
large startup market, while another may have fewer companies but a
different average valuation profile. Similarly, a high valuation
relative to disclosed funding may indicate a company worth
investigating, but it does not establish profitability or investor
returns.

**Business question:** How do unicorn valuation, funding intensity,
growth speed, investor participation and geographic concentration differ
across the observed global ecosystem, and which patterns warrant deeper
investment research?

This analysis addresses five questions:

1.  **Capital intensity:** Which companies and industries have high or
    low reported valuation relative to disclosed funding?
2.  **Growth velocity:** How does the observed time from founding to
    unicorn status vary across industries?
3.  **Investor concentration:** Which investors appear most frequently
    in the company records, and which investor pairs repeatedly appear
    together?
4.  **Geographic structure:** How do unicorn counts and average reported
    valuations vary across continents, countries and cities?
5.  **Historical change:** How did unicorn formation and industry
    composition change across the recorded years, particularly around
    the 2021 peak and subsequent 2022 slowdown?

The intended audience is an analyst or investment-research team building
an initial screening shortlist. The dashboard helps identify where to
investigate further; it does not estimate actual fund performance,
private-company fair value, startup failure probability,
ownership-adjusted returns or investment eligibility.

[Back to Table of Contents](#table-of-contents)

## 3. Dataset Overview & Tools

The earlier project analysis reported a working sample of **1,074 global
unicorn company records**. This is a historical baseline from the prior
analytical version; the current SQL pipeline and CSV exports should be
re-counted before publishing it as a verified current row count. The
source dataset's download URL, extraction date and refresh date have not
been independently confirmed in the project documentation.

### 3.1 Data structure

The updated SQL workflow separates company-level attributes from
investor relationships. A company can have multiple listed investors;
repeating company valuation once for every investor would inflate
company-level totals if the resulting table were aggregated without
accounting for the changed grain.

  ------------------------------------------------------------------------
  Data object              Grain                   Main purpose
  ------------------------ ----------------------- -----------------------
  `#Unicorn_Analysis`      Prepared company-level  Company attributes and
                           record                  derived analytical
                                                   fields

  `#Investor_Long`         Company × investor      Normalised investor
                           relationship            participation records

  `Fact_Unicorn.csv`       Company-level fact      Main Power BI analysis
                           output                  table

  `Bridge_Investors.csv`   Company × investor      Investor filtering and
                           relationship            network-related
                                                   analysis
  ------------------------------------------------------------------------

### 3.2 Main analytical fields

  -----------------------------------------------------------------------
  Field                               Role in the analysis
  ----------------------------------- -----------------------------------
  `Company_ID`                        Prepared company key connecting
                                      company and investor tables

  `Company`                           Company name

  `Industry`                          Industry classification

  `City`, `Country`, `Continent`      Geographic segmentation

  `Year Founded`                      Company founding year

  `Date Joined`                       Recorded date of attaining unicorn
                                      status

  `Year_Joined`                       Year extracted from `Date Joined`

  `Valuation_Num`                     Numeric reported company valuation

  `Funding_Num`                       Numeric reported funding amount

  `Years_To_Unicorn`                  Difference between unicorn entry
                                      year and founding year

  `Capital_Efficiency_Ratio`          Valuation divided by positive
                                      disclosed funding

  `Efficiency_Category`               Project-defined category based on
                                      ratio and funding availability

  `Investor`                          Individual investor name in the
                                      bridge table
  -----------------------------------------------------------------------

### 3.3 Tools and roles

  -----------------------------------------------------------------------
  Tool                                Role
  ----------------------------------- -----------------------------------
  Microsoft SQL Server (T-SQL)        Data preparation, currency
                                      conversion, key construction,
                                      date-derived fields, investor-list
                                      normalisation, metric calculation
                                      and analytical queries

  Power Query                         Importing the two CSV outputs and
                                      applying/confirming data types

  Power BI                            Interactive exploration, KPI
                                      reporting, segmentation and
                                      dashboard presentation
  -----------------------------------------------------------------------

### 3.4 Data-grain and identifier decision

`Fact_Unicorn` is the company-level table. `Bridge_Investors` stores one
row for each distinct company-investor relationship. The intended Power
BI relationship is:

`Fact_Unicorn[Company_ID]` **1 → many** `Bridge_Investors[Company_ID]`

The relationship should be active, with single-direction filtering from
the company fact table to the investor bridge table unless a specific
measure requires a different, carefully tested design.

`Company_ID` is constructed from the trimmed, uppercased company name
and industry. It is a practical key for this dataset, not a permanent
external company identifier. Revalidate it if company names or industry
labels change.

[Back to Table of Contents](#table-of-contents)

## 4. EDA Framework & Methodology

The analytical structure is informed by Christine Jiang's
business-oriented EDA approach: begin with the stakeholder's objective,
organise the investigation around meaningful questions, understand the
columns and their coverage, examine aggregates and anomalies, identify
notable segments, and communicate findings in terms of what they mean
for the business.

The framework is applied as a practical sequence rather than a rigid
formula. The central discipline is to make the reasoning visible: **what
question was asked, what data was examined, what pattern appeared, how
reliable that pattern is, and what should happen next.**

### 4.1 Define the objective before exploring

The objective is not simply to describe every column. It is to
understand differences in the observed unicorn ecosystem that may help
an analyst decide where additional research is worthwhile. The five
business questions in Section 2 determine which variables, comparisons
and visualisations are relevant. This prevents the dashboard from
becoming a collection of charts without a clear analytical purpose.

### 4.2 Understand the data and its coverage

The company-level dataset contains company, industry, location,
founding, unicorn-entry, valuation, funding and investor-list
information. Preparation therefore focuses on:

-   understanding the meaning and type of each field;
-   checking whether key company, date and financial fields are present;
-   converting valuation and funding strings into numeric values;
-   distinguishing unknown funding from an actual zero;
-   checking company-key uniqueness and repeated company-investor
    relationships;
-   examining whether dates produce plausible founding-to-unicorn
    intervals; and
-   recognising that investor lists may be incomplete or inconsistently
    named.

The data should be profiled before interpreting averages or rankings. A
missing funding value must not be silently treated as zero, because that
would create an invalid denominator and distort capital-efficiency
analysis.

### 4.3 Examine aggregates, distributions and anomalies

The next stage examines the overall shape of the data before drawing
conclusions from individual companies or segments. Relevant checks
include total records and distinct `Company_ID` values; missing or
non-positive funding; valuation and funding distributions; minimum,
maximum, median and average values where appropriate; the distribution
of `Years_To_Unicorn`; counts by industry and geography; duplicate
company-investor relationships; and unusually high or low ratios and
durations.

Anomalies are not automatically deleted. They should be investigated in
context and handled according to the metric being calculated. A record
with an invalid negative founding-to-unicorn interval should not
contribute to a duration statistic, but may still be retained in
company-level counts if it remains valid for those other purposes.

### 4.4 Segment around the business questions

After examining data structure and quality, compare meaningful segments:

-   **Industry:** capital intensity, unicorn counts and observed
    formation speed.
-   **Geography:** company concentration and average reported valuation
    across continents, countries and cities.
-   **Time:** unicorn-entry cohorts and changes in industry composition.
-   **Investor relationships:** investor participation and repeated
    company co-occurrence.
-   **Company-level observations:** high and low valuation-to-funding
    ratios and unusual formation intervals.

Segment comparisons should retain their denominators and sample sizes. A
high average based on a small number of companies should not be treated
as directly equivalent to a high average from a large, diverse group.

### 4.5 Investigate relationships, not just rankings

The project examines relationships between valuation and funding,
founding year and unicorn-entry year, geography and company
concentration, and investor names and shared company records. These are
descriptive relationships; they do not, by themselves, establish
causation. A shorter observed time to unicorn status in an industry does
not prove that the industry is inherently more successful. The result
may reflect cohort composition, survivor selection, date precision and
reporting differences.

### 4.6 Interpret and communicate findings

Each dashboard theme is presented through four linked elements:

1.  **Question:** the business issue being investigated.
2.  **Evidence:** the measure, comparison or pattern observed in the
    data.
3.  **Interpretation:** what the pattern may indicate, including
    important qualifications.
4.  **Implication:** what an analyst should validate or investigate
    next.

This keeps the project focused on analytical reasoning rather than
visual presentation alone.

### 4.7 Updated SQL preparation pipeline

The current preparation workflow uses `Unicorn_Company` as its source
and creates two temporary analytical structures:

-   `#Unicorn_Analysis` for company-level attributes and derived fields.
-   `#Investor_Long` for normalised company-investor relationships.

The final company-level output adds `Capital_Efficiency_Ratio` and
`Efficiency_Category` before export. The investor bridge output uses the
prepared long table and retains distinct company-investor relationships.

**Capital-efficiency calculation:**

``` sql
ROUND(
    Valuation_Num / NULLIF(Funding_Num, 0),
    2
) AS Capital_Efficiency_Ratio
```

**Project-defined classification:**

``` sql
CASE
    WHEN Funding_Num IS NULL OR Funding_Num <= 0
        THEN 'Not Classified'
    WHEN Valuation_Num / NULLIF(Funding_Num, 0) >= 10
        THEN 'Elite Efficiency (10x+)'
    WHEN Valuation_Num / NULLIF(Funding_Num, 0) < 2
        THEN 'Cash Burner (<2x)'
    ELSE 'Standard Growth'
END AS Efficiency_Category
```

These thresholds are project-specific screening categories, not
universal venture-capital benchmarks. The ratio is not ROI,
profitability, a cash-burn measure or an investor return multiple.
`Not Classified` preserves the distinction between missing/non-positive
funding and a valid positive denominator.

### 4.8 Power BI model and data delivery

The final outputs are exported as two CSV files: `Fact_Unicorn.csv` and
`Bridge_Investors.csv`. Both are imported through Power Query. The
expected model uses `Company_ID` to connect the company fact table to
the investor bridge table in a one-to-many relationship. Company-level
measures, such as total unicorn count, should be calculated from
`Fact_Unicorn` using `Company_ID`, not by counting rows in the investor
bridge.

This model design protects company-level valuation and funding measures
from being multiplied by the number of investors associated with each
company.

### 4.9 Key measures and definitions

  -------------------------------------------------------------------------
  Measure                             Calculation / interpretation
  ----------------------------------- -------------------------------------
  Capital-efficiency ratio            `Valuation_Num / Funding_Num`, for
                                      positive known funding; not realised
                                      ROI

  Years to unicorn                    `Year_Joined − Year Founded`; a
                                      year-granularity approximation

  Value-velocity proxy                `Valuation_Num / Years_To_Unicorn`,
                                      excluding zero or invalid intervals;
                                      not annual valuation growth

  Unicorn count                       Distinct companies in a defined
                                      segment

  Average reported valuation          Mean reported valuation within a
                                      defined group; sensitive to outliers
                                      and sample size

  Investor participation              Number of distinct company
                                      relationships associated with an
                                      investor

  Co-investment frequency             Number of distinct companies shared
                                      by an investor pair
  -------------------------------------------------------------------------

**Illustrative SQL pattern --- capital-efficiency screening:**

``` sql
SELECT
    Company_ID,
    Company,
    Industry,
    Valuation_Num,
    Funding_Num,
    ROUND(
        Valuation_Num / NULLIF(Funding_Num, 0),
        2
    ) AS Capital_Efficiency_Ratio
FROM #Unicorn_Analysis
WHERE Funding_Num IS NOT NULL
  AND Funding_Num > 0
ORDER BY Capital_Efficiency_Ratio DESC;
```

The calculation compares reported amounts. It does not account for
ownership percentages, investment dates, dilution, exits, cash returned
or investment terms.

[Back to Table of Contents](#table-of-contents)

## 5. Executive Summary

The earlier project analysis reported a sample of **1,074 unicorn
company records** and an estimated combined reported valuation of
approximately **\$3.71 trillion**. Those figures describe the previous
analytical version and should be treated as historical reported results
until the latest CSV exports are recounted and reconciled.

The prior analysis described a highly concentrated market, with **562
unicorns in the United States**, **148 in San Francisco** and **103 in
New York**. It also identified **520 companies with a recorded unicorn
entry year of 2021**, making that year prominent in the earlier dataset.

Across industries, the earlier analysis reported an average
founding-to-unicorn interval of approximately **5.9 years for Artificial
Intelligence** and **5.03 years for Auto & Transportation**. It reported
**205 Internet Software unicorns** in the earlier sample. Company-level
valuation-to-funding ratios varied widely, while investor co-occurrence
analysis highlighted repeated relationships among a subset of venture
firms.

These figures are retained as prior analytical findings, not represented
as newly validated results from the updated pipeline. The updated data
architecture improves the separation of company and investor records,
introduces a consistent `Company_ID`, and makes the funding
classification explicit. The latest dashboard values should be checked
against the final CSV exports before being reported as current.

**Overall conclusion:** The observed patterns are useful for identifying
where to investigate further. The dataset does not establish realised
investor returns, startup profitability, fair entry valuations, causal
drivers of the 2021 spike or a uniquely optimal city for venture-capital
deployment.

[Back to Table of Contents](#table-of-contents)

## 6. Key Findings & Visualizations

The findings below preserve the analytical themes and prior observations
from the earlier project version. Where exact figures came from that
earlier analysis, they are explicitly identified as prior reported
results. They should be refreshed against the current exports before
being presented as validated current KPIs.

### 6.1 Capital Efficiency

**Business question:** Which companies have high or low reported
valuation relative to disclosed funding, and what should an analyst
investigate about those differences?

The valuation-to-funding comparison highlights substantial variation in
reported company valuations relative to disclosed funding. The earlier
analysis highlighted companies such as **Zapier** and **Canva** among
high-ratio observations, while **Magic Leap** and **Ola Cabs** appeared
in a lower-ratio group. Some reported outliers approached a **4,000×**
valuation-to-funding ratio in that earlier analysis.

A high ratio may warrant investigation of business model, funding
history and valuation timing. It does **not** demonstrate that the
company generated a 4,000× investor return or achieved its valuation
without substantial capital. Likewise, a ratio below 2× does not by
itself establish cash burn or value destruction.

![Capital efficiency dashboard](dashboard_pic/CAPITAL_EFFICIENCY.PNG)

**Interpretation:** Reported valuation relative to disclosed funding is
a screening proxy for apparent capital intensity. Its usefulness depends
on funding completeness, consistency of valuation and funding dates, and
comparability of companies.

**Business implication:** Analysts can use the ratio to create a
diligence shortlist, but should not rank companies as investment winners
or losers on this measure alone.

**Recommended action:** Validate funding disclosures, valuation dates,
business models and financing terms for extreme observations. Review the
distribution and number of companies in each efficiency category,
including `Not Classified`.

**Metric note:** The current project uses `Capital_Efficiency_Ratio` and
four categories: `Elite Efficiency (10x+)`, `Cash Burner (<2x)`,
`Standard Growth` and `Not Classified`. These are project-defined
labels, not industry-standard ratings.

[Back to Table of Contents](#table-of-contents)

### 6.2 Industry Growth Velocity

**Business question:** How does the observed time from founding to
unicorn status differ across industries?

The earlier analysis reported an average time to unicorn status of
approximately **5.9 years for Artificial Intelligence** and **5.03 years
for Auto & Transportation**. Internet Software had **205 unicorns** in
the earlier sample and a reported value-velocity proxy of approximately
**\$500 million per year**, compared with approximately **\$1.1 billion
per year** for AI.

These statistics describe companies that *have already reached unicorn
status*. They do not capture startups that never did. A lower
time-to-unicorn interval cannot independently establish stronger
fundamentals or lower investment risk. The value-velocity proxy divides
a reported valuation by years since founding; it is not an observed
yearly return series.

![Industry growth velocity
dashboard](dashboard_pic/high_growth_velocity.PNG)

**Interpretation:** Industries differ in the observed time taken by
companies in this unicorn sample to reach the \$1 billion threshold.
Differences may reflect company mix, cohort timing, reporting
conventions and survivorship---not just industry characteristics.

**Business implication:** Sector comparisons can help prioritise further
review of funding requirements and business-model characteristics, but
should not be used as stand-alone forecasts.

**Recommended action:** Compare cohort years, funding intensity and
sample sizes. Exclude zero or invalid duration values from
duration-based measures, investigate negative intervals, and test
whether findings are robust to extreme observations.

[Back to Table of Contents](#table-of-contents)

### 6.3 Investor Networks

**Business question:** Which investors appear frequently in the unicorn
sample, and which investor pairs repeatedly appear together?

The earlier project reported approximately **1,247 investor names** in
the analysed network, with some investors linked to many companies. It
highlighted **Accel** (approximately **60** unicorn company
relationships in the selected records) and **Sequoia Capital China**
(approximately **\$473 billion** in aggregate portfolio-company
valuation as reported in the earlier project).

The earlier investor-pair analysis reported **nine shared unicorn
investments** for Sequoia China and Tencent, and **six** for Accel and Y
Combinator. These are co-occurrence counts from the prior analysis, not
evidence of formal syndicate leadership, ownership share or
investment-performance superiority.

![Investor network dashboard](dashboard_pic/kingmaker_network.PNG)

**Interpretation:** Investor relationships are unevenly distributed
across the selected unicorn records, and some investor pairs co-occur
repeatedly. A long investor list can reveal network connections, but
source data may not provide complete or standardised investor coverage.

**Business implication:** The network can support due-diligence mapping
and identification of commonly co-invested companies. Summed company
valuations are not the value owned by an investor and cannot be treated
as a measure of fund return.

**Recommended action:** Standardise investor names, check incomplete
investor lists and distinguish investor-company exposure from actual
ownership and investment returns. Use `Company_ID` when connecting the
investor bridge to the company fact table.

**Data-model note:** `Bridge_Investors` stores distinct company-investor
relationships. Do not sum company valuation directly over bridge rows,
because companies with multiple listed investors would be counted
repeatedly.

[Back to Table of Contents](#table-of-contents)

### 6.4 Global Ecosystem Comparison

**Business question:** How do unicorn counts and average reported
valuations vary across countries and cities, and which locations merit
further research?

The earlier analysis compared unicorn counts and reported average
valuations by country and city. It described a global unicorn sample
valued at approximately **\$3.71 trillion** and identified both
high-volume hubs and smaller markets with relatively high average
company valuations. The earlier commentary referenced **Austin,
Hangzhou, Stockholm, Shenzhen and Boston** among cities worth closer
examination.

The earlier geographic analysis grouped companies by continent, country
and city, calculated company counts and average reported valuation, and
applied a minimum-count filter in one city-level query. This can surface
high-valuation observations but does **not** measure actual startup
entry prices, VC deal competition or the cost of acquiring equity.
Results for locations with small counts can also be unstable.

![Global ecosystem dashboard](dashboard_pic/GEOGRAPHICAL_ARBITRAGE.PNG)

**Interpretation:** Counts and average reported valuations highlight
geographic concentration and variation within the observed sample. They
do not establish that one city is cheaper, more investable or more
likely to generate superior returns.

**Business implication:** Geographic comparisons can help build a
research shortlist. The term *arbitrage* remains a framing device for
comparative screening rather than a verified mispricing opportunity.

**Recommended action:** Add funding-stage-adjusted entry valuations,
funding volumes, exit performance, deal terms and consistent city-level
coverage before ranking investment destinations.

[Back to Table of Contents](#table-of-contents)

### 6.5 Market Structure & Historical Trends

**Business question:** How did unicorn formation change over time, and
how concentrated is the observed market by geography and industry?

The earlier analysis highlighted **520 unicorn entries in 2021**,
alongside a subsequent decrease in new entries in 2022. It also reported
**562 US unicorns** within the earlier 1,074-record sample, including
**148 in San Francisco** and **103 in New York**. The project also
examined industry composition and pre-2021 growth patterns through SQL
queries.

The 2021 spike and subsequent slowdown are descriptive cohort patterns.
Attributing them to low interest rates, pandemic behaviour or market
correction would require external economic and financing evidence. A
change in the number of unicorn entries should not automatically be
interpreted as a change in total venture investment, startup
profitability or the number of successful startups.

**Interpretation:** The timing and geographic concentration of unicorn
formation are distinctive features of the earlier analysed snapshot.

**Business implication:** Cohort patterns provide context for
interpreting the other dashboard themes. They also warn against treating
one unusually active year as a stable baseline for future activity.

**Recommended action:** Re-run the cohort analysis on a dated,
consistently maintained source and compare results with venture-capital
funding and macroeconomic indicators. Clearly distinguish observed
changes from explanations that require external evidence.

[Back to Table of Contents](#table-of-contents)

## 7. Recommendations & Business Implications

The results support **research prioritisation**, not immediate
investment execution. The recommendations connect the EDA findings to
the next evidence-gathering steps.

  ----------------------------------------------------------------------------
  Priority          Analytical opportunity Recommended       Evidence needed
                                           action            before stronger
                                                             conclusions
  ----------------- ---------------------- ----------------- -----------------
  High              Extreme                Verify funding    Consistent, dated
                    valuation-to-funding   completeness,     funding and
                    ratios                 valuation dates,  valuation records
                                           company           
                                           financials and    
                                           ownership         
                                           structure         

  High              Fast unicorn formation Review            Comparable
                    in selected industries industry/cohort   sector-level
                                           sample sizes,     measures and
                                           survivorship bias sensitivity
                                           and capital needs checks

  High              Concentrated investor  Resolve investor  Reliable investor
                    networks               aliases and       entity matching
                                           validate          and complete
                                           co-investment     round histories
                                           pairs against     
                                           external records  

  Medium            High-valuation but     Compare actual    Stage-adjusted
                    lower-count cities     deal entry        investment terms
                                           prices, stages,   and consistent
                                           liquidity and     geographic
                                           exits             coverage

  Ongoing           Historic unicorn waves Monitor cohorts   Dated snapshots
                                           against           and external
                                           contemporaneous   contextual data
                                           VC activity and   
                                           macroeconomic     
                                           indicators        
  ----------------------------------------------------------------------------

### Business implications

1.  **For investment research:** Treat the dashboard as a first-stage
    screening tool. Any shortlist should proceed to company-level
    financial, market, governance and financing diligence.
2.  **For ecosystem analysis:** Compare both company counts and
    valuation distributions. Averages alone can conceal skewness and
    small-sample effects.
3.  **For investor-network research:** Separate the number of companies
    associated with an investor from ownership, capital deployed and
    realised returns.
4.  **For sector comparison:** Review the underlying company mix and
    cohort years before interpreting formation speed as a structural
    industry advantage.
5.  **For ongoing monitoring:** Refresh the source data and document the
    extraction date so that dashboard changes can be distinguished from
    changes in data coverage.

**Expected value:** A better-documented research shortlist, more
transparent screening criteria and fewer misleading comparisons. No
investment return, cost saving or causal impact has been established by
this project.

[Back to Table of Contents](#table-of-contents)

## 8. Limitations & Further Investigation

1.  **Dataset provenance and timing:** The earlier project documentation
    does not establish a verifiable source URL, extraction date or
    refresh date. Historical figures in this README should be treated as
    prior reported results until reconciled against the current CSV
    exports.
2.  **Selection and survivorship bias:** Unicorn-only records exclude
    most startups that did not reach a billion-dollar valuation. Results
    cannot be generalised to all funded startups or used to estimate the
    probability of becoming a unicorn.
3.  **Reported valuations are not realised returns:** Company valuations
    and cumulative funding do not establish ROI, cash flows,
    dilution-adjusted multiples, ownership value or fund-level
    performance.
4.  **Valuation/funding comparability:** Funding may be incomplete or
    not aligned with valuation dates. Missing and zero funding require
    explicit handling. `Not Classified` prevents invalid denominators
    from being presented as ordinary ratio observations.
5.  **Capital-efficiency categories:** The thresholds are analytical
    choices for screening. They are not universal venture-capital
    standards and should not be interpreted as ratings of company
    quality.
6.  **Growth-velocity measurement:** `Year_Joined − Year Founded` is a
    year-level approximation rather than an exact duration. Negative or
    zero intervals require investigation or exclusion from
    duration-based calculations. The value-velocity proxy is not a
    measured annual growth rate.
7.  **Investor attribution:** Investor lists may be partial or
    inconsistent. Assigning an entire company's valuation to every named
    investor double-counts company value and cannot estimate ownership
    value.
8.  **Geographic conclusions:** Average valuations and counts do not
    measure deal access, entry price, liquidity or geographic investment
    arbitrage. Small groups are especially sensitive to individual
    observations.
9.  **Macroeconomic explanations:** The analysis describes the 2021
    spike and 2022 slowdown but does not independently establish their
    causes.
10. **Identifier limitations:** `Company_ID`, constructed from
    normalised company name and industry, is a dataset key. It is not a
    verified global legal-entity identifier; name or industry changes
    may affect matching.
11. **Power BI model integrity:** Company-level measures must be
    calculated from the company fact table. Investor bridge rows
    represent relationships and should not be treated as additional
    unicorn companies.

### Additional evidence that would improve the project

  -----------------------------------------------------------------------
  Area                    Additional evidence     Purpose
  ----------------------- ----------------------- -----------------------
  Capital efficiency      Dated funding rounds,   Separate valuation
                          valuation dates,        proxies from realised
                          dilution, revenues and  performance
                          exits                   

  Sector velocity         Exact founding and      Reduce timing error and
                          unicorn dates, full     survivorship bias
                          startup cohorts and     
                          failure data            

  Investor network        Standardised investor   Improve network
                          IDs, ownership stakes   reliability and
                          and complete round      economic interpretation
                          histories               

  Geographic comparison   Stage-adjusted deal     Test whether alleged
                          prices, funding         efficiency hubs are
                          availability, exits and investable or
                          liquidity               underpriced

  Historical trends       Dated unicorn snapshots Support robust cohort
                          and contemporaneous     and contextual
                          VC/macro data           comparisons

  Data quality            Source documentation,   Make the analysis
                          extraction timestamp    reproducible and track
                          and repeatable          changes between
                          validation checks       refreshes
  -----------------------------------------------------------------------

[Back to Table of Contents](#table-of-contents)

## 9. Project Files & Deliverables

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Resource                                                                                                                                                                Description
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- -----------------------------------
  [Interactive Power BI                                                                                                                                                   Published dashboard; access depends
  dashboard](https://app.powerbi.com/links/NDQXqXVVke?ctid=319a61c8-ee1e-4161-8f35-b9553227afd7&pbi_source=linkShare&bookmarkGuid=6aa14441-554f-4a07-b90e-b58e37eac958)   on Power BI permissions

  [Main SQL analysis script](SQL_Query/SQL_query_for_Unicorn.sql)                                                                                                         SQL preparation and analysis
                                                                                                                                                                          script; confirm the repository copy
                                                                                                                                                                          reflects the latest
                                                                                                                                                                          `Unicorn_Company` pipeline

  `Fact_Unicorn.csv`                                                                                                                                                      Company-level export used by Power
                                                                                                                                                                          BI

  `Bridge_Investors.csv`                                                                                                                                                  Distinct company-investor
                                                                                                                                                                          relationship export used by Power
                                                                                                                                                                          BI

  `dashboard_pic/CAPITAL_EFFICIENCY.PNG`                                                                                                                                  Valuation-to-funding screening
                                                                                                                                                                          visual

  `dashboard_pic/high_growth_velocity.PNG`                                                                                                                                Industry growth-velocity visual

  `dashboard_pic/kingmaker_network.PNG`                                                                                                                                   Investor participation and
                                                                                                                                                                          co-occurrence visual

  `dashboard_pic/GEOGRAPHICAL_ARBITRAGE.PNG`                                                                                                                              Geographic valuation and
                                                                                                                                                                          company-count comparison
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

**Repository note:** The dashboard image paths and SQL path above are
retained from the earlier README. Confirm that each file exists with the
exact spelling and capitalisation in the current GitHub repository. The
two CSV filenames describe the updated data-delivery design; include
them as repository links only after the files have actually been
committed. The full underlying source dataset and Power BI source file
should only be listed as downloadable deliverables if they are included
in the repository.

[Back to Table of Contents](#table-of-contents)

## 10. Potential Extensions

1.  **Unicorn prediction research:** Explore a carefully time-split
    model using information available before unicorn status, with
    non-unicorn examples, leakage controls and a clear prediction
    target.
2.  **Investor network visualisation:** Build a graph of
    investor-company and investor-pair relationships, with consistent
    entity identifiers, coverage checks and measures that distinguish
    participation from ownership.
3.  **Funding-cycle analysis:** Compare dated funding activity and
    valuations with macroeconomic conditions, while testing temporal
    direction and potential confounding factors.
4.  **Geographic ecosystem benchmarking:** Add stage-adjusted deal
    values, funding availability, exit outcomes and liquidity measures
    to test whether high-valuation/low-count locations offer any
    defensible comparative advantage.
5.  **Reproducible EDA refresh:** Automate source validation, profiling,
    anomaly reporting and dashboard refresh checks so each update
    records what changed and whether earlier findings still hold.

These are **future research ideas**, not completed parts of the current
project.

[Back to Table of Contents](#table-of-contents)

------------------------------------------------------------------------

## Analytical references

-   Jiang, Christine. *The EDA Framework Data Hiring Managers Love*
    (2024). [YouTube](https://www.youtube.com/watch?v=LJlwl9LBDLo).
-   Jiang, Christine. *How to NAIL Exploratory Data Analysis* (2025).
    [YouTube](https://www.youtube.com/watch?v=deS6lETubdU).
-   NIST/SEMATECH. *What Is Exploratory Data Analysis?* [NIST/SEMATECH
    e-Handbook](https://www.itl.nist.gov/div898/handbook/eda/section1/eda11.htm).

The references inform the EDA presentation and analytical discipline.
Project-specific metrics and findings are derived from the project's own
SQL and dashboard work; these references do not independently validate
those results.
