#installing libraries
install.packages("pROC")

#Importing library
library(pROC)
library(car)
library(dplyr)
library(ggplot2)
library(MASS)
library(readxl)
library("tidyverse")
library("readxl")
library("MASS")
library(caTools)
library(caret)
library(car)
library(generalhoslem)
library(plyr)

#importing Dataset
bank_full<- read.csv("H:/Data/WINXP/Desktop/DANA 4820/full_bank.csv", header = TRUE)

# JOB CATEGORICAL VARIABLE:
# Identifying the job distribution
sort(table(bank_full$job), decreasing = TRUE)

# Removing unknown job data
df1 <- bank_full[bank_full$job != "unknown",]

# Dividing job types between blue-collar x white-collar x other
df1<- mutate(df1, 
             job = case_when(
               job == "blue-collar" ~ "blue-collar",
               job == "management" ~ "white-collar",
               job=="technician" ~ "white-collar",
               job=="admin." ~ "white-collar",
               job=="services" ~ "white-collar",
               job=="retired" ~ "other",
               job=="self-employed" ~ "white-collar",
               job=="entrepreneur"~ "white-collar",
               job=="unemployed"~"other",
               job=="housemaid"~"other",
               job=="student"~'other'))

sort(table(df1$job), decreasing = TRUE)

#dividing month into two half's

df2 <- df1[df1$month != "unknown",]

df2<- mutate(df2,
             month=case_when(
               month == "jan" ~ "first half",               
               month == "feb" ~ "first half",
               month == "mar" ~ "first half",
               month == "apr" ~ "first half",
               month == "may" ~ "first half",
               month == "jun" ~ "first half",
               month == "jul" ~ "second half",
               month == "aug" ~ "second half",
               month == "sep" ~ "second half",
               month == "oct" ~ "second half",
               month == "nov" ~ "second half",
               month == "dec" ~ "second half",
             ))

sort(table(df2$month), decreasing = TRUE)

write.csv(df2,"C:/Users/ABC/Desktop/Dana 4820/Project/new_bank_dana.csv",)

# after refining(removing unknowns and transforming columns) dataset we imported final dataset again.

bank_final<- read.csv("C:/Users/ABC/Desktop/Dana 4820/Project/Test&Training/new_bank_dana.csv", header = TRUE)
nrow(bank_final)
#checking for significance of variables(Priliminary test)
#for job
tableJ<- table(bank_final$y,bank_final$job)
chisq.test(tableJ)#pvalue less than alpha meaning job is significant variable

#for marital
tableM<- table(bank_final$y,bank_final$marital)
chisq.test(tableM)#pvalue less than alpha meaning marital is significant variable

#for education
tableE<- table(bank_final$y,bank_final$education)
chisq.test(tableE)#pvalue=0.04,less than alpha meaning Education is significant variable

#for default

tableD<- table(bank_final$y,bank_final$default)
chisq.test(tableD)#pvalue=0.8805,greater than alpha meaning default is not significant variable

#for housing

tableH<- table(bank_final$y,bank_final$housing)
chisq.test(tableH)#pvalue=0.00000,less than alpha meaning housing is significant variable

#for loan

tableL<- table(bank_final$y,bank_final$loan)
chisq.test(tableL)#pvalue=0.00000,less than alpha meaning loan is significant variable

#for contact

tableC<- table(bank_final$y,bank_final$loan)
chisq.test(tableC)#pvalue=0.00000,less than alpha meaning Contact is significant variable

#for month

tableM<- table(bank_final$y,bank_final$month)
chisq.test(tableM)#pvalue=0.002531,less than alpha meaning Contact is significant variable

#for age
var(bank_final$age[bank_final$y=="yes"]) 
var(bank_final$age[bank_final$y=="no"]) #variance unequal
t.test(bank_final$age~bank_final$y, var.equal=FALSE)#Pvalue=0.06765,greater than alpha, meaning that age is insignificant

#for balance
var(bank_final$balance[bank_final$y=="yes"]) 
var(bank_final$balance[bank_final$y=="no"])#variance unequal
t.test(bank_final$balance~bank_final$y, var.equal=FALSE)#Pvalue=0.1583,greater than alpha, meaning that age is insignificant

#for day
var(bank_final$day[bank_final$y=="yes"]) 
var(bank_final$day[bank_final$y=="no"])#variance unequal
t.test(bank_final$day~bank_final$y, var.equal=FALSE)#Pvalue=0.3574,greater than alpha, meaning that age is insignificant

#for duration
var(bank_final$duration[bank_final$y=="yes"]) 
var(bank_final$duration[bank_final$y=="no"])#variance unequal
t.test(bank_final$duration~bank_final$y, var.equal=FALSE)#Pvalue=0.00000,less than alpha, meaning that duration is significant

#for Campaign
var(bank_final$campaign[bank_final$y=="yes"]) 
var(bank_final$campaign[bank_final$y=="no"])#variance unequal
t.test(bank_final$duration~bank_final$y, var.equal=FALSE)#Pvalue=0.00000,less than alpha, meaning that campaign is significant

#for pdays
var(bank_final$pdays[bank_final$y=="yes"]) 
var(bank_final$pdays[bank_final$y=="no"])#variance unequal
t.test(bank_final$pdays~bank_final$y, var.equal=FALSE)#Pvalue=0.0001,less than alpha, meaning that campaign is significant

#for previous
var(bank_final$previous[bank_final$y=="yes"]) 
var(bank_final$pdays[bank_final$y=="no"])#variance unequal
t.test(bank_final$pdays~bank_final$y, var.equal=FALSE)#Pvalue=0.0001,less than alpha, meaning that previous is significant


#checking multicollinearity between variable
colnames(bank_final)
vif(glm(y~age+job+marital+education+contact+day+duration+campaign+pdays+previous+balance+housing+default+loan+month,family = binomial(link = logit), data = bank_final))
#Non of the variable has GVIF value to be more than 3.16 
#hence we conclude that there is no multicollinearity

#removing the final data outside to divide it into training and testing in SAS
write.csv(df2, "C:/Users/ABC/Desktop/Dana 4820/Project/final_bank.csv")

#importing the training and testing dataset 
bank_train<-read.csv("C:/Users/ABC/Desktop/Dana 4820/Project/Test&Training/new_bank_dana_train.csv", header = TRUE)
bank_test<-read.csv("C:/Users/ABC/Desktop/Dana 4820/Project/Test&Training/new_bank_dana_test.csv", header = TRUE)


# model without intereaction
fit_full<-glm(y~., family = binomial(link = logit), data = bank_train)
summary(fit_full)
#performing Hosmer lemeshow test to determine whether model fits the data well
logitgof(bank_train$y, fitted(fit_full)) #pvalue=0.0002561, less than alpha that means model does not fits the data well

#model with intereaction
fit_inter<-glm(y~(age+job+marital+education+default+balance+housing+loan+contact+day+month+duration+campaign+pdays+previous)^2, family = binomial(link = logit), data = bank_train)
summary(fit_inter)
#Likelihood test between fit_full and fit_intereaction
anova(fit_full, fit_inter, test="LRT")#pvalue=0.00000, Hence we reject h0 and conclude model with interaction is better
#performing hosmer lemeshow to determine whether model fits the data well
logitgof(bank_train$y, fitted(fit_inter))#pvalue=0.6286, greater than alpha meaning that model fits the data well

#model with backward selection in R
stepAIC(fit_inter, direction = "backward")
fit_backward <- stepAIC(fit_inter, direction = "backward", trace = FALSE)
summary(fit_backward)
#Likelihood test between fit_inter and fit_backward
anova(fit_inter, fit_backward, test="LRT")#pvalue=0.9999, Hence we reject h0 and conclude backward elimination model is better
#performing hosmer lemeshow to determine whether model fits the data well
logitgof(bank_train$y, fitted(fit_backward))#pvalue=0.07763, greater than alpha meaning that model fits the data well

#model selected by backward elimination in SAS
fit_sas_backward<-glm(y~day+duration+campaign+pdays+previous+housing+loan+month+duration:campaign+day:month+pdays:month, family=binomial(link = logit), data=bank_train)
summary(fit_sas_backward)


#preping data for classification table
bank.full<- bank_final[c(1:3,4:16)]
bank.train <- bank_train[c(1:3,4:16)]
bank.test <- bank_test[c(1:3,4:16)]
bank.full$y <- revalue(bank_final$y, c("yes"=1,"no"=0))
bank.train$y <- revalue(bank_train$y, c("yes"=1,"no"=0))
bank.test$y <- revalue(bank_test$y, c("yes"=1,"no"=0))
bank.full$y<-as.numeric(as.character(bank.full$y))
bank.train$y <- as.numeric(as.character(bank.train$y))
bank.test$y <- as.numeric(as.character(bank.test$y))

#calculating the classification table for r
prop_bank<- sum(bank.full$y)/nrow(bank.full)
prop_bank#0.1429504

head(predict(fit_backward,bank.test, type = "response"))
predicted_r<-as.numeric(predict(fit_backward,bank.test, type = "response") > prop_bank)
xtabs(~bank.test$y + predicted_r)
xtabs(~predicted_r+bank.test$y)

#classification table for sas backward elimination model
head(predict(fit_sas_backward,bank.test, type = "response"))
predicted_sas<-as.numeric(predict(fit_sas_backward,bank.test, type = "response") > prop_bank)
xtabs(~bank.test$y + predicted_sas)
xtabs(~predicted_sas+bank.test$y)

#ROC curve for R backward eliminated model
rocplot_r<-roc(y~predict(fit_backward,bank.test, type = "response"), data=bank.test)
plot.roc(rocplot_r, legacy.axes=TRUE)
auc(rocplot_r)#we gor AUC=0.8304

#ROC curve for sas backward eliminated model
rocplot_sas<-roc(y~predict(fit_sas_backward,bank.test, type = "response"), data=bank.test)
plot.roc(rocplot_sas, legacy.axes=TRUE)
auc(rocplot_sas)#we got AUC=0.8428

#comparing both ROC curve
list(rocplot_r,rocplot_sas)
ggroc(list(rocplot_r,rocplot_sas), legacy.axes=TRUE)

#residual check
rstandard(fit_backward,type = "pearson")