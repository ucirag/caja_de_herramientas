#####UNIVERSAL AMBULATORIOS####

IRA_UNIVERSAL_AMBULATORIOS<- VR_NOMINAL%>%
  filter(EVENTO=="COVID-19, Influenza y OVR en ambulatorios (No UMAs)")%>%
  filter(AÑO==2024)


SE_MAX<-max(IRA_UNIVERSAL_AMBULATORIOS$SEPI_CREADA)
SE_MIN<-min(IRA_UNIVERSAL_AMBULATORIOS$SEPI_CREADA)

#CUENTO CASOS POR SE Y POR DETERMINACIÓN# 

CONTEO_AMBULATORIOS_SE<- IRA_UNIVERSAL_AMBULATORIOS%>%
  group_by(SEPI_CREADA,DETERMINACION)%>%
  count()%>%
  ungroup()%>%
  complete(SEPI_CREADA, DETERMINACION, fill = list(n = 0))

N_testeos<-sum(CONTEO_AMBULATORIOS_SE$n, na.rm = T)
N_testeos


#CUENTO CASOS TOTALES POR SE#
CONTEO_AMBULATORIOS_SE_TOTAL <-
  IRA_UNIVERSAL_AMBULATORIOS%>%
  mutate(SEPI_CREADA=factor(SEPI_CREADA, levels = 1:SE_MAX))%>%
  group_by(SEPI_CREADA) %>%
  count()%>%
  ungroup()%>%
  complete(SEPI_CREADA, fill = list(n = 0))




#CUENTO CASOS POR SE Y POR DETERMINACION (SOLO LAS POSITIVAS)## 
CASOS_AMBULATORIOS_SE_POSITIVOS<-IRA_UNIVERSAL_AMBULATORIOS%>%
  filter(determinacion2== "1")%>%
  filter(AÑO==2024)%>%
  mutate(DETERMINACION = case_when(
    DETERMINACION %in% c("Genoma viral SARS-CoV-2", "Detección de Antígeno de SARS CoV-2",
                         "Genoma viral de Coronavirus NL63", "Genoma viral de Coronavirus OC43",
                         "Genoma viral de Coronavirus 229E") ~ "Sars-Cov-2",
    DETERMINACION %in% c("Genoma viral de Parainfluenza 1", "Genoma viral de Parainfluenza 2",
                         "Genoma viral de Parainfluenza 3", "Genoma viral de Parainfluenza 4") ~ "Parainfluenza",
    DETERMINACION %in% c("Genoma viral de VSR", "Genoma viral de VSR A", "Genoma viral de VSR B") ~ "VSR",
    DETERMINACION == "Genoma viral de Metaneumovirus Humano" ~ "Metaneumovirus",
    DETERMINACION %in% c("Genoma viral de Influenza A (sin subtipificar)", "Genoma viral de Influenza A H1N1pdm",
                         "Genoma viral de Influenza A H3N2", "Antígeno viral de influenza A") ~ "Influenza A",
    DETERMINACION %in% c("Genoma viral de Influenza B (sin linaje)", "Antígeno viral de influenza B",
                         "Genoma viral de Influenza B, linaje Victoria") ~ "Influenza B",
    DETERMINACION %in% c("Detección molecular de Adenovirus", "Genoma viral de Adenovirus") ~ "Adenovirus",
    DETERMINACION %in% c("Detección molecular de Enterovirus", "Genoma viral de Enterovirus") ~ "Enterovirus",
    DETERMINACION == "Detección molecular de Bocavirus" ~ "Bocavirus",
    DETERMINACION == "Genoma viral de Rinovirus" ~ "Rinovirus",
    DETERMINACION %in% c("", NA) ~ "Sin determinacion", # Combina celdas vacías y NA
    TRUE ~ "Otro"),
    SEPI_CREADA=factor(SEPI_CREADA, levels = 1:SE_MAX))%>%
  group_by(SEPI_CREADA,DETERMINACION)%>%
  count()%>%
  ungroup()%>%
  complete(SEPI_CREADA, DETERMINACION, fill = list(n = 0))


N_testeos_positivos<-sum(CASOS_AMBULATORIOS_SE_POSITIVOS$n, na.rm = T)
N_testeos_positivos

POSITIVIDAD_AMBULATORIOS_UNIVERSAL<- N_testeos_positivos/N_testeos*100
POSITIVIDAD_AMBULATORIOS_UNIVERSAL

###ARMO UNA TABLA CON LOS TESTEOS, POSITIVOS Y POSITIVIDAD###
tabla_ambulatorios_universal <- data.frame(Evento="COVID-19, Influenza y OVR en ambulatorios (No UMAs)",N_testeos_positivos, N_testeos, POSITIVIDAD_AMBULATORIOS_UNIVERSAL)

tabla_ambulatorios_universal$POSITIVIDAD_AMBULATORIOS_UNIVERSAL <- round(tabla_ambulatorios_universal$POSITIVIDAD_AMBULATORIOS_UNIVERSAL, 2)

tabla_ambulatorios_universal<-tabla_ambulatorios_universal%>%mutate(POSITIVIDAD_AMBULATORIOS_UNIVERSAL=paste0(POSITIVIDAD_AMBULATORIOS_UNIVERSAL,"%"))
names(tabla_ambulatorios_universal) <- c("Evento"   ,  "Testeos positivos"  ,             
                                         "Testeos totales",    "Positividad")

### CUENTO POR EDAD Y DETERMINACIÓN##

CONTEO_AMBULATORIOS_edad <-IRA_UNIVERSAL_AMBULATORIOS%>%
  filter(determinacion2== "1")%>%
  mutate(DETERMINACION = case_when(
    DETERMINACION %in% c("Genoma viral SARS-CoV-2", "Detección de Antígeno de SARS CoV-2",
                         "Genoma viral de Coronavirus NL63", "Genoma viral de Coronavirus OC43",
                         "Genoma viral de Coronavirus 229E") ~ "Sars-Cov-2",
    DETERMINACION %in% c("Genoma viral de Parainfluenza 1", "Genoma viral de Parainfluenza 2",
                         "Genoma viral de Parainfluenza 3", "Genoma viral de Parainfluenza 4") ~ "Parainfluenza",
    DETERMINACION %in% c("Genoma viral de VSR", "Genoma viral de VSR A", "Genoma viral de VSR B") ~ "VSR",
    DETERMINACION == "Genoma viral de Metaneumovirus Humano" ~ "Metaneumovirus",
    DETERMINACION %in% c("Genoma viral de Influenza A (sin subtipificar)", "Genoma viral de Influenza A H1N1pdm",
                         "Genoma viral de Influenza A H3N2", "Antígeno viral de influenza A") ~ "Influenza A",
    DETERMINACION %in% c("Genoma viral de Influenza B (sin linaje)", "Antígeno viral de influenza B",
                         "Genoma viral de Influenza B, linaje Victoria") ~ "Influenza B",
    DETERMINACION %in% c("Detección molecular de Adenovirus", "Genoma viral de Adenovirus") ~ "Adenovirus",
    DETERMINACION %in% c("Detección molecular de Enterovirus", "Genoma viral de Enterovirus") ~ "Enterovirus",
    DETERMINACION == "Detección molecular de Bocavirus" ~ "Bocavirus",
    DETERMINACION == "Genoma viral de Rinovirus" ~ "Rinovirus",
    DETERMINACION %in% c("", NA) ~ "Sin determinacion", # Combina celdas vacías y NA
    TRUE ~ "Otro"))%>%
  group_by(GRUPO_EDAD2, DETERMINACION)%>%
  count()%>%
  ungroup()
# Usar complete para rellenar los grupos de edad faltantes y completar con 0 en "casos
# Me aseguro que no queden rangos sin completar
CONTEO_AMBULATORIOS_edad<- CONTEO_AMBULATORIOS_edad %>%
  complete(GRUPO_EDAD2, DETERMINACION, fill = list(n = 0))


#### CUENTO POR LOCALIDAD LOS CASOS POSITIVOS##
CONTEO_AMBULATORIOS_localidad <-
  IRA_UNIVERSAL_AMBULATORIOS %>%
  filter(determinacion2== "1") %>%
  group_by(LOCALIDAD_RESIDENCIA) %>%
  count()
write.csv(x = CONTEO_AMBULATORIOS_localidad, file = "CONTEO_AMBULATORIOS_localidad.csv", row.names = FALSE) 

###CUENTO LOS SINTOMAS DE LOS CASOS POSITIVOS
# Agrupar los datos por los síntomas y calcular el total de casos
CONTEO_AMBULATORIOS_sintomas <- IRA_UNIVERSAL_AMBULATORIOS %>%
  filter(determinacion2== "1")%>%
  summarise(across(starts_with("SINTOMA_"), sum, na.rm = TRUE)) %>% #Suma las columnas relacionadas con síntomas ( starts_with("SINTOMA_")) en todo el conjunto de datos
  pivot_longer(cols = everything(), 
               names_to = "Sintoma", 
               values_to = "n") #Convierta las columnas de síntomas en filas para tener solo dos columnas: Sintomay n


####CUENTO LAS COMORBILIDADES DE LOS CASOS POSITIVOS
CONTEO_AMBULATORIOS_comorbilidades <- IRA_UNIVERSAL_AMBULATORIOS %>%
  filter(determinacion2== "1")%>%
  summarise(across(starts_with("COMORB_"), sum, na.rm = TRUE)) %>% #Suma las columnas relacionadas con síntomas ( starts_with("SINTOMA_")) en todo el conjunto de datos
  pivot_longer(cols = everything(), 
               names_to = "Comorbilidades", 
               values_to = "n") #Convierta las columnas de síntomas en filas para tener solo dos columnas: Sintomay n



####UNIVERSAL INTERNADOS####
IRA_UNIVERSAL_INTERNADOS<- VR_NOMINAL%>%
  filter(EVENTO=="Internado y/o fallecido por COVID o IRA")%>%
  filter(AÑO==2024)
#POR DETERMINACIÓN# Acá cuento cuantos testeos por semana y por determinacion de 2024(incluye positivos y negativos)

SE_MAX_INTERNADOS<-max(IRA_UNIVERSAL_INTERNADOS$SEPI_CREADA)
SE_MIN_INTERNADOS<-min(IRA_UNIVERSAL_INTERNADOS$SEPI_CREADA)

#CUENTO CASOS POR SE Y POR DETERMINACIÓN# 

CONTEO_INTERNADOS_SE<- IRA_UNIVERSAL_INTERNADOS%>%
  group_by(SEPI_CREADA,DETERMINACION)%>%
  count()%>%
  ungroup()%>%
  complete(SEPI_CREADA, DETERMINACION, fill = list(n = 0))

N_testeos_internados<-sum(CONTEO_INTERNADOS_SE$n, na.rm = T)
N_testeos_internados


#CUENTO CASOS TOTALES POR SE#
CONTEO_INTERNADOS_SE_TOTAL <-
  IRA_UNIVERSAL_INTERNADOS%>%
  mutate(SEPI_CREADA=factor(SEPI_CREADA, levels = 1:SE_MAX_INTERNADOS))%>%
  group_by(SEPI_CREADA) %>%
  count()%>%
  ungroup()%>%
  complete(SEPI_CREADA, fill = list(n = 0))




#CUENTO CASOS POR SE Y POR DETERMINACION (SOLO LAS POSITIVAS)## 
CASOS_INTERNADOS_SE_POSITIVOS<-IRA_UNIVERSAL_INTERNADOS%>%
  filter(determinacion2== "1")%>%
  filter(AÑO==2024)%>%
  mutate(DETERMINACION = case_when(
    DETERMINACION %in% c("Genoma viral SARS-CoV-2", "Detección de Antígeno de SARS CoV-2",
                         "Genoma viral de Coronavirus NL63", "Genoma viral de Coronavirus OC43",
                         "Genoma viral de Coronavirus 229E") ~ "Sars-Cov-2",
    DETERMINACION %in% c("Genoma viral de Parainfluenza 1", "Genoma viral de Parainfluenza 2",
                         "Genoma viral de Parainfluenza 3", "Genoma viral de Parainfluenza 4") ~ "Parainfluenza",
    DETERMINACION %in% c("Genoma viral de VSR", "Genoma viral de VSR A", "Genoma viral de VSR B") ~ "VSR",
    DETERMINACION == "Genoma viral de Metaneumovirus Humano" ~ "Metaneumovirus",
    DETERMINACION %in% c("Genoma viral de Influenza A (sin subtipificar)", "Genoma viral de Influenza A H1N1pdm",
                         "Genoma viral de Influenza A H3N2", "Antígeno viral de influenza A") ~ "Influenza A",
    DETERMINACION %in% c("Genoma viral de Influenza B (sin linaje)", "Antígeno viral de influenza B",
                         "Genoma viral de Influenza B, linaje Victoria") ~ "Influenza B",
    DETERMINACION %in% c("Detección molecular de Adenovirus", "Genoma viral de Adenovirus") ~ "Adenovirus",
    DETERMINACION %in% c("Detección molecular de Enterovirus", "Genoma viral de Enterovirus") ~ "Enterovirus",
    DETERMINACION == "Detección molecular de Bocavirus" ~ "Bocavirus",
    DETERMINACION == "Genoma viral de Rinovirus" ~ "Rinovirus",
    DETERMINACION %in% c("", NA) ~ "Sin determinacion", # Combina celdas vacías y NA
    TRUE ~ "Otro"),
    SEPI_CREADA=factor(SEPI_CREADA, levels = 1:SE_MAX_INTERNADOS))%>%
  group_by(SEPI_CREADA,DETERMINACION)%>%
  count()%>%
  ungroup()%>%
  complete(SEPI_CREADA, DETERMINACION, fill = list(n = 0))


N_testeos_positivos_internados<-sum(CASOS_INTERNADOS_SE_POSITIVOS$n, na.rm = T)
N_testeos_positivos_internados

POSITIVIDAD_INTERNADOS_UNIVERSAL<- N_testeos_positivos_internados/N_testeos_internados*100
POSITIVIDAD_INTERNADOS_UNIVERSAL

###ARMO UNA TABLA CON LOS TESTEOS, POSITIVOS Y POSITIVIDAD###
tabla_internados_universal <- data.frame(Evento="Internado y/o fallecido por COVID o IRA",N_testeos_positivos_internados, N_testeos_internados, POSITIVIDAD_INTERNADOS_UNIVERSAL)

tabla_internados_universal$POSITIVIDAD_INTERNADOS_UNIVERSAL <- round(tabla_internados_universal$POSITIVIDAD_INTERNADOS_UNIVERSAL, 2)

tabla_internados_universal<-tabla_internados_universal%>%mutate(POSITIVIDAD_INTERNADOS_UNIVERSAL=paste0(POSITIVIDAD_INTERNADOS_UNIVERSAL,"%"))
names(tabla_internados_universal) <- c("Evento"   ,  "Testeos positivos"  ,             
                                       "Testeos totales",    "Positividad")

### CUENTO POR EDAD Y DETERMINACIÓN##

CONTEO_INTERNADOS_edad <-IRA_UNIVERSAL_INTERNADOS%>%
  filter(determinacion2== "1")%>%
  mutate(DETERMINACION = case_when(
    DETERMINACION %in% c("Genoma viral SARS-CoV-2", "Detección de Antígeno de SARS CoV-2",
                         "Genoma viral de Coronavirus NL63", "Genoma viral de Coronavirus OC43",
                         "Genoma viral de Coronavirus 229E") ~ "Sars-Cov-2",
    DETERMINACION %in% c("Genoma viral de Parainfluenza 1", "Genoma viral de Parainfluenza 2",
                         "Genoma viral de Parainfluenza 3", "Genoma viral de Parainfluenza 4") ~ "Parainfluenza",
    DETERMINACION %in% c("Genoma viral de VSR", "Genoma viral de VSR A", "Genoma viral de VSR B") ~ "VSR",
    DETERMINACION == "Genoma viral de Metaneumovirus Humano" ~ "Metaneumovirus",
    DETERMINACION %in% c("Genoma viral de Influenza A (sin subtipificar)", "Genoma viral de Influenza A H1N1pdm",
                         "Genoma viral de Influenza A H3N2", "Antígeno viral de influenza A") ~ "Influenza A",
    DETERMINACION %in% c("Genoma viral de Influenza B (sin linaje)", "Antígeno viral de influenza B",
                         "Genoma viral de Influenza B, linaje Victoria") ~ "Influenza B",
    DETERMINACION %in% c("Detección molecular de Adenovirus", "Genoma viral de Adenovirus") ~ "Adenovirus",
    DETERMINACION %in% c("Detección molecular de Enterovirus", "Genoma viral de Enterovirus") ~ "Enterovirus",
    DETERMINACION == "Detección molecular de Bocavirus" ~ "Bocavirus",
    DETERMINACION == "Genoma viral de Rinovirus" ~ "Rinovirus",
    DETERMINACION %in% c("", NA) ~ "Sin determinacion", # Combina celdas vacías y NA
    TRUE ~ "Otro"))%>%
  group_by(GRUPO_EDAD2, DETERMINACION)%>%
  count()%>%
  ungroup()
# Usar complete para rellenar los grupos de edad faltantes y completar con 0 en "casos
# Me aseguro que no queden rangos sin completar
CONTEO_INTERNADOS_edad<- CONTEO_INTERNADOS_edad %>%
  complete(GRUPO_EDAD2, DETERMINACION, fill = list(n = 0))


#### CUENTO POR LOCALIDAD LOS CASOS POSITIVOS##
CONTEO_INTERNADOS_localidad <-
  IRA_UNIVERSAL_INTERNADOS %>%
  filter(determinacion2== "1") %>%
  group_by(LOCALIDAD_RESIDENCIA) %>%
  count()
write.csv(x = CONTEO_INTERNADOS_localidad, file = "CONTEO_INTERNADOS_localidad.csv", row.names = FALSE) 

###CUENTO LOS SINTOMAS DE LOS CASOS POSITIVOS
# Agrupar los datos por los síntomas y calcular el total de casos
CONTEO_INTERNADOS_sintomas <- IRA_UNIVERSAL_INTERNADOS %>%
  filter(determinacion2== "1")%>%
  summarise(across(starts_with("SINTOMA_"), sum, na.rm = TRUE)) %>% #Suma las columnas relacionadas con síntomas ( starts_with("SINTOMA_")) en todo el conjunto de datos
  pivot_longer(cols = everything(), 
               names_to = "Sintoma", 
               values_to = "n") #Convierta las columnas de síntomas en filas para tener solo dos columnas: Sintomay n


####CUENTO LAS COMORBILIDADES DE LOS CASOS POSITIVOS
CONTEO_INTERNADOS_comorbilidades <- IRA_UNIVERSAL_INTERNADOS %>%
  filter(determinacion2== "1")%>%
  summarise(across(starts_with("COMORB_"), sum, na.rm = TRUE)) %>% #Suma las columnas relacionadas con síntomas ( starts_with("SINTOMA_")) en todo el conjunto de datos
  pivot_longer(cols = everything(), 
               names_to = "Comorbilidades", 
               values_to = "n") #Convierta las columnas de síntomas en filas para tener solo dos columnas: Sintomay n


#####CENTINELA_UMA#####
IRA_UMA<- VR_NOMINAL%>%
  filter(EVENTO== "Monitoreo de SARS COV-2, Influenza y VSR en ambulatorios")%>%
  filter(AÑO==2024)

#POR DETERMINACIÓN# Acá cuento cuantos testeos por semana y por determinacion de 2024(incluye positivos y negativos)

SE_MAX_UMA<-max(IRA_UMA$SEPI_CREADA)
SE_MIN_UMA<-min(IRA_UMA$SEPI_CREADA)

#CUENTO CASOS POR SE Y POR DETERMINACIÓN# 

CONTEO_IRA_UMA_SE<- IRA_UMA%>%
  group_by(SEPI_CREADA,DETERMINACION)%>%
  count()%>%
  ungroup()%>%
  complete(SEPI_CREADA, DETERMINACION, fill = list(n = 0))

N_testeos_UMA<-sum(CONTEO_IRA_UMA_SE$n, na.rm = T)
N_testeos_UMA


#CUENTO CASOS TOTALES POR SE#
CONTEO_UMA_SE_TOTAL <-
  IRA_UMA%>%
  mutate(SEPI_CREADA=factor(SEPI_CREADA, levels = 1:SE_MAX_UMA))%>%
  group_by(SEPI_CREADA) %>%
  count()%>%
  ungroup()%>%
  complete(SEPI_CREADA, fill = list(n = 0))




#CUENTO CASOS POR SE Y POR DETERMINACION (SOLO LAS POSITIVAS)## 
CASOS_UMA_SE_POSITIVOS<-IRA_UMA%>%
  filter(determinacion2== "1")%>%
  mutate(DETERMINACION = case_when(
    DETERMINACION %in% c("Genoma viral SARS-CoV-2", "Detección de Antígeno de SARS CoV-2",
                         "Genoma viral de Coronavirus NL63", "Genoma viral de Coronavirus OC43",
                         "Genoma viral de Coronavirus 229E") ~ "Sars-Cov-2",
    DETERMINACION %in% c("Genoma viral de Parainfluenza 1", "Genoma viral de Parainfluenza 2",
                         "Genoma viral de Parainfluenza 3", "Genoma viral de Parainfluenza 4") ~ "Parainfluenza",
    DETERMINACION %in% c("Genoma viral de VSR", "Genoma viral de VSR A", "Genoma viral de VSR B") ~ "VSR",
    DETERMINACION == "Genoma viral de Metaneumovirus Humano" ~ "Metaneumovirus",
    DETERMINACION %in% c("Genoma viral de Influenza A (sin subtipificar)", "Genoma viral de Influenza A H1N1pdm",
                         "Genoma viral de Influenza A H3N2", "Antígeno viral de influenza A") ~ "Influenza A",
    DETERMINACION %in% c("Genoma viral de Influenza B (sin linaje)", "Antígeno viral de influenza B",
                         "Genoma viral de Influenza B, linaje Victoria") ~ "Influenza B",
    DETERMINACION %in% c("Detección molecular de Adenovirus", "Genoma viral de Adenovirus") ~ "Adenovirus",
    DETERMINACION %in% c("Detección molecular de Enterovirus", "Genoma viral de Enterovirus") ~ "Enterovirus",
    DETERMINACION == "Detección molecular de Bocavirus" ~ "Bocavirus",
    DETERMINACION == "Genoma viral de Rinovirus" ~ "Rinovirus",
    DETERMINACION %in% c("", NA) ~ "Sin determinacion", # Combina celdas vacías y NA
    TRUE ~ "Otro"),
    SEPI_CREADA=factor(SEPI_CREADA, levels = 1:SE_MAX_UMA))%>%
  group_by(SEPI_CREADA,DETERMINACION)%>%
  count()%>%
  ungroup()%>%
  complete(SEPI_CREADA, DETERMINACION, fill = list(n = 0))


N_testeos_positivos_UMA<-sum(CASOS_UMA_SE_POSITIVOS$n, na.rm = T)
N_testeos_positivos_UMA

POSITIVIDAD_UMA<- N_testeos_positivos_UMA/N_testeos_UMA*100
POSITIVIDAD_UMA

###ARMO UNA TABLA CON LOS TESTEOS, POSITIVOS Y POSITIVIDAD###
tabla_UMA <- data.frame(Evento="Monitoreo de SARS COV-2, Influenza y VSR en ambulatorios",N_testeos_positivos_UMA, N_testeos_UMA, POSITIVIDAD_UMA)

tabla_UMA$POSITIVIDAD_UMA <- round(tabla_UMA$POSITIVIDAD_UMA, 2)

tabla_UMA<-tabla_UMA%>%mutate(POSITIVIDAD_UMA=paste0(POSITIVIDAD_UMA,"%"))
names(tabla_UMA) <- c("Evento"   ,  "Testeos positivos"  ,             
                      "Testeos totales",    "Positividad")

### CUENTO POR EDAD Y DETERMINACIÓN##

CONTEO_UMA_edad <-IRA_UMA%>%
  filter(determinacion2== "1")%>%
  mutate(DETERMINACION = case_when(
    DETERMINACION %in% c("Genoma viral SARS-CoV-2", "Detección de Antígeno de SARS CoV-2",
                         "Genoma viral de Coronavirus NL63", "Genoma viral de Coronavirus OC43",
                         "Genoma viral de Coronavirus 229E") ~ "Sars-Cov-2",
    DETERMINACION %in% c("Genoma viral de Parainfluenza 1", "Genoma viral de Parainfluenza 2",
                         "Genoma viral de Parainfluenza 3", "Genoma viral de Parainfluenza 4") ~ "Parainfluenza",
    DETERMINACION %in% c("Genoma viral de VSR", "Genoma viral de VSR A", "Genoma viral de VSR B") ~ "VSR",
    DETERMINACION == "Genoma viral de Metaneumovirus Humano" ~ "Metaneumovirus",
    DETERMINACION %in% c("Genoma viral de Influenza A (sin subtipificar)", "Genoma viral de Influenza A H1N1pdm",
                         "Genoma viral de Influenza A H3N2", "Antígeno viral de influenza A") ~ "Influenza A",
    DETERMINACION %in% c("Genoma viral de Influenza B (sin linaje)", "Antígeno viral de influenza B",
                         "Genoma viral de Influenza B, linaje Victoria") ~ "Influenza B",
    DETERMINACION %in% c("Detección molecular de Adenovirus", "Genoma viral de Adenovirus") ~ "Adenovirus",
    DETERMINACION %in% c("Detección molecular de Enterovirus", "Genoma viral de Enterovirus") ~ "Enterovirus",
    DETERMINACION == "Detección molecular de Bocavirus" ~ "Bocavirus",
    DETERMINACION == "Genoma viral de Rinovirus" ~ "Rinovirus",
    DETERMINACION %in% c("", NA) ~ "Sin determinacion", # Combina celdas vacías y NA
    TRUE ~ "Otro"))%>%
  group_by(GRUPO_EDAD2, DETERMINACION)%>%
  count()%>%
  ungroup()
# Usar complete para rellenar los grupos de edad faltantes y completar con 0 en "casos
# Me aseguro que no queden rangos sin completar
CONTEO_UMA_edad<- CONTEO_UMA_edad %>%
  complete(GRUPO_EDAD2, DETERMINACION, fill = list(n = 0))


###CUENTO LOS SINTOMAS DE LOS CASOS POSITIVOS
# Agrupar los datos por los síntomas y calcular el total de casos
CONTEO_UMA_sintomas <- IRA_UMA %>%
  filter(determinacion2== "1")%>%
  summarise(across(starts_with("SINTOMA_"), sum, na.rm = TRUE)) %>% #Suma las columnas relacionadas con síntomas ( starts_with("SINTOMA_")) en todo el conjunto de datos
  pivot_longer(cols = everything(), 
               names_to = "Sintoma", 
               values_to = "n") #Convierta las columnas de síntomas en filas para tener solo dos columnas: Sintomay n


####CUENTO LAS COMORBILIDADES DE LOS CASOS POSITIVOS
CONTEO_UMA_comorbilidades <- IRA_UMA %>%
  filter(determinacion2== "1")%>%
  summarise(across(starts_with("COMORB_"), sum, na.rm = TRUE)) %>% #Suma las columnas relacionadas con síntomas ( starts_with("SINTOMA_")) en todo el conjunto de datos
  pivot_longer(cols = everything(), 
               names_to = "Comorbilidades", 
               values_to = "n") #Convierta las columnas de síntomas en filas para tener solo dos columnas: Sintomay n

###CENTINELA_UCI-IRAG####
IRA_UCI <- VR_NOMINAL %>%
  filter(EVENTO == "Unidad Centinela de Infección Respiratoria Aguda Grave (UC-IRAG)") %>%
  filter(AÑO == 2024)%>%
  mutate(DIAS_TOTALES_INTERNACION = as.numeric(FECHA_ALTA_MEDICA - FECHA_INTERNACION),
         DIAS_INTERNACION_UTI = as.numeric(coalesce(FECHA_ALTA_MEDICA, FECHA_FALLECIMIENTO) - FECHA_CUI_INTENSIVOS)
  )


#POR DETERMINACIÓN# Acá cuento cuantos testeos por semana y por determinacion de 2024(incluye positivos y negativos)

SE_MAX_UCI<-max(IRA_UCI$SEPI_CREADA)
SE_MIN_UCI<-min(IRA_UCI$SEPI_CREADA)

#CUENTO CASOS POR SE Y POR DETERMINACIÓN# 

CONTEO_IRA_UCI_SE<- IRA_UCI%>%
  group_by(SEPI_CREADA,DETERMINACION)%>%
  count()%>%
  ungroup()%>%
  complete(SEPI_CREADA, DETERMINACION, fill = list(n = 0))

N_testeos_UCI<-sum(CONTEO_IRA_UCI_SE$n, na.rm = T)
N_testeos_UCI


#CUENTO CASOS TOTALES POR SE#
CONTEO_UCI_SE_TOTAL <-
  IRA_UCI%>%
  mutate(SEPI_CREADA=factor(SEPI_CREADA, levels = 1:SE_MAX_UCI))%>%
  group_by(SEPI_CREADA) %>%
  count()%>%
  ungroup()%>%
  complete(SEPI_CREADA, fill = list(n = 0))




#CUENTO CASOS POR SE Y POR DETERMINACION (SOLO LAS POSITIVAS)## 
CASOS_UCI_SE_POSITIVOS<-IRA_UCI%>%
  filter(determinacion2== "1")%>%
  mutate(DETERMINACION = case_when(
    DETERMINACION %in% c("Genoma viral SARS-CoV-2", "Detección de Antígeno de SARS CoV-2",
                         "Genoma viral de Coronavirus NL63", "Genoma viral de Coronavirus OC43",
                         "Genoma viral de Coronavirus 229E") ~ "Sars-Cov-2",
    DETERMINACION %in% c("Genoma viral de Parainfluenza 1", "Genoma viral de Parainfluenza 2",
                         "Genoma viral de Parainfluenza 3", "Genoma viral de Parainfluenza 4") ~ "Parainfluenza",
    DETERMINACION %in% c("Genoma viral de VSR", "Genoma viral de VSR A", "Genoma viral de VSR B") ~ "VSR",
    DETERMINACION == "Genoma viral de Metaneumovirus Humano" ~ "Metaneumovirus",
    DETERMINACION %in% c("Genoma viral de Influenza A (sin subtipificar)", "Genoma viral de Influenza A H1N1pdm",
                         "Genoma viral de Influenza A H3N2", "Antígeno viral de influenza A") ~ "Influenza A",
    DETERMINACION %in% c("Genoma viral de Influenza B (sin linaje)", "Antígeno viral de influenza B",
                         "Genoma viral de Influenza B, linaje Victoria") ~ "Influenza B",
    DETERMINACION %in% c("Detección molecular de Adenovirus", "Genoma viral de Adenovirus") ~ "Adenovirus",
    DETERMINACION %in% c("Detección molecular de Enterovirus", "Genoma viral de Enterovirus") ~ "Enterovirus",
    DETERMINACION == "Detección molecular de Bocavirus" ~ "Bocavirus",
    DETERMINACION == "Genoma viral de Rinovirus" ~ "Rinovirus",
    DETERMINACION %in% c("", NA) ~ "Sin determinacion", # Combina celdas vacías y NA
    TRUE ~ "Otro"), # Captura cualquier valor no contemplado
    SEPI_CREADA=factor(SEPI_CREADA, levels = 1:SE_MAX_UCI))%>%
  group_by(SEPI_CREADA,DETERMINACION)%>%
  count()%>%
  ungroup()%>%
  complete(SEPI_CREADA, DETERMINACION, fill = list(n = 0))


N_testeos_positivos_UCI<-sum(CASOS_UCI_SE_POSITIVOS$n, na.rm = T)
N_testeos_positivos_UCI

POSITIVIDAD_UCI<- N_testeos_positivos_UCI/N_testeos_UCI*100
POSITIVIDAD_UCI

###ARMO UNA TABLA CON LOS TESTEOS, POSITIVOS Y POSITIVIDAD###
tabla_UCI <- data.frame(Evento="Unidad Centinela de Infección Respiratoria Aguda Grave (UC-IRAG)",N_testeos_positivos_UCI, N_testeos_UCI, POSITIVIDAD_UCI)

tabla_UCI$POSITIVIDAD_UCI<- round(tabla_UCI$POSITIVIDAD_UCI, 2)

tabla_UCI<-tabla_UCI%>%mutate(POSITIVIDAD_UCI=paste0(POSITIVIDAD_UCI,"%"))
names(tabla_UCI) <- c("Evento"   ,  "Testeos positivos"  ,             
                      "Testeos totales",    "Positividad")

### CUENTO POR EDAD Y DETERMINACIÓN##

CONTEO_UCI_edad <-IRA_UCI%>%
  filter(determinacion2== "1")%>%
  mutate(DETERMINACION = case_when(
    DETERMINACION %in% c("Genoma viral SARS-CoV-2", "Detección de Antígeno de SARS CoV-2",
                         "Genoma viral de Coronavirus NL63", "Genoma viral de Coronavirus OC43",
                         "Genoma viral de Coronavirus 229E") ~ "Sars-Cov-2",
    DETERMINACION %in% c("Genoma viral de Parainfluenza 1", "Genoma viral de Parainfluenza 2",
                         "Genoma viral de Parainfluenza 3", "Genoma viral de Parainfluenza 4") ~ "Parainfluenza",
    DETERMINACION %in% c("Genoma viral de VSR", "Genoma viral de VSR A", "Genoma viral de VSR B") ~ "VSR",
    DETERMINACION == "Genoma viral de Metaneumovirus Humano" ~ "Metaneumovirus",
    DETERMINACION %in% c("Genoma viral de Influenza A (sin subtipificar)", "Genoma viral de Influenza A H1N1pdm",
                         "Genoma viral de Influenza A H3N2", "Antígeno viral de influenza A") ~ "Influenza A",
    DETERMINACION %in% c("Genoma viral de Influenza B (sin linaje)", "Antígeno viral de influenza B",
                         "Genoma viral de Influenza B, linaje Victoria") ~ "Influenza B",
    DETERMINACION %in% c("Detección molecular de Adenovirus", "Genoma viral de Adenovirus") ~ "Adenovirus",
    DETERMINACION %in% c("Detección molecular de Enterovirus", "Genoma viral de Enterovirus") ~ "Enterovirus",
    DETERMINACION == "Detección molecular de Bocavirus" ~ "Bocavirus",
    DETERMINACION == "Genoma viral de Rinovirus" ~ "Rinovirus",
    DETERMINACION %in% c("", NA) ~ "Sin determinacion", # Combina celdas vacías y NA
    TRUE ~ "Otro"))%>%
  group_by(GRUPO_EDAD2, DETERMINACION)%>%
  count()%>%
  ungroup()
# Usar complete para rellenar los grupos de edad faltantes y completar con 0 en "casos
# Me aseguro que no queden rangos sin completar
CONTEO_UCI_edad<- CONTEO_UCI_edad %>%
  complete(GRUPO_EDAD2, DETERMINACION, fill = list(n = 0))


###CUENTO LOS SINTOMAS DE LOS CASOS POSITIVOS
# Agrupar los datos por los síntomas y calcular el total de casos
CONTEO_UCI_sintomas <- IRA_UCI %>%
  filter(determinacion2== "1")%>%
  summarise(across(starts_with("SINTOMA_"), sum, na.rm = TRUE)) %>% #Suma las columnas relacionadas con síntomas ( starts_with("SINTOMA_")) en todo el conjunto de datos
  pivot_longer(cols = everything(), 
               names_to = "Sintoma", 
               values_to = "n") #Convierta las columnas de síntomas en filas para tener solo dos columnas: Sintomay n


####CUENTO LAS COMORBILIDADES DE LOS CASOS POSITIVOS
CONTEO_UCI_comorbilidades <- IRA_UCI %>%
  filter(determinacion2== "1")%>%
  summarise(across(starts_with("COMORB_"), sum, na.rm = TRUE)) %>% #Suma las columnas relacionadas con síntomas ( starts_with("SINTOMA_")) en todo el conjunto de datos
  pivot_longer(cols = everything(), 
               names_to = "Comorbilidades", 
               values_to = "n") #Convierta las columnas de síntomas en filas para tener solo dos columnas: Sintomay n

####CUENTO DIAS TOTATLES DE INTERNACION X DETERMINACION

INTERNADOS_HZ <- read.csv2("internadoshz.csv",encoding = "UTF-8", na.strings = c("","*SIN DATO* (*SIN DATO*)"))

Tabla_dias_internacion_determinacion<-IRA_UCI %>%
  filter(determinacion2== "1")%>%
  mutate(DETERMINACION = case_when(
    DETERMINACION %in% c("Genoma viral SARS-CoV-2", "Detección de Antígeno de SARS CoV-2",
                         "Genoma viral de Coronavirus NL63", "Genoma viral de Coronavirus OC43",
                         "Genoma viral de Coronavirus 229E") ~ "Sars-Cov-2",
    DETERMINACION %in% c("Genoma viral de Parainfluenza 1", "Genoma viral de Parainfluenza 2",
                         "Genoma viral de Parainfluenza 3", "Genoma viral de Parainfluenza 4") ~ "Parainfluenza",
    DETERMINACION %in% c("Genoma viral de VSR", "Genoma viral de VSR A", "Genoma viral de VSR B") ~ "VSR",
    DETERMINACION == "Genoma viral de Metaneumovirus Humano" ~ "Metaneumovirus",
    DETERMINACION %in% c("Genoma viral de Influenza A (sin subtipificar)", "Genoma viral de Influenza A H1N1pdm",
                         "Genoma viral de Influenza A H3N2", "Antígeno viral de influenza A") ~ "Influenza A",
    DETERMINACION %in% c("Genoma viral de Influenza B (sin linaje)", "Antígeno viral de influenza B",
                         "Genoma viral de Influenza B, linaje Victoria") ~ "Influenza B",
    DETERMINACION %in% c("Detección molecular de Adenovirus", "Genoma viral de Adenovirus") ~ "Adenovirus",
    DETERMINACION %in% c("Detección molecular de Enterovirus", "Genoma viral de Enterovirus") ~ "Enterovirus",
    DETERMINACION == "Detección molecular de Bocavirus" ~ "Bocavirus",
    DETERMINACION == "Genoma viral de Rinovirus" ~ "Rinovirus",
    DETERMINACION %in% c("", NA) ~ "Sin determinacion", # Combina celdas vacías y NA
    TRUE ~ "Otro"))%>%
  group_by(DETERMINACION) %>%
  summarize(TOTAL_INTERNADOS= n(),  # Total de internados por determinación
            PROMEDIO_DIAS_INTERNACION = round(mean(DIAS_TOTALES_INTERNACION, na.rm = TRUE),1),
            REQUIRIO_CUIDADO_INTENSIVO = sum(CUIDADO_INTENSIVO == "SI", na.rm = TRUE),  # Conteo de "SI"
            #PORCENTAJE_CUIDADO_INTENSIVO = round((REQUIRIO_CUIDADO_INTENSIVO / TOTAL_INTERNADOS) * 100, 1),
            PROMEDIO_DIAS_INTERNACION_UCI= ifelse(all(is.na(DIAS_INTERNACION_UTI)), 
                                                  NA, round(mean(DIAS_INTERNACION_UTI, na.rm = TRUE), 1)),
            TOTAL_FALLECIDOS= sum(FALLECIDO == "SI", na.rm = TRUE))%>%
  arrange(desc(PROMEDIO_DIAS_INTERNACION))
#PORCENTAJE_FALLECIDOS = round((TOTAL_FALLECIDOS / TOTAL_INTERNADOS) * 100, 1))%>%   # Porcentaje


# Calcula la fila de totales
# Calcula la fila de totales
fila_totales <- IRA_UCI %>%
  filter(determinacion2 == "1")%>%
  summarize(
    DETERMINACION = "Totales",
    TOTAL_INTERNADOS = n(),
    PROMEDIO_DIAS_INTERNACION = round(mean(DIAS_TOTALES_INTERNACION, na.rm = TRUE), 1),
    REQUIRIO_CUIDADO_INTENSIVO = sum(CUIDADO_INTENSIVO == "SI", na.rm = TRUE),
    #PORCENTAJE_CUIDADO_INTENSIVO = round((REQUIRIO_CUIDADO_INTENSIVO / TOTAL_INTERNADOS) * 100, 1),
    PROMEDIO_DIAS_INTERNACION_UCI = ifelse(all(is.na(DIAS_INTERNACION_UTI)), 
                                           NA, round(mean(DIAS_INTERNACION_UTI, na.rm = TRUE), 1)),
    TOTAL_FALLECIDOS = sum(FALLECIDO == "SI", na.rm = TRUE))
#PORCENTAJE_FALLECIDOS = round((TOTAL_FALLECIDOS / TOTAL_INTERNADOS) * 100, 1)


# Une la fila de totales con la tabla original
Tabla_dias_internacion_determinacion <- Tabla_dias_internacion_determinacion %>%
  bind_rows(fila_totales)

Tabla_dias_internacion_determinacion <- Tabla_dias_internacion_determinacion %>%
  mutate(PROMEDIO_DIAS_INTERNACION_UCI = replace_na(PROMEDIO_DIAS_INTERNACION_UCI, 0))


Tabla_dias_internacion_determinacion<-Tabla_dias_internacion_determinacion%>%mutate
names(Tabla_dias_internacion_determinacion) <- c("Tipo de determinación"   ,  "N° total de internados"  ,             
                                                 "Promedio de dias de internación",    "Requerimiento de UTI",  "Promedio de dias de internación en UTI",
                                                 "N° total de fallecidos")
# Ordena de mayor a menor promedio

#### UNO LA BASE DE SNVS CON LA BASE DEL HOSPITAL###

Tabla_servicios <- INTERNADOS_HZ %>%
  group_by(SERVICIO) %>%
  summarize(
    TOTAL_IRAG = n(),  # Total de internados por IRAG
    HISOPADOS = sum(HISOPADO == "SI", na.rm = TRUE),  # Total de hisopados
    PORCENTAJE_DE_HISOPADOS = round((sum(HISOPADO == "SI", na.rm = TRUE) / n()) * 100, 1)  # Porcentaje de hisopados
  ) %>%
  arrange(desc(HISOPADOS))

# Calcular la fila de totales
Fila_totales <- Tabla_servicios %>%
  summarize(
    SERVICIO = "Totales",  # Etiqueta para la fila de totales
    TOTAL_IRAG = sum(TOTAL_IRAG),
    HISOPADOS = sum(HISOPADOS),
    PORCENTAJE_DE_HISOPADOS = round((sum(HISOPADOS) / sum(TOTAL_IRAG)) * 100, 1)
  )

# Agregar la fila de totales
Tabla_servicios <- bind_rows(Tabla_servicios, Fila_totales)

# Renombrar columnas
names(Tabla_servicios) <- c(
  "Servicio", 
  "Compatible con definición IRAG", 
  "Hisopados", 
  "Porcentaje de hisopados"
)

# Resultado final
Tabla_servicios





