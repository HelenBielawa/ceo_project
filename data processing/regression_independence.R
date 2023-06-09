library(dplyr)
library(tidyr)
library(readr)
library(forcats)
#loading the data
barometer = read_csv('barometer.csv')

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
    ECO_OVER_ENV = ACTITUD_MEDIAMBIENT) %>%
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

#3. How relevant is age?

#4. How relevant is type of area?

#5. How relevant is place of birth?

...

#CONTINUING WITH THE POLITICAL QUESTIONS

#1. How relevant is trust in government?
...


#choosing the relevant variables and calculating the predictions for them
