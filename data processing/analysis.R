library(tidyverse)
library(dplyr)
library(ggplot2)
load('data processing/data_for_analysis.RData')

glimpse(data_imp)
# VARIABLES CAN BE SELECTED
frm_indep = INDEP ~ CATALAN_ONLY + SPANISH_ONLY + SPAIN_ONLY + BORN_CATALONIA + BORN_ABROAD + 
  SELF_DETERM + I(CONFI_POL_CAT-CONFI_POL_ESP)


frm_right = RIGHT ~ ACTITUD_ECONOMIA + ACTITUD_IMPOSTOS + ACTITUD_INGRESSOS + 
  ACTITUD_AUTORITAT + ACTITUD_RELIGIO + ACTITUD_OBEIR + ACTITUD_IMMIGRACIO + 
  ACTITUD_MEDIAMBIENT

m_indep.all = glm(frm_indep, data=data_imp, family = 'binomial')
m_right.all = lm(frm_right, data=data_imp)

#anova(m_indep.all, update(m_indep.all, .~.-SELF_DETERM), test = 'LRT')

#Create the dataset with the predictions per interviewee, also adding age and gender

data_imp_pred = data_imp %>%
  mutate(
    INDEP.PRED = predict(m_indep.all, type = 'response'),
    RIGHT.PRED = predict(m_right.all)
  ) %>%
  select(FEMALE, AGE, INDEP, RIGHT, INDEP.PRED, RIGHT.PRED)

# Define age range groups
data_imp_pred <- data_imp_pred %>%
  mutate(AGE_RANGE = case_when(
    AGE >= 18 & AGE <= 34 ~ "18-34",
    AGE >= 35 & AGE <= 49 ~ "35-49",
    AGE >= 50 & AGE <= 64 ~ "50-64",
    AGE >= 65 ~ "65+"
  ))

# Group by gender and age range and calculate cluster means
clustered_data <- data_imp_pred %>%
  group_by(FEMALE, AGE_RANGE) %>%
  summarise(INDEP_Pred_Mean = mean(INDEP.PRED),
            RIGHT_Pred_Mean = mean(RIGHT.PRED))

data_imp_pred
library(ggplot2)
ggplot(data= sample_n(data_imp_pred, 1000)) +
  geom_violin(aes(x = factor(INDEP), y = INDEP.PRED))

ggplot(data= sample_n(data_imp_pred, 1000)) +
  geom_point(aes(x = RIGHT, y = RIGHT.PRED)) +
  scale_y_continuous(breaks = 0:10, limits = c(0,10)) +
  scale_x_continuous(breaks = 0:10, limits = c(0,10)) +
  geom_smooth(aes(x = RIGHT, y = RIGHT.PRED))

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
cat("var PROB = 1/(1+exp(-LP))")

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

# Calculation to get the score in the indy axis

LP =-2.003 * 1 + 1.727 * CATALAN_ONLY -0.915 * SPANISH_ONLY + 
  0.241 * SPAIN_ONLY + 0.715 * BORN_CATALONIA + 0.847 * BORN_ABROAD + 
  0.286 * SELF_DETERM -0.011 * (CONFI_POL_CAT - CONFI_POL_ESP)

1/(1+exp(-LP))

# Example of response in left-right axis

vs = names(coef(m_right.all))
vs[1] = '1'
cat(sprintf("var LP = %s", gsub('\\+ -', '-', paste(sprintf("%0.3f * %s", coef(m_right.all), vs), collapse = ' + '))))
ACTITUD_ECONOMIA = 1
ACTITUD_IMPOSTOS = 0
ACTITUD_INGRESSOS = 0
ACTITUD_AUTORITAT = 2
ACTITUD_RELIGIO = 1
ACTITUD_OBEIR = 1
ACTITUD_IMMIGRACIO = 1
ACTITUD_MEDIAMBIENT = 1

# Calculation to get the score in the left-right axis

LP = 4.552 * 1 + 0.032 * ACTITUD_ECONOMIA + 0.102 * ACTITUD_IMPOSTOS +
  -0.219 * ACTITUD_INGRESSOS + 0.203 * ACTITUD_AUTORITAT +
  -0.235 * ACTITUD_RELIGIO + 0.185 * ACTITUD_OBEIR + 
  0.150 * ACTITUD_IMMIGRACIO + 0.062 * ACTITUD_MEDIAMBIENT
(LP - 2) / (8-2)

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


data_imp %>%
  select(AGE, FEMALE) %>%
  left_join(PREDICTED) %>%
  ggplot() +
  geom_point(aes(x = INDEP.PRED, y = RIGHT.PRED))

  # geom_density_2d_filled(aes(x = INDEP.PRED, y = RIGHT.PRED))
