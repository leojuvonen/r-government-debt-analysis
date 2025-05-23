# Government Debt's Impact on Private Consumption - Time Series Analysis in R

This project contains the core components of my master's thesis studying the effect of government debt on private consumption using R.


## Overview

- **Objective**: To assess whether government debt affects private consumption, and whether the effect is positive, negative or non-linear.
- **Methods**: Stationarity testing, linear regression, vector autoregression (VAR) and panel smooth transition regression (PSTR)
- **Tools**: R ( notably 'urca', 'forecast', 'vars', 'ggplot2', and 'PSTR among others)

## Project Structure

 <code> r-government-debt-analysis/ 
  ├── data/ # Sample or anonymized datasets 
  ├── scripts/ # R scripts used in the analysis 
  ├── output/ # Generated plots and tables
  ├── report/ # PDF or summary of the thesis 
  └── README.md # Project overview and usage instructions </code> </code></pre>


## Getting Started

### Requirements

This project was developed using R (version X.X.X). To run the analysis, you’ll need the following R packages installed:

```r
install.packages(c("forecast", "urca", "vars", "ggplot2", "dplyr", "readr"))
# The 'PSTR' package may require installation from GitHub or other sources.
# devtools::install_github("user/PSTR")
```

## Stationarity tests

The analysis begins with evaluating the stationarity of the variables. The variables inluded in the analysis are Government Debt to GDP ratio (DBTP), private consumption (PCON) and GDP (GDP). The code is included in the scripts folder as debt_stationarity.R. The results were collected manually and included in the following table.

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

The results suggest that the variables are mostly unstationary before differencing. The test values were not statistically significant except for a few exceptions. The symbol Δ represents differencing and the tests were all significant at 99% level. 
