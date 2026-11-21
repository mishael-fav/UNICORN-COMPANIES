# Global Unicorn Ecosystem Analysis — Data Dictionary

This document defines the fields used in the company-level fact output and investor bridge output. It also records the staging fields used by the SQL preparation pipeline. Field types below describe the intended Power Query / Power BI import types; confirm them against the actual CSV export when loading refreshed data.

## 1. Data model and table grain

| Table / object | Grain | Purpose |
|---|---|---|
| `Unicorn_Company` | Source-record level | Source table containing company attributes and the original investor-list field |
| `#Unicorn_Analysis` | One prepared row per company record | Normalised company attributes and derived company-level measures |
| `#Investor_Long` | One row per company-investor relationship | Staging table created by splitting the source investor list |
| `Fact_Unicorn.csv` | One row per `Company_ID` | Company-level attributes and measures used for company counts, valuation and funding analysis |
| `Bridge_Investors.csv` | One row per distinct `Company_ID`–`Investor` pair | Investor filtering, participation counts and co-investment analysis |

The intended relationship is `Fact_Unicorn[Company_ID]` (one) to `Bridge_Investors[Company_ID]` (many). Do not aggregate company valuation by summing repeated values in the bridge table. Use the fact table for company-level financial measures and distinct `Company_ID` counts for company counts.

## 2. Company fact table — `Fact_Unicorn.csv`

| Field | Suggested data type | Definition and analytical role | Derivation / handling |
|---|---|---|---|
| `Company_ID` | Text | Dataset-specific company key used to connect the fact and investor tables. | Constructed from the trimmed, uppercased company name and industry, separated by `|`. Not a globally verified legal-entity identifier. |
| `Company` | Text | Company name as represented in the source data. | Retain the displayed company name; do not use it alone as a unique key because duplicate names and case variations can occur. |
| `Industry` | Text | Industry classification assigned to the company. | Source classification. Used for sector segmentation. |
| `City` | Text | City associated with the company record. | Source geographic attribute; missing values should remain blank/unknown rather than being inferred. |
| `Country` | Text | Country associated with the company record. | Source geographic attribute. |
| `Continent` | Text | Continent associated with the company record. | Source or prepared geographic attribute. |
| `Year Founded` | Whole number | Recorded founding year of the company. | Source field. Used with `Year_Joined` to calculate the year-level time-to-unicorn measure. |
| `Date Joined` | Date | Recorded date on which the company joined the unicorn population. | Source date. Rows with a null date are excluded from the final fact output by the documented SQL filter. |
| `Year_Joined` | Whole number | Calendar year extracted from `Date Joined`. | Derived using the year component of `Date Joined`. Used for cohort and annual-entry analysis. |
| `Valuation_Num` | Decimal number | Numeric reported company valuation. | Converted from the source valuation field. Treat as a reported valuation amount, not realised proceeds or investor-owned value. |
| `Funding_Num` | Decimal number | Numeric reported funding amount. | Converted from the source funding field. Missing funding remains null; it must not be recoded to zero. |
| `Years_To_Unicorn` | Whole number | Year-level interval between company founding and unicorn entry. | `Year_Joined - [Year Founded]`. Negative or zero values require validation and should not contribute to positive-duration statistics. |
| `Capital_Efficiency_Ratio` | Decimal number | Reported valuation divided by disclosed funding for screening comparisons. | `ROUND(Valuation_Num / NULLIF(Funding_Num, 0), 2)`. Only positive, known funding yields a valid ratio. Not ROI, profitability, cash burn or an investor return multiple. |
| `Efficiency_Category` | Text | Project-defined classification of the valuation-to-funding ratio. | `Elite Efficiency (10x+)` when ratio is at least 10; `Cash Burner (<2x)` when ratio is below 2; `Standard Growth` when ratio is at least 2 and below 10; `Not Classified` when funding is null or non-positive. These are project-specific screening labels, not industry standards. |

### Fact table inclusion rule

The final fact query includes rows where `Date Joined` is not null. This rule does not, by itself, remove records with negative `Years_To_Unicorn`; those records should be retained for general company-level analysis where appropriate and excluded or separately flagged in duration-based analysis after validation.

## 3. Investor bridge table — `Bridge_Investors.csv`

| Field | Suggested data type | Definition and analytical role | Derivation / handling |
|---|---|---|---|
| `Company_ID` | Text | Foreign-key field connecting an investor relationship to the company fact record. | Uses the same key-generation rule as `Fact_Unicorn[Company_ID]`. |
| `Company` | Text | Company name associated with the investor relationship. | Carried from the prepared company record for convenient display and validation. |
| `Industry` | Text | Industry of the company associated with the investor relationship. | Carried from the prepared company record. |
| `Year_Joined` | Whole number | Year the associated company joined the unicorn population. | Carried from the prepared company record. |
| `Investor` | Text | One investor name associated with the company. | Created by splitting the source `[Select Investors]` field on commas, trimming whitespace and retaining distinct company-investor pairs. Null or blank investor values are excluded. |

**Bridge-table rule:** A company may have several investor rows. The bridge table therefore has a different grain from the fact table. Count companies using distinct `Company_ID`; count investor-company relationships using distinct `Company_ID`–`Investor` pairs. Co-investment frequency is the number of distinct companies shared by an investor pair.

## 4. SQL staging objects

### 4.1 `#Unicorn_Analysis`

This temporary table is the prepared company-level staging object created from `Unicorn_Company`. It contains the company attributes and derived fields used to produce `Fact_Unicorn.csv` and to build the investor bridge.

| Field | Suggested data type | Definition |
|---|---|---|
| `Company_ID` | Text | Normalised company-name and industry key. |
| `Company` | Text | Source company name. |
| `Industry` | Text | Source industry classification. |
| `City` | Text | Company city. |
| `Country` | Text | Company country. |
| `Continent` | Text | Company continent. |
| `Year Founded` | Whole number | Source founding year. |
| `Date Joined` | Date | Source unicorn-entry date. |
| `Year_Joined` | Whole number | Year extracted from `Date Joined`. |
| `Valuation_Num` | Decimal number | Numeric reported valuation. |
| `Funding_Num` | Decimal number | Numeric reported funding amount. |
| `Years_To_Unicorn` | Whole number | `Year_Joined - [Year Founded]`. |

The source `[Select Investors]` field is also used by the investor-list preparation step. It is a comma-delimited text field, not a single investor value.

### 4.2 `#Investor_Long`

| Field | Suggested data type | Definition |
|---|---|---|
| `Company_ID` | Text | Company key from `#Unicorn_Analysis`. |
| `Company` | Text | Company name. |
| `Industry` | Text | Company industry. |
| `Year_Joined` | Whole number | Unicorn-entry year. |
| `Investor` | Text | One trimmed investor name from the source investor list. |

This staging table is produced by splitting `[Select Investors]` on commas, trimming each resulting value and selecting distinct company-investor relationships.

## 5. Derived metric definitions

| Metric | Formula | Validity / interpretation |
|---|---|---|
| Capital-efficiency ratio | `Valuation_Num / Funding_Num` | Calculate only where funding is known and greater than zero. A descriptive ratio, not a return measure. |
| Years to unicorn | `Year_Joined - [Year Founded]` | Year-granularity approximation; investigate zero and negative values. |
| Value-velocity proxy | `Valuation_Num / Years_To_Unicorn` | Use only for valid positive durations. Not an observed annual growth rate or investor return. |
| Unicorn count | Distinct count of `Company_ID` | Calculate from the company fact table or a properly de-duplicated company set. |
| Investor participation | Distinct company-investor relationships per investor | Measures recorded participation links, not ownership or capital deployed. |
| Co-investment frequency | Distinct `Company_ID` values shared by an investor pair | Measures co-occurrence in the recorded investor lists, not necessarily a formally documented syndicate. |
| Geographic share | Distinct companies in a geography divided by distinct companies in scope, multiplied by 100 | Report alongside the underlying company count. |
| Annual entry share | Companies with a given `Year_Joined` divided by all companies with a valid entry year, multiplied by 100 | Denominator should be consistent across the years being compared. |

## 6. Data quality and interpretation rules

1. **Unknown funding is not zero.** Preserve null funding values. Do not calculate a valuation-to-funding ratio for missing or non-positive funding.
2. **Negative or zero durations require review.** They may indicate source-date inconsistencies or insufficient date precision. Exclude them from positive-duration summaries and disclose the number excluded.
3. **Do not use company name as the only key.** The same or similar company names may occur in different records; use the constructed `Company_ID` while recognising its dataset-specific limitations.
4. **Do not multiply company values through the bridge.** A company with multiple investors appears in multiple bridge rows. Aggregate company valuation and funding from the fact table.
5. **Investor coverage may be incomplete.** The bridge reflects names present in the source investor-list field; absence from the bridge does not prove that a company had no investors.
6. **Reported valuation is not investor-owned value.** A company's reported valuation cannot be attributed in full to every investor listed for that company.
7. **Category thresholds are analytical choices.** The four `Efficiency_Category` labels are project-defined screening bands, not universal venture-capital classifications.
8. **Reconcile counts on refresh.** Record the source extraction date and verify row counts, distinct `Company_ID` counts, missing-value counts and relationship counts after each export.

## 7. Refresh checklist

- [ ] Confirm the source table and extraction date.
- [ ] Re-run the SQL preparation and export `Fact_Unicorn.csv` and `Bridge_Investors.csv` from the same refresh.
- [ ] Confirm `Company_ID` is unique in the fact table.
- [ ] Confirm each bridge row has a matching fact-table `Company_ID`.
- [ ] Confirm company-investor pairs are distinct in the bridge table.
- [ ] Confirm Power Query data types match the suggested types in this dictionary.
- [ ] Reconcile total rows, distinct companies, null funding, invalid durations and investor relationship counts.
- [ ] Refresh Power BI and verify that company-level KPIs use the fact table rather than bridge-row counts.
