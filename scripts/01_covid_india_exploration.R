# 01_covid_india_exploration.R

# Load packages
library(readr)

# 1. Load data (update path as needed)
Covid <- read_csv("Covid19 India (Jan 20 - Mar 20).csv")

# 2. Inspect structure and basic summaries
str(Covid)
head(Covid)
summary(Covid)

# Dimensions and variable types
nrow(Covid)       # number of rows
ncol(Covid)       # number of columns
dim(Covid)        # rows × columns
colnames(Covid)   # variable names

sum(sapply(Covid, is.numeric))   # count numeric variables
sum(sapply(Covid, is.character)) # count character variables

# 3. Convert Date from character ("dd-mm-YYYY") to Date class
Covid$Date <- as.Date(Covid$Date, format = "%d-%m-%Y")
str(Covid)

# Date range
min(Covid$Date)
max(Covid$Date)

# 4. States / union territories
unique(Covid$`State/UnionTerritory`)
length(unique(Covid$`State/UnionTerritory`))

state_freq <- table(Covid$`State/UnionTerritory`)
state_freq

which.max(state_freq)            # index of most frequent state
names(which.max(state_freq))     # name of most frequent state

# 5. Frequency analysis of recoveries

# Create binary variable: has_recovery = 1 if Cured > 0, else 0
Covid$has_recovery <- ifelse(Covid$Cured > 0, 1, 0)

head(Covid[, c("Date", "State/UnionTerritory", "Cured", "has_recovery")])

# Frequency table: recoveries vs no recoveries
recovery_freq <- table(Covid$has_recovery)
recovery_freq

# Proportions and percentages
recovery_prop <- prop.table(recovery_freq)
recovery_prop

round(recovery_prop * 100, 1)    # percentages

# 6. Frequency analysis of deaths

# Binary indicator: has_deaths = 1 if Deaths > 0, else 0
Covid$has_deaths <- ifelse(Covid$Deaths > 0, 1, 0)

death_freq <- table(Covid$has_deaths)
death_freq

# Factor version with labels
Covid$has_deaths_factor <- factor(
  Covid$has_deaths,
  levels = c(0, 1),
  labels = c("No Deaths", "Deaths Reported")
)

table(Covid$has_deaths_factor)

# 7. Total confirmed cases and case level categories

# Row-wise total confirmed cases (Indian + foreign nationals)
Covid$total_confirmed <- Covid$ConfirmedIndianNational + Covid$ConfirmedForeignNational

# Create categorical case_level using dplyr::mutate() and case_when()
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

# Inspect distribution and a few rows

table(Covid$case_level)
head(Covid[, c("Date", "State/UnionTerritory", "total_confirmed", "case_level")])

# 8. State reporting frequency and top 10 states

state_freq <- table(Covid$`State/UnionTerritory`)
state_freq

state_freq_sorted <- sort(state_freq, decreasing = TRUE)
state_freq_sorted

top10_states <- head(state_freq_sorted, 10)
top10_states
