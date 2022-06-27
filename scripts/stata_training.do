// set wd
// cd "C:\Users\mrhayes\OneDrive - AlixPartners\Documents\projects\trainings\stata"

**# Import data

import excel "data/cars_test_without99.xlsx", sheet("cars") firstrow

save "data/cars_test_without99.dta"

clear

import excel "data/cars_test_99.xlsx", sheet("cars") firstrow

save "data/cars_test_99.dta"

clear

import excel "data/lookup_radio_model.xlsx", firstrow

save "data/lookup_radio_model.dta"	

clear

// Append data from 1999 to the rest of data

use data/cars_test_without99

append using data/cars_test_99, force

summarize

// variables 'he' and 'do' were converted from double and byte to str6 and str17, respectively

**# CLEANING
gen year = 1900 + ye

drop ye

// 3.2

summarize

// adjust price for NGDP per capita.
gen ngdp_pc = ngdp/pop

gen adj_price = pr/ngdp_pc

summarize adj_price

// to divide or multiply the exchange rate ? what are the units?

gen common_currency_price = pr/avdexr

gen exporter_currency_price = pr/avexr

summarize pr adj_price common_currency_price exporter_currency_price




// 3.3

drop if zcode == 17 //should now be 11,404 observations

//3.4


gen luxury = 0
replace luxury = 1 if cla == "luxury"

gen compact = 0
replace compact = 1 if cla == "compact"

gen lux_alfa_romeo = 0
replace lux_alfa_romeo = 1*luxury if brand == "alfa romeo"

// 3.5 

replace model = subinstr(model, ",", "/",.)


// looks like operation 3.5 has already been completed in the dataset we have...

// 3.6


gen obs_num = _n

// 3.7

gen total_obs = _N

// 3.8 
// Sorting by brand to find total observations per brand

bysort brand: gen tot_obs_per_brand = _N


// 3.9 
// finding average price for each brand

bysort brand: egen avg_brand_pr = mean(pr)

**# 4.0
// Tables

/// 4.1, table of average price, weight, and length by car class

table cla, statistic(mean pr we le)

collect export "tables/table4.1.xlsx" // export the table to XLSX file


// 4.2, table of total number of observations for each brand per country

table brand ma, count()
collect export "tables/table4.2.xlsx"

// 4.3 and 4.4

table brand ma, statistic(sum pr)

collect export "tables/table4.3.xlsx"

table brand ma, statistic(sum qu)

collect export "tables/table4.4.xlsx"

**# 5.0

// save "data/cars_test_Q5.dta"
use "data/cars_test_Q5.dta"

// before the following command there are 11,404 obs

joinby brand model using data/lookup_radio_model.dta, unmatched(both)


// Let's look at which models were missing Radio data:

table brand model if Radio >=.

// and save this to a table

collect export "tables/table5.xlsx"