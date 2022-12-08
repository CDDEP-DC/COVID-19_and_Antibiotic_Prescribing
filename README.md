# COVID-19_and_Antibiotic_Prescribing
Code and data for the manuscript "COVID-19 and Antibiotic Prescribing: A County-level Analysis"

FOLDERS
1. Data
2. Code
3. Results

WORKFLOW
1. Replace "[Main file path]" in all files in Code folder
2. IQVIA_2017_2020_byCounty.py reads files in Data folder and outputs Data/IQVIA_2017_2020_byCounty_forRegression.csv. NOTE: IQVIA data with zip codes will not load (line 70) to preserve anonymity. Data/IQVIA_2017_2020_byCounty_forRegression.csv aggregates data at the county level.
3. IQVIA_AgeClass_byState.py reads files in the Data folder and outputs Data/IQVIA_AgeClass_byState.csv, which is used to generate figures.
4. IQVIA_COVID_PanelRegression.do reads Data/IQVIA_2017_2020_byCounty_forRegression.csv, runs the regression, and outputs Data/finaldataset.dta, Data/IQVIA_2017_2020_byCounty_forFigures.csv, Results/iqvia_covid_regression_trx_mch.xls (Table 2 and Supplementary Table 6), Results/iqvia_covid_regression_children_trx_mch.xls (Table 2 and Supplementary Table 6), Results/iqvia_covid_regression_trx_edu.xls (Supplementary Table 8), Results/iqvia_covid_regression_children_trx_edu.xls (Supplementary Table 8), and Results/iqvia_covid_regression_ddd_mch.xls (Supplementary Table 7). IQVIA_COVID_PanelRegression.do also generates descriptive statistics (Table 1 and Supplementary Table 5).
5. IQVIA_COVID_ManuscriptFigures.R generates Figures 1 and 2.
6. IQVIA_COVID_SupplementFigures.R generates Supplementary Figures 1 and 2. 
