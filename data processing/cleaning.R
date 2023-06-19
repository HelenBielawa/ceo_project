library(dplyr)
library(tidyr)
library(readr)
library(forcats)
#loading the data
barometer0 = read_csv('data processing/barometer.csv')
names(barometer0)
select = dplyr::select
barometer = barometer0 %>%
  select(-BOP_NUM, -MES, -DIA, 
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
    SELF_RULE = as.integer(as.character(fct_recode(RELACIONS_CAT_ESP,
                                                 "2" = 'Un estat dins una Espanya federal',
                                                 "3" = 'Un estat independent',
                                                 "1" = 'Una comunitat autònoma d\'Espanya',
                                                 "0" = 'Una regió d\'Espanya'))),
    PROVINCE = as.integer(as.character(fct_recode(PROVINCIA,
                                                   "0" = 'Barcelona',
                                                   "1" = 'Girona',
                                                   "2" = 'Lleida',
                                                   "3" = 'Tarragona'))),
    MUNICIPALITY = as.integer(as.character(fct_recode(HABITAT,
                                                   "0" = '<2.000 habitants',
                                                   "0" = '2.001-10.000 habitants',
                                                   "1" = '10.001-50.000 habitants',
                                                   "2" = '50.001-150.000 habitants',
                                                   "3" = '150.001-1.000.000 habitants',
                                                   "4" = '>1.000.000 habitants'))),
    LANGUAGE = as.integer(as.character(fct_recode(LLENGUA_IDENTIFICACIO,
                                                      "0" = 'Altres llengües o altres combinacions',
                                                      "0" = 'Aranès',
                                                      "0" = 'Totes dues igual: català (valencià / balear) i castellà',
                                                      "1" = 'Català (valencià / balear)',
                                                      "2" = 'Castellà'))),
    EDUCATION = as.integer(as.character(fct_recode(ESTUDIS,
                                                   "1" = 'Batxillerat, BUP, COU, Batxillerat superior, PREU',
                                                   "1" = 'Cicle formatiu de grau mitjà, FP1, Oficialia industrial o e',
                                                   "2" = 'Cicle formatiu de grau superior, FP2, Mestratge industrial o',
                                                   "2" = 'Cursos d\'especialització professional, Postgrau, Màster (M',
                                                   "2" = 'Diplomatura, Enginyeria/arquitectura tècnica o equivalent',
                                                   "2" = 'Doctorat',
                                                   "1" = 'ESO completa (Graduat escolar), EGB, Batxiller elemental o C',
                                                   "2" = 'Llicenciatura, Arquitectura, Enginyeria, Grau o equivalent (',
                                                   "0" = 'No sap llegir i escriure',
                                                   "0" = 'Sap llegir i escriure però va anar menys de 5 anys a l\'esco',
                                                   "0" = 'Va anar a l\'escola 5 o mès anys però sense completar ESO,'))),
    BELONGING = as.integer(as.character(fct_recode(SENTIMENT_PERTINENCA,
                                                  "0" = 'Només espanyol/a',
                                                  "1" = 'Més espanyol/a que català/ana',
                                                  "2" = 'Tan espanyol/a com català/ana',
                                                  "3" = 'Més català/ana que espanyol/a',
                                                  "4" = 'Només català/ana'))),
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
set.seed(1)
imp = mice(data, maxit = 0)
imp = mice(data, method = imp$method, maxit = 50, m = 1, seed = 1)
data_imp = complete(imp, 1)

round(100*(p0<-prop.table(table(data$RIGHT))), 2)
round(100*(p1<-prop.table(table(data_imp$RIGHT))), 2)
round(p1-p0, 6)

save(data_imp, file = 'data processing/data_for_analysis.RData')
