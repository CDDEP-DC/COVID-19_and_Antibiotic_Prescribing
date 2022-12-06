# COVID-19 and Antibiotic Prescribing
# Process data for Figures 1 and 2 - Prescriptions by year, state, age, and class
# Created by Alisa Hamilton

import pandas as pd

OneDrive = "/Users/alisahamilton/Library/CloudStorage/OneDrive-SharedLibraries-CenterforDiseaseDynamics,Economics&Policy/Eili Klein - CDDEP Research Projects (active)/IMS/2017-2020 IQVIA Data"
state_abbr = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY']

years = ['2017','2018', '2019', '2020']
final_lst = []
for year in years:
    #print(line)
    data = pd.read_csv(OneDrive + '/1. Data/IQVIA_' + year + '_Disaggregated.csv')
    data.loc[data['AGE'] == '00-02', 'age_group'] = '0-2'
    data.loc[data['AGE'] == '03-09', 'age_group'] = '3-9'
    data.loc[data['AGE'] == '10-19', 'age_group'] = '10-19'
    data.loc[data['AGE'] == '20-39', 'age_group'] = '20-39'
    data.loc[data['AGE'] == '40-59', 'age_group'] = '40-59'
    data.loc[data['AGE'] == '60-64', 'age_group'] = '60-74'
    data.loc[data['AGE'] == '65-74', 'age_group'] = '60-74'
    data.loc[data['AGE'] == '75-84', 'age_group'] = '75+'
    data.loc[data['AGE'] == '85+', 'age_group'] = '75+'
    data = data.drop(columns=['AGE'])
    data = data.groupby(['prescriber_st', 'productname', 'year_month', 'age_group']).agg({'trx':'sum', 'DDD':'sum'}).reset_index()
    final_lst.append(data)
final = pd.concat(final_lst)

################## map productname to drug class ##############################

#drug_class = pd.read_excel(OneDrive + "/IQVIAExampleData_DDDrevised.xlsx")
drug_class = pd.read_csv(OneDrive + '/1. Data/DDDcrosswalk2020.csv')
drug_class = drug_class.groupby(['productname', 'drug','class'])['usc5_num'].first().reset_index()
drug_class = drug_class[['productname', 'class']]
drug_class = drug_class.drop_duplicates(subset=['productname'])
drug_class.loc[drug_class['productname'] == 'STREPTOMYCIN SULF', 'class'] = 'Aminoglycosides'

################### Pop by Age Group #########################################

# https://www.census.gov/programs-surveys/popest/technical-documentation/research/evaluation-estimates/2020-evaluation-estimates/2010s-state-detail.html
# https://www2.census.gov/programs-surveys/popest/technical-documentation/file-layouts/2010-2020/sc-est2020-agesex-civ.pdf

pop = pd.read_csv(OneDrive + '/1. Data/SC-EST2020-AGESEX-CIV.csv')
pop = pop.loc[pop['SEX'] == 0]
pop = pop.loc[pop['STATE'] != 0]
pop = pop.loc[pop['AGE'] != 999]
pop = pop[['STATE', 'NAME', 'AGE', 'POPEST2017_CIV', 'POPEST2018_CIV', 'POPEST2019_CIV', 'POPEST2020_CIV']]
pop['age_group'] = '75+'
pop.loc[pop['AGE'] <= 74, 'age_group'] = '60-74'
pop.loc[pop['AGE'] <= 59, 'age_group'] = '40-59'
pop.loc[pop['AGE'] <= 39, 'age_group'] = '20-39'
pop.loc[pop['AGE'] <= 19, 'age_group'] = '10-19'
pop.loc[pop['AGE'] <= 9,  'age_group'] = '3-9'
pop.loc[pop['AGE'] <= 2, 'age_group'] = '0-2'

states = pd.read_csv(OneDrive + '/1. Data/StateCodes.csv')
states = states[['Province_State', 'state_abbr']]
states.rename(columns={'Province_State':'NAME', 'state_abbr':'prescriber_st'}, inplace = True)

pop = pop.merge(states, how='left', on = 'NAME')
pop = pop.groupby(['prescriber_st', 'age_group']).agg({'POPEST2017_CIV':'sum', 'POPEST2018_CIV':'sum', 'POPEST2019_CIV':'sum', 'POPEST2020_CIV':'sum'})
pop = pop.reset_index().sort_values(['prescriber_st', 'age_group'])

############### Merge ########################################################

final2 = final.merge(drug_class, how='left', on='productname')
final2 = final2.groupby(['prescriber_st', 'age_group', 'class', 'year_month']).agg({'DDD':'sum', 'trx':'sum'})
final2 = final2.reset_index()
final2 = final2.merge(pop, how='left', on=['prescriber_st', 'age_group'])
final2['year_month'] = final2['year_month'].astype(str)
final2['year'] = final2['year_month'].str[:4]
final2['month'] = final2['year_month'].str[-2:]

final2.to_csv(OneDrive + '/1. Data/IQVIA_AgeClass_byState.csv')

######################### old code ############################################

# May 2022 Sara correction
iqvia_years = ['2017', '2018', '2019', '2020']
data_lst = []
for year in iqvia_years:
    data = pd.read_csv(OneDrive + '/ProcessedData/IQVIA_AgeGroups_' + year + '_v2_trx.csv')
    data = data[['prescriber_st', 'age_group', 'DDD', 'trx', 'year_month', 'month']]
    data = data.merge(pop, how='left', on=['prescriber_st', 'age_group'])
    data['year'] = int(year)
    data = data.rename(columns={'POPEST2017_CIV':'pop'})
    data = data[['prescriber_st', 'age_group', 'year', 'month', 'DDD', 'trx', 'pop']]
    data_lst.append(data)  
final3 = pd.concat(data_lst)

#Export
final3.to_csv(OneDrive + '/ProcessedData/IQVIA_AgeGroups_AllYears_v4_trx.csv')

################## Combining all years (with 75+ correction) ##################

#2017
iqvia2017 = pd.read_csv(OneDrive + '/ProcessedData/IQVIA_AgeGroups_2017_v2_trx.csv')
iqvia2017 = iqvia2017[['prescriber_st', 'age_group', 'DDD', 'trx', 'year_month', 'month']]
iqvia2017 = iqvia2017.merge(pop, how='left', on=['prescriber_st', 'age_group'])
iqvia2017['year'] = 2017
iqvia2017 = iqvia2017.rename(columns={'POPEST2017_CIV':'pop'})
iqvia2017 = iqvia2017[['prescriber_st', 'age_group', 'year', 'month', 'DDD', 'trx', 'pop']]

#2018
iqvia2018 = pd.read_csv(OneDrive + '/ProcessedData/IQVIA_AgeGroups_2018_v2_trx.csv')
iqvia2018 = iqvia2018[['prescriber_st', 'age_group', 'DDD', 'trx', 'year_month', 'month']]
iqvia2018 = iqvia2018.merge(pop, how='left', on=['prescriber_st', 'age_group'])
iqvia2018['year'] = 2018
iqvia2018 = iqvia2018.rename(columns={'POPEST2018_CIV':'pop'})
iqvia2018 = iqvia2018[['prescriber_st', 'age_group', 'year', 'month', 'DDD', 'trx', 'pop']]
iqvia2018 = iqvia2018.loc[iqvia2018['prescriber_st'] != 'UN']

#2019
iqvia2019 = pd.read_csv(OneDrive + '/ProcessedData/IQVIA_AgeGroups_2019_v2_trx.csv')
iqvia2019 = iqvia2019[['prescriber_st', 'age_group', 'DDD', 'trx', 'year_month', 'month']]
iqvia2019 = iqvia2019.merge(pop, how='left', on=['prescriber_st', 'age_group'])
iqvia2019['year'] = 2019
iqvia2019 = iqvia2019.rename(columns={'POPEST2019_CIV':'pop'})
iqvia2019 = iqvia2019[['prescriber_st', 'age_group', 'year', 'month', 'DDD', 'trx', 'pop']]

#2020
iqvia2020 = pd.read_csv(OneDrive + '/ProcessedData/IQVIA_AgeGroups_2020_v2_trx.csv')
iqvia2020 = iqvia2020[['prescriber_st', 'age_group', 'DDD', 'trx', 'year_month', 'month']]
iqvia2020 = iqvia2020.merge(pop, how='left', on=['prescriber_st', 'age_group'])
iqvia2020['year'] = 2020
iqvia2020 = iqvia2020.rename(columns={'POPEST2020_CIV':'pop'})
iqvia2020 = iqvia2020[['prescriber_st', 'age_group', 'year', 'month', 'DDD', 'trx', 'pop']]

#Merge all years
allyears = []
allyears.append(iqvia2017)
allyears.append(iqvia2018)
allyears.append(iqvia2019)
allyears.append(iqvia2020)
final3 = pd.concat(allyears)

#Export
final3.to_csv(OneDrive + '/ProcessedData/IQVIA_AgeGroups_AllYears_v3_trx.csv')

################ checking #####################################################
final3 = pd.read_csv(OneDrive + '/ProcessedData/IQVIA_AgeGroups_AllYears_v3_trx.csv')
agepops = final3.groupby(['year', 'prescriber_st', 'age_group'])['pop'].first().reset_index()
agepops = agepops.groupby(['year', 'age_group'])['pop'].sum().reset_index()
agetrx = final3.groupby(['year', 'age_group'])['trx'].sum().reset_index()

trxpop = agetrx.merge(agepops, how='left', on=['year', 'age_group'])
trxpop['TRXper100k'] = trxpop['trx'] / trxpop['pop'] * 100000

#ages = pd.read_csv(OneDrive + '/ProcessedData/IQVIA_AgeGroups_AllYears_v2_trx.csv')






