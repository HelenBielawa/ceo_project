library(tidyverse)
library(dplyr)
library(ggplot2)
load('data processing/data_for_analysis.RData')

glimpse(data_imp)
# VARIABLES CAN BE SELECTED
count(data_imp, SELF_RULE)
frm_indep = SELF_RULE/3 ~ CATALAN_ONLY + SPANISH_ONLY + SPAIN_ONLY + BORN_CATALONIA + BORN_ABROAD + 
  SELF_DETERM + BELONGING

count(data_imp, RIGHT)
frm_right = RIGHT/10 ~ ACTITUD_ECONOMIA + ACTITUD_IMPOSTOS + ACTITUD_INGRESSOS + 
  ACTITUD_AUTORITAT + ACTITUD_RELIGIO + ACTITUD_OBEIR + ACTITUD_IMMIGRACIO + 
  ACTITUD_MEDIAMBIENT

m_indep.all = lm(frm_indep, data=data_imp)
m_right.all = lm(frm_right, data=data_imp)

# # To obtain tables to be used in javascript for calculating the empirical 
# # cumulative distribution
# #
#  x_pred_indep = predict(m_indep.all)
#  dindep = tibble(
#  x = sort(unique(x_pred_indep)),
# quantile = round(sapply(x, function(x_) mean(x_pred_indep<=x_)), 4))
# # 
# x_pred_right = predict(m_right.all)
# dright = tibble(
# x = sort(unique(x_pred_right)),
# quantile = round(sapply(x, function(x_) mean(x_pred_right<=x_)), 4)) %>% 
#   slice(seq(1,21133,20))
# 
# library(jsonlite)
# 
# json_dindep = toJSON(dindep)
# write(json_dindep, file = "dindep.json")
# 
# json_dright = toJSON(dright)
# write(json_dright, file = "dright.json")

F_indep = ecdf(predict(m_indep.all))
F_right = ecdf(predict(m_right.all))

#Calculate position for all individuals

predict_indep = function(dat){
  F_indep(predict(m_indep.all, newdata = dat))
}
predict_right = function(dat){
  F_right(predict(m_right.all, newdata = dat))
}

#Checking distribution
# summary(predict_indep(data_imp))
# summary(predict_right(data_imp))
# 
# 
# boxplot(predict_indep(data_imp)~data_imp$SELF_RULE)
# boxplot(predict_right(data_imp)~data_imp$RIGHT)

# dplot = tibble(
#   right = predict_right(data_imp),
#   indep = predict_indep(data_imp)
# )
# ggplot(data=dplot, aes(x = right, y = indep)) +
#   geom_point(alpha = 0.1) + 
#   geom_smooth()

#anova(m_indep.all, update(m_indep.all, .~.-SELF_DETERM), test = 'LRT')

#Create the dataset with the predictions per interviewee, also adding age and gender

data_imp_pred = data_imp %>%
  mutate(
    INDEP.PRED = predict_indep(.)*100, #predict(m_indep.all, type = 'response'),
    RIGHT.PRED = predict_right(.)*100  #predict(m_right.all)
  ) %>%
  select(AGE, INDEP, RIGHT, INDEP.PRED, RIGHT.PRED, PROVINCE, MUNICIPALITY, LANGUAGE, EDUCATION, SELF_RULE)

# Define age range groups
data_imp_pred <- data_imp_pred %>%
  mutate(AGE_RANGE = case_when(
    AGE >= 18 & AGE <= 34 ~ "18-34",
    AGE >= 35 & AGE <= 49 ~ "35-49",
    AGE >= 50 & AGE <= 64 ~ "50-64",
    AGE >= 65 ~ "65+"
  ))


#Clustering data by similar characteristics in INDEP.PRED and RIGHT.PRED

clustering_data = data_imp_pred %>% select(INDEP.PRED, RIGHT.PRED)

k = 25  # Number of clusters you want to create
set.seed(123) 
clusters = kmeans(clustering_data, centers = k, nstart = 20, iter.max = 300, algorithm = "Lloyd")

data_with_clusters = data_imp_pred %>%
  mutate(Cluster = as.factor(clusters$cluster))

ggplot(data=data_with_clusters) +
  geom_point(aes(x = RIGHT.PRED, y = INDEP.PRED, col = Cluster))

mode_category = function(x){
  tab = table(x)
  names(tab[order(tab, decreasing = TRUE)])[1]
}
mode_category_prop = function(x){
  tab = prop.table(table(x))
  max(tab)
}
clustered_data = data_with_clusters %>%
  group_by(Cluster) %>%
  summarise(INDEP_Pred_Mean = mean(INDEP.PRED),
            RIGHT_Pred_Mean = mean(RIGHT.PRED),
            Num_Users = n(),
            AGE_cat = mode_category(AGE_RANGE),
            AGE_prop = mode_category_prop(AGE_RANGE)*100,
            EDUCATION_cat = mode_category(EDUCATION),
            EDUCATION_prop = mode_category_prop(EDUCATION)*100,
            LANGUAGE_cat = mode_category(LANGUAGE),
            LANGUAGE_prop = mode_category_prop(LANGUAGE)*100) %>%
  ungroup()

ggplot(data=clustered_data) +
  geom_point(aes(x = RIGHT_Pred_Mean, y = INDEP_Pred_Mean, size = Num_Users))

library(dplyr)

indicator_distribution_ages <- data_with_clusters %>%
  count(Cluster, AGE_RANGE) %>%
  group_by(Cluster) %>%
  mutate(Percentage = (n / sum(n)) * 100) %>%
  top_n(1, n)

indicator_distribution_language <- data_with_clusters %>%
  count(Cluster, LANGUAGE) %>%
  group_by(Cluster) %>%
  mutate(Percentage = (n / sum(n)) * 100) %>%
  top_n(1, n)

indicator_distribution_education <- data_with_clusters %>%
  count(Cluster, EDUCATION) %>%
  group_by(Cluster) %>%
  mutate(Percentage = (n / sum(n)) * 100) %>%
  top_n(1, n)


indicator_distribution <- bind_rows(indicator_distribution_ages, indicator_distribution_language, indicator_distribution_education)


data_imp_pred
library(ggplot2)
ggplot(data = sample_n(data_imp_pred, 1000)) +
  geom_violin(aes(x = INDEP.PRED, y = factor(SELF_RULE)))


ggplot(data = sample_n(data_imp_pred, 1000)) +
  geom_point(aes(x = RIGHT, y = RIGHT.PRED)) +
  scale_y_continuous(breaks = seq(0, 1, 0.1), limits = c(0, 1)) +
  scale_x_continuous(breaks = 0:10, limits = c(0, 10)) +
  geom_smooth(aes(x = RIGHT, y = RIGHT.PRED))



library(ggplot2)

ggplot(clustered_data, aes(x = INDEP_Pred_Mean, y = RIGHT_Pred_Mean)) +
  geom_point(color = "blue") +
  geom_text(aes(label = Cluster), color = "blue", size = 3, nudge_x = 0.03, nudge_y = 0.05) +
  labs(x = "INDEP.PRED", y = "RIGHT.PRED") +
  theme_minimal()

cat(paste(sprintf("'%s'", union(attr(m_indep.all$terms ,"term.labels"), attr(m_right.all$terms ,"term.labels"))), collapse = ', '))

# Language:  "CATALAN_ONLY"                     "SPANISH_ONLY"
#  Catalan  -> CATALAN_ONLY = 1, SPANISH_ONLY = 0
#  Spanish  -> CATALAN_ONLY = 0, SPANISH_ONLY = 1
#  Both     -> CATALAN_ONLY = 0, SPANISH_ONLY = 0
#  Aranès   -> CATALAN_ONLY = 0, SPANISH_ONLY = 0
#  Other    -> CATALAN_ONLY = 0, SPANISH_ONLY = 0

# Nacionality: 
# Spanish:            SPAIN_ONLY=1
# Spanish and other:  SPAIN_ONLY=0
# Other:              SPAIN_ONLY=0

# BORN: 
# In Catalonia,                  ->  BORN_CATALONIA=1, BORN_ABROAD=0
# In Spain but not in Catalonia, ->  BORN_CATALONIA=0, BORN_ABROAD=0
# Europe but not in Spain,       ->  BORN_CATALONIA=0, BORN_ABROAD=1
# World but not Europe           ->  BORN_CATALONIA=0, BORN_ABROAD=1

VARS = c('CATALAN_ONLY', 'SPANISH_ONLY', 'SPAIN_ONLY', 'BORN_CATALONIA', 
         'BORN_ABROAD', 'SELF_RULE', 'SELF_DETERM', 'CONFI_POL_CAT' ,'CONFI_POL_ESP',
         'ACTITUD_ECONOMIA', 'ACTITUD_IMPOSTOS', 'ACTITUD_INGRESSOS', 
         'ACTITUD_AUTORITAT', 'ACTITUD_RELIGIO', 'ACTITUD_OBEIR', 
         'ACTITUD_IMMIGRACIO', 'ACTITUD_MEDIAMBIENT')

vs = names(coef(m_indep.all))
vs[1] = '1'
cat(sprintf("var LP = %s", gsub('\\+ -', '-', paste(sprintf("%0.3f * %s", coef(m_indep.all), vs), collapse = ' + '))))
# cat("var PROB = 1/(1+exp(-LP))")

USER = slice(data_imp, 1) 
USER

# Example of response in indy axis

CATALAN_ONLY  = 1
SPANISH_ONLY = 0
SPAIN_ONLY = 1
BORN_CATALONIA = 1
BORN_ABROAD  = 0
SELF_DETERM = 3
CONFI_POL_CAT = 7
CONFI_POL_ESP = 1
BELONGING = 2

# Calculation to get the score in the indy axis

LP = 0.156 * 1 + 0.075 * CATALAN_ONLY -0.048 * SPANISH_ONLY + 
  0.023 * SPAIN_ONLY + 0.016 * BORN_CATALONIA + 0.049 * BORN_ABROAD + 
  0.011 * SELF_DETERM + 0.166 * BELONGING

# Example of response in left-right axis

vs = names(coef(m_right.all))
vs[1] = '1'
cat(sprintf("var LP = %s", gsub('\\+ -', '-', paste(sprintf("%0.3f * %s", coef(m_right.all), vs), collapse = ' + '))))
LP = 0.457 * 1 + 0.000 * ACTITUD_ECONOMIA + 0.009 * ACTITUD_IMPOSTOS -0.023 * ACTITUD_INGRESSOS + 
  0.021 * ACTITUD_AUTORITAT -0.024 * ACTITUD_RELIGIO + 0.019 * ACTITUD_OBEIR + 
  0.018 * ACTITUD_IMMIGRACIO + 0.008 * ACTITUD_MEDIAMBIENT

ACTITUD_ECONOMIA = 1
ACTITUD_IMPOSTOS = 0
ACTITUD_INGRESSOS = 0
ACTITUD_AUTORITAT = 2
ACTITUD_RELIGIO = 1
ACTITUD_OBEIR = 1
ACTITUD_IMMIGRACIO = 1
ACTITUD_MEDIAMBIENT = 1

# Calculation to get the score in the left-right axis

# LP = 4.552 * 1 + 0.032 * ACTITUD_ECONOMIA + 0.102 * ACTITUD_IMPOSTOS +
#   -0.219 * ACTITUD_INGRESSOS + 0.203 * ACTITUD_AUTORITAT +
#   -0.235 * ACTITUD_RELIGIO + 0.185 * ACTITUD_OBEIR + 
#   0.150 * ACTITUD_IMMIGRACIO + 0.062 * ACTITUD_MEDIAMBIENT
# (LP - 2) / (8-2)

PREDICTED = data_imp %>%
  mutate(
    INDEP.PRED = predict(m_indep.all, newdata = . , type = 'response'),
    RIGHT.PRED = (predict(m_right.all, newdata = .)-2)/(8-2)
  )

ggplot(data = PREDICTED) +
  geom_point(aes(x = INDEP.PRED, y = RIGHT.PRED), alpha = 0.02)

USER %>%
  select(AGE, FEMALE) %>%
  left_join(PREDICTED) %>%
  ggplot() +
  geom_point(aes(x = INDEP.PRED, y = RIGHT.PRED))



#Keep only some variables and remove decimals, only keep 2

clustered_data_reduced

data_with_clusters_reduced <- data_with_clusters %>%
  select(INDEP.PRED, RIGHT.PRED, Cluster) %>%
  mutate(INDEP.PRED = round(INDEP.PRED, 2)) %>%
  mutate(RIGHT.PRED = round(RIGHT.PRED, 2))
  

#Remove decimals, only keep 2
clustered_data_reduced <- clustered_data


for (col in names(clustered_data_reduced)) {
  if (is.numeric(clustered_data_reduced[[col]])) {
    clustered_data_reduced[[col]] <- round(clustered_data_reduced[[col]], 2)
  }
}



library(jsonlite)
json_data = toJSON(clustered_data_reduced)
write(json_data, file = "clusters.json")


json_data_2 = toJSON(data_with_clusters_reduced)
write(json_data_2, file = "pred_individuals.json")
