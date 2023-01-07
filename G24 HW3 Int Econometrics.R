install.packages("wooldridge")
library(wooldridge)
library(AER)
library(dplyr)
library(stargazer)
data(airfare)

#################### Question 1 #################### 
#### 1.1 ####

df <- airfare %>%  filter(year=='1997')
passenOLSlog <- lm(lpassen ~ lfare+ ldist + ldistsq, data = df)
summary(passenOLSlog)$coefficients
stargazer(passenOLSlog, type="latex", single.row=T, header=T)

#### 1.2 #### 

# The coefficient of log(fare) is  -0.3911724 and significant at the 1% level. 
# The interpretation is that on average for every 1% increase in the fare, the number of 
# passengers decreases by 0.39%, ceteris paribus.

# Price elasiticity i.e. how much demand changes as a result of a change in price
# This is alpha_1_hat as both our independent and dependent variables are in logs.

#### 1.3 ####

passenOLS <- lm(passen ~ fare + dist + I(dist^2), data = df)
summary(passenOLS)$coefficients
stargazer(passenOLS, type="text", single.row=T, header=T)

# Interpretration: if the average 1 way fare increases by $1 , the avg nb of passengers per day
# for flights is decreased by approximately 1.

pelasticity <- -1.088398 * mean(df$fare)/mean(df$passen)

pelasticity

# Our result for price elasiticity is -0.3146387, which is smaller in magnitude than that in 1.2.

#################### Question 2 #################### 
# The estimates in Model 1 are likely not to be consistent because of a form of endogeneity called
# simultaneous equations (there is reverse causality). The fare and the number of passengers cannot
# be assumed to vary freely because in equilibrium they are jointly determined by the supply and
# demand equations, and we only have the demand equation. Hence, the lfare is an endogenous variable.
# Another source of endogeneity is omitted variable bias, as there are further variables which could
# impact the number of passengers and are not regressors e.g. the size of the population in the city 
# of origin/destination. However, to the constraints of this report, we have decided to focus on 
# simultaneous equations.

# The parameters of price in demand equations always have a positive bias. This means that actually 
# the value we estimated is closer to zero than the actual one (which is more negative)

#The intuition is the following:
# (1) There is an exogenous increase in fares.
# (2) The number of passengers decreases.
# (3) After such decrease in passengers, the firm lowers the price to attract more passengers.
# (4) The number of passengers increases again. 


#################### Question 3 #################### 
####3.1####

# An instrumental variable must be relevant i.e. correlated with the endogenous regressor and 
# exogenous i.e. uncorrelated with the error term 

####3.2####

# An estimator is consistent under the assumptions IID, RANK, MOMENTS and ERRORS;
# the mean-independence errors being the only assumption missing in our model. 
# An instrumental variable restores the consistency of the estimators as the instrument 
# should be uncorrelated with the error term; the idea of using this method is to
# split the endogenous variables into two components: the exogenous and the endogenous part.

#################### Question 4 #################### 
####4.1####

# The fact that the variable concen is not a vector of 1s implies that there is not a monopoly (there is
# competition). One would therefore expect that as the market share of the biggest carrier is greater, such
# company has higher market power and economies of scale in production, what would enable it to lower
# prices to limit their competitors growth; thus concen negatively affects prices


####4.2####
# The requirement for concen to be exogenous is that it is not correlated with any of the variables captured
# by the error term which also impact the number of passengers. Moreover, to be used as an instrument it
# must also be relevant, that is concen is correlated with the endogenous regressor

#################### Question 5 #################### 
####5.1####
##b##
stage1 <- lm(lfare ~ concen + ldist + ldistsq, data = df)
summary(stage1)$coefficients
stargazer(stage1, type="text", single.row=T, header=T)

####5.2####
# No, the effect of our instrument concen on lfare (γ1) does not align with our suspicion from Q4.1, as it is
# positive instead of negative. The effect is statistically significant (at 1% level). This is important because
# we must establish that the impact of the instrument on the endogenous variable is significant for it to be
# relevant, which implies it is valid as we assumed exogeneity


#################### Question 6 #################### 
####6.1####
passenIV <- ivreg(lpassen ~ ldist + ldistsq + lfare|concen + ldist + ldistsq, data = df)
summary(passenIV)$coefficients
stargazer(passenIV, type="text", single.row=T, header=T)

####6.2#### (interpret new coefficient of log fare)
# The coefficient on log(fare) for 2SLS is -1.174, which means that on average a 1% increase in the fares is
# associated with a 1.17% decrease in the average number of passengers ceteris paribus. On the other hand,
# the coefficient for OLS  is −0.39. Hence, the bias of the OLS estimate is of the expected sign (positive: OLS > 2SLS )

####6.3#### (test for the exogeneity of log fare)
#a
#Our H0 is that lfare is exogenous
#H1 is that lfare is endogenous

#b
#Under H0, the test statistic behaves as a normal with mean 0 and variance 1.

#c
Var_a1 <- ((diag(vcov(passenOLSlog))))[2]
Var_a1
Var_a1_2SLS <- (diag(vcov(passenIV)))['lfare']
Var_a1_2SLS
t=(coef(passenIV)[4] - coef(passenOLSlog)[2])/sqrt(Var_a1_2SLS - Var_a1)
t

#d
z <- qnorm(0.975)
#Our t-statistic is |-2.045221| > 1.9599 = z. As the absolute value of our t-statistic is 
#greater than z, we can reject the null hypothesis and argue that lfare is endogenous.

####6.4#### (are overidentifying restrictions a concern in this model?)
#No, they are not a concern since the number of instruments is not greater than the number of potential 
#endogenous regressors. If it was, we could test it with a Sargan or J-test.


#################### Question 7 #################### 
#The exogeneity assumption is indeed a concern here because there are other channels through which market share can affect
#the average number of passengers in ways that are not mediated by the fares. For instance, variables which could impact 
#the number of passengers are new technology, customer loyalty, talented employees or acquiring competitors. A firm with a 
#substantial market share might be able to innovate and put in place new technology which enables for an enhanced flying 
#experience, that could increase the average number of passengers. It could also be that a firm with a big market share is
#more able (relative to those with smaller market share) to establish brand loyalty and strengthen customer relationships - 
#this way, satisfied customers speak to others who then become new customers, which would also increase the average number
#of passengers.

