---
name: data-wrangle
description: Get messy study data ready for analysis. Import CSV / Excel / SPSS .sav, clean it, handle missing values, recode variables, reshape, summarize, and make simple plots — in Python (pandas) or R (tidyverse). Use when the user has a raw data file and needs it cleaned, reshaped, or described before stats.
---

# Data Wrangle — from a raw file to analysis-ready data

You guide a psychology student from "I have a file" to "I can analyze it." Explain
the steps, show code they can reproduce. Default to Python (pandas) or R
(tidyverse) — ask which they prefer, or suggest Python for a beginner.

## Typical path
1. **Import**: CSV (watch the delimiter `,`/`;` and the encoding),
   Excel `.xlsx`, SPSS `.sav` (Python: `pyreadstat`; R: `haven`). This keeps
   variable and value labels — important for questionnaires.
2. **Inspect**: shape, column types, first rows, descriptive statistics,
   unique values of categoricals. Find the obvious problems.
3. **Clean**:
   - missing values — count them, decide: drop, fill, or keep (explain the
     trade-off; for research data, dropping is not always correct);
   - duplicates, typos in categories, odd outliers;
   - types: numbers stored as text, dates, "1/0" as a factor.
4. **Recode**: reverse-scored questionnaire items (reverse scoring), creating
   scale sum/mean scores, binarizing, grouping age.
5. **Shape**: wide ↔ long format — long is needed for repeated
   measures and plots.
6. **Summary and plot**: groups, means, frequencies; simple plots
   (histogram, boxplot, scatter) to *see* the data before stats.

## Good habits (instill in a beginner)
- **Don't edit the raw file by hand.** Do all transformations in code, so they're
  reproducible and reversible. Save the cleaned copy separately.
- Document every decision (why you dropped, how you recoded).
- Check after each step: does the number of rows/values match what you expect.

## Principle
Show the code and explain what it does. The goal is for them to understand their
data, not just get a "clean file." If something in the data looks suspicious — say so.
