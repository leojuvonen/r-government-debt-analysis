############ PSTR

library(readxl)
data <- read_excel("data/debt_data.xlsx")

library(np) #install.packages("np")
library(plm) #install.packages("plm")
library(tidyverse) #install.packages("tidyverse")
#install.packages("devtools")
library(devtools)
#devtools::install_github("yukai-yang/PSTR")
library(PSTR) #install.packages("PSTR")
library(snowfall)


# difference data
data_pstr <- data.frame(TIME = data$TIME[-1], diff(as.matrix(data[, -1])))

# create dummy variables for quarters
data_pstr$Q1 <- ifelse(grepl("Q1", data_pstr$TIME), 1, 0)
data_pstr$Q2 <- ifelse(grepl("Q2", data_pstr$TIME), 1, 0)
data_pstr$Q3 <- ifelse(grepl("Q3", data_pstr$TIME), 1, 0)
data_pstr$Q4 <- ifelse(grepl("Q4", data_pstr$TIME), 1, 0)


countries <- c("Belgium", "Bulgaria", "Czechia", "Denmark", "Germany", "Estonia", "Ireland",
               "Greece", "Spain", "France", "Croatia", "Italy", "Cyprus", "Latvia",
               "Lithuania", "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria",
               "Portugal", "Poland", "Romania", "Slovenia", "Slovakia", "Finland",
               "Sweden", "Norway")

# transform data into long format
library(tidyr)
library(dplyr)

data_pstr <- data_pstr %>%
  pivot_longer(
    cols = -c(TIME, Q1, Q2, Q3, Q4),          
    names_to = c("variable", "Country"),
    names_sep = "_"
  ) %>%
  pivot_wider(
    names_from = variable,  
    values_from = value
  ) %>%
  rename_with(~paste0(., "_diff"), starts_with("con") | starts_with("dbtp") | starts_with("gdp"))

# add the non-differenced dbtp variable to the data_pstr dataframe
data_long <- data %>%
  pivot_longer(
    cols = -TIME,          
    names_to = c("variable", "Country"),
    names_sep = "_"
  ) %>%
  pivot_wider(
    names_from = variable,  
    values_from = value
  )
data_pstr$dbtp <- data_long$dbtp[-(1:28)]

#arrange dataframe
data_pstr <- data_pstr %>%
  arrange(Country, TIME)


# Let's start building the PSTR model by using the panel regression model from before as the base

pstr = NewPSTR(data_pstr, dep='con_diff',  # dependent variable
                indep = c( 'dbtp_diff',  'Q2', 'Q3', 'Q4', 'gdp_diff'),  # Explanatory variables
                tvars = 'dbtp',  # Transition variable
                im = 1, 
                iT = 97)


### Homogeneity tests

print(pstr,"summary")
summary(pstr)
plot(pstr$mQ, pstr$vY)
pstr_lin=LinTest(use=pstr)
print(pstr_lin, "tests")
# bootstraps
pstr_test = WCB_LinTest(use=pstr_lin,iB=100,parallel=T,cpus=6)
print(pstr_test, "tests")

### Results of the PSTR model

#gather the min and max values of the dbtp variable and place them as vLower and vUpper
summary(data_pstr$dbtp)

pstr_nln = EstPSTR(use = pstr, im=1, iq="dbtp", vLower= 3.6, vUpper = 215.9)
print(pstr_nln)



### Evaluation tests

pstr_eval = EvalTest(use=pstr_nln,vq=pstr_nln$mQ[,1])
print(pstr_eval)

pstr_evalPC = WCB_TVTest(use=pstr_eval, iB=100, parallel=T, cpus=6)
pstr_evalPC

pstr_evalNonLin = WCB_HETest(use=pstr_eval, vq=pstr$mQ[,1], iB=100, parallel=T, cpus=6)
pstr_evalNonLin






