# Stationarity tests for government debt, consumption, and GDP data
# Data is quarterly and stored in 'data/data.xlsx'

library(readxl)
library(lubridate)
library(zoo)
library(dplyr)
library(urca)
library(ggplot2)
library(tidyr)

# Load data
data <- read_excel("data/debt_data.xlsx")

# Convert TIME to quarterly time series format
data$TIME <- as.yearqtr(data$TIME, "%Y-Q%q")

# Countries grouped for analysis
group1 <- c("Belgium", "Bulgaria", "Czechia", "Denmark", "Germany", "Estonia", "Ireland", "Greece", 
            "Spain", "France", "Croatia", "Italy", "Cyprus", "Latvia")

group2 <- c("Lithuania", "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria", "Poland", 
            "Portugal", "Romania", "Slovenia", "Slovakia", "Finland", "Sweden", "Norway")

countries <- c(group1, group2)

# Save results to a data frame

results <- data.frame()

for (country in countries) {
  for (var in c("dbtp", "con", "gdp")) {
    var_name <- paste0(var, "_", country)
    test <- ur.df(data[[var_name]], type = "drift", selectlags = "AIC")
    stat <- test@teststat[1]  # ADF test statistic for tau
    results <- rbind(results, data.frame(
      Country = country,
      Variable = var,
      ADF_statistic = round(stat, 4)
    ))
  }
}

# Function to perform ADF unit root test with automatic lag selection by AIC
run_adf_tests <- function(countries, var_prefix) {
  for (country in countries) {
    cat("\n###", country, " -", var_prefix, "###\n")
    var_name <- paste0(var_prefix, "_", country)
    cat("Unit root test\n")
    print(summary(ur.df(data[[var_name]], type = "drift", selectlags = "AIC")))
    cat("\n-------------------------------------------------\n")
  }
}

# Run ADF tests on debt variables for both groups
run_adf_tests(group1, "dbtp")
run_adf_tests(group2, "dbtp")

# Run ADF tests on consumption variables for both groups
run_adf_tests(group1, "con")
run_adf_tests(group2, "con")

# Run ADF tests on GDP variables for both groups
run_adf_tests(group1, "gdp")
run_adf_tests(group2, "gdp")


# DIFFERENCE DATA: first differences to achieve stationarity
data_diff <- data.frame(
  TIME = data$TIME[-1],  # remove first time point
  lapply(data[, -which(names(data) == "TIME")], diff)
)

# Save differenced data results to a new dataframe
results_diff <- data.frame()

for (country in countries) {
  for (var in c("dbtp", "con", "gdp")) {
    var_name <- paste0(var, "_", country)
    stat <- test@teststat[1]
    crit <- test@cval[1, ]
    results_diff <- rbind(results_diff, data.frame(
      Country = country,
      Variable = var,
      ADF_statistic = round(stat, 4)
    ))
  }
}


# Function to perform ADF unit root test with automatic lag selection by AIC for differenced data
run_adf_tests_diff <- function(countries, var_prefix, diff_data) {
  for (country in countries) {
    cat("\n###", country, "- differenced", var_prefix, "###\n")
    var_name <- paste0(var_prefix, "_", country)
    cat("Unit root test\n")
    print(summary(ur.df(diff_data[[var_name]], type = "drift", selectlags = "AIC")))
    cat("\n--------------------------------------\n")
  }
}

# Run ADF tests on differenced debt variables
run_adf_tests_diff(group1, "dbtp", data_diff)
run_adf_tests_diff(group2, "dbtp", data_diff)

# Run ADF tests on differenced consumption variables
run_adf_tests_diff(group1, "con", data_diff)
run_adf_tests_diff(group2, "con", data_diff)

# Run ADF tests on differenced GDP variables
run_adf_tests_diff(group1, "gdp", data_diff)
run_adf_tests_diff(group2, "gdp", data_diff)




