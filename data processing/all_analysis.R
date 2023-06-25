library(tidyverse)
library(dplyr)
library(ggplot2)
load('data processing/data_for_analysis.RData')

glimpse(data_imp)

# VARIABLES selected to get pro-independence feeling
count(data_imp, SELF_RULE)
frm_indep = SELF_RULE/3 ~ CATALAN_ONLY + SPANISH_ONLY + SPAIN_ONLY + BORN_CATALONIA + BORN_ABROAD + 
  SELF_DETERM + BELONGING

# VARIABLES selected to get left-right feeling

count(data_imp, RIGHT)
frm_right = RIGHT/10 ~ ACTITUD_ECONOMIA + ACTITUD_IMPOSTOS + ACTITUD_INGRESSOS + 
  ACTITUD_AUTORITAT + ACTITUD_RELIGIO + ACTITUD_OBEIR + ACTITUD_IMMIGRACIO + 
  ACTITUD_MEDIAMBIENT

#Regression
m_indep.all = lm(frm_indep, data=data_imp)
m_right.all = lm(frm_right, data=data_imp)
coef(m_indep.all)
coef(m_right.all)

#Building linear model expression for independence
vs = names(coef(m_indep.all))
vs[1] = '1'
cat(sprintf("var LP = %s", gsub('\\+ -', '-', paste(sprintf("%0.3f * %s", coef(m_indep.all), vs), collapse = ' + '))))

#Building linear model expression for left-right
vs = names(coef(m_right.all))
vs[1] = '1'
cat(sprintf("var LP = %s", gsub('\\+ -', '-', paste(sprintf("%0.3f * %s", coef(m_right.all), vs), collapse = ' + '))))

F_indep = ecdf(predict(m_indep.all))
F_right = ecdf(predict(m_right.all))

data_imp_pred = data_imp %>%
  tibble() %>%
  mutate(
    INDEP.PRED = predict(m_indep.all),
    RIGHT.PRED = predict(m_right.all),
    INDEP.PRED.QUANT = round(100*F_indep(INDEP.PRED), 2),
    RIGHT.PRED.QUANT = round(100*F_right(RIGHT.PRED), 2)
  ) %>%
  select(AGE, 
         INDEP, RIGHT, INDEP.PRED, RIGHT.PRED, INDEP.PRED.QUANT, RIGHT.PRED.QUANT, 
         PROVINCE, MUNICIPALITY, LANGUAGE, EDUCATION, SELF_RULE)

data_imp_pred <- data_imp_pred %>%
  mutate(AGE_RANGE = case_when(
    AGE >= 18 & AGE <= 34 ~ "18-34",
    AGE >= 35 & AGE <= 49 ~ "35-49",
    AGE >= 50 & AGE <= 64 ~ "50-64",
    AGE >= 65 ~ "65+"
  ))
data_imp_pred

# Group by gender and age range and calculate cluster means
social_clustered_data <- data_imp_pred %>%
  group_by(AGE_RANGE, LANGUAGE, EDUCATION) %>%
  summarise(INDEP.QUANT_Pred_Mean = round(100*F_indep(mean(INDEP.PRED)), 2),
            RIGHT.QUANT_Pred_Mean = round(100*F_right(mean(RIGHT.PRED)), 2),
            Num_Users = n()) %>%
  ungroup()  %>%
  mutate(
    Perc_Users = 100 * Num_Users/sum(Num_Users)
  ) %>%
  mutate(Social_Cluster = row_number()) %>%
  arrange(desc(Perc_Users))

data_imp_pred = data_imp_pred %>%
  left_join(select(social_clustered_data, AGE_RANGE, LANGUAGE, EDUCATION, Social_Cluster), 
            by = c('AGE_RANGE', 'LANGUAGE', 'EDUCATION'))

data_imp_pred_reduced = data_imp_pred %>%
  arrange(Social_Cluster) %>%
  select(Social_Cluster, INDEP = INDEP.PRED.QUANT, RIGHT=RIGHT.PRED.QUANT)

l_data_imp_pred = split(data_imp_pred_reduced, data_imp_pred_reduced$Social_Cluster)
l_data_imp_pred = lapply(l_data_imp_pred, function(x){ x$Social_Cluster = NULL; x})

library(jsonlite)
json_l_data_imp_pred = toJSON(l_data_imp_pred)
write(json_l_data_imp_pred, file = 'data processing/json_social_clusters.json')

social_clustered_data_reduced = social_clustered_data %>%
  arrange(Social_Cluster) %>%
  select(Social_Cluster, AGE_RANGE, LANGUAGE, EDUCATION, 
         INDEP.QUANT_Pred_Mean, RIGHT.QUANT_Pred_Mean, Perc_Users)
json_social_clustered_data = toJSON(social_clustered_data_reduced)
write(json_social_clustered_data, file = 'data processing/json_social_clustered_data.json')

ggplot(data=social_clustered_data_reduced) +
  geom_point(aes(x=RIGHT.QUANT_Pred_Mean, y = INDEP.QUANT_Pred_Mean, size = Perc_Users)) +
  labs(title = 'Social Clusters') +
  coord_cartesian(xlim = c(0,100), ylim = c(0,100))

ggplot(data=filter(data_imp_pred_reduced, Social_Cluster == 12)) +
  geom_point(aes(x=RIGHT, y = INDEP), alpha=0.2) +
  labs(title = 'Inviduals') +
  coord_cartesian(xlim = c(0,100), ylim = c(0,100))



### POLITICAL CLUSTERS
k = 25  # Number of clusters you want to create
set.seed(123) 
clusters = kmeans(data_imp_pred[,c('INDEP.PRED.QUANT', 'RIGHT.PRED.QUANT')], centers = k, nstart = 20, iter.max = 300, algorithm = "Lloyd")

data_imp_pred = data_imp_pred %>%
  mutate(Political_Cluster = clusters$cluster)

mode_category = function(x){
  tab = table(x)
  names(tab[order(tab, decreasing = TRUE)])[1]
}
mode_category_prop = function(x){
  tab = prop.table(table(x))
  max(tab)
}
data_imp_pred_political = data_imp_pred  %>%
  mutate(Political_Cluster = clusters$cluster) %>%
  group_by(Political_Cluster) %>%
  summarise(INDEP.QUANT_Pred_Mean = round(mean(INDEP.PRED.QUANT), 2),
            RIGHT.QUANT_Pred_Mean = round(mean(RIGHT.PRED.QUANT), 2),
            AGE_cat = mode_category(AGE_RANGE),
            AGE_prop = mode_category_prop(AGE_RANGE)*100,
            EDUCATION_cat = mode_category(EDUCATION),
            EDUCATION_prop = mode_category_prop(EDUCATION)*100,
            LANGUAGE_cat = mode_category(LANGUAGE),
            LANGUAGE_prop = mode_category_prop(LANGUAGE)*100,
            Num_Users = n()) %>%
  ungroup()  %>%
  mutate(
    Perc_Users = 100 * Num_Users/sum(Num_Users),
    Num_Users = NULL
  ) %>%
  arrange(Political_Cluster)

ggplot(data=data_imp_pred_political) +
  geom_point(aes(x=RIGHT.QUANT_Pred_Mean, y = INDEP.QUANT_Pred_Mean, size = Perc_Users)) +
  labs(title = 'Political Clusters') +
  coord_cartesian(xlim = c(0,100), ylim = c(0,100))

json_data_imp_pred_political = toJSON(data_imp_pred_political)
write(json_data_imp_pred_political, file = 'data processing/json_political_clusters_all_info.json')

variables_mean_values = data_imp %>%
  as_tibble() %>%
  select(CATALAN_ONLY, SPANISH_ONLY, SPAIN_ONLY, BORN_CATALONIA, BORN_ABROAD, SELF_DETERM,
         BELONGING, ACTITUD_ECONOMIA, ACTITUD_IMPOSTOS, ACTITUD_INGRESSOS, 
         ACTITUD_AUTORITAT, ACTITUD_RELIGIO, ACTITUD_OBEIR, ACTITUD_IMMIGRACIO, 
         ACTITUD_MEDIAMBIENT) %>%
  pivot_longer(everything()) %>%
  group_by(name) %>%
  summarise(mean = mean(value))

json_variables_mean_values = toJSON(variables_mean_values)
write(json_variables_mean_values, file = 'data processing/json_variables_mean_values.json')


# To obtain tables to be used in javascript for calculating the empirical
# cumulative distribution
#
x_pred_indep = predict(m_indep.all)
dindep = tibble(
  x = sort(unique(x_pred_indep)),
  quantile = round(sapply(x, function(x_) mean(x_pred_indep<=x_)), 4))

x_pred_right = predict(m_right.all)
dright = tibble(
  x = sort(unique(x_pred_right)),
  quantile = round(sapply(x, function(x_) mean(x_pred_right<=x_)), 4)) %>%
  slice(seq(1,21133,20))

json_dindep = toJSON(dindep)
write(json_dindep, file = "data processing/json_dindep.json")

json_dright = toJSON(dright)
write(json_dright, file = "data processing/json_dright.json")
