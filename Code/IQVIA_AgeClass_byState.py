# COVID-19 and Antibiotic Prescribing
# Process data for Figures 1 and 2 - Prescriptions by year, state, age, and class
# Created by Alisa Hamilton

import pandas as pd

OneDrive = "[Main file path]"
state_abbr = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY']

years = ['2017','2018', '2019', '2020']
final_lst = []
for year in years:
    #print(line)
    data = pd.read_csv(OneDrive + '/Data/IQVIA_' + year + '_Disaggregated.csv')
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

drug_class = pd.read_csv(OneDrive + '/Data/DDDcrosswalk2020.csv')
drug_class = drug_class.groupby(['productname', 'drug','class'])['usc5_num'].first().reset_index()
drug_class = drug_class[['productname', 'class']]
drug_class = drug_class.drop_duplicates(subset=['productname'])
drug_class.loc[drug_class['productname'] == 'STREPTOMYCIN SULF', 'class'] = 'Aminoglycosides'

################### Pop by Age Group #########################################

# https://www.census.gov/programs-surveys/popest/technical-documentation/research/evaluation-estimates/2020-evaluation-estimates/2010s-state-detail.html
# https://www2.census.gov/programs-surveys/popest/technical-documentation/file-layouts/2010-2020/sc-est2020-agesex-civ.pdf

pop = pd.read_csv(OneDrive + '/Data/SC-EST2020-AGESEX-CIV.csv')
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

states = pd.read_csv(OneDrive + '/Data/StateCodes.csv')
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

final2.to_csv(OneDrive + '/Data/IQVIA_AgeClass_byState.csv')

