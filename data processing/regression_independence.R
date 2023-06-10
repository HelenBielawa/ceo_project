library(dplyr)
library(tidyr)
library(readr)
library(forcats)
#loading the data
barometer0 = read_csv('data processing/barometer.csv')

#translating and selecting relevant one, deleting some that have been asked only very very few times
barometer = barometer0 %>%
  select(-c(REO, BOP_NUM, GENERE, MES, DIA, EDAT, EDAT_CEO, PROVINCIA, MUNICIPI, COMARCA)) %>%
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
         BIRTH_PLACE = fct_recode(BIRTH_PLACE,
                                  'Catalonia' = "Catalunya",
                                  'Other parts in spain'  = "Altres comunitats autònomes",
                                  'Abroad' = 'Resta del món',
                                  'Abroad' = 'Fora d\'Espanya',
                                  'Abroad' = 'Unió Europea',
                                  NULL = 'No contesta'),
         NO_MIGRATIONS = fct_recode(ACTITUD_IMMIGRACIO,
                                    '4' = "Molt d'acord",
                                    '3' = "D'acord",
                                    '2' = "Ni d'acord ni en desacord",
                                    '1' = "En desacord",
                                    '0' = "Molt en desacord"),
         
         ECO_OVER_ENV = fct_recode(ECO_OVER_ENV,
                                   '4' = "Molt d'acord",
                                   '3' = "D'acord",
                                   '2' = "Ni d'acord ni en desacord",
                                   '1' = "En desacord",
                                   '0' = "Molt en desacord"),
         INDEP = fct_recode(INDEP,
                            '0' = "No",
                            '1' = "Sí",
                            NULL = "No contesta",
                            NULL = "No ho sap"),
         NO_RELIGION_INFL = fct_recode(ACTITUD_RELIGIO,
                                       '0' = "Molt d'acord",
                                       '1' = "D'acord",
                                       '2' = "Ni d'acord ni en desacord",
                                       '3' = "En desacord",
                                       '4' = "Molt en desacord"),
         AGE_GROUP = fct_recode(AGE_GROUP,
                                '18-34' = 'De 18 a 24 anys',
                                '18-34' = 'De 25 a 34 anys',
                                '35-49' = 'De 35 a 49 anys',
                                '50-64' = 'De 50 a 64 anys',
                                '65+' = 'Mès de 64 anys'),
         LOWER_TAXES = fct_recode(LOWER_TAXES,
                                  '0' = 'Molt en desacord',
                                  '1' = 'En desacord',
                                  '2' = 'Ni d\'acord ni en desacord',
                                  '3' = 'D\'acord',
                                  '4' = 'Molt d\'acord'),
         VNINSATISFIED = NA_real_,
         VNONSATISFIED = as.numeric(SATIS_DEMOCRACY == 'Gens satisfet/a'),
         RIGHT_NUM = as.numeric(as.character(RIGHTNESS)),
         INDEP_BIN = as.numeric(as.character(INDEP)),
         LOWER_TAXES_NUM = as.numeric(as.character(LOWER_TAXES))
  ) 

barometer
#CHECKING WHICH VARIABLES CAN PREDICT THE ATTITUDE TOWARDS INDEPENDENCE

count(barometer, INDEP)

#STARTING WITH THE SOCIOECONOMIC ONES

#1. How relevant is sex?
m1_lm = lm(INDEP_BIN~SEX, data = barometer) # Linear regression, predictions can be made outside the [0,1] interval. Nonsense.

m1 = glm(INDEP_BIN~SEX, data = barometer, family = 'binomial')  # Logistic regression
summary(m1)
# exp(-0.05554) = prob(ind|female) / prob(unity|female)
# exp(-0.05554 + 0.07456) = prob(ind|male) / prob(unity|male)
exp(coef(m1))
count(barometer, SEX) %>%
  mutate(prob = predict(m1, newdata =., type = 'response'))

count(barometer, BIRTH_PLACE)
#2. How relevant is nationality?
m2 = glm(INDEP_BIN~BIRTH_PLACE, data=barometer, family = 'binomial')
summary(m2)
count(barometer, BIRTH_PLACE) %>%
  mutate(prob = predict(m2, newdata =., type = 'response'))

# Combining SEX and BIRTH_PLACE
m3 = glm(INDEP_BIN~SEX+BIRTH_PLACE, data=barometer, family = 'binomial')
summary(m3)
count(barometer, BIRTH_PLACE, SEX) %>%
  mutate(prob = predict(m3, newdata =., type = 'response'))

count(barometer, AGE_GROUP)
#3. How relevant is age?
m4 = glm(INDEP_BIN~AGE_GROUP, data=barometer, family = 'binomial')
summary(m4)
count(barometer, AGE_GROUP) %>%
  mutate(prob = predict(m4, newdata =., type = 'response'))

m5 = glm(INDEP_BIN~SEX+BIRTH_PLACE+AGE_GROUP, data=barometer, family = 'binomial')
summary(m5)
count(barometer, BIRTH_PLACE,SEX,AGE_GROUP) %>%
  mutate(prob = predict(m5, newdata =., type = 'response')) %>%
  select(SEX, BIRTH_PLACE, AGE_GROUP, prob) %>%
  pivot_wider(names_from = AGE_GROUP, values_from = prob)


# 
# SEX+BIRTH_PLACE+AGE_GROUP
count(barometer, RIGHT_NUM)
m_right_1 = lm(RIGHT_NUM~SEX+BIRTH_PLACE*AGE_GROUP, data = barometer)
summary(m_right_1)
count(barometer, BIRTH_PLACE,SEX,AGE_GROUP) %>%
  mutate(prob = predict(m_right_1, newdata =., type = 'response')) %>%
  select(SEX, BIRTH_PLACE, AGE_GROUP, prob) %>%
  pivot_wider(names_from = AGE_GROUP, values_from = prob)

count(barometer, LOWER_TAXES_NUM)
m_right_2 = lm(RIGHT_NUM~SEX+BIRTH_PLACE*AGE_GROUP+LOWER_TAXES_NUM, data = barometer)
count(barometer, BIRTH_PLACE,AGE_GROUP, LOWER_TAXES_NUM, SEX) %>%
  mutate(prob = predict(m_right_2, newdata =., type = 'response')) %>%
  filter(SEX == 'Femení') %>%
  na.omit() %>%
  select(LOWER_TAXES_NUM, BIRTH_PLACE, AGE_GROUP, prob) %>%
  pivot_wider(names_from = AGE_GROUP, values_from = prob) %>%
  arrange(LOWER_TAXES_NUM)

### 
FINAL_VARIABLES = . ~ SEX+BIRTH_PLACE*AGE_GROUP+LOWER_TAXES_NUM+NO_MIGRATIONS

MODEL_INDEP = update(glm(INDEP_BIN~1, data = barometer, family = 'binomial'), FINAL_VARIABLES)
MODEL_RIGTH = update(lm(RIGHT_NUM~1, data = barometer), FINAL_VARIABLES)

set.seed(1)
barometer_valid = select(barometer, all_of(all.vars(FINAL_VARIABLES)[-1])) %>%
  na.omit()
barometer_sample = sample_n(barometer_valid, 100)



COORD = barometer_sample %>%
  transmute(indep = predict(MODEL_INDEP, ., type = 'response'),
            rigth = predict(MODEL_RIGTH, .))

summary(COORD)
ALL_PROBS = count(barometer, SEX, BIRTH_PLACE,AGE_GROUP, LOWER_TAXES_NUM, NO_MIGRATIONS) %>%
  na.omit() %>%
  mutate(indep = predict(MODEL_INDEP, ., type = 'response'),
         right = predict(MODEL_RIGTH, .),
         indep_scaled = (indep - min(indep)) / (max(indep)-min(indep)),
         right_scaled = (right - min(right)) / (max(right)-min(right)))

## DISCARTED
plot(ALL_PROBS[,9:10])

set.seed(1)
user_response = sample_n(barometer_valid, 1)
all_of(all.vars(FINAL_VARIABLES)[-1])
sub_setting = barometer %>%
  mutate(indep = predict(MODEL_INDEP, ., type = 'response'),
         right = predict(MODEL_RIGTH, .)) %>%
  semi_join(user_response) %>%
  select(all_of(all.vars(FINAL_VARIABLES)[-1]), RIGHT_NUM, indep, right)

barplot(prop.table(table(sub_setting$RIGHT_NUM)))

library(nnet)
multinom()
# SCALING



rowSums(round(prop.table(with(barometer, table(RIGHT_NUM, EQUAL_INCOME) ), 1), 4)[,c(1,3)])

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
