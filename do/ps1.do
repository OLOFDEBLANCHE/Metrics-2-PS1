cd "C:\Users\24693\OneDrive - Handelshögskolan i Stockholm\Documents\Plugg\Metrics 2\PS\1"

global pics "Pictures"

global data "data"

clear all

**# Question 1

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

replace d = 1 if X == 3
replace d = 1 if X == 2 & d_base <= 2/3
replace d = 1 if X == 1 & d_base <= 1/3

gen Y_i = Y_0
replace Y_i = Y_1 if d == 1

//ATE is not identified. MAR not satisfied
sum IT
reg Y_i d

//ATT is identified. Since no systematic  differnce between low potetntial outcome
sum IT if d == 1
reg Y_i d 

//CATT
reg Y_i d if X == 1
sum IT if X == 1

//CATT
reg Y_i d if X == 2
sum IT if X == 2

//CATT
reg Y_i d if X == 3
sum IT if X == 3

**# Question 2

clear all

set seed 10 

set obs 200

g Y_0 = rnormal(0,1)

g bern_base = runiform(0,1)

g X = 0 
replace X = 1 if bern_base < 0.3

g treat_base = runiform(0,1)

g Y_1 = Y_0 + 1 - 2 * X

g D = 0
replace D = 1 if treat_base <= 0.5

gen Y = Y_0
replace Y = Y_1 if D == 1 

gen IT = Y_1 - Y_0

sum IT

sum Y if D == 1
local d1 : display %8.7f r(mean) 


sum Y if D == 0
local d0 : display %8.7f r(mean) 

display `d1' - `d0'

reg Y D

//Exactly the same 

forvalues i = 0/1{
	
	sum Y if D == 1 & X == `i'
	local d1 : display %9.8f r(mean) 


	sum Y if D == 0 & X == `i'
	local d0 : display %9.8f r(mean) 
	display `d1' - `d0'
	
}


	sum Y if D == 0 & X == 1
	local d0 : display %8.7f r(mean) 
display `d0'
reg Y X##D



**# Question 3

clear all 
set seed  10

set obs 100

g Y_1 = rnormal(0,1)

g Y_0 = rnormal(0,1)

g D = _n <= 50

g Y = Y_1*D + Y_0*(1-D)

g IT = Y_1 - Y_0

twoway (hist IT,  ytitle("Density") xtitle("Individual Treatment Effect"))

graph export "$pics\densities2.png", replace 


reg Y D 
eststo m1 

local tao = r(table)[1,1]

display r(table)[1,1]

esttab m1 using "$data\Q3.tex", p replace

	
	
frame create measures 
frame change measures 
set obs 1000

g measures = 0

frame change default


forvalues i = 1/1000{
	
	gen random = runiform(0,1)
	sort random 
	gen D_a = _n <= 50
	
	quietly reg Y D_a 
	local measure = r(table)[1,1]
	frame change measures
	quietly replace measures = `measure' if `i' == _n
	
	frame change default 
	
	drop D_a random
}

frame change measures 

hist measures, xline(`tao')

gen count = `tao' < measures

count if count == 1
display r(N)/1000

drop count

frame change default
order Y D
display Y[1]


forvalues i = 1/1000{
	
	matrix obs = J(100,2,.)
	
	forvalues t = 1/100{
		gen random = runiform(0,1)
		sort random 
		matrix obs[`t',1] = Y[1]
		matrix obs[`t',2] = D[1]
		
		drop random
	}
	
	
	preserve 
	svmat double obs 
	
	quietly reg obs1 obs2 
	
	restore 
	
	frame change measures 
	quietly replace measures = r(table)[1,1] if `i' == _n
	
	frame change default 
}

frame change measures

hist measures, xline(`tao')