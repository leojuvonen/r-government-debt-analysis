#### panel regression
library(dplyr)
library(tidyr)
library(readxl)
library(plm)

data <- read_excel("data/debt_data.xlsx")
TIME <- data$TIME[-1]

data_diff <- data.frame(TIME = data$TIME[-1], diff(as.matrix(data[, -1])))

data_diff$Q1 <- ifelse(grepl("Q1", data_diff$TIME), 1, 0)
data_diff$Q2 <- ifelse(grepl("Q2", data_diff$TIME), 1, 0)
data_diff$Q3 <- ifelse(grepl("Q3", data_diff$TIME), 1, 0)
data_diff$Q4 <- ifelse(grepl("Q4", data_diff$TIME), 1, 0)

data_long <- data_diff %>%
  pivot_longer(
    cols = -c(TIME, Q1, Q2, Q3, Q4),          # All columns except TIME and quarters
    names_to = c("variable", "Country"),
    names_sep = "_"
  ) %>%
  pivot_wider(
    names_from = variable,  # distinguish between different variables
    values_from = value
  ) %>%
  rename_with(~paste0(., "_diff"), starts_with("con") | starts_with("dbtp") | starts_with("gdp"))

pdata <- pdata.frame(data_long, index = c("Country", "TIME"))

preg1 <- plm(con_diff ~ dbtp_diff, data=pdata)
summary(preg1)

preg2 <- plm(con_diff ~ dbtp_diff + Q2 + Q3 + Q4, data=pdata)
summary(preg2)

preg3 <- plm(con_diff ~ dbtp_diff + Q2 + Q3 + Q4 + gdp_diff, data=pdata)
summary(preg3)

preg4 <- plm(con_diff ~ dbtp_diff + Q2 + Q3 + Q4 + gdp_diff + exp(dbtp_diff), data=pdata)
summary(preg4)
