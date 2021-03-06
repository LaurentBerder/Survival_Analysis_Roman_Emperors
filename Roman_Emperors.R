### Roman emperors, a Survival Analysis
Laurent Berder


#### Introduction

# This paper will be a survival analysis based on Roman Emperors (from 26 before JC to 395 AD), for which data was found on this website: https://public.opendatasoft.com/explore/dataset/roman-emperors/table/?sort=index


####### Preparation
# Load libraries (survival and the ones I'm used to working with) and import data


library(survival) # for survival analysis
library(data.table) # for data import
library(tidyverse) # for data manipulation
library(lubridate) # because the dates stretch over AD and BC eras, we need lubridate's as_date() to handle negative dates
library(survminer) # for plotting survival curves
library(plotly) # for other plots

emperors <- fread("https://public.opendatasoft.com/explore/dataset/roman-emperors/download/?format=csv&timezone=Europe/Berlin&use_labels_for_header=true", stringsAsFactors = TRUE, check.names = TRUE) #download file straight from sourcepage
# emperors <- fread("roman-emperors.csv", stringsAsFactors = TRUE, check.names = TRUE) #use previously downloaded file


#######__Cleaning & formatting__


emperors <- emperors %>% select(-Verif, -Image) %>% arrange(Index)

emperors$Birth <- as.character(emperors$Birth) %>% as_date()
emperors$Death <- as.character(emperors$Death) %>% as_date()
emperors$Reign.Start <- as.character(emperors$Reign.Start) %>% as_date()
emperors$Reign.End <- as.character(emperors$Reign.End) %>% as_date()


# Some of the birth dates (and the first reign start date) take place in BCE, so we need to change them to negative years, which is where the lubridate package comes into play. The indication of whether the date should be modified is in the Notes field.


ref_year <- as.integer(as_date("1/1/1"))

emperors$Birth[grep("BCE", emperors$Notes)] <- as_date(as.integer(emperors$Birth[grep("BCE", emperors$Notes)]) - 2*(as.integer(emperors$Birth[grep("BCE", emperors$Notes)]) - ref_year) - 365)

emperors$Reign.Start[grep("reign.start are BCE", emperors$Notes)] <- as_date(as.integer(emperors$Reign.Start[grep("reign.start are BCE", emperors$Notes)]) - 2*(as.integer(emperors$Reign.Start[grep("reign.start are BCE", emperors$Notes)]) - ref_year) - 365)


###### Exploration
#How did they die?
plot_ly(data = emperors, x = ~Cause, type = "histogram") %>% layout(title = "Causes of death", xaxis = list(title = "Cause"), yaxis = list(title = "Frequency"))


###### Definition of Survival

# We'll look at **Assassination**, **Captivity** and **Execution** as traumatic ends to their reigns (event = 1), while Natural Causes, Died in Battle and Suicide are more "normal" ways for an emperor's reign to come to an end (event = 0). We'll censor on emperors who died after the end of their reign (the ones that abdicated or were deposed without being killed)
emperors$event <- ifelse(emperors$Cause %in% c("Assassination", "Captivity", "Execution"), 1, 0)
emperors$event <- ifelse(emperors$Reign.End < emperors$Death, 0, emperors$event)

emperors <- filter(emperors, Cause != "Unknown" | Reign.End < Death) # Getting rid of the unknown deaths that are not censored

# We need to calculate ages.
emperors$age_accession <- interval(emperors$Birth, emperors$Reign.Start) / years(1)
emperors$length_reign <- interval(emperors$Reign.Start, emperors$Reign.End) / years(1)
emperors$age_death <- interval(emperors$Birth, emperors$Death) / years(1)

plot_ly(data = filter(emperors, !is.na(age_death)), type = "histogram", alpha = 0.6) %>%
  add_trace(x = ~age_death, type = "histogram", name = "Age of death")  %>%
  add_trace(x = ~length_reign, type = "histogram", name = "Length of reign") %>%
  layout(barmode = "overlay", title = "Age of Death & Length of Reign", xaxis = list(title = "Years"), yaxis = list(title = "Frequency"))

# An explicit chart of the lifespan and reign length of all the emperors over time.
p <- plot_ly()
for(i in 1:(nrow(emperors) - 1)){
  p <- add_trace(p, type = "scatter", mode = "lines", # Life line
                 x = c(year(emperors$Birth[i]),
                           year(emperors$Death[i])),
                 y = c(i, i),
                 line = list(color = "white", width = 5),
                 showlegend = F, hoverinfo = "text",
                 # Create custom hover text
                 text = paste("Name: ", emperors$Name[i], "<br>",
                              "Age: ", round(emperors$age_death[i], 1), "years<br>",
                              "Length of reign: ", round(emperors$length_reign[i], 1), "years<br>")) %>%

    add_trace(type = "scatter", x = c(year(emperors$Reign.Start[i]),
                                      year(emperors$Reign.End[i])), # Reign line
              y = c(i, i), mode = "lines", line = list(color = "blue", width = 3),
              showlegend = F, hoverinfo = "none") %>%


    layout(plot_bgcolor = "#424D5C", paper_bgcolor = "#424D5C",
           font=list(color = "white", size = 12),
           yaxis = list(showgrid = F, tickmode = "array", tickfont = list(size = 7),
                        autorange = "reversed",
                        tickvals = 1:nrow(emperors), ticktext = unique(emperors$Name)),
           xaxis = list(showgrid = F,
                        tickval = min(emperors$Birth, na.rm=T):max(emperors$Death, na.rm=T), title = " <b><i>Date</i></b>", titlefont = list(color= c("#7F9FBD"))),
           title = "Life and reign of Roman emperors")
}

p


###### Distribution observation

table(emperors$event)
plot_ly(data = emperors, x = ~length_reign, type = "histogram", marker = list(color="red")) %>% layout(title = "Distribution of length reign for all emperors", xaxis = list(title = "Years of reign"), yaxis = list(title = "Frequency"))

plot_ly(data = filter(emperors, event == 1), x = ~length_reign, type = "histogram", marker = list(color="purple")) %>% layout(title = "Distribution of length reign for uncensored emperors", xaxis = list(title = "Years of reign"), yaxis = list(title = "Frequency"))
# The data is evenly split between events and censoring.
# Neither of the distributions seem to follow a specific law, so we'll have to skip the classical statistics, and jump straight to the survival analysis.

### Survival Analysis
####### Kaplan-Meier
# The simplest analysis we can look at is the Kaplan-Meier survival curves.

KM <- survfit(Surv(length_reign, event)~1, data=emperors)
KM
# *Median Survival:* The first observation is that after almost 15 years, half of the 66 emperors had already been killed.

ggsurvplot(KM, risk.table = TRUE, main = "Kaplan-Meier for emperors' survival", xlab = "Length of reign in years", ylab = "Survival rate")

# This plot shows the survival rate of emperors based on their length of reign, with crosses for the emperors that were not killed (censored).
# The table at the bottom indicates the number of surviving emperors after years of reign from 0 (minimum survival time) to 40 (maximum survival time).

###### Logrank
# There are two large eras covered by the data's timeframe: the Principate (earlier) and the Dominate (or despotic) eras. Let's find out if there are significant differences in emperors' survival expectation between these two eras or not.
table(emperors$Era, emperors$event)
logrank <- survdiff(Surv(length_reign, event)~Era, data = emperors)
logrank
# The rather low p-value of this logrank test shows us that there seems to be a significant difference, which we'll investigate further with stratification.


###### Stratification
# To find out in which way the era influences survival, we'll plot the distinction.
ggsurvplot(survfit(Surv(length_reign, event) ~Era, data=emperors), pval = TRUE, risk.table = TRUE, main = "Emperors' survival by Era (log-log)", fun="cloglog")
# We can see already that there is a steep difference in survival rate if we distinguish the 2 eras: emperors were much likely to get killed in the Principate era than in the Dominate era. This finding is reinforced by the parallelism of both curves, in log-log format.

# This result is rather surprising, as we know that the Principate era was characterised by an effort on the part of the emperors to preserve the illusion of continuance of the Roman Republic.

# We'll investigate on other possible distinctions that might influence the risk for emperors to get killed.
# For example, we can wonder if the way the emperor achieved his position (Succession) influences the risk. There are too many categories, so let's first group some of them together.

emperors$Succession2 <- ifelse(emperors$Succession %in% c("Appointment by Army", "Appointment by Praetorian Guard"), "Appointment by military", ifelse(emperors$Succession %in% c("Appointment by Emperor", "Appointment by Senate"), "Appointment by state", ifelse(emperors$Succession == "Birthright", "Birthright", ifelse(emperors$Succession == "Seized Power", "Seized Power",  "Other"))))

summary(coxph(Surv(length_reign, event) ~Era + Succession2, data = emperors))
summary(coxph(Surv(length_reign, event) ~Era + strata(Succession2), data = emperors))
ggsurvplot(survfit(Surv(length_reign, event) ~ Succession2, data = emperors), pval = TRUE, pval.coord = c(30,0.8), main = "Emperors' survival by way of accessing power", legend.labs = c("Appointment by military", "Appointment by state", "Birthright", "Other", "Seized Power"))

# The first detailed model, displays interesting relevance with low p-values indicating that different succession methods imply different risks, while the second more general model does not offer a credible p-value to be followed as-is.
# Indeed, plotting the Cox in cloglog we can see that the lines are not parralel, which is why the model as a whole is not so effective.

ggsurvplot(survfit(Surv(length_reign, event) ~ Era + Succession2, data = emperors), pval = TRUE, pval.coord = c(30,-2), fun="cloglog", legend.labs = c("Dominate/Appointment by military", "Dominate/Appointment by state", "Dominate/Birthright", "Dominate/Other", "Dominate/Seized Power","Principate/Appointment by military", "Principate/Appointment by state", "Principate/Birthright", "Principate/Other", "Principate/Seized Power"))

# We can conclude from this (none of the lines are parallel) that the model is not accurate because the Cox assumption of proportionality of hazards is not respected: we will not be able to use the coefficients from the model, but we may still consider Succession as a somewhat interesting variable, since adding the Succession to the Era improves the p-value.


# We can wonder if the __Emperor's origin__ plays a role in his popularity in Rome and therefore his survival likelihood.
table(emperors$Birth.Province, emperors$event)
# However, the categories are a little too numerous and therefore too restrictive to be very indicative, so we'll proceed to some grouping in order to have wider groups.

emperors$Birth.Region <- ifelse(emperors$Birth.Province %in% c("Africa", "Libya", "Mauretania"), "Africa", ifelse(emperors$Birth.Province %in% c("Gallia Lugdunensis", "Gallia Narbonensis"), "Gaul", ifelse(emperors$Birth.Province %in% c("Hispania", "Hispania Baetica"), "Spain", ifelse(emperors$Birth.Province %in% c("Dacia Aureliana", "Dalmatian", "Moesia", "Moesia Superior", "Pannonia", "Pannonia Inferior", "Thrace"), "East Europe", ifelse(emperors$Birth.Province %in% c("Phrygia", "Syria"),    "Asia Minor", ifelse(emperors$Birth.Province == "Italia", "Italia", "Unknown"))))))
table(emperors$Birth.Region, emperors$event)

# It will be easier to work with 7 levels than 18.

region <- survfit(Surv(length_reign, event) ~Birth.Region, data=emperors)
summary(region)
ggsurvplot(region, pval = TRUE, pval.coord = c(30,0.9), palette = c(c("#00EE00", "#0000EE", "#CD0000", "#BF3EFF", "#EEEE00", "#00FFFF", "#EE9A00")), main = "Emperors' survival by Province of origin", legend.labs = c("Africa","Asia Minor", "East Europe", "Gaul", "Italia", "Spain", "Unknown"))

# Here we can see the survival curves based on the region of origin. There is definitively some impact, based on the low p-value, but the lines themselves are not that indicative (in log-log, they are not parallel), so we won't be using the information as such.




# Looking at the __age emperors had at the time they took power__. As for the origin, we'll have to categorize first.
emperors$age_accession2 <- ifelse(emperors$age_accession>60, "61+", ifelse(emperors$age_accession>40, "41-60", ifelse(emperors$age_accession>30, "31-40", ifelse(emperors$age_accession<30, "30-", "Unknown"))))
age_access <- survfit(Surv(length_reign, event) ~age_accession2, data=emperors)
summary(age_access)
ggsurvplot(age_access, pval = TRUE, pval.coord = c(30,0.6), main = "Emperors' survival by age at beginning of reign in log-log", legend.labs = c("30 & less", "31-40", "41-60", "61 and above"), fun="cloglog")
# Here the p-value is much lower even, and the lines barely cross which implies that we're closer to a model we could use.

###### Cox regression Model

library(networkD3)
# _**Distribution of emperors by Dynasty**_
simpleNetwork(select(emperors, Name, Dynasty), fontSize = 18, nodeColour = "red")
# To find out the difference of survival chance between dynasties, we can use the Cox model.
# This will compare all dynasties with the first one. By default, the first one in alphabetical order will be used for comparison. Here, we'll change the order, so that the Flavian dynasty comes first, as it is the only one that had a 50-50 survival rate.

emperors$Dynasty = factor(emperors$Dynasty,levels(emperors$Dynasty)[c(2,1,3:8)])
summary(coxph(formula = Surv(length_reign, event) ~ Dynasty, data = emperors))

# This shows us first that the influence of dynasty on survival chances is significant (p-value 0.02493), and that compared to the Flavian dynasty, emperors in the Constantinian dynasty had 0.31 times more chance to survive (+/- 3.19).
# Still compared to the Flavian, Nerva-Antonine had a very small chance to be killed at 0.0841 (+/- 1.189).



###### Multiple Covariates
# Now, let's look at the three variables of *Succession*, *Era* and *Age at accession* (with redefined categories as seen above), and try to identify the best explicative model for emperors' survival.

# To study the covariates, we need to use the Cox proportional hazards regression model.
# The model, and the stepwise algorithm, only works with non-missing values, so I'll make a selection of the variables to consider, and remove the rows with missing values.

selection <- emperors %>% select(c(length_reign, event, Succession2, Era, age_accession2))
selection <- filter(selection, complete.cases(selection))

all_variables <- coxph(Surv(length_reign, event) ~ . , data = selection)

AIC <- step(all_variables, direction="forward")
summary(AIC)
ggsurvplot(survfit(AIC), main="Survival function (prediction)", color="blue")

# The result of the Cox model and step algorithm (which went through 16 iterations starting with no variable, then adding them one by one) is a predictor based on 8 variables, with low p-values on all tests, indicating that we can safely discard the null hypothesis (that the 8 variables chosen by the stepwise algorithm do not significantly impact chances of survival).
# This gives enough confidence to chose the model for the last step of this paper:


### Prediction
# To make a prediction, we need to split the data in 2 parts, one to train the model, the other to test it.

## 75% of the sample size
smp_size <- floor(0.7 * nrow(emperors))

## set the seed to make your partition reproductible
set.seed(24)
train_ind <- sample(seq_len(nrow(emperors)), size = smp_size)

train <- emperors[train_ind, ]
test <- emperors[-train_ind, ]
# Here I've decided to train the model on 80% of the data (46 emperors), and make the prediction on the 20 left.

# Let's only keep the useful variables in the two data.frames, and remove the rows with NA values in train.

test <- test %>% select(Name, Succession2, Era, age_accession2, length_reign, event)
train <- train %>% select(Succession2, Era, age_accession2, length_reign, event)
train <- filter(train, complete.cases(train))

model <- coxph(Surv(length_reign, event) ~ . , data = train)

models <- step(model, direction="forward")

# Now that the model is train, we just need to use it to generate the predictions, and compare the predicted value with the true vale in the "event" column.

test$predicted_value <- ifelse(predict(models, newdata=test, type = "expected") > 0.5, 1,0)
library(ROCR)
results <- ROCR::prediction(test$event, test$predicted_value)
plot(unlist(results@tp), unlist(results@fp), type="l")

plot(performance(results, measure = "tpr", x.measure = "fpr"))
