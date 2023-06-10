library(dplyr)
library(tidyr)
library(readr)
library(forcats)
#loading the data
barometer = read_csv('data processing/barometer.csv')

#translating and selecting relevant one, deleting some that have been asked only very very few times
barometer = barometer %>%
  select(-c(REO, BOP_NUM, GENERE, MES, DIA, EDAT, EDAT_CEO, PROVINCIA, MUNICIPI, COMARCA, ACTITUD_IMMIGRACIO)) %>%
  rename(
    YEAR = ANY,
    INDEP = ACTITUD_INDEPENDENCIA,
    AREA_TYPE = HABITAT,
    NAT = CIUTADANIA,
    SEX = SEXE,
    AGE_GROUP = EDAT_GR,
    BIRTH_PLACE = LLOC_NAIX,
    LESS_ECO_INTERV = ACTITUD_ECONOMIA,
    LOWER_TAXES = ACTITUD_IMPOSTOS,
    EQUAL_INCOME = ACTITUD_INGRESSOS,
    TEACH_AUTH_OBEY = ACTITUD_AUTORITAT,
    OBEY_LAW = ACTITUD_OBEIR,
    ECO_OVER_ENV = ACTITUD_MEDIAMBIENT,
    TRUST_CAT_POL = CONFI_POL_CAT,
    TRUST_ESP_POL = CONFI_POL_ESP,
    SATIS_DEMOCRACY = SATIS_DEMOCRACIA) %>%
    mutate(RIGHTNESS = fct_recode(IDEOL_0_10,
                       "No answer" = 'No contesta',
                       "I don't know" = 'No ho sap',
                       "10" = 'Extrema dreta',
                       "0" = 'Extrema esquerra'),
    STATE_FORM = fct_recode(RELACIONS_CAT_ESP,
                       "No answer" = 'No contesta',
                       "I don't know" = 'No ho sap',
                       "Federal state inside Spain" = 'Un estat dins una Espanya federal',
                       "Independent state" = 'Un estat independent',
                       "Autonomous community" = 'Una comunitat autònoma d\'Espanya',
                       "Region of Spain" = 'Una regió d\'Espanya'
    ),
    REFERENDUM = fct_recode(DRET_DECIDIR,
                            "very much agree" = "Molt d'acord",
                              "agree" = "Bastant d'acord",
                            "neither nor" = "Ni d'acord ni en desacord",
                            "disagree" = "En desacord", 
                            "very much disagree" = "Molt en desacord",
                            ),
    POL_INTEREST = fct_recode(INTERES_POL,
      "a lot" = "Molt",
      "a bit" = "Poc",
      "not much"= "Bastant",
      "not at all" = "Gens",
    ),
    INDEP = fct_recode(INDEP,
                       '0' = "No",
                       '1' = "Sí",
                       "NA" = "No contesta",
                       "NA" = "No ho sap"),
    NO_RELIGION_INFL = fct_recode(ACTITUD_RELIGIO,
                          '0' = "Molt d'acord",
                          '1' = "D'acord",
                          '2' = "Ni d'acord ni en desacord",
                          '3' = "En desacord",
                          '4' = "Molt en desacord"),
    RIGHT_NUM = as.numeric(as.character(RIGHTNESS))
  ) 

barometer
#CHECKING WHICH VARIABLES CAN PREDICT THE ATTITUDE TOWARDS INDEPENDENCE

count(barometer, INDEP)

#STARTING WITH THE SOCIOECONOMIC ONES

#1. How relevant is sex?
m1 = lm(INDEP~SEX, data = barometer, na.action=na.exclude)


#2. How relevant is nationality?
m2 = lm(INDEP~NAT, data=barometer, na.action=na.exclude)


#3. How relevant is age?
m3 = lm(INDEP~AGE_GROUP, data=barometer, na.action=na.exclude)

#4. How relevant is type of area?
## 'Habitat' doesn't exist
m4 = lm(INDEP~AREA_TYPE, data=barometer, na.action=na.exclude)

#5. How relevant is place of birth?
m4 = lm(INDEP~BIRTH_PLACE, data=barometer, na.action=na.exclude)
...

#CONTINUING WITH THE POLITICAL QUESTIONS

#1. How relevant is trust in Catalan politicians?
m5 = lm(INDEP~TRUST_CAT_POL, data=barometer, na.action=na.exclude)

#2. How relevant is trust in Spanish politicians?
m6 = lm(INDEP~TRUST_ESP_POL, data=barometer, na.action=na.exclude)

#3. How relevant is the support for a referendum on independence?
m7 = lm(INDEP~REFERENDUM, data=barometer, na.action=na.exclude)

#4. How relevant is the level of satisfaction with democracy?
m8 = lm(INDEP~SATIS_DEMOCRACY, data=barometer, na.action=na.exclude)

#4. How relevant is the preferred form of state?
m9 = lm(INDEP~STATE_FORM, data=barometer, na.action=na.exclude)


...


#choosing the relevant variables and calculating the predictions for them
