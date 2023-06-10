library(tidyverse)
barometer = read_csv('data processing/barometer.csv')
barometer = barometer %>%
  mutate(
    INDEP = fct_recode(RELACIONS_CAT_ESP,
                       "No answer" = 'No contesta',
                       "I don't know" = 'No ho sap',
                       "Federal state inside Spain" = 'Un estat dins una Espanya federal',
                       "Independent state" = 'Un estat independent',
                       "Autonomous community" = 'Una comunitat autònoma d\'Espanya',
                       "Region of Spain" = 'Una regió d\'Espanya'
    ),
    RIGHT = fct_recode(IDEOL_0_10,
                       "No answer" = 'No contesta',
                       "I don't know" = 'No ho sap',
                       "10" = 'Extrema dreta',
                       "0" = 'Extrema esquerra'),
    RELIGION = fct_recode(ACTITUD_RELIGIO,
                          '0' = "Molt d'acord",
                          '1' = "D'acord",
                          '2' = "Ni d'acord ni en desacord",
                          '3' = "En desacord",
                          '4' = "Molt en desacord"),
    RIGHT_NUM = as.numeric(as.character(RIGHT))
  ) 

count(barometer, RELACIONS_CAT_ESP)
count(barometer, INDEP)

with(barometer, table(RIGHT_NUM, INDEP)) %>%
  prop.table(1)

with(barometer, plot(factor(RIGHT_NUM), INDEP))

## Response variable
with(barometer, summary(RIGHT_NUM))
count(barometer, ACTITUD_RELIGIO)

# Fins a quin punt està d’acord o en desacord amb cadascuna de les següents afirmacions: 
#   La religió no hauria de tenir cap influència en la política

# Find to what extent you agree or disagree with each of the following statements: 
#   "Religion should not have any influence in politics."

m1 = lm(RIGHT_NUM~RELIGION, data = barometer)
anova(m1)
summary(m1)

m2 = lm(RIGHT_NUM~SEXE, data = barometer)
anova(m2)

m3 = lm(RIGHT_NUM~EDAT, data = barometer)
anova(m3)
summary(m3)

m4 = lm(RIGHT_NUM~EDAT+RELIGION, data = barometer)
anova(m4)
summary(m4)

m4_inter = lm(RIGHT_NUM~EDAT + RELIGION + EDAT:RELIGION, data = barometer)
anova(m4_inter)
summary(m4_inter)

anova(m4, m4_inter)

tibble(
  RELIGION = as.character(0:4)) %>%
  mutate(
    RIGHT_MEAN = predict(m1, list(RELIGION = as.character(0:4))))

expand_grid(
  EDAT = seq(20, 60, 10),
  RELIGION = as.character(0:4)
) %>%
  mutate(
    RIGHT_MEAN = predict(m4, list(RELIGION = RELIGION, EDAT = EDAT))) %>%
  pivot_wider(names_from = RELIGION, values_from = RIGHT_MEAN)

expand_grid(
  EDAT = seq(20, 60, 10),
  RELIGION = as.character(0:4)
) %>%
  mutate(
    RIGHT_MEAN = predict(m4_inter, list(RELIGION = RELIGION, EDAT = EDAT))) %>%
  pivot_wider(names_from = RELIGION, values_from = RIGHT_MEAN)

# LEFT_RIGHT  [0-1]
# SPAIN_INDENT [0-1]   

count(barometer, ANY)
m5 = lm(RIGHT_NUM~factor(ANY), data = barometer)
anova(m5)
summary(m5)

expand_grid(
  ANY = c(2014:2020, 2022:2023)
) %>%
  mutate(
    RIGHT_MEAN = predict(m5, list(ANY = factor(ANY))))


m5yes = lm(RIGHT_NUM~factor(ANY), data = barometer, subset = ACTITUD_INDEPENDENCIA == 'Sí')
anova(m5yes)
summary(m5yes)

dyes = expand_grid(
  ANY = c(2015:2020, 2022:2023)
) %>%
  mutate(
    RIGHT_MEAN_yes = predict(m5yes, list(ANY = factor(ANY))))

m5no = lm(RIGHT_NUM~factor(ANY), data = barometer, subset = ACTITUD_INDEPENDENCIA == 'No')
anova(m5no)
summary(m5no)

dno = expand_grid(
  ANY = c(2015:2020, 2022:2023)
) %>%
  mutate(
    RIGHT_MEAN_no = predict(m5no, list(ANY = factor(ANY))))

dplot = inner_join(dyes, dno) %>%
  mutate(
    diff = RIGHT_MEAN_yes - RIGHT_MEAN_no
  )
ggplot(data=dplot) +
  geom_point(aes(x = ANY, y = RIGHT_MEAN_yes, col = 'yes')) +
  geom_point(aes(x = ANY, y = RIGHT_MEAN_no, col = 'no'))

barometer %>%
  group_by(ANY) %>%
  summarise(prop.indep = mean(ACTITUD_INDEPENDENCIA == 'Sí', na.rm=TRUE),
            prop.against = mean(ACTITUD_INDEPENDENCIA == 'No', na.rm=TRUE))

m6 = glm((ACTITUD_INDEPENDENCIA == 'Sí')~EDAT+RELIGION+EDAT:RELIGION, 
            data = barometer, family = 'binomial')
anova(m6, test = 'LRT')
summary(m6)
expand_grid(
  EDAT = seq(20, 60, 10),
  RELIGION = c('0','1','2','3')
) %>%
  mutate(
    ProbINDEP = predict(m6, list(EDAT = EDAT, RELIGION = RELIGION), type = 'response')) %>%
  pivot_wider(names_from = RELIGION , values_from = ProbINDEP)

