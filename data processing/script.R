#Install CEO package

# install.packages("CEOdata")
library(CEOdata)

#Load barometer raw data
barometer = CEOdata()


#Search indicators related to language 

#select(barometer, matches("llengua", ignore.case=TRUE)) %>% 
#  View

column_names
getwd()

#Select relevant columns 

library(dplyr)

barometer = select(barometer, 
                          REO,BOP_NUM,ANY,MES,DIA,PROVINCIA,HABITAT,MUNICIPI,COMARCA,CIUTADANIA,GENERE,SEXE,EDAT, EDAT_GR, EDAT_CEO,LLOC_NAIX,IDEOL_0_10, RELACIONS_CAT_ESP, DRET_DECIDIR,INTERES_POL,SATIS_DEMOCRACIA,CONFI_POL_CAT,CONFI_POL_ESP,ACTITUD_ECONOMIA,ACTITUD_IMPOSTOS,ACTITUD_INGRESSOS, ACTITUD_AUTORITAT,ACTITUD_RELIGIO,ACTITUD_OBEIR,ACTITUD_IMMIGRACIO,ACTITUD_MEDIAMBIENT,
                          ACTITUD_INDEPENDENCIA, LLENGUA_IDENTIFICACIO)

#Export CSV
# write.csv(barometer, "baròmetre.csv")
write.csv(barometer, 'data processing/barometer.csv', row.names=FALSE)
