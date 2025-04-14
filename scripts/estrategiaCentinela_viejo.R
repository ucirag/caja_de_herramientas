###CENTINELA_UCI-IRAG####

# Convertir fecha
fecha_corte <- dmy(dia_de_corte_de_datos)
anio_corte <- year(fecha_corte)
# Calcular semana epidemiológica (ISO)
semana_epi_corte <- epiweek(fecha_corte)

# Calcular última semana válida a incluir
ultima_semana_valida <- semana_epi_corte - num_ultimas_semana_no_incluidas


IRA_UCI <- VR_NOMINAL_EVENTOCASO %>%
  filter(EVENTO == "Unidad Centinela de Infección Respiratoria Aguda Grave (UC-IRAG)") %>%
  filter(AÑO ==anio_de_analisis|AÑO ==anio_de_analisis-1)%>%
  filter((AÑO < anio_corte) |
           (AÑO == anio_corte & SEPI_CREADA <= ultima_semana_valida)) %>% 
  mutate(DIAS_TOTALES_INTERNACION = as.numeric(FECHA_ALTA_MEDICA - FECHA_INTERNACION),
         DIAS_INTERNACION_UTI = as.numeric(coalesce(FECHA_ALTA_MEDICA, FECHA_FALLECIMIENTO) - FECHA_CUI_INTENSIVOS)
  )

# Calcular el año máximo presente
max_anio <- max(IRA_UCI$AÑO, na.rm = TRUE)

# Calcular la SEPI máxima dentro del año máximo
SE_MAX_UCI <- IRA_UCI %>%
  filter(AÑO == max_anio) %>%
  summarise(max_sepi = max(SEPI_CREADA, na.rm = TRUE)) %>%
  pull(max_sepi)

# También podés calcular el mínimo SEPI (por si necesitás)
SE_MIN_UCI <- IRA_UCI %>%
  filter(AÑO == max_anio) %>%
  summarise(min_sepi = min(SEPI_CREADA, na.rm = TRUE)) %>%
  pull(min_sepi)


#POR DETERMINACIÓN# Acá cuento cuantos testeos por semana y por determinacion de 2024(incluye positivos y negativos)


#CUENTO CASOS POR SE Y POR DETERMINACIÓN# PREGUNTAR SI SON LOS POSITIVOS
# Seleccionar solo las columnas que empiezan con "DETERMINACION_" EXCLUYENDO "DETERMINACION_DICO" y "DETERMINACION_DICO_CENTINELA"
# columnas_determinacion <- names(IRA_UCI) %>%
#   str_subset("^DETERMINACION_") %>%
#   setdiff(c("DETERMINACION_DICO", "DETERMINACION_DICO_centinela", "DETERMINACION_SIN_DATO"))  # Excluir estas columnas

columnas_determinacion <-columnas_existentes

# Generar una secuencia continua de semanas epidemiológicas desde el mínimo al máximo








semanas_completas <- tibble(SEPI_CREADA = seq(SE_MIN_UCI, 
                                              SE_MAX_UCI, 
                                              by = 1))


# Transformar el dataset a formato largo
CONTEO_IRA_UCI_SE <- IRA_UCI %>%
  pivot_longer(cols = all_of(columnas_determinacion), 
               names_to = "Tipo_Determinacion", 
               values_to = "Resultado") %>%
  
  # Agrupar por semana epidemiológica y tipo de determinación
  group_by(SEPI_CREADA, Tipo_Determinacion) %>%
  
  # Crear las columnas Positivos y No detectables según el resultado
  summarise(
    Detectable = sum(str_detect(Resultado, regex("Detectable|Positivo", ignore_case = TRUE)), na.rm = TRUE),
    No_detectable = sum(str_detect(Resultado, regex("No detectable|Negativo", ignore_case = TRUE)), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  
  # Unir con la secuencia completa de semanas para asegurar valores continuos
  right_join(semanas_completas, by = "SEPI_CREADA") %>%
  
  # Asegurar que todas las combinaciones de semana y tipo de determinación existan
  complete(SEPI_CREADA, Tipo_Determinacion, fill = list(Detectable = 0, No_detectable = 0, Total_testeos = 0)) %>%
  
  # Calcular la columna de total de testeos y asegurar que no tenga NA
  mutate(Total_testeos = replace_na(Detectable + No_detectable, 0)) %>%
  
  # Eliminar filas donde Tipo_Determinacion es NA
  filter(!is.na(Tipo_Determinacion))

# Mostrar la tabla
CONTEO_IRA_UCI_SE


N_testeos_UCI<-sum(CONTEO_IRA_UCI_SE$Total_testeos, na.rm = T)
N_testeos_UCI


#CUENTO CASOS TOTALES POR SE#
# Generar la secuencia completa de semanas desde 1 hasta SE_MAX_UCI
semanas_completas <- tibble(SEPI_CREADA = factor(1:SE_MAX_UCI, levels = 1:SE_MAX_UCI))


CONTEO_UCI_SE_TOTAL_positivos <- IRA_UCI %>%
  filter(DETERMINACION_DICO_centinela == 1) %>%  # Filtra solo los casos positivos en DETERMINACION_DICO
  mutate(SEPI_CREADA = factor(SEPI_CREADA, levels = 1:SE_MAX_UCI)) %>%
  group_by(SEPI_CREADA) %>%
  summarise(n = n(), .groups = "drop") %>%
  
  # Asegurar la secuencia completa de semanas, rellenando con 0 en las semanas sin registros
  right_join(semanas_completas, by = "SEPI_CREADA") %>%
  replace_na(list(n = 0))

# Mostrar la tabla
CONTEO_UCI_SE_TOTAL_positivos



# Seleccionar solo las columnas que comienzan con "DETERMINACION_", excluyendo "DETERMINACION_DICO" y "DETERMINACION_DICO_CENTINELA"
columnas_determinacion <- names(IRA_UCI) %>%
  str_subset("^DETERMINACION_") %>%
  setdiff(c("DETERMINACION_DICO", "DETERMINACION_DICO_centinela", "DETERMINACION_SIN_DATO"))  # Excluir estas columnas

columnas_determinacion <-columnas_existentes

# Generar la secuencia completa de semanas desde el mínimo al máximo
semanas_completas <- tibble(SEPI_CREADA = seq(min(IRA_UCI$SEPI_CREADA, na.rm = TRUE), 
                                              max(IRA_UCI$SEPI_CREADA, na.rm = TRUE), 
                                              by = 1))

# Transformar el dataset a formato largo y agrupar las determinaciones en categorías
CASOS_UCI_SE_det <- IRA_UCI %>%
  pivot_longer(cols = all_of(columnas_determinacion), 
               names_to = "Tipo_Determinacion", 
               values_to = "Resultado") %>%
  
  # Crear la nueva columna de agrupación de determinaciones
  mutate(DETERMINACION = case_when(
    str_detect(Tipo_Determinacion, "Genoma viral SARS-CoV-2") ~ "Sars-Cov-2",
    
    str_detect(Tipo_Determinacion, "Genoma viral de Influenza A \\(sin subtipificar\\)|Genoma viral de Influenza A H1N1pdm|Genoma viral de Influenza A H3N2") ~ "Influenza A",
    
    str_detect(Tipo_Determinacion, "Genoma viral de Influenza B \\(sin linaje\\)|Genoma viral de Influenza B, linaje Victoria") ~ "Influenza B",
    
    str_detect(Tipo_Determinacion, "Genoma viral de VSR|Genoma viral de VSR A|Genoma viral de VSR B") ~ "VSR",
    # influenza sin tipificar
    str_detect(Tipo_Determinacion, "Genoma viral de Influenza") ~ "Influenza sin tipificar",
    
    TRUE ~ "Otro"
  )) %>%
  
  # Agrupar por semana epidemiológica y categoría de determinación
  group_by(SEPI_CREADA, DETERMINACION) %>%
  
  # Crear las columnas Detectable y No_detectable según el resultado
  summarise(
    Detectable = sum(str_detect(Resultado, regex("Detectable|Positivo", ignore_case = TRUE)), na.rm = TRUE),
    No_detectable = sum(str_detect(Resultado, regex("No detectable|Negativo", ignore_case = TRUE)), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  
  # Calcular la columna de total de testeos
  mutate(Total_testeos = Detectable + No_detectable) %>%
  
  # Unir con la secuencia completa de semanas para asegurar valores continuos
  right_join(semanas_completas, by = "SEPI_CREADA") %>%
  
  # Asegurar que todas las combinaciones de semana y determinación existan
  complete(SEPI_CREADA, DETERMINACION, fill = list(Detectable = 0, No_detectable = 0, Total_testeos = 0)) %>%
  
  # Eliminar filas donde la categoría de determinación es NA
  filter(!is.na(DETERMINACION)) %>% 
  mutate(positividad= round(Detectable/Total_testeos*100,2))


N_testeos_positivos_UCI<-sum(CASOS_UCI_SE_det$Detectable, na.rm = T)
N_testeos_positivos_UCI

POSITIVIDAD_UCI<- sum(CASOS_UCI_SE_det$Detectable, na.rm = T)/sum(CASOS_UCI_SE_det$Total_testeos, na.rm = T)*100
POSITIVIDAD_UCI

###ARMO UNA TABLA CON LOS TESTEOS, POSITIVOS Y POSITIVIDAD###
tabla_UCI <- data.frame(Evento="Unidad Centinela de Infección Respiratoria Aguda Grave (UC-IRAG)",
                        N_testeos_positivos_UCI, N_testeos_UCI, POSITIVIDAD_UCI)

tabla_UCI$POSITIVIDAD_UCI<- round(tabla_UCI$POSITIVIDAD_UCI, 2)

tabla_UCI<-tabla_UCI%>%mutate(POSITIVIDAD_UCI=paste0(POSITIVIDAD_UCI,"%"))
names(tabla_UCI) <- c("Evento"   ,  "Testeos positivos"  ,             
                      "Testeos totales",    "Positividad")


CASOS_UCI_SE_det_totales <- CASOS_UCI_SE_det %>% 
  filter(DETERMINACION!="Otro") %>% 
  group_by(SEPI_CREADA) %>% 
  summarise(Total_testeos= sum(Total_testeos), 
            Detectable= sum(Detectable),
            No_detectable= sum(No_detectable)
            ) %>% 
  mutate(positividad= round(Detectable/Total_testeos*100,2))


## ACA TENGO QUE PONER UNA TABLA QUE CUENTE POR SEPI_CREADA Y AÑO CUANTAS FILAS TIENE LA VARIABLE DETERMINACION_dico_centinela ==1 ==0 y 99
table(IRA_UCI$DETERMINACION_DICO_centinela)

casos_sepi_graf1 <- IRA_UCI %>%
  filter(DETERMINACION_DICO_centinela %in% c("0", "1", "99")) %>%
  filter(year(FECHA_CREADA)==anio_de_analisis|year(FECHA_CREADA)==anio_de_analisis-1) %>% 
  group_by(SEPI_CREADA, AÑO, DETERMINACION_DICO_centinela) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(
    DETERMINACION_DICO_centinela = recode_factor(
      DETERMINACION_DICO_centinela,
      `1` = "Detectable",
      `0` = "No detectable",
      `99` = "Sin datos",
      .ordered = FALSE
    )
  ) %>%
  pivot_wider(
    names_from = DETERMINACION_DICO_centinela,
    values_from = n,
    values_fill = 0
  )

# Mostrar tabla
casos_sepi_graf1

### CUENTO POR EDAD Y DETERMINACIÓN##
columnas_determinacion <-columnas_existentes

# Obtener los grupos de edad únicos
grupos_edad_completos <- distinct(IRA_UCI, GRUPO_ETARIO3)

# Transformar el dataset a formato largo y agrupar las determinaciones en categorías
CONTEO_UCI_edad <- IRA_UCI %>%
  pivot_longer(cols = all_of(columnas_determinacion), 
               names_to = "Tipo_Determinacion", 
               values_to = "Resultado") %>%
  
  # Crear la nueva columna de agrupación de determinaciones
  mutate(DETERMINACION = case_when(
    str_detect(Tipo_Determinacion, "Genoma viral SARS-CoV-2") ~ "Sars-Cov-2",
    
    str_detect(Tipo_Determinacion, "Genoma viral de Influenza A \\(sin subtipificar\\)|Genoma viral de Influenza A H1N1pdm|Genoma viral de Influenza A H3N2") ~ "Influenza A",
    
    str_detect(Tipo_Determinacion, "Genoma viral de Influenza B \\(sin linaje\\)|Genoma viral de Influenza B, linaje Victoria") ~ "Influenza B",
    
    str_detect(Tipo_Determinacion, "Genoma viral de VSR|Genoma viral de VSR A|Genoma viral de VSR B") ~ "VSR",
    TRUE ~ "Otro")) %>%
  
  # Agrupar por semana epidemiológica, grupo de edad y categoría de determinación
  group_by( GRUPO_ETARIO3, DETERMINACION) %>%
  
  # Crear las columnas Detectable y No_detectable según el resultado
  summarise(
    Detectable = sum(str_detect(Resultado, regex("Detectable|Positivo", ignore_case = TRUE)), na.rm = TRUE),
    No_detectable = sum(str_detect(Resultado, regex("No detectable|Negativo", ignore_case = TRUE)), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  
  # Calcular la columna de total de testeos
  mutate(Total_testeos = Detectable + No_detectable) %>%
  
  # Unir con la secuencia completa de semanas y grupos de edad para asegurar valores continuos
  #right_join(semanas_completas, by = "SEPI_CREADA") %>%
  right_join(grupos_edad_completos, by = "GRUPO_ETARIO3") %>%
  
  # Asegurar que todas las combinaciones de semana, grupo de edad y determinación existan
  complete(GRUPO_ETARIO3, DETERMINACION, fill = list(Detectable = 0, No_detectable = 0, Total_testeos = 0)) %>%
  
  # Eliminar filas donde la categoría de determinación es NA
  filter(!is.na(DETERMINACION) ) %>% 
  mutate(positividad= Detectable/Total_testeos*100)



###CUENTO LOS SINTOMAS DE LOS CASOS POSITIVOS
# Agrupar los datos por los síntomas y calcular el total de casos
# Contar los síntomas en los casos positivos (DETERMINACION_DICO == 1)
# Filtrar solo casos positivos
positivos <- IRA_UCI %>%
  filter(DETERMINACION_DICO == 1)

# Contar los casos sin ningún síntoma (todas las columnas de síntomas en 0 o NA)
casos_sin_sintomas <- positivos %>%
  filter(rowSums(select(., starts_with("SINTOMA_")), na.rm = TRUE) == 0) %>%
  nrow()

# Contar los síntomas en los casos positivos
CONTEO_UCI_sintomas <- positivos %>%
  summarise(across(starts_with("SINTOMA_"), ~ sum(.x, na.rm = TRUE))) %>%  # Sumar síntomas
  pivot_longer(cols = everything(), 
               names_to = "Sintoma", 
               values_to = "n") %>%
  mutate(Sintoma = str_remove(Sintoma, "^SINTOMA_")) %>%  # Eliminar el prefijo "SINTOMA_"
  arrange(desc(n))

# Agregar la fila de NA para los casos sin síntomas
CONTEO_UCI_sintomas <- bind_rows(
  CONTEO_UCI_sintomas,
  tibble(Sintoma = NA, n = casos_sin_sintomas)
)


####CUENTO LAS COMORBILIDADES DE LOS CASOS POSITIVOS
# Contar los casos sin ningún síntoma (todas las columnas de síntomas en 0 o NA)
casos_sin_sintomas_c <- positivos %>%
  filter(rowSums(select(., starts_with("COMORB_")), na.rm = TRUE) == 0) %>%
  nrow()

# Contar los síntomas en los casos positivos
CONTEO_UCI_comorbilidad <- positivos %>%
  summarise(across(starts_with("COMORB_"), ~ sum(.x, na.rm = TRUE))) %>%  # Sumar síntomas
  pivot_longer(cols = everything(), 
               names_to = "Comorbilidad", 
               values_to = "n") %>%
  mutate(Comorbilidad = str_remove(Comorbilidad, "^COMORB_")) %>%  # Eliminar el prefijo "SINTOMA_"
  arrange(desc(n))

# Agregar la fila de NA para los casos sin síntomas
CONTEO_UCI_comorbilidad <- bind_rows(
  CONTEO_UCI_comorbilidad,
  tibble(Comorbilidad = NA, n = casos_sin_sintomas_c)
)

####CUENTO DIAS TOTATLES DE INTERNACION X DETERMINACION

# Seleccionar las columnas que comienzan con "DETERMINACION_", excluyendo las que no deben considerarse
columnas_determinacion <- names(IRA_UCI) %>%
  str_subset("^DETERMINACION_") %>%
  setdiff(c("DETERMINACION_DICO", "DETERMINACION_DICO_CENTINELA", "DETERMINACION_DICO_centinela"))  # Excluir estas columnas específicas

columnas_determinacion <-columnas_existentes
# Filtrar solo los casos con determinación positiva
internados <- IRA_UCI %>%
  filter(DETERMINACION_DICO == "1") %>%
  pivot_longer(cols = all_of(columnas_determinacion), 
               names_to = "Tipo_Determinacion", 
               values_to = "Resultado") %>%
  
  # Agrupar determinaciones en categorías
  mutate(DETERMINACION = case_when(
    str_detect(Tipo_Determinacion, "Genoma viral SARS-CoV-2") ~ "Sars-Cov-2",
    
    str_detect(Tipo_Determinacion, "Genoma viral de Influenza A \\(sin subtipificar\\)|Genoma viral de Influenza A H1N1pdm|Genoma viral de Influenza A H3N2") ~ "Influenza A",
    
    str_detect(Tipo_Determinacion, "Genoma viral de Influenza B \\(sin linaje\\)|Genoma viral de Influenza B, linaje Victoria") ~ "Influenza B",
    
    str_detect(Tipo_Determinacion, "Genoma viral de VSR|Genoma viral de VSR A|Genoma viral de VSR B") ~ "VSR",
    TRUE ~ "Otro"
  )) %>%
  
  # Filtrar solo registros donde la determinación sea positiva o detectable
  filter(str_detect(Resultado, "Positivo|Detectable")) 

# Crear la tabla con el total de internados y métricas
Tabla_dias_internacion_determinacion <- internados %>%
  group_by(DETERMINACION) %>%
  summarise(
    `N° total de internados` = n_distinct(IDEVENTOCASO),  # Solo contar pacientes únicos
    `Promedio de días de internación` = round(mean(DIAS_TOTALES_INTERNACION, na.rm = TRUE), 1),
    `Requerimiento de UTI` = sum(CUIDADO_INTENSIVO == "SI", na.rm = TRUE),
    `Promedio de días de internación en UTI` = ifelse(all(is.na(DIAS_INTERNACION_UTI)), 
                                                      NA, round(mean(DIAS_INTERNACION_UTI, na.rm = TRUE), 1)),
    `N° total de fallecidos` = sum(FALLECIDO == "SI", na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(`Promedio de días de internación`))

# Calcular la fila de totales
fila_totales <- internados %>%
  summarise(
    DETERMINACION = "Totales",
    `N° total de internados` = n_distinct(IDEVENTOCASO),
    `Promedio de días de internación` = round(mean(DIAS_TOTALES_INTERNACION, na.rm = TRUE), 1),
    `Requerimiento de UTI` = sum(CUIDADO_INTENSIVO == "SI", na.rm = TRUE),
    `Promedio de días de internación en UTI` = ifelse(all(is.na(DIAS_INTERNACION_UTI)), 
                                                      NA, round(mean(DIAS_INTERNACION_UTI, na.rm = TRUE), 1)),
    `N° total de fallecidos` = sum(FALLECIDO == "SI", na.rm = TRUE),
    .groups = "drop"
  )

# Unir la fila de totales con la tabla principal
Tabla_dias_internacion_determinacion <- bind_rows(Tabla_dias_internacion_determinacion, fila_totales)

# Reemplazar NA en `Promedio de días de internación en UTI` con 0
Tabla_dias_internacion_determinacion <- Tabla_dias_internacion_determinacion %>%
  mutate(`Promedio de días de internación en UTI` = replace_na(`Promedio de días de internación en UTI`, 0))

# Mostrar la tabla final
Tabla_dias_internacion_determinacion
# Ordena de mayor a menor promedio

#generar nueva no centinela_ Tabla_dias_internacion_determinacion
# cambiar todo a mediana. 

#### UNO LA BASE DE SNVS CON LA BASE DEL HOSPITAL###
INTERNADOS_HZ <- read.csv2("internadoshz.csv",encoding = "UTF-8", na.strings = c("","*SIN DATO* (*SIN DATO*)"))

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





