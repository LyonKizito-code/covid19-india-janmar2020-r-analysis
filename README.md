# COVID-19 India (Jan–Mar 2020) – R Exploratory Analysis

This repository contains an exploratory analysis of early COVID‑19 cases in India (January–March 2020) using a small state‑wise daily dataset. The focus is on **descriptive statistics**, **date handling**, **frequency analysis**, and **basic visualisation** using base R plus readr/dplyr.

## Dataset

- Source: Kaggle – "A Small COVID-19 Dataset" (Indian states, Jan–Mar 2020).
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
  - At least one recovery: ~20.4% of reports.

### 5. Frequency analysis of deaths

Goal: mirror the recovery analysis for death reporting.

#### 5.1 Binary and factor variables for deaths

```r
# Binary indicator: any deaths on a state–day
Covid$has_deaths <- ifelse(Covid$Deaths > 0, 1, 0)

death_freq <- table(Covid$has_deaths)
death_freq

# Labeled factor version for readability
Covid$has_deaths_factor <- factor(
  Covid$has_deaths,
  levels = c(0, 1),
  labels = c("No Deaths", "Deaths Reported")
)

table(Covid$has_deaths_factor)
```

**Results:**

- Counts:
  - `No Deaths`: 245 state–day reports
  - `Deaths Reported`: 25 state–day reports.

### 6. Case severity categories (`case_level`)

Goal: classify each state–day into four levels based on total confirmed cases (Indian + foreign nationals):

- No Cases = 0 cases
- Low Cases = 1–5 cases
- Medium Cases = 6–15 cases
- High Cases = 16+ cases.

#### 6.1 Total confirmed cases per row

```r
Covid$total_confirmed <- Covid$ConfirmedIndianNational + Covid$ConfirmedForeignNational
```

This is a **row‑wise** calculation: for each state–day, `total_confirmed` is the sum of Indian and foreign confirmed cases on that date in that state.

#### 6.2 Create `case_level` using dplyr + case_when

```r
library(dplyr)

Covid <- Covid |>
  mutate(
    case_level = case_when(
      total_confirmed == 0                          ~ "No Cases",
      total_confirmed >= 1 & total_confirmed <= 5   ~ "Low Cases",
      total_confirmed >= 6 & total_confirmed <= 15  ~ "Medium Cases",
      total_confirmed > 15                          ~ "High Cases"
    )
  )

table(Covid$case_level)
```

**Results:**

- `Low Cases`: 177 state–day reports (~65.6%).
- `Medium Cases`: 61 state–day reports (~22.6%).
- `High Cases`: 32 state–day reports (~11.9%).
- `No Cases`: 0 state–day reports.

### 7. State reporting frequency bar chart

Using the state/UT field, a bar chart was drawn from the frequency table `state_freq`:

```r
state_freq <- table(Covid$`State/UnionTerritory`)

barplot(state_freq,
        las = 2,
        col = "steelblue",
        main = "Frequency of COVID-19 Reports by State/UT",
        xlab = "State / Union Territory",
        ylab = "Number of state-day reports")
```

![Bar chart of report frequency by state/UT](plots/BarChart.png)

### 8. Case severity pie chart

The `case_level` variable was summarised with a pie chart:

```r
case_freq <- table(Covid$case_level)

pie(case_freq,
    main = "Distribution of Case Severity Levels",
    col = c("gray80", "lightblue", "orange", "red"))
```

![Pie chart of case severity levels](plots/PieChart.png)

### 9. Histogram of recovery numbers

The distribution of the `Cured` variable was explored with a histogram:

```r
hist(Covid$Cured,
     main = "Distribution of Recovery Numbers (Cured)",
     xlab = "Number of recoveries on a state-day",
     ylab = "Frequency",
     col = "lightgreen",
     border = "darkgreen")
```

![Histogram of recovery counts per state-day](plots/Histogram.png)

### 10. Line chart of total confirmed cases over time

Total confirmed cases across all states were aggregated by date and plotted as a time series:

```r
Covid$total_confirmed <- Covid$ConfirmedIndianNational + Covid$ConfirmedForeignNational

total_by_date <- aggregate(total_confirmed ~ Date, data = Covid, sum)

plot(total_by_date$Date, total_by_date$total_confirmed,
     type = "l",
     col = "blue",
     lwd = 2,
     main = "Trend of Total Confirmed Cases Over Time",
     xlab = "Date",
     ylab = "Total confirmed cases (all states combined)")
```

![Line chart of total confirmed cases over time](plots/LineChart.png)

### 11. State reporting frequency and top 10 states

Using the same frequency table:

```r
state_freq <- table(Covid$`State/UnionTerritory`)
state_freq_sorted <- sort(state_freq, decreasing = TRUE)
top10_states <- head(state_freq_sorted, 10)

state_freq_sorted
top10_states
```
