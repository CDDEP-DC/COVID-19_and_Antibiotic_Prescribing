# COVID-19 and Antibiotic Prescribing
# Process data for county-level panel regression
# Created by Alisa Hamilton

import pandas as pd
import glob

OneDrive = "[Main file path]"

state_abbr = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY']
state_code = ['01', '02', '04', '05', '06', '08', '09', '10', '11', '12', '13', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '44', '45', '46', '47', '48', '49', '50', '51', '53', '54', '55', '56']

statecodes = pd.read_csv(OneDrive + '/Data/StateCodes.csv')
statecodes = statecodes[['state_abbr', 'state_code']]

################## map productname to drug class ##############################

#drug_class = pd.read_excel(OneDrive + "/IQVIAExampleData_DDDrevised.xlsx")
drug_class = pd.read_csv(OneDrive + '/Data/DDDcrosswalk2020.csv')
drug_class = drug_class.groupby(['productname', 'drug','class'])['usc5_num'].first().reset_index()
drug_class = drug_class[['productname', 'class']]
drug_class = drug_class.drop_duplicates(subset=['productname'])
drug_class.loc[drug_class['productname'] == 'STREPTOMYCIN SULF', 'class'] = 'Aminoglycosides'

#################### map zip to county ########################################

#https://www.huduser.gov/portal/datasets/usps_crosswalk.html

zip_county = pd.read_excel(OneDrive + "/Data/ZIP_COUNTY_122020.xlsx").sort_values(['ZIP', 'RES_RATIO'])
zip_county = zip_county.groupby(['ZIP']).agg({'RES_RATIO':'max', 'COUNTY':'last'}).reset_index() #taking county with highest proportion of residents
zip_county = zip_county[['ZIP', 'COUNTY']]
zip_county.loc[zip_county['COUNTY'] < 10000, 'COUNTY'] = '0' + zip_county['COUNTY'].map(str)
zip_county.loc[zip_county['COUNTY'].map(float) >= 10000, 'COUNTY'] = zip_county['COUNTY'].map(str)
zip_county = zip_county.rename(columns={'ZIP':'prescriber_zip', 'COUNTY':'FIPS'})
zip_county.to_csv(OneDrive + '/Data/ZIP_FIPS_Crosswalk.csv')

print(len(zip_county['FIPS'].unique()))

################### Pop by Age Group by County ################################

# https://www.census.gov/programs-surveys/popest/technical-documentation/research/evaluation-estimates/2020-evaluation-estimates/2010s-county-detail.html
# https://www2.census.gov/programs-surveys/popest/technical-documentation/file-layouts/2010-2020/cc-est2020-alldata6.pdf

pop = pd.read_csv(OneDrive + '/Data/CC-EST2020-ALLDATA6.csv', encoding = "ISO-8859-1", engine='python')
pop = pop[['STATE', 'COUNTY', 'YEAR', 'AGEGRP', 'TOT_POP']] 
pop = pop.loc[(pop['YEAR'] == 10) | (pop['YEAR'] == 11) | (pop['YEAR'] == 12) | (pop['YEAR'] == 14)] #2017-2020
pop = pop.loc[(pop['AGEGRP'] == 0) | (pop['AGEGRP'] == 1) | (pop['AGEGRP'] == 2)] 
pop.loc[(pop['AGEGRP'] == 0), 'AGEGRP'] = "all"
pop.loc[(pop['AGEGRP'] == 1) | (pop['AGEGRP'] == 2), 'AGEGRP'] = "children"
pop.loc[pop['YEAR'] == 10, 'YEAR'] = 'Pop2017'
pop.loc[pop['YEAR'] == 11, 'YEAR'] = 'Pop2018'
pop.loc[pop['YEAR'] == 12, 'YEAR'] = 'Pop2019'
pop.loc[pop['YEAR'] == 14, 'YEAR'] = 'Pop2020'
pop.loc[pop['STATE'] <  10, 'FIPSstate'] = '0' + pop['STATE'].map(str)
pop.loc[pop['STATE'] >= 10, 'FIPSstate'] = pop['STATE'].map(str)
pop['FIPScounty'] = pop['COUNTY'].map(str)
pop.loc[pop['COUNTY'] < 100, 'FIPScounty'] = '0' + pop['COUNTY'].map(str)
pop.loc[pop['COUNTY'] < 10, 'FIPScounty'] = '00' + pop['COUNTY'].map(str)
pop['FIPS'] = pop['FIPSstate'] + pop['FIPScounty']
pop['TOT_POP'] = pop['TOT_POP'].astype(int)
pop = pop.groupby(['FIPS', 'YEAR', 'AGEGRP']).agg({'TOT_POP':'sum'}).reset_index()
pop['POP'] = pop['YEAR'] + '_' + pop['AGEGRP']
pop = pd.pivot_table(pop, values='TOT_POP', index='FIPS', columns='POP')

statepops = pop['Pop2020_all'].reset_index()
statepops['state'] = statepops['FIPS'].astype(str).str[:2]
statepops = statepops.groupby('state')['Pop2020_all'].sum().reset_index()

############################ IQVIA data ######################################

files = glob.glob(OneDrive + "/Data/*_Disaggregated_v3.csv")
file_lst = []

for file in files:
    iqvia = pd.read_csv(file)
    iqvia1 = iqvia.groupby(['prescriber_st', 'prescriber_zip', 'year_month']).agg({'trx':'sum', 'DDD':'sum'}).reset_index()
    iqvia2 = iqvia.loc[(iqvia['AGE'] == '00-02') | (iqvia['AGE'] == '03-09')]
    iqvia2 = iqvia2.groupby(['prescriber_st', 'prescriber_zip', 'year_month']).agg({'trx':'sum', 'DDD':'sum'}).reset_index()
    iqvia2.rename(columns={'DDD':'child_DDD', 'trx':'child_trx'}, inplace = True)
    iqvia3 = iqvia1.merge(iqvia2, how='outer', on=['prescriber_st','prescriber_zip','year_month'])
    iqvia3 = iqvia3.merge(zip_county, how='left', on='prescriber_zip')
    iqvia3 = iqvia3.groupby(['FIPS', 'year_month']).agg({'DDD':'sum', 'trx':'sum', 'child_DDD':'sum', 'child_trx':'sum'}).reset_index()
    file_lst.append(iqvia3)
    
iqvia_all = pd.concat(file_lst)
# iqvia_adults = iqvia.loc[iqvia['agegroup'] == 'all']
# iqvia_adults = iqvia_adults.drop(columns='agegroup')
# iqvia_child = iqvia.loc[iqvia['agegroup'] == 'children']
# iqvia_child = iqvia_child.drop(columns='agegroup')
# iqvia_child.rename(columns={'DDD':'child_DDD', 'trx':'child_trx'}, inplace = True)
# iqvia_all = iqvia_adults.merge(iqvia_child, how='outer', on = ['FIPS', 'year_month'])
iqvia_all['year'] = iqvia_all['year_month'].astype(str).str[:4]
iqvia_all['month'] = iqvia_all['year_month'].astype(str).str[-2:]
iqvia_all = iqvia_all.drop(columns='year_month')
iqvia_all = iqvia_all.merge(pop, how='left', on='FIPS')

iqvia2017 = iqvia_all.loc[iqvia_all['year'] == '2017']
iqvia2017['DDD2017_per100k'] = iqvia2017['DDD'] / iqvia2017['Pop2017_all'] * 100000
iqvia2017['TRX2017_per100k'] = iqvia2017['trx'] / iqvia2017['Pop2017_all'] * 100000
iqvia2017['child_DDD2017per100k'] = iqvia2017['child_DDD'] / iqvia2017['Pop2017_children'] * 100000
iqvia2017['child_TRX2017per100k'] = iqvia2017['child_trx'] / iqvia2017['Pop2017_children'] * 100000
iqvia2017 = iqvia2017[['FIPS', 'month', 'DDD2017_per100k', 'TRX2017_per100k', 'child_DDD2017per100k', 'child_TRX2017per100k']]

iqvia2018 = iqvia_all.loc[iqvia_all['year'] == '2018']
iqvia2018['DDD2018_per100k'] = iqvia2018['DDD'] / iqvia2018['Pop2018_all'] * 100000
iqvia2018['TRX2018_per100k'] = iqvia2018['trx'] / iqvia2018['Pop2018_all'] * 100000
iqvia2018['child_DDD2018per100k'] = iqvia2018['child_DDD'] / iqvia2018['Pop2018_children'] * 100000
iqvia2018['child_TRX2018per100k'] = iqvia2018['child_trx'] / iqvia2018['Pop2018_children'] * 100000
iqvia2018 = iqvia2018[['FIPS', 'month', 'DDD2018_per100k', 'TRX2018_per100k', 'child_DDD2018per100k', 'child_TRX2018per100k']]

iqvia2019 = iqvia_all.loc[iqvia_all['year'] == '2019']
iqvia2019['DDD2019_per100k'] = iqvia2019['DDD'] / iqvia2019['Pop2019_all'] * 100000
iqvia2019['TRX2019_per100k'] = iqvia2019['trx'] / iqvia2019['Pop2019_all'] * 100000
iqvia2019['child_DDD2019per100k'] = iqvia2019['child_DDD'] / iqvia2019['Pop2019_children'] * 100000
iqvia2019['child_TRX2019per100k'] = iqvia2019['child_trx'] / iqvia2019['Pop2019_children'] * 100000
iqvia2019 = iqvia2019[['FIPS', 'month', 'DDD2019_per100k', 'TRX2019_per100k', 'child_DDD2019per100k', 'child_TRX2019per100k']]

iqvia2020 = iqvia_all.loc[iqvia_all['year'] == '2020']
iqvia2020['DDD2020_per100k'] = iqvia2020['DDD'] / iqvia2020['Pop2020_all'] * 100000
iqvia2020['TRX2020_per100k'] = iqvia2020['trx'] / iqvia2020['Pop2020_all'] * 100000
iqvia2020['child_DDD2020per100k'] = iqvia2020['child_DDD'] / iqvia2020['Pop2020_children'] * 100000
iqvia2020['child_TRX2020per100k'] = iqvia2020['child_trx'] / iqvia2020['Pop2020_children'] * 100000
print(iqvia2020['trx'].sum())
print(iqvia2020['child_trx'].sum())
iqvia2020 = iqvia2020[['FIPS', 'month', 'DDD2020_per100k', 'TRX2020_per100k', 'child_DDD2020per100k', 'child_TRX2020per100k']]

iqvia_final = iqvia2017.merge(iqvia2018, how='outer', on = ['FIPS', 'month'])
iqvia_final = iqvia_final.merge(iqvia2019, how='outer', on = ['FIPS', 'month'])
iqvia_final = iqvia_final.merge(iqvia2020, how='outer', on = ['FIPS', 'month'])

print(pop['Pop2020_all'].sum())
print(pop['Pop2020_children'].sum())

##################### Covid by county from dartmouth ##########################

# https://github.com/Dartmouth-DAC

covid = pd.read_csv(OneDrive + "/Data/CasesandDeathsbyCounty.csv")
covid = covid.loc[covid['date'] < "2021-01-01"]
covid = covid.groupby(['county', 'date', 'countypop']).agg({'countycaserate100k':'first'})
covid = covid.reset_index()
covid['year_month'] = covid['date'].str[:7].str.replace("-","")
covid['state'] = covid['county'].str[:2]
covid = covid.loc[covid['state'].isin(state_code)]
covid = covid.groupby(['county', 'countypop', 'year_month']).agg({'countycaserate100k':'last'}) #143 counties represented
covid = covid.reset_index()
covid.rename(columns={'county':'FIPS'}, inplace = True)
covid['FIPS'] = covid['FIPS'].astype(str)
covid['year_month'] = covid['year_month'].astype(str)
covid.rename(columns={'countycaserate100k':'cases_per100k'}, inplace = True)
covid['monthly_cases_per100k'] = covid.groupby('FIPS')['cases_per100k'].diff(1)
covid['month'] = covid['year_month'].str[-2:]
covid = covid[['FIPS', 'month', 'cases_per100k', 'monthly_cases_per100k']]
covid['monthly_cases_per100k'] = covid['monthly_cases_per100k'].fillna(0)
covid.loc[covid['monthly_cases_per100k'] < 0, 'monthly_cases_per100k'] = 0
#test = covid.groupby('FIPS').first('month') #3143 counties represented 

#################### urban rural classification ###############################

# NCHS Urban-Rural Classification Scheme for Counties
# https://www.cdc.gov/nchs/data_access/urban_rural.htm#2013_Urban-Rural_Classification_Scheme_for_Counties

urcodes = pd.read_excel(OneDrive + '/Data/NCHSURCodes2013.xlsx')
urcodes = urcodes[['FIPS code', '2013 code']]
urcodes.loc[urcodes['FIPS code'] <  10000, 'FIPS'] = '0' + urcodes['FIPS code'].map(str)
urcodes.loc[urcodes['FIPS code'] >= 10000, 'FIPS'] = urcodes['FIPS code'].map(str)
urcodes = urcodes[['FIPS', '2013 code']]
urcodes.rename(columns={'2013 code':'URcode'}, inplace = True)

##################### Poverty by county ######################################

# SAIPE State and County Estimates for 2019
# https://www.census.gov/data/datasets/2019/demo/saipe/2019-state-and-county.html

poverty = pd.read_excel(OneDrive + '/Data/PovertyPercent_byCounty.xls')
poverty = poverty.loc[poverty['County FIPS'] != 0]
poverty.loc[poverty['State FIPS'] <  10, 'FIPSstate'] = '0' + poverty['State FIPS'].map(str)
poverty.loc[poverty['State FIPS'] >= 10, 'FIPSstate'] = poverty['State FIPS'].map(str)
poverty['FIPScounty'] = poverty['County FIPS'].map(str)
poverty.loc[poverty['County FIPS'] < 100, 'FIPScounty'] = '0' + poverty['County FIPS'].map(str)
poverty.loc[poverty['County FIPS'] < 10, 'FIPScounty'] = '00' + poverty['County FIPS'].map(str)
poverty['FIPS'] = poverty['FIPSstate'] + poverty['FIPScounty']
poverty.rename(columns={'County FIPS':'COUNTY', 'State FIPS':'STATE'}, inplace = True)
poverty['PovertyPercent'] = pd.to_numeric(poverty['PovertyPercent'],errors='coerce')
poverty = poverty[['FIPS', 'PovertyPercent', 'COUNTY', 'STATE']]

############ minority groups ##################################################

# https://www.census.gov/data/tables/time-series/demo/popest/2010s-counties-detail.html
# https://www2.census.gov/programs-surveys/popest/datasets/2010-2020/counties/asrh/

minority = pd.read_csv(OneDrive+ '/Data/CC-EST2020-ALLDATA_MinorityGroups.csv', encoding = "ISO-8859-1", engine='python')
minority = minority.loc[minority['AGEGRP'] == 0]
minority = minority.loc[minority['YEAR'] == 12]
minority = minority[['STATE', 'COUNTY', 'TOT_POP', 'WA_MALE', 'WA_FEMALE']]
minority['minority'] = minority['TOT_POP'].map(int) - minority['WA_MALE'].map(int) - minority['WA_FEMALE'].map(int)
minority['MinorityPercent'] = minority['minority'] / minority['TOT_POP'].map(int) * 100
minority = minority[['STATE', 'COUNTY', 'MinorityPercent']]

census = poverty.merge(minority, how='left', on=['STATE', 'COUNTY'])
census = census[['FIPS', 'PovertyPercent', 'MinorityPercent']]

#### physicians ###

healthcare = pd.read_csv(OneDrive + "/Data/USCounty_Demographic_Profile.csv")
healthcare = healthcare[['FIPS', 'Healthcare practitioners and technicians']]
healthcare.rename(columns={'Healthcare practitioners and technicians':'HCworkers'}, inplace = True)

industry = pd.read_stata(OneDrive + "/Data/industry.dta")
industry.rename(columns={'fips':'FIPS'}, inplace = True)
industry.rename(columns={'physicians':'physician_offices'}, inplace = True)
industry = industry.drop(columns="fipstate")

healthcare = healthcare.merge(industry, how='left', on='FIPS')
healthcare.loc[healthcare['FIPS'] < 10000, 'FIPS'] = '0' + healthcare['FIPS'].map(str)
healthcare.loc[healthcare['FIPS'].map(float) >= 10000, 'FIPS'] = healthcare['FIPS'].map(str)
healthcare = healthcare.loc[healthcare['FIPS'].map(float) < 72000]
pop2020 = pop['Pop2020_all']
healthcare = healthcare.merge(pop2020, how='left', on='FIPS')

healthcare['HCworkers_per100k'] = healthcare['HCworkers'] / healthcare['Pop2020_all'] *100000
healthcare['nursingcare_per100k'] = healthcare['nursingcare'] / healthcare['Pop2020_all'] *100000
healthcare['assistedliving_per100k'] = healthcare['assistedliving'] / healthcare['Pop2020_all'] *100000
healthcare['physician_off_per100k'] = healthcare['physician_offices'] / healthcare['Pop2020_all'] *100000
healthcare['kidneydialysis_per100k'] = healthcare['kidneydialysis'] / healthcare['Pop2020_all'] *100000
healthcare['hospitals_per100k'] = healthcare['hospitals'] / healthcare['Pop2020_all'] *100000
healthcare['ltcfs_per100k'] = healthcare['ltcfs'] / healthcare['Pop2020_all'] *100000
healthcare = healthcare.drop(columns=['HCworkers', 'nursingcare', 'assistedliving', 'physician_offices', 'kidneydialysis', 'hospitals', 'ltcfs', 'Pop2020_all'])

##################### School closures EducationWeek ###########################

school = pd.read_csv(OneDrive + '/Data/school_mnth_data2.csv')
school = school[['State_Abbr', 'Public School Enrollment', 'Status', 'month']]
school.rename(columns={'State_Abbr':'state_abbr'}, inplace = True)
school = school.merge(statecodes, how='left', on='state_abbr')
school = school[['state_code', 'Public School Enrollment', 'Status', 'month']]
school.loc[school['month'] < 10, 'month'] = '0' + school['month'].map(str)
school.loc[school['month'].map(float) >= 10, 'month'] = school['month'].map(str)
school.loc[school['state_code'] < 10, 'state_code'] = '0' + school['state_code'].map(str)
school.loc[school['state_code'].map(float) >= 10, 'state_code'] = school['state_code'].map(str)
school.rename(columns={'state_code':'state', 'Public School Enrollment':'school_enrollment', 'Status':'school_edu'}, inplace = True)
school_edu = school

################### School closures MCH #######################################
# https://www.mchdata.com/covid19/schoolclosings

district = pd.read_excel(OneDrive + "/Data/EDGE_GEOCODE_PUBLICLEA_1819.xlsx")
district.rename(columns={'LEAID':'DistrictNCES', "NAME": "DistrictName_census", "STATE":"state"}, inplace = True)
district = district[['DistrictNCES', 'DistrictName_census', 'CNTY', 'state']]

mch = pd.read_excel(OneDrive + "/Data/MCH school data.xlsx")
mch = mch[['DistrictNCES', 'DistrictName', 'PhysicalState','Enrollment', 'OpenDate','TeachingMethod']]
mch.rename(columns={"DistrictName": "DistrictName_MCH", "PhysicalState":"state"}, inplace = True)
mch = mch.dropna()

school = mch.merge(district, how='left', on=['DistrictNCES', 'state'])
school = school.dropna()
school['date'] = pd.to_datetime(school['OpenDate'])
school['month'] = school['date'].map(str).str[5:7]
school = school.groupby(['CNTY','TeachingMethod', 'date','month'])['Enrollment'].sum().reset_index()
school = school.sort_values(['CNTY', 'date', 'Enrollment'])
school = school.groupby('CNTY')['TeachingMethod', 'date', 'month', 'Enrollment'].first().reset_index()
school = school[['CNTY', 'month', 'TeachingMethod']]
school['mch'] = 1
mch_fips = school[['CNTY','mch']]
fips_month = covid[['FIPS','month']]
fips_month['CNTY'] = fips_month['FIPS'].map(float)
school = fips_month.merge(school, how='left', on=['CNTY','month'])

school = school.merge(mch_fips, how='left', on='CNTY')
school = school.loc[school['mch_y']==1]
school = school[['FIPS','month', 'CNTY','TeachingMethod']]
#school1 = school['TeachingMethod'].unique()
school["TeachingMethod"] = school.groupby('FIPS')['TeachingMethod'].transform(lambda x: x.ffill())
school.loc[school['month'].map(float) < 3, 'TeachingMethod'] = 'On Premises'
school['TeachingMethod'] = school['TeachingMethod'].fillna('Closed')
school.loc[school['TeachingMethod'] == 'On Premises', 'TeachingMethod'] = 'Open'
school.loc[school['TeachingMethod'] == 'Online Only', 'TeachingMethod'] = 'Closed'
school.loc[(school['TeachingMethod'] == 'Hybrid') | (school['TeachingMethod'] == 'Unknown') | (school['TeachingMethod'] == 'Other'), 'TeachingMethod'] = 'Hybrid/Other'
school.loc[school['CNTY'] <  10000, 'FIPS'] = '0' + school['CNTY'].map(str).str[:4]
school.loc[school['CNTY'] >= 10000, 'FIPS'] = school['CNTY'].map(str).str[:5]
school_mch = school[['FIPS', 'month', 'TeachingMethod']]

################## NPIs from OxCGRT ###########################################

# https://github.com/OxCGRT/USA-covid-policy/tree/master/data
# pdf explaining indices: https://github.com/OxCGRT/USA-covid-policy/blob/master/working%20paper%20archive/BSG-WP-2020-034-v2.pdf
# codebook: https://github.com/OxCGRT/covid-policy-tracker/blob/master/documentation/codebook.md

# Global indice
npi_indice = pd.read_excel(OneDrive + '/Data/OxCGRTUS_timeseries_all.xlsx')
npi_indice['region_code'] = npi_indice['region_code'].str[-2:]
npi_indice = npi_indice.loc[npi_indice['region_code'].isin(state_abbr)] 
npi_indice = npi_indice.drop(['country_code', 'country_name', 'region_name', 'jurisdiction'], axis=1).set_index('region_code')
npi_indice = npi_indice.stack().reset_index()
npi_indice.rename(columns={'region_code':'state_abbr', 'level_1':'date', 0:'npi_indice'}, inplace = True)
npi_indice['date'] = pd.to_datetime(npi_indice['date'])
npi_indice = npi_indice.loc[npi_indice['date'] < '2021-01-01']
npi_indice['month'] = npi_indice['date'].map(str).str[5:7]
npi_indice = npi_indice.groupby(['state_abbr', 'month'])['npi_indice'].mean()
npi_indice = npi_indice.reset_index()
npi_indice = npi_indice.merge(statecodes, how='left', on='state_abbr')
npi_indice.loc[npi_indice['state_code'] < 10, 'state_code'] = '0' + npi_indice['state_code'].map(str)
npi_indice.loc[npi_indice['state_code'].map(float) >= 10, 'state_code'] = npi_indice['state_code'].map(str)
npi_indice.rename(columns={'state_code':'state'}, inplace = True)
npi_indice = npi_indice[['state', 'month', 'npi_indice']]

# Separate indicators (Movement, facial coverings, schools)
npi_all = pd.read_csv(OneDrive + "/Data/OxCGRT_US_latest.csv")
npi_all['state_abbr'] = npi_all['RegionCode'].str[-2:]
npi_all = npi_all.loc[npi_all['state_abbr'].isin(state_abbr)] 
npi_all = npi_all.merge(statecodes, how='left', on='state_abbr')
npi_all.loc[npi_all['state_code'] < 10, 'state_code'] = '0' + npi_all['state_code'].map(str)
npi_all.loc[npi_all['state_code'].map(float) >= 10, 'state_code'] = npi_all['state_code'].map(str)
npi_all.rename(columns={'state_code':'state', 'C7_Restrictions on internal movement':'Movement_restrictions', 'H6_Facial Coverings':'face_coverings', 'C1_School closing': 'School_status'}, inplace = True)
npi_all = npi_all[['state', 'Date', 'Movement_restrictions', 'face_coverings', 'School_status']]
npi_all['month'] = npi_all['Date'].map(str).str[4:6]
npi_all = npi_all.set_index(['state', 'month'])
npi_all1 = npi_all.groupby(['state', 'month'])['face_coverings'].apply(lambda x: x.mode().iloc[0]).reset_index()
npi_all2 = npi_all.groupby(['state', 'month'])['Movement_restrictions'].apply(lambda x: x.mode().iloc[0]).reset_index()
npi_all3 = npi_all.groupby(['state', 'month'])['School_status'].apply(lambda x: x.mode().iloc[0]).reset_index()
npi_all = npi_all1.merge(npi_all2, how='left', on=['state', 'month'])
npi_all = npi_all.merge(npi_all3, how='left', on=['state', 'month'])

##################### COVID Testing ##########################################

#by state
# https://github.com/govex/COVID-19/tree/master/data_tables/testing_data
testing = pd.read_csv(OneDrive + "/Data/testing_time_series_covid19_US.csv")
testing = testing[['state', 'date', 'tests_combined_total']]
testing = testing.loc[testing['state'].isin(state_abbr)]
testing['date'] = pd.to_datetime(testing['date'])
testing = testing.loc[testing['date'] < "2021-01-01"]
testing['month'] = testing['date'].map(str).str[5:7]
testing = testing.groupby(['state','month'])['tests_combined_total'].last().reset_index()
testing.rename(columns={'state':'state_abbr'}, inplace = True)
testing = testing.merge(statecodes, how='left', on='state_abbr')
testing.loc[testing['state_code'] < 10, 'state_code'] = '0' + testing['state_code'].map(str)
testing.loc[testing['state_code'].map(float) >= 10, 'state_code'] = testing['state_code'].map(str)
testing.rename(columns={'state_code':'state'}, inplace = True)
testing = testing.merge(statepops, how='left', on='state')
testing['tests_per100k'] = testing['tests_combined_total'] / testing['Pop2020_all'] * 100000
testing = testing[['state', 'month', 'tests_per100k']]

# by county (starts August 2021)
# https://github.com/govex/COVID-19/tree/master/data_tables/testing_data
# testing = pd.read_csv(OneDrive + "/data/testing_county_time_series_covid19_US.csv")
# testing['date'] = pd.to_datetime(testing['date'])
# testing = testing.loc[testing['date'] < "2021-01-01"]
# min_date = testing['date'].min()

final = covid.merge(iqvia_final, how='outer', on=['FIPS', 'month'])
final = final.merge(urcodes, how='left', on='FIPS')
final = final.merge(census, how='left', on='FIPS')
final['DDD17_19avg_per100k'] = final[['DDD2017_per100k', 'DDD2018_per100k', 'DDD2019_per100k']].mean(axis=1) # 3094 fips represented
final['TRX17_19avg_per100k'] = final[['TRX2017_per100k', 'TRX2018_per100k', 'TRX2019_per100k']].mean(axis=1)
final['childDDD17_19avg_per100k'] = final[['child_DDD2017per100k', 'child_DDD2018per100k', 'child_DDD2019per100k']].mean(axis=1)
final['childTRX17_19avg_per100k'] = final[['child_TRX2017per100k', 'child_TRX2018per100k', 'child_TRX2019per100k']].mean(axis=1)
final['state'] = final['FIPS'].str[:2]
#test = final.groupby(['FIPS']).first('state') #3143 counties represented 
#final = final.merge(npi_indice, how='left', on=['state', 'month'])

final = final.merge(npi_all, how='left', on=['state', 'month'])
final = final.merge(school_edu, how='left', on=['state', 'month'])
final['school_edu'] = final['school_edu'].fillna('closed')
final.loc[(final['month']== "01") | (final['month']== "02"), 'school_edu'] = 'open' 
final = final.merge(school_mch, how='left', on=['FIPS', 'month'])
#final = final.merge(children,how='left', on=['FIPS', 'month'])
final = final.merge(testing, how='left', on=['state', 'month'])
final['tests_per100k'] = final['tests_per100k'].fillna(0)
final = final.merge(healthcare, how='left', on='FIPS')

final.to_csv(OneDrive + '/Data/IQVIA_2017_2020_byCounty_forRegression.csv')

