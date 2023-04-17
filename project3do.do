*will need to edit line 26 and 42 filepath to run
pwd
cd C:\Users\rubycb\Downloads
*import death by day/county data
import delimited "https://raw.githubusercontent.com/nytimes/covid-19-data/mast
> er/us-counties.csv"
*drop all non-2020 observations
keep if substr(date, 1, 4) == "2020"
*collapse data into death by county per year and save new data set
collapse (sum) deaths, by(fips)
save aggregated_deaths, replace

*import population data
import delimited "https://raw.githubusercontent.com/rcbithell/Data-Assignment-3/main/PEPPOP2019.PEPANNRES-Data.csv", clear
*format the geography var into county ID #
gen county = substr(v1, 10, 6)
*drop uneeded vars
drop v1 v3 v4 v6
drop if missing(county)
*collapse data by county
destring v5, replace
rename v5 countypop
collapse (mean) v5, by(county)
save population, replace
*import zip code/county data and merge with population.dta
import excel "C:\Users\rubycb\Downloads\ZIP_COUNTY_122020.xlsx", sheet("ZIP_COUNTY_122020") clear
drop C D E F
rename B county
rename A fips
drop if fips == "ZIP"
save zipcounty, replace
use population.dta, clear
merge 1:m county using zipcounty.dta
save mergedata,replace
drop if _merge == 1
drop if _merge == 2
save mergedata, replace
drop _merge
destring fips, replace
save mergedata, replace
*import hpi index, must delete content in row 1 2 3 4 before importing
import excel "C:\Users\rubycb\Downloads\HPI_AT_3zip.xlsx", sheet("HPI_AT_3zip") clear
drop C E F G
rename A fips
rename B year
rename D index
keep if year == "2020"
save index, replace
*merge mergedata with index
use mergedata.dta, clear
tostring fips, replace
gen fips2 = substr(fips, 1, 2)
save mergedata, replace
use index.dta, clear
rename fips fips2
merge m:m fips2 using mergedata.dta
save indexmerge, replace
drop if _merge == 1
drop if _merge == 2
drop _merge
save indexmerge, replace
*merge deaths into merged data set
use aggregated_deaths.dta, clear
tostring fips, replace
gen fips2 = substr(fips, 1, 2)
save aggregated_deaths, replace
merge m:m fips2 using indexmerge.dta
drop if _merge == 1
drop if _merge == 2
drop _merge
save indexmerge,replace
*import and add control var, income
 import delimited "C:\Users\rubycb\Downloads\ACSST5Y2020.S1901-Data.csv", clear
keep v47 v1
rename v1 county
rename v47 medinc
gen county2 = substr(county, 10, 6)
drop county
rename county2 county
save income, replace
use indexmerge, clear
merge m:m county using income.dta
drop if _merge == 1
drop if _merge == 2
drop _merge
save indexmerge, replace
*now collapse zip codes into countys
destring, replace
collapse fips year death index countypop medinc, by(county)
drop fips
save indexmerge, replace
*regression to answer question
reg index deaths countypop medinc, robust
test deaths
test countypop
test medinc



































