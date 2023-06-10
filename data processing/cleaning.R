library(dplyr)
library(tidyr)
library(readr)
library(forcats)
#loading the data
barometer0 = read_csv('data processing/barometer.csv')
names(barometer0)
select = dplyr::select
barometer = barometer0 %>%
  select(-BOP_NUM, -MES, -DIA, -PROVINCIA, -HABITAT, 
         -MUNICIPI, -COMARCA, -GENERE, -EDAT_CEO, -EDAT_GR) %>%
  mutate_if(is.character, function(x) fct_recode(x, 
                                              NULL = 'No contesta',
                                              NULL = 'No ho sap',
                                              "3" = "Molt",
                                              "2" = "Bastant",
                                              "1" = "Poc",
                                              "0" = "Gens",
                                              "3" = "Molt satisfet/a",
                                              "2" = "Bastant satisfet/a",
                                              "1" = "Poc satisfet/a",
                                              "0" = "Gens satisfet/a",
                                              "10" = 'Extrema dreta',
                                              "0" = 'Extrema esquerra',
                                              '2' = "Molt d'acord",
                                              '1' = 'Bastant d\'acord',
                                              '1' = "D'acord",
                                              '0' = "Ni d'acord ni en desacord",
                                              '-1' = "En desacord",
                                              '-2' = "Molt en desacord",
                                              '0' = 'Cap confiança',
                                              '10' = 'Molta confiança')) 
glimpse(barometer)
count(barometer, LLOC_NAIX)
data = barometer %>%
  transmute(
    CATALAN_ONLY = as.integer(LLENGUA_IDENTIFICACIO == 'Català (valencià / balear)'),
    SPANISH_ONLY = as.integer(LLENGUA_IDENTIFICACIO == 'Castellà'),
    SPAIN_ONLY = as.integer(CIUTADANIA == 'Sí, tinc la ciutadania (espanyola)'),
    FEMALE = as.integer(SEXE == 'Femení'),
    AGE = EDAT,
    BORN_CATALONIA = as.integer(LLOC_NAIX == 'Catalunya'),
    BORN_ABROAD = as.integer(LLOC_NAIX %in% c('Fora d\'Espanya', 'Resta del món', 'Unió Europea')),
    RIGHT = as.integer(as.character(IDEOL_0_10)),
    SELF_RULE = as.integer(fct_recode(RELACIONS_CAT_ESP,
                            "2" = 'Un estat dins una Espanya federal',
                            "3" = 'Un estat independent',
                            "1" = 'Una comunitat autònoma d\'Espanya',
                            "0" = 'Una regió d\'Espanya')),
    SELF_DETERM = as.numeric(DRET_DECIDIR),
    INTEREST_POL = as.numeric(INTERES_POL),
    CONFI_POL_CAT = as.numeric(CONFI_POL_CAT),
    CONFI_POL_ESP = as.numeric(CONFI_POL_ESP),
    ACTITUD_ECONOMIA = as.numeric(as.character(ACTITUD_ECONOMIA)),
    ACTITUD_IMPOSTOS = as.numeric(as.character(ACTITUD_IMPOSTOS)),
    ACTITUD_INGRESSOS = as.numeric(as.character(ACTITUD_INGRESSOS)),
    ACTITUD_AUTORITAT = as.numeric(as.character(ACTITUD_AUTORITAT)),
    ACTITUD_RELIGIO = as.numeric(as.character(ACTITUD_RELIGIO)),
    ACTITUD_OBEIR = as.numeric(as.character(ACTITUD_OBEIR)),
    ACTITUD_IMMIGRACIO = as.numeric(as.character(ACTITUD_IMMIGRACIO)),
    ACTITUD_MEDIAMBIENT = as.numeric(as.character(ACTITUD_MEDIAMBIENT)),
    INDEP = as.numeric(ACTITUD_INDEPENDENCIA == 'Sí')
  )
#install.packages("mice")
library(mice)

#Imputing missing data
imp = mice(data, maxit = 0)
imp = mice(data, method = imp$method, maxit = 5, m = 1, seed = 1)
data_imp = complete(imp, 1)

round(100*(p0<-prop.table(table(data$RIGHT))), 2)
round(100*(p1<-prop.table(table(data_imp$RIGHT))), 2)
round(p1-p0, 6)

glimpse(data_imp)
# VARIABLES CAN BE SELECTED
frm_indep = INDEP ~ CATALAN_ONLY + SPANISH_ONLY + SPAIN_ONLY + BORN_CATALONIA + BORN_ABROAD + 
  SELF_RULE + SELF_DETERM + I(CONFI_POL_CAT-CONFI_POL_ESP)


frm_right = RIGHT ~ ACTITUD_ECONOMIA + ACTITUD_IMPOSTOS + ACTITUD_INGRESSOS + 
  ACTITUD_AUTORITAT + ACTITUD_RELIGIO + ACTITUD_OBEIR + ACTITUD_IMMIGRACIO + 
  ACTITUD_MEDIAMBIENT

m_indep.all = glm(frm_indep, data=data_imp, family = 'binomial')
m_right.all = lm(frm_right, data=data_imp)

#anova(m_indep.all, update(m_indep.all, .~.-SELF_DETERM), test = 'LRT')

data_imp_pred = data_imp %>%
  mutate(
    INDEP.PRED = predict(m_indep.all, type = 'response'),
    RIGHT.PRED = predict(m_right.all)
  ) %>%
  select(INDEP, RIGHT, INDEP.PRED, RIGHT.PRED) 

data_imp_pred
library(ggplot2)
ggplot(data= sample_n(data_imp_pred, 1000)) +
  geom_violin(aes(x = factor(INDEP), y = INDEP.PRED))

ggplot(data= sample_n(data_imp_pred, 1000)) +
  geom_point(aes(x = RIGHT, y = RIGHT.PRED)) +
  scale_y_continuous(breaks = 0:10, limits = c(0,10)) +
  scale_x_continuous(breaks = 0:10, limits = c(0,10)) +
  geom_smooth(aes(x = RIGHT, y = RIGHT.PRED))

