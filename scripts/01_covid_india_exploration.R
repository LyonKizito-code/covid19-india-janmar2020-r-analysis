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
