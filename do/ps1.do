cd "C:\Users\24693\OneDrive - Handelshögskolan i Stockholm\Documents\Plugg\Metrics 2\PS\1"

global pics "C:\Users\24693\OneDrive - Handelshögskolan i Stockholm\Documents\Plugg\Metrics 2\PS\1\Pictures"

clear all
set obs 100

set seed 10

gen x_base = runiform(0,1)

gen d_base = runiform(0,1)

br

gen X = 1 if x_base <= 0.5

replace X = 2 if x_base > 0.5 & x_base <= 0.75
replace X = 3 if x_base > 0.75

gen Y_0 = runiform(0,1)

gen Y_1 = runiform(0,1) * X

gen IT = Y_1 - Y_0


twoway (kdensity IT if X == 1, ytitle("Density") xtitle("Individual Treatment Effect") legend(label(1 "X = 1") label(2 "X = 2") label(3 "X = 3"))) (kdensity IT if X == 2) (kdensity IT if X == 3) 

graph export "$pics\densities.png", replace 

gen d = 0

replace d = 1 if X == 1
replace d = 1 if X == 2 & d_base <= 2/3
replace d = 1 if X == 1 & d_base <= 1/3

gen Y_i = Y_0
replace Y_i = Y_1 if d == 1

sum IT

reg Y_i d 


