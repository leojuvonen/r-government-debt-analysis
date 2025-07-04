# Government Debt's Impact on Private Consumption - Time Series Analysis in R


## Overview

This project contains the core components of my master's thesis studying the effect of government debt on private consumption using R.
**Objective** of the project is to assess whether government debt affects private consumption, and whether the effect is positive, negative or non-linear. **Methods** used in the project consist of stationarity testing, panel regression, and panel smooth transition regression (PSTR).

## Data Source

The data used in the project was gathered from Eurostat and consists of debt per gdp, private consumption and gdp data. The dataset consists of 28 European countries. The data is quarterly and falls within the timeframe 2000-2024, making the number of observations 98 per country before possible differentation. The data is located in the data folder as debt_data.xlsx.

## Tools

- Excel - data cleaning and preparation
- R - data analysis (packages: "readxl", "zoo", "urca", "dplyr", "tidyr", "plm", "devtools", "snowfall" and "PSTR"))

## Project Structure

 <code> r-government-debt-analysis/ 
  ├── data/ # Sample or anonymized datasets 
  ├── scripts/ # R scripts used in the analysis 
  └── README.md # Project overview and usage instructions </code> </code></pre>


## Getting Started

### Requirements

This project was developed using R (version 4.4.2). To run the analysis, you’ll need the following R packages installed:

```r
install.packages(c("readxl", "zoo", "urca", "dplyr", "tidyr", "plm", "devtools", "snowfall"))
# The 'PSTR' package requires installation from GitHub or other sources.
# devtools::install_github("user/PSTR")
```

## Stationarity tests

To start I load the data set, set the TIME variable to quarterly time series format and divide the countries into two groups to make the results fit in the console.

```r

library(readxl)
# Load data
data <- read_excel("data/debt_data.xlsx")

library(zoo)
# Convert TIME to quarterly time series format
data$TIME <- as.yearqtr(data$TIME, "%Y-Q%q")

# Countries grouped for analysis
group1 <- c("Belgium", "Bulgaria", "Czechia", "Denmark", "Germany", "Estonia", "Ireland", "Greece", 
            "Spain", "France", "Croatia", "Italy", "Cyprus", "Latvia")

group2 <- c("Lithuania", "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria", "Poland", 
            "Portugal", "Romania", "Slovenia", "Slovakia", "Finland", "Sweden", "Norway")

countries <- c(group1, group2)

```

The analysis begins with evaluating the stationarity of the variables. The variables inluded in the analysis are Government Debt to GDP ratio (DBTP), private consumption (PCON) and GDP (GDP). The stationairty tests will first be conducted on non-differenced data. After that the data will be differenced and the same tests will be conducted. The code that provides the results to all the time series' stationarity tests per country is as follows: 

```r
library(urca)

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
data_diff <- data.frame(TIME = data$TIME[-1], diff(as.matrix(data[, -1])))

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
```



The results were collected manually and included in the following table.

| Maa        | DBTP       | PCON       | GDP        | ΔDBTP       | ΔPCON       | ΔGDP        |
|------------|------------|------------|------------|-------------|-------------|-------------|
| Belgia     | -2.2343    | 0.6106     | 0.6054     | -7.5136***  | -8.7745***  | -8.5758***  |
| Bulgaria   | -4.4681*** | -0.9281    | -0.272     | -5.1492***  | -19.4766*** | -14.7005*** |
| Tšekki     | -2.2603    | 0.2903     | 0.2278     | -7.7567***  | -8.3163***  | -9.0981***  |
| Tanska     | -1.9179    | 0.1724     | 0.4053     | -6.068***   | -9.0548***  | -6.8955***  |
| Saksa      | -1.4809    | 0.3032     | 0.3392     | -5.224***   | -10.2161*** | -13.4316*** |
| Viro       | 0.4074     | 0.9732     | 0.2664     | -6.6714***  | -7.7447***  | -8.5912***  |
| Irlanti    | -0.958     | 0.0999     | 0.4321     | -3.1091**   | -9.4776***  | -7.2456***  |
| Kreikka    | -1.1088    | -3.9793*** | -2.439     | -5.4994***  | -25.0471*** | -12.7869*** |
| Espanja    | -0.6999    | -0.3632    | -0.1559    | -4.1359***  | -7.4098***  | -7.0338***  |
| Ranska     | -0.6442    | -0.0675    | 0.0158     | -6.3947***  | -10.8421*** | -9.1931***  |
| Kroatia    | -1.5342    | -4.2308*** | -1.6279    | -4.3753***  | -17.7234*** | -25.1575*** |
| Italia     | -0.9666    | -1.1689    | -1.078     | -6.9468***  | -12.9589*** | -9.6485***  |
| Kypros     | -1.4477    | -1.4779    | -0.3243    | -6.3843***  | -21.1124*** | -11.7298*** |
| Latvia     | -0.9986    | -0.2661    | -0.2549    | -4.7962***  | -11.7686*** | -11.1427*** |
| Liettua    | -1.0569    | 0.3678     | 0.3071     | -5.8827***  | -11.032***  | -15.4245*** |
| Luxemburg  | -0.6843    | 1.4776     | -0.2758    | -8.265***   | -8.7499***  | -9.1891***  |
| Unkari     | -1.5981    | 0.2111     | -0.2694    | -7.6584***  | -8.3501***  | -9.7682***  |
| Malta      | -0.5764    | -0.9121    | 1.1088     | -6.3216***  | -18.1637*** | -12.7411*** |
| Alankomaat | -1.0007    | 2.489      | 3.3872     | -5.8329***  | -7.2284***  | -5.3657***  |
| Itävalta   | -1.9646    | -0.8166    | -0.0571    | -8.5836***  | -14.6769*** | -9.7629***  |
| Puola      | -2.3755    | 2.315      | 0.5917     | -5.7161***  | -6.0717***  | -9.8827***  |
| Portugali  | -1.5827    | -0.1054    | 0.6807     | -4.8706***  | -11.4073*** | -9.3532***  |
| Romania    | 0.3444     | -0.7765    | -1.1534    | -3.8906***  | -12.0328*** | -14.1433*** |
| Slovenia   | -0.9113    | -0.7589    | 0.5203     | -4.9256***  | -12.2195*** | -10.3577*** |
| Slovakia   | -0.7564    | 0.7982     | -0.2576    | -5.8126***  | -9.8213***  | -16.7126*** |
| Suomi      | 0.5813     | -0.6971    | -0.6951    | -6.296***   | -9.6245***  | -8.4141***  |
| Ruotsi     | -1.3441    | -0.3591    | -0.5526    | -7.5084***  | -6.7751***  | -6.0344***  |
| Norja      | -2.6754*   | -1.5894    | -2.1673    | -7.8034***  | -7.3108***  | -6.9618***  |

---

* (*): Statistically significant at 90% level  
* (**): Statistically significant at 95% level  
* (***): Statistically significant at 99% level  

The results suggest that the variables are mostly unstationary before differencing. The test values were not statistically significant except for a few exceptions. The symbol Δ represents differencing and the tests were all significant at 99% level on the differenced variables. 

The full code is provided in the scripts folder as debt_stationarity.R.

## Regression Analysis

Now that the variables are stationary we can move on in the analysis. We will build four panel regression models and assess which sufficiently describes our data. The models are as follows:

**Model 1**

$$
\Delta PCON_{it} = \beta_1 \Delta DBTP_{it} + a_i + u_{it}
$$

**Model 2**

$$
\Delta PCON_{it} = \beta_1 \Delta DBTP_{it} + \beta_2 Q2 + \beta_3 Q3 + \beta_4 Q4 + a_i + u_{it}
$$

**Model 3**

$$
\Delta PCON_{it} = \beta_1 \Delta DBTP_{it} + \beta_2 Q2 + \beta_3 Q3 + \beta_4 Q4 + \beta_5 \Delta GDP + a_i + u_{it}
$$

**Model 4**

$$
\Delta PCON_{it} = \beta_1 \Delta DBTP_{it} + \beta_2 Q2 + \beta_3 Q3 + \beta_4 Q4 + \beta_5 \Delta GDP + \beta_6 (\Delta DBTP_{it})^2 + a_i + u_{it}
$$

Model 1 is a simple univariate model with private consumption as the dependent variable and government debt as the independent variable. Model 2 builds on this by adding dummy variables for all quarters, controlling for seasonality in the data. Model 3 adds GDP as a control variable. Finally model 4 adds government debt as a squared value to account for possible non-linearity. 

The code that adds the needed variables, modifies the dataframes format to fit panel regression and computes the panel regression models is as follows:

```r
# add quarterly dummy variables to control for seasonality

data_diff$Q1 <- ifelse(grepl("Q1", data_diff$TIME), 1, 0)
data_diff$Q2 <- ifelse(grepl("Q2", data_diff$TIME), 1, 0)
data_diff$Q3 <- ifelse(grepl("Q3", data_diff$TIME), 1, 0)
data_diff$Q4 <- ifelse(grepl("Q4", data_diff$TIME), 1, 0)

# Change the data into long format
library(dplyr)
library(tidyr)

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

# change the data into a panel format
library(plm)
pdata <- pdata.frame(data_long, index = c("Country", "TIME"))

# compute the panel regression models

#Model 1
preg1 <- plm(con_diff ~ dbtp_diff, data=pdata)
summary(preg1)

#Model 2
preg2 <- plm(con_diff ~ dbtp_diff + Q2 + Q3 + Q4, data=pdata)
summary(preg2)

#Model 3
preg3 <- plm(con_diff ~ dbtp_diff + Q2 + Q3 + Q4 + gdp_diff, data=pdata)
summary(preg3)

#Model 4
preg4 <- plm(con_diff ~ dbtp_diff + Q2 + Q3 + Q4 + gdp_diff + exp(dbtp_diff), data=pdata)
summary(preg4)

```

Here are the results of all the panel regression models:

| Variable        | Model 1       | Model 2       | Model 3       | Model 4       |
| --------------- | ------------- | ------------- | ------------- | ------------- |
| ΔDBTP           | -250.87\*\*\* | -196.03\*\*\* | -174.86\*\*\* | -177.93\*\*\* |
|                 | (36.37)       | (34.96)       | (34.77)       | (35.48)       |
| Q2              | -             | 3507.73\*\*\* | 2639.88\*\*\* | 2636.70\*\*\* |
|                 |               | (237.71)      | (265.07)      | (265.21)      |
| Q3              | -             | 3263.72\*\*\* | 2719.96\*\*\* | 2715.10\*\*\* |
|                 |               | (241.44)      | (251.07)      | (251.35)      |
| Q4              | -             | 3070.19\*\*\* | 2120.10\*\*\* | 2117.20\*\*\* |
|                 |               | (241.67)      | (273.97)      | (274.10)      |
| ΔGDP            | -             | -             | 1.29\*\*\*    | 1.29\*\*\*    |
|                 |               |               | (0.18)        | (0.18)        |
| (ΔDBTP)²        | -             | -             | -             | 0.0001        |
|                 |               |               |               | (0.0003)      |
| **Adjusted R²** | 0.007         | 0.101         | 0.117         | 0.117         |

---

* (*): Statistically significant at 90% level  
* (**): Statistically significant at 95% level  
* (***): Statistically significant at 99% level  

Model 3 seems to be the most fitting, because adding ΔGDP raises the adjusted $R^2$ slightly and the variable itself is statistically significant. Adding the squared government debt doesn't seem to have any impact so it is safe to say that Model 3 is sufficent. According to all the models, government debts effect on private consumption seems to be negative and the effect is statistically significant.

The full code is provided in the scripts folder as debt_preg.R.

## Panel Smooth Transition Regression (PSTR)

The PSTR model is based on the third regression model which was assessed as the most descriptive. The model is presented mathematically as follows:

$$
\begin{aligned}
\Delta PCON_{it} &= \mu_i + \lambda_t + \beta_{1}\Delta DBTP_{it} + \phi_1 Q2 + \theta_1 Q3 + \delta_1 Q4 + \psi_1 \Delta BKT_{it} \\
&\quad + \left[ \beta_2 \Delta DBTP_{it} + \phi_2 Q2 + \theta_2 Q3 + \delta_2 Q4 + \psi_2 \Delta BKT_{it} \right] g(DBTP_{it}; \gamma, c)
\end{aligned}
$$


The process starts by assessing the linearity (or homogeneity) and number of transitions in the model.

### Homogeneity Tests by Transition Variable $DBTP$

```r
# start by building the PSTR model by using the panel regression model from before as the base

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

```

#### Results of Linearity (Homogeneity) Tests

| $m$ | $\text{LM}_X$ | p-value | $\text{LM}_F$ | p-value | $\text{HAC}_X$ | p-value | $\text{HAC}_F$ | p-value | WB_PV | WCB_PV |
|-----|---------------|---------|---------------|---------|----------------|---------|----------------|---------|--------|---------|
| 1   | 198.3         | 0       | 39.1          | 0       | 7.557          | 0.1824  | 1.49           | 0.1896  | 0      | 0       |

---

#### Series of Homogeneity Tests to Select Number of Transitions $m$

| $m$ | $\text{LM}_X$ | p-value | $\text{LM}_F$ | p-value | $\text{HAC}_X$ | p-value | $\text{HAC}_F$ | p-value | WB_PV | WCB_PV |
|-----|---------------|---------|---------------|---------|----------------|---------|----------------|---------|--------|---------|
| 1   | 198.3         | 0       | 39.1          | 0       | 7.557          | 0.1824  | 1.49           | 0.1896  | 0      | 0       |



The homogeneity tests based on the transition variable DBTP partly reject linearity. While the Lagrange Multiplier tests show significant results, the HAC-consistent tests do not—raising concerns about heteroskedasticity and autocorrelation. The number of transitions is also debated across tests. To resolve these inconsistencies, Wild Bootstrap (WB) and Wild Cluster Bootstrap (WCB) methods are used, which consistently reject the null hypothesis. Thus, linearity can reasonably be rejected, and one transition is considered sufficient.

### Results of the PSTR Model

Next the parameters of the PSTR model will be assessed.

```r
### Results of the PSTR model

#gather the min and max values of the dbtp variable and place them as vLower and vUpper
summary(data_pstr$dbtp)

pstr_nln = EstPSTR(use = pstr, im=1, iq="dbtp", vLower= 3.6, vUpper = 215.9)
print(pstr_nln)
```

#### Parameter Estimates

| Variable        | Regime 1       | Regime 2       |
|-----------------|----------------|----------------|
| $\Delta DBTP$   | -127.20 ***     | -183.50 *       |
|                 | (42.25)        | (99.18)        |
| Q2              | 2362           | 895.6          |
|                 | (1493)         | (1707.0)       |
| Q3              | 2037           | 4244 ***        |
|                 | (1246)         | (1426)         |
| Q4              | 2712           | -4394          |
|                 | (1722)         | (3046)         |
| $\Delta BKT$    | 0.7571         | 7.642 ***       |
|                 | (0.4943)       | (1.948)        |

---

#### Transition Parameters

| Parameter       | Value (Standard Error)   |
|----------------|--------------------------|
| $\gamma$        | 2.644 (3.155)             |
| $c$             | 99.690 *** (1.694)        |

---

**N = 2716**

> \* Statistically significant at the 90% level  
> \*\* Statistically significant at the 95% level  
> \*\*\* Statistically significant at the 99% level


The PSTR model describes a negative relationship between government debt and private consumption. In the first regime, this negative effect is statistically significant at the 99% level and is relatively strong. In the second regime, the negative impact appears even more pronounced but is only significant at the 90% level, making its quantification less reliable. The transition parameters indicate that while the threshold parameter (c) is statistically significant at 99.690 (suggesting a debt-to-GDP ratio of 99.69% as the threshold), the gamma parameter is relatively low and not statistically significant, implying a steep but statistically uncertain transition between regimes.


### Model Diagnostic Tests

In the final stage of the analysis, the model's adequacy is evaluated. The diagnostic tests examine the stability of the estimated parameters and any residual nonlinearity in the model. The null hypothesis of the first test is that the parameters remain stable over time. For the second test, the null hypothesis is that no residual nonlinearity remains in the model—in other words, the model satisfactorily captures the prevailing nonlinearity. 

```r
### Evaluation tests

pstr_eval = EvalTest(use=pstr_nln,vq=pstr_nln$mQ[,1])
print(pstr_eval)

pstr_evalPC = WCB_TVTest(use=pstr_eval, iB=100, parallel=T, cpus=6)
pstr_evalPC

pstr_evalNonLin = WCB_HETest(use=pstr_eval, vq=pstr$mQ[,1], iB=100, parallel=T, cpus=6)
pstr_evalNonLin

```

The results are shown in the following tables.

#### Parameter Stability Test Results

| $m$ | $\text{LM}_X$ | p-value | $\text{LM}_F$ | p-value | $\text{HAC}_X$ | p-value | $\text{HAC}_F$ | p-value | WB\_PV       |WCB\_PV      |
|-----|---------------|---------|---------------|---------|----------------|---------|----------------|---------|---------|---------|
| 1   | 82.92         | 0.000   | 8.146         | 0.000   | 11.32          | 0.3334  | 1.112          | 0.349   |0.79    |   0.99    |


---

#### Test for No Residual Nonlinearity

| $m$ | $\text{LM}_X$ | p-value | $\text{LM}_F$ | p-value | $\text{HAC}_X$ | p-value | $\text{HAC}_F$ | p-value | WB\_PV       |WCB\_PV      |
|-----|---------------|---------|---------------|---------|----------------|---------|----------------|---------|---------|---------|
| 1   | 53.25         | 0.000   | 5.231         | 0.000   | 13.87          | 0.179   | 1.362          | 0.1915  | 1        |  1     |

---

The interpretation of these results is initially challenging, as the LM tests and the HAC tests yield conflicting outcomes in both cases. The LM tests reject parameter stability and indicate that there is nonlinearity in the data that the model fails to capture. However, the WB and WCB tests support the null hypotheses, suggesting that the model's parameters are stable over time and that the model adequately accounts for the nonlinearity.

The full code is provided in the scripts folder as debt_pstr.R.


## Conclusion

### Regression Results
- **Panel Regressions:**  
  - The analyses consistently show statistically significant negative coefficients for government debt on private consumption.
  - There is no evidence of a statistically significant positive impact on private consumption.

### PSTR Model Results
- A statistically significant threshold is identified at a government debt-to-GDP ratio of 99.69%.
- **First Regime:**  
  - Government debt has a statistically significant negative effect on private consumption.
- **Second Regime:**  
  - The negative effect becomes stronger, but it is statistically significant only at the 90% level, making it less reliably quantified.















