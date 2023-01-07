.libPaths("/Users/zoejamois/Documents/R")
library(lmtest)
install.packages('gap')
install.packages('estimatr')
library(gap)
library(AER)
################# Exercise 1: #################
################# Question 1: #################

set.seed(100)

#We define the random variables that will generate the dataset. 

x1 <- runif(n=200, min=0, max=1)
x2 <- rnorm(n=200, mean=0, sd=1)
v <- rnorm(n=200, mean=0, sd=sqrt(2))

y <- 1.5 + 2*x1 + 3*x2 + v

#We generate the dataset once we defined the variables. 

df<- data.frame(y, x1, x2)

################# Question 2: #################

reg1<-lm(y~x1+x2,data=df) #We estimate the model by OLS
summary(reg1) 
betahat <- coef(reg1) #We put all parameters estimates in a vector. 

################# Question 3: #################

coefci(reg1) #0.95 not necessary (default)
coefci(reg1)[2,]   #We extract the 95% confidence interval for beta_1

################# Question 4: #################

#We extract the parameter estimate of interest (beta_1) and its standard error. 

beta_1 <- as.numeric(betahat[2]) 
se_1 <- as.numeric(sqrt(diag(vcov(reg1)))[2])

#We rename the 0.975th quantile of the normal distribution z. 

z <- qnorm(0.975)

#We compute the lower and upper bounds of the interval. 

lower_bound <- round((beta_1-se_1*z),2) 
upper_bound <- round((beta_1+se_1*z),2) 

#Finally we put the bounds into a vector to construct the interval. 

cbind(lower_bound,upper_bound)

################# Question 5: #################

#It doesn’t include zero, it means it will be statistically different from 0, it is significant. 

################# Question 6: #################

#We divide the dataset into two parts.

A<- df[1:100,]

B <- df[101:200,]

#We run the 2 regressions on the restricted models using OLS. 

reg2=lm(y~x1+x2,data=A)
reg3=lm(y~x1+x2,data=B)

#H0: (beta_0_A,beta_1_A,beta_2_A) = (beta_0_b,beta_1_b,beta_2_b) 
#H1: (beta_0_A,beta_1_A,beta_2_A) =! (beta_0_b,beta_1_b,beta_2_b) 

#We use a F-statistic, which we can do because errors are normal by assumption. 

y1 <- A[1] #Dependent variable for A
x1 <- A[2:3] #Explanatory variables for A

y2<- B[1] #Dependent variable for B
x2 <- B[2:3] #Explanatory variables for B

chow.test(y1,x1,y2,x2) 

#F-statistic = 0.7342459. The F-statistic follows a Chi-Square distribution under the null. 
#P-value = 0.5327458. 

#The p-value is higher than 10%, we can't reject the null hypothesis. 

#The result is convincing, we cannot reject that they are equal since they are 
#both result of an OLS coming from 2 equally distributed groups from the same random dataset.

################# Exercise 2: #################

housing <- read.table("/Users/zoejamois/Documents/M1/Intermediate Econometrics/HW2/housing.csv",h=T)


################# Question 1: #################

#We create the log transformation of the variables: "crim", "medv":

housing$lg_crim <- log(housing$crim)
housing$lg_medv <- log(housing$medv)

#We estimate the model by OLS.
reg_housing <- lm(formula = lg_medv ~ age + lg_crim + nox + lstat + ptratio ,data = housing)

summary(reg_housing) 

beta_3 <- coef(reg_housing)[4] #We extract the nox coefficient
beta_4 <- coef(reg_housing)[5] #We extract the lstat coefficient

#We will use a t-test to evaluate the significance. Under the null 
# hypothesis, such test is distributed as a standard normal distribution.
# If the absolute value of the t-statistic is greater than the critical value of 1.96 we reject the null hypothesis.

  #Beta_3: If the nitrogen oxides concentration increases by 1 unit, the median price of
  #houses decreases on average  by 52.3% ceteris paribus.

se_3 <- as.numeric(sqrt(diag(vcov(reg_housing)))[4]) #We extract the standard error of beta 3
t_3 <- beta_3/se_3 #We compute the t-statistic
z_beta3 <- qnorm(0.975) 


abs(t_3) > z_beta3 #We can reject the null hypothesis

#The coefficient is significant at a 95% level.

  #Beta_4: If the percentage of low socioeconomic increases by
  #1 percentage point, the median price of houses decreases on average  by 4% ceteris paribus.

se_4 <- as.numeric(sqrt(diag(vcov(reg_housing)))[5]) #We extract the standard error of beta 4
t_4 <- beta_4/se_4 #We compute the t-statistic
z_beta4 <- qnorm(0.975)

abs(t_4) > z_beta4 #We can reject the null hypothesis

  #The coefficient is significant at a 95% level.

 
################# Question 2: #################

#OPTION 1 TO TEST FOR HETEROSKEDASTICITY:
#Breusch–Pagan test from the AER Package:

bptest(reg_housing, varformula= ~ age +log(crim) + nox + lstat + ptratio + I(age^2)+ I(log(crim)^2) + I(nox^2) + I(lstat^2) + I(ptratio^2), data=housing)

# P-value=2.916e-14 (smaller than 1%) -> We can reject the null hypothesis  at 1%-> There's heteroskedasticity


#OPTION 2 TO TEST FOR HETEROSKEDASTICITY:

#General specification test including the squares of the explanatory variables:

resOLS <- residuals(reg_housing)
resOLS2 <- resOLS^2  # We square the residuals 

#We create the squared variables:

housing$age2 <- (housing$age)^2
housing$lg_crim2 <- log(housing$crim)^2
housing$nox2 <- (housing$nox)^2
housing$lstat2 <- (housing$lstat)^2
housing$ptratio2 <- (housing$ptratio)^2

#We regress the squared residuals on the original variables and their squares:

aux <- lm(resOLS2 ~ age +lg_crim + nox + lstat + ptratio + age2 + lg_crim2 + nox2 + lstat2 + ptratio2, data=housing)  


#Null: All the coefficients of the parameters of the auxiliar regression are 0 
#Alternative: At least one of them is not zero (there's heteroskedasticity)

#We're using Wald testsince we don't know the distribution of errors and the sample 
#is not big enough (an F test does not converge asymptotically to Wald test)

#The Wald statistic follows a Chi square distribution under the null.

linearHypothesis(aux, c("age=0","lg_crim=0", "nox=0","lstat=0","ptratio=0","age2=0","lg_crim2=0","nox2=0","lstat2=0","ptratio2=0"),test = "Chisq", vcov. = vcovHC(aux))

w_statistic <- qchisq(0.95,10)

#If the W-statistic is greater than the critical value of the Chi square with 10 degrees of freedom at a 95% level of confidence we reject the null hypothesis.

#As 41.699 > 18.30704 we reject the null hypothesis.
#We conclude that there's heteroskedasticity 

################# Question 3: #################

# Option 1: we estimate the model using FGLS:

#Since we're considering a multiplicative model we log transformate
#the square of the residuals

lresOLS2 <- log(resOLS2)

aux2 <- lm(lresOLS2 ~ age + lg_crim + nox + lstat + ptratio, data = housing) 

ghat <- fitted(aux2) #Vector of the fitted log squared residuals 
hhat <- exp(ghat) #This is our estimation of heteroskedasticity robust covariance matrix 

#We estimate the model using FGLS by weighting the original model by the inverse of the estimated variance
FGLS <- lm( log(medv) ~ age + lg_crim + nox + lstat + ptratio, weights = I(1 / hhat), data = housing)

#We extract the two-sided 99% confidence interval of lstat under the heteroskedasticity robust covariance matrix obtained from FGLS
coefci(FGLS,l=0.99)[5,]

#We also extract the confidence interval of lstat under the heteroskedasticity robust covariance matrix by using the R 
#command (without estimating FGLS) - we would expect these to be equivalent
coefci(reg_housing, l=0.99, vcov. = vcovHC(reg_housing))[5,]

#Finally, we extract the confidence interval of lstat under the homoskedastic covariance matrix
coefci(reg_housing,l=0.99)[5,]

#We observe that the confidence intervals for lstat, for both heteroskedasticity robust covariance matrices 
# are wider than that for the homoskedastic covariance matrix. The intuition behind is that when we use a heterskedastic
# functional form we are relaxing the variance assumption of OLS. By being more flexible with the distributuion of the 
#error term, we lose some precision in our estimation and hence we would expect bigger confidence intervals for our parameters estimates.

################# Question 4: #################

#We estimate the model using GLS
GLS_lstat <- lm( log(medv) ~ age + lg_crim + nox + lstat + ptratio, weights = I(1 / sqrt(lstat) ), data = housing) #we estimate the model by GLS

summary(GLS_lstat)
coefci(GLS_lstat) #We extract the 95% confidence interval for the parameters
