# COVID-19 India (Jan–Mar 2020) – R Exploratory Analysis

This repository contains an exploratory analysis of early COVID‑19 cases in India (January–March 2020) using a small state‑wise daily dataset. The focus is on **descriptive statistics**, **date handling**, and **frequency analysis of recoveries** using base R and the readr package.

## Dataset

- Source: Kaggle – "COVID-19 India Dataset (January 2020 - March 2020)" (small subset of early reports).
- Structure: 270 rows × 7 columns (state–date level reports):
  - `Sno`: serial number (numeric)
  - `Date`: report date (character converted to Date)
  - `State/UnionTerritory`: Indian state / union territory name (character)
  - `ConfirmedIndianNational`: confirmed cases among Indian nationals (numeric)
  - `ConfirmedForeignNational`: confirmed cases among foreign nationals (numeric)
  - `Cured`: recovered cases (numeric)
  - `Deaths`: deaths (numeric)

The raw CSV is **not** included in this repo; you can download it from Kaggle and place it locally if you want to reproduce the analysis.

## Analysis steps

All analysis is demonstrated in **R 4.6.0**. The core script is `scripts/01_covid_india_exploration.R`.

### 1. Load and inspect the data

Key commands used:

```r
library(readr)
Covid <- read_csv("Covid19 India (Jan 20 - Mar 20).csv")

str(Covid)
head(Covid)
summary(Covid)

nrow(Covid)     # number of rows
ncol(Covid)     # number of columns
dim(Covid)      # rows × columns
colnames(Covid) # variable names

sum(sapply(Covid, is.numeric))   # count numeric variables
sum(sapply(Covid, is.character)) # count character variables
```

**Findings:**

- 270 observations, 7 variables.
- 5 numeric variables and 2 character variables.
- `Date` initially imported as character.

### 2. Convert Date to proper Date type

The `Date` column is stored as strings like `"30-01-2020"` (day–month–year). This is converted to a proper Date class using `as.Date()` with an explicit format string:

```r
Covid$Date <- as.Date(Covid$Date, format = "%d-%m-%Y")
str(Covid$Date)
```

After conversion, `Date` is a `Date` vector, enabling date‑based summaries.

**Date range:**

```r
min(Covid$Date)
max(Covid$Date)
```

- Earliest report: 2020‑01‑30
- Latest report: 2020‑03‑21

### 3. Basic descriptive statistics and structure

Unique states and their counts:

```r
unique_states <- unique(Covid$`State/UnionTerritory`)
length(unique_states)              # number of unique states/UTs
state_freq <- table(Covid$`State/UnionTerritory`)

most_frequent_state <- names(which.max(state_freq))
```

**Findings:**

- 27 distinct states / union territories in this subset.
- Kerala appears most frequently in the dataset (most state–day records), reflecting its early importance in the Indian outbreak.

### 4. Frequency analysis of recoveries

Goal: understand how often state–day reports included **any recoveries**.

#### 4.1 Create a binary `has_recovery` variable

```r
Covid$has_recovery <- ifelse(Covid$Cured > 0, 1, 0)

head(Covid[, c("Date", "State/UnionTerritory", "Cured", "has_recovery")])
```

- `has_recovery = 1` if there was at least one recovery (`Cured > 0`) on that date in that state.
- `has_recovery = 0` otherwise.

#### 4.2 Frequency table and proportions

```r
recovery_freq <- table(Covid$has_recovery)
recovery_freq

recovery_prop <- prop.table(recovery_freq)
recovery_percent <- round(recovery_prop * 100, 1)
recovery_percent
```

**Results:**

- Counts:
  - `has_recovery = 0`: 215 state–day reports
  - `has_recovery = 1`: 55 state–day reports
- Percentages:
  - No recoveries: ~79.6% of reports
  - At least one recovery: ~20.4% of reports

Interpretation:

> In this early Jan–Mar 2020 window, only about one in five state‑level daily reports in India included recovery cases, while roughly four out of five reported zero recoveries. This reflects the very early epidemic stage: many cases were still active and recoveries were relatively rare.

## Additional R practice (Week 2 context)

In the same session, some core R concepts were practiced on small toy examples:

- **Vectors and operations**: creating numeric vectors, checking type (`is.vector`, `class`, `str`, `length`), and performing arithmetic.
- **Matrices**: building a matrix with `seq()` and `matrix()`, indexing elements, and using `which(..., arr.ind = TRUE)` to find positions.
- **Random sampling**: using `sample()` to generate random integers and `runif()` + `floor()` for uniform random numbers.
- **Apply family**:
  - `apply(students[, c("english", "math")], 1, sum)` for row‑wise totals.
  - `lapply(students, sum)` and `sapply(students, sum)` for column‑wise summaries.
- **Factors**: creating labeled categorical variables with `factor()`:

  ```r
  gender <- c(1, 2, 1, 2, 2, 2, 1, 2)
  fac_gender <- factor(gender,
                       levels = c(1, 2),
                       labels = c("Male", "Female"))
  ```

These exercises support the main COVID analysis by reinforcing data structures, indexing, and summarisation skills.

## Reproducibility notes

To rerun the analysis:

1. Install R (4.6.0 or later) and RStudio.
2. Install required package:

   ```r
   install.packages("readr")
   ```

3. Download the CSV from Kaggle (Jan–Mar 2020 India COVID dataset) and update the file path in the script.
4. Run the commands in `scripts/01_covid_india_exploration.R` or copy-paste from the README into your R session.

## Next steps / possible extensions

In future iterations of this project, I plan to:

- Aggregate cases per state and compute total confirmed, recovered, and deaths over the period.
- Plot an early epidemic curve by date using base R or ggplot2.
- Compare recovery frequencies by state (e.g. proportion of state–day reports with at least one recovery).
- Extend the dataset beyond March 2020 for longer-term trend analysis.
