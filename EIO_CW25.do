********************************************
** EIO CW 2025 Production Functions 1A-1D **
********************************************

clear all

*Set WD
cd"/Users/thomastrainor-gilham/Library/CloudStorage/OneDrive-UniversityofBristol/TB2/EIO TB2/EIO CW 2025"

*Set up log

*Import data
use HA_Data.dta, clear

*Create a set of year dummy variables. DO YOU NEED THIS???
tab year, gen(year_)
*For each unique value of year, it generates a binary indicator variable named year_1, year_2, etc.These dummy variables will be used to control for time fixed effects

****************************************************************************

/* 
Q1.A REPORT SAMPLE STATISTICS (# of observations, mean, median, standard deviation, etc) for the key variables in the data (yit, lit, kit, iit, and ait) {5 Marks}
*/

* FOR FULL SAMPLE
summarize Y L K I A
// summarize Y L K I A, detail


* Create BALANCED SUB-SAMPLE (firms present in all years)
bysort firm: egen nyears = count(year)  // Count number of years per firm
egen maxyears = max(nyears) 			// Create temp var of max number of years in dataset (10)
gen balanced = (nyears == maxyears) 	// gen binary var, (1 if balanced, 0 otherwise)
drop maxyears 							// drop temp var
summarize Y L K I A if balanced == [1]  // Summarise if balanced sub-panel


* FOR EXITERS (firms not present in all years)
summarize Y L K I A if balanced == [0] // Summarise if not balanced sub-panel



*****************************************************************************************
/* 
Q1.B 
"Using only the balanced sub-panel compute the total, between, within, and random effects estimators for equation (1). How are they different? 
Perform a Hausman test of random effects versus fixed effects (i.e., within estimator). 
What have you learned about firm heterogeneity and about possible measurement error from these results?"
																													{10 Marks}
*/

* USE ONLY BALANCED SUB-PANEL:
keep if balanced == [1]

* 1. Total (Pooled OLS) with clustered robust SE
reg Y A L K
estimates store total

*NOW DECLARE PANEL DATA STRUCTURE
xtset firm year
*firm is the panel identifier (each unique firm)
*year is the time variable

* 2. Between Estimator
xtreg Y A L K, be
estimates store between

* 3. Within Estimator (Fixed Effects) with clustered robust SE
xtreg Y A L K, fe 
estimates store fixed

* 4. Random Effects Estimator with clustered robust SE
xtreg Y A L K, re
estimates store random

* Display all estimates for comparison
esttab total between fixed random, se star stats(N r2) b(%9.3f)


* Hausman Test (Fixed vs Random Effects)
// Note: Hausman test doesn't depend on robust SE. Therefore re-run without robust for 
//       consistency

// Default Hausman test
hausman fixed random



*****************************************************************************************

/* Q1.C
"Using the balanced sub-panel, compute difference estimators in which you take
differences over t of both sides of equation (1). Report results from estimates of the first (i.e., 1 year) differenced model, second (i.e., 2 years) differenced model and third (i.e., 3 years) differenced model. What do these tell you about measurement error? Base your discussion on Golsbee (2000, NBER)" */


* Generate first differences (1-year)
gen d1_Y = D1.Y
gen d1_A = D1.A
gen d1_L = D1.L
gen d1_K = D1.K

* Estimate first-difference model
reg d1_Y d1_A d1_L d1_K, noconstant robust
estimates store diff1
//   "noconstant"  : since differencing removes α0
// "cluster(firm)" : Adjusts standard errors for within-firm correlation

// Generate second differences (2-years)
gen d2_Y = Y - L2.Y
gen d2_A = A - L2.A
gen d2_L = L - L2.L
gen d2_K = K - L2.K

// Estimate second-difference model
reg d2_Y d2_A d2_L d2_K, noconstant robust
estimates store diff2

// Generate third differences (3-years)
gen d3_Y = Y - L3.Y
gen d3_A = A - L3.A
gen d3_L = L - L3.L
gen d3_K = K - L3.K

// Estimate third-difference model
reg d3_Y d3_A d3_L d3_K, noconstant robust
estimates store diff3

// Display all estimates for comparison
estimates table diff1 diff2 diff3, star stats(N r2) b(%9.3f)

esttab diff1 diff2 diff3, se star b(%9.3f) stats(N r2)

esttab total between fixed random, se star stats(N r2) b(%9.3f)


*****************************************************************************************

/* Q1.D.i
"Using the full (unbalanced) panel, compute the pooled and fixed-effect estimators. 
How do these estimates compare to the pooled and fixed-effect estimates on the balanced panel? 
What does this tell you about the possible effects of selection in this dataset?
*/

* Clear any existing data
clear all

* Set WD
cd"/Users/thomastrainor-gilham/Library/CloudStorage/OneDrive-UniversityofBristol/TB2/EIO TB2/EIO CW 2025"

* Reimport data
use HA_Data.dta, clear

*DECLARE PANEL DATA STRUCTURE
xtset firm year

// Unbalanced Pooled OLS with robust SEs
reg Y A L K, robust
estimates store pooled_unbal

// Fixed Effects with robust SEs
xtset firm year
xtreg Y A L K, fe robust
estimates store fe_unbal 

* BALANCED SUB-SAMPLE (firms present in all years)
bysort firm: egen nyears = count(year) // Count number of years per firm
egen maxyears = max(nyears) 	// Create temp var of max number of years in dataset (10)
gen balanced = (nyears == maxyears) // gen binary var, (1 if balanced, 0 otherwise)
drop maxyears 					// drop temp var
keep if balanced==1 		// Remove unbalanced panel data

// Balanced Pooled OLS with robust SEs
reg Y A L K, robust
estimates store pooled_bal

// Fixed Effects with robust SEs
xtreg Y A L K, fe robust
estimates store fe_bal

// Display estimates for comparison

esttab pooled_unbal fe_unbal pooled_bal fe_bal, se star b(%9.3f) stats(N r2)


/* Q1.D.ii
"Use a Probit model to estimate the probability that a firm exits in period t + 1 as a function of iit, ait, and kit. (Variable X in the dataset is zero in t if the firm exits in t + 1.) 
Compute the implied inverse mills ratio (as in a standard endogenous sample selection model) and include it as a regressor in both your pooled and fixed effect regressions above. 
Does this appear to correct for selection bias?
*/

* Clear any existing data
clear all

* Set WD
cd"/Users/thomastrainor-gilham/Library/CloudStorage/OneDrive-UniversityofBristol/TB2/EIO TB2/EIO CW 2025"

* Reimport data
use HA_Data.dta, clear

* DECLARE PANEL DATA STRUCTURE
xtset firm year

* Generate exit variable (1 if firm exits, 0 if continues)
gen exit = 1-X

* Sort data by firm and year
sort firm year

* Probit model for firm exit
probit exit i.year K I A
// 'i.year' -> creates a dummy variable for each unique value of the year variable (except one omitted reference year) These year dummies control for any time-specific effects that might affect firm exit probabilities

predict p_exit, p

* Calculate the inverse Mills ratio
gen z = invnormal(p_exit)
gen imr = normalden(z)/normal(z) if exit==1
replace imr = normalden(z)/(1-normal(z)) if exit==0

* Unbalanced Pooled OLS
reg Y A L K
estimates store pooled_full

* Unbalanced Fixed Effects
xtset firm year
xtreg Y A L K, fe
estimates store fe_full

* Pooled OLS with IMR
reg Y A L K imr
estimates store pooled_full_imr

* Fixed Effects with IMR
xtreg Y A L K imr, fe
estimates store fe_full_imr

* Display results with and without IMR
esttab pooled_full fe_full pooled_full_imr fe_full_imr, se star b(%9.3f) stats(N r2)

********************************************************************************************************
*Runs a fixed effects panel regression that includes:
xtreg  Y A L K year_*, fe robust
// Firm fixed effects (fe)
// Year dummy variables ('year_*' which includes all variables starting with "year_"), Including year dummies (like year_2000, year_2001, ...) allows you to control for macro-level shocks or economy-wide changes that affect all firms in a given year.
// Robust standard errors (robust)
********************************************************************************************************


********************************************
*** EIO CW 2025 Production Functions 1E  ***
********************************************

clear all

*Set WD
cd"/Users/thomastrainor-gilham/Library/CloudStorage/OneDrive-UniversityofBristol/TB2/EIO TB2/EIO CW 2025"

*Import data
use HA_Data.dta, clear
// 'L' -> log of labour, lit
// 'I' -> log of investment, iit
// 'K' -> log of capital, kit
// 'Y' -> log of output, yit

* DECLARE PANEL DATA STRUCTURE
xtset firm year


*********************************************************************************************

					  /***** First Stage: Estimating αL *****/
				
* Generate squared terms and interaction terms for all state variables and investment
gen K_sq = K^2
gen A_sq = A^2
gen I_sq = I^2 

gen K_I = K * I
gen A_I = A * I
gen K_A = K * A

* Define the phi function to include all state variables
global phi = "year K A I K_sq A_sq I_sq K_I A_I K_A"

* Run first stage regression to estimate αL and store results
reg Y L $phi, robust

* Store predictions and coefficient
predict fitted, xb

* Store the estimated coefficient for log labour (α̂L) 
global aL = _b[L] 

*********************************************************************************************

  /***** Second Stage: Estimating αK and αA without controlling for Endogenous Exit *****/


* Sort data by firm and year to ensure the lagged variables work correctly
sort firm year 

* Create the dependent variable: yit - α̂Llit (using labour coefficient from first stage)
gen dep_var = Y - ${aL}*L

* Create lagged phi value from first stage
gen lag_phi = l.fitted - ${aL}*l.L

* Create lagged state variables
//gen lag_K = l.K
//gen lag_A = l.A

* Create lagged state variables
by firm: gen lag_K = K[_n-1] if _n > 1
by firm: gen lag_A = A[_n-1] if _n > 1

/* Run NLLS Regression with both state variables */
* dep_var = αK*kit + αA*ait + ẽh(φ̂t-1 - αK*kit-1 - αA*ait-1) + ξit + eit
* We approximate ẽh with a second-order polynomial
nl (dep_var = {aK}*K + {aA}*A + {a0h} ///
           + {a1h}*(lag_phi - {aK}*lag_K - {aA}*lag_A) ///
           + {a2h}*(lag_phi - {aK}*lag_K - {aA}*lag_A)^2) if year > 1 & !missing(dep_var, K, A, lag_phi, lag_K, lag_A)

*********************************************************************************************

				/***** Second Stage: Controlling for Endogenous Exit *****/


/* Create survival indicator based on X */
gen survival = X  /* X is 0 in t if firm exits in t+1, so X itself indicates survival */
order survival, after(year)
// I have assumed that if X == 10, this means the firm survives into year 11, and am keeping all year 10 observations as a result


/* Estimate propensity score (probability of survival) */
global s = "l.(year K A I K_sq A_sq I_sq K_I A_I K_A)"
probit survival $s
predict propensity_score, pr

/* Second-stage estimation with survival correction */
nl (dep_var = {aK}*K + {aA}*A + {a0g} ///
          + {a1g}*(lag_phi - {aK}*lag_K - {aA}*lag_A) ///
          + {a2g}*(lag_phi - {aK}*lag_K - {aA}*lag_A)^2 /// 
          + {a3g}*propensity_score ///
          + {a4g}*propensity_score^2 ///
          + {a5g}*(lag_phi - {aK}*lag_K - {aA}*lag_A)*propensity_score) if year > 1 & !missing(dep_var, K, A, lag_phi, lag_K, lag_A, propensity_score)
		  
		  
**---------------------------------------**
**     FIRM CLUSTERED BOOTSTRAP S.E.     **
**---------------------------------------**

/****** NO ENDOGENOUS EXIT CONTROL ******/

clear all
cd "/Users/thomastrainor-gilham/Library/CloudStorage/OneDrive-UniversityofBristol/TB2/EIO TB2/EIO CW 2025"

* Import data
use HA_Data.dta, clear

* Declare panel data structure
xtset firm year

* Generate squared terms and interaction terms for all state variables and investment
gen K_sq = K^2
gen A_sq = A^2
gen I_sq = I^2 
gen K_I = K * I
gen A_I = A * I
gen K_A = K * A

* Define the phi function to include all state variables
global phi = "year K A I K_sq A_sq I_sq K_I A_I K_A"

* Sort data by firm and year to ensure the lagged variables work correctly
sort firm year 

* Create lagged variables
by firm: gen lag_K = K[_n-1] if _n > 1 // REMOVE THESE!!!
by firm: gen lag_A = A[_n-1] if _n > 1


program op_estimator, eclass
    version 18.0
	
	sort firm year
	
    * Run regression without panel structure for the first stage
    regress Y L $phi
    
    * Store predictions and coefficients from first stage
    tempvar fitted
    predict `fitted', xb
    
    * Create the dependent variable: yit - α̂Llit
    tempvar dep_var
    gen `dep_var' = Y - _b[L]*L
    
    * Create lagged phi value from first stage
    tempvar lag_phi
    gen `lag_phi' = l.`fitted' - _b[L]*l.L
    
    /* Run NLLS Regression with both state variables */
    nl (`dep_var' = {aK}*K + {aA}*A + {a0h} ///
              + {a1h}*(`lag_phi' - {aK}*lag_K - {aA}*lag_A) ///
              + {a2h}*(`lag_phi' - {aK}*lag_K - {aA}*lag_A)^2) if year > 1 & !missing(`dep_var', K, A, `lag_phi', lag_K, lag_A)
			  
    * Store results for bootstrap
    matrix b = e(b)
    matrix V = e(V)
    ereturn post b V


end

* Run Bootstrap
bootstrap _b, reps(400) seed(12345) cluster(firm) idcluster(newid) group(year) nodots: op_estimator if year > 1 & !missing(K, A, I, lag_K, lag_A)


******************************************************************************************************************
******************************************************************************************************************


/****** NO ENDOGENOUS EXIT CONTROL ******/

clear all
cd "/Users/thomastrainor-gilham/Library/CloudStorage/OneDrive-UniversityofBristol/TB2/EIO TB2/EIO CW 2025"

* Import data
use HA_Data.dta, clear

* Declare panel data structure
xtset firm year

* Generate squared terms and interaction terms for all state variables and investment
gen K_sq = K^2
gen A_sq = A^2
gen I_sq = I^2 
gen K_I = K * I
gen A_I = A * I
gen K_A = K * A

* Define the phi function to include all state variables
global phi = "year K A I K_sq A_sq I_sq K_I A_I K_A"

* Sort data by firm and year to ensure the lagged variables work correctly
sort firm year 

* Create lagged state variables
gen lag_year = l.year
gen lag_K = l.K
gen lag_A = l.A
gen lag_I = l.I
gen lag_K_sq = l.K_sq
gen lag_A_sq = l.A_sq
gen lag_I_sq = l.I_sq
gen lag_K_I = l.K_I 
gen lag_A_I = l.A_I
gen lag_K_A = l.K_A


* Create survival indicator using a regular variable name
//gen survival = (X == 1) if year < $maxyear & !missing(X)
gen survival = X 
order survival, after(year)


/***** Second Stage: Controlling for Endogenous Exit *****/

program op_estimator_exit, eclass
    version 18.0
	
	*Sort firm year for lagged variables
	sort firm year
	
    * Run regression without panel structure for the first stage
    regress Y L $phi, vce(cluster firm)
    
    * Store predictions and coefficients from first stage
    tempvar fitted
    predict `fitted', xb
    
    * Create the dependent variable: yit - α̂Llit
    tempvar dep_var
    gen `dep_var' = Y - _b[L]*L
    
    * Create lagged phi value from first stage
    tempvar lag_phi
    gen `lag_phi' = l.`fitted' - _b[L]*l.L

	/* Estimate propensity score (probability of survival) using lagged variables */
	probit survival lag_year lag_K lag_A lag_I lag_K_sq lag_A_sq lag_I_sq lag_K_I lag_A_I lag_K_A, robust
	tempvar propensity_score
	predict `propensity_score', pr

	/* Second-stage estimation with survival correction */
	nl (`dep_var' = {aK}*K + {aA}*A + {a0g} ///
          + {a1g}*(`lag_phi' - {aK}*lag_K - {aA}*lag_A) ///
          + {a2g}*(`lag_phi' - {aK}*lag_K - {aA}*lag_A)^2 /// 
          + {a3g}*`propensity_score' ///
          + {a4g}*`propensity_score'^2 ///
          + {a5g}*(`lag_phi' - {aK}*lag_K - {aA}*lag_A)*`propensity_score') if year > 1 & !missing(survival, lag_year, lag_K, lag_A, lag_I, lag_K_sq, lag_A_sq, lag_I_sq, lag_K_I, lag_A_I, lag_K_A, `lag_phi', `propensity_score')
		  
    * Store results for bootstrap
    matrix b = e(b)
    matrix V = e(V)
    ereturn post b V

end			  

bootstrap _b, reps(400) seed(10101) cluster(firm) idcluster(newid) group(year) nodots: op_estimator_exit if year > 1 & !missing(K, A, I, lag_K, lag_A, lag_I, survival)

// & !missing(`dep_var', K, A, `lag_phi', lag_K, lag_A, `propensity_score', `propensity_sq')
