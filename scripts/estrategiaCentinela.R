# ====================================================
# SCRIPT: estrategiaCentinela.R
# Objetivo: Calcular indicadores y generar tablas para informe UC-IRAG
# ====================================================

### PARÁMETROS DE FILTRO TEMPORAL ###

# Fecha de corte y cantidad de semanas no incluidas
fecha_corte <- dmy(dia_de_corte_de_datos)
anio_corte <- year(fecha_corte)
semana_epi_corte <- epiweek(fecha_corte)
ultima_semana_valida <- semana_epi_corte - num_ultimas_semana_no_incluidas

### FILTRADO DE BASE: UC-IRAG ###
IRA_UCI <- VR_NOMINAL_EVENTOCASO %>%
  filter(EVENTO == "Unidad Centinela de Infección Respiratoria Aguda Grave (UC-IRAG)") %>%
  filter(AÑO == anio_de_analisis | AÑO == anio_de_analisis - 1) %>%
  filter((AÑO < anio_corte) | (AÑO == anio_corte & SEPI_CREADA <= ultima_semana_valida)) %>%
  mutate(
    DIAS_TOTALES_INTERNACION = as.numeric(FECHA_ALTA_MEDICA - FECHA_INTERNACION),
    DIAS_INTERNACION_UTI = as.numeric(coalesce(FECHA_ALTA_MEDICA, FECHA_FALLECIMIENTO) - FECHA_CUI_INTENSIVOS)
  )

### CALCULO DE AÑO Y SEMANA EPIDEMIOLÓGICA MÁXIMA ###
max_anio <- max(IRA_UCI$AÑO, na.rm = TRUE)
SE_MAX_UCI <- IRA_UCI %>% filter(AÑO == max_anio) %>% summarise(max_sepi = max(SEPI_CREADA, na.rm = TRUE)) %>% pull()
SE_MIN_UCI <- IRA_UCI %>% filter(AÑO == max_anio) %>% summarise(min_sepi = min(SEPI_CREADA, na.rm = TRUE)) %>% pull()

fecha_inicio_semana <- ISOweek::ISOweek2date(paste0(max_anio, "-W", str_pad(SE_MAX_UCI, 2, pad = "0"), "-1"))

# 4. Extraer mes (en número o en texto)
mes_SE_MAX_UCI_num <- month(fecha_inicio_semana)       # Ej: 4

mes_SE_MAX_UCI_nombre <- lubridate::month(fecha_inicio_semana, label = TRUE, abbr = FALSE)

### TABLA DE TESTEOS POR DETERMINACIÓN Y SE ###
# Transformación larga y conteo de resultados
semanas_completas <- tibble(SEPI_CREADA = seq(SE_MIN_UCI, SE_MAX_UCI, 1))

CONTEO_IRA_UCI_SE <- IRA_UCI %>%
  pivot_longer(cols = all_of(columnas_existentes), names_to = "Tipo_Determinacion", values_to = "Resultado") %>%
  group_by(SEPI_CREADA, Tipo_Determinacion) %>%
  summarise(
    Detectable = sum(str_to_lower(Resultado) %in% c("detectable", "positivo"), na.rm = TRUE),
    No_detectable = sum(str_to_lower(Resultado) %in% c("no detectable", "negativo"), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  right_join(semanas_completas, by = "SEPI_CREADA") %>%
  complete(SEPI_CREADA, Tipo_Determinacion, fill = list(Detectable = 0, No_detectable = 0)) %>%
  mutate(Total_testeos = Detectable + No_detectable) %>%
  filter(!is.na(Tipo_Determinacion))

# Totales
N_testeos_UCI <- sum(CONTEO_IRA_UCI_SE$Total_testeos, na.rm = TRUE)

### CONTEO TOTAL DE POSITIVOS POR SE ###
semanas_completas <- tibble(SEPI_CREADA = factor(1:SE_MAX_UCI, levels = 1:SE_MAX_UCI))

CONTEO_UCI_SE_TOTAL_positivos <- IRA_UCI %>%
  filter(DETERMINACION_DICO_centinela == 1) %>%
  mutate(SEPI_CREADA = factor(SEPI_CREADA, levels = 1:SE_MAX_UCI)) %>%
  group_by(SEPI_CREADA) %>%
  summarise(n = n(), .groups = "drop") %>%
  right_join(semanas_completas, by = "SEPI_CREADA") %>%
  replace_na(list(n = 0))

### AGRUPAMIENTO DE DETERMINACIONES ###
# Agrupamos por virus para resumen gráfico
semanas_completas$SEPI_CREADA <- as.numeric(semanas_completas$SEPI_CREADA)

CASOS_UCI_SE_det <- IRA_UCI %>%
  pivot_longer(cols = all_of(columnas_existentes), names_to = "Tipo_Determinacion", values_to = "Resultado") %>%
  mutate(DETERMINACION = case_when(
    str_detect(Tipo_Determinacion, "SARS-CoV-2") ~ "Sars-Cov-2",
    str_detect(Tipo_Determinacion, "Influenza A") ~ "Influenza A",
    str_detect(Tipo_Determinacion, "Influenza B") ~ "Influenza B",
    str_detect(Tipo_Determinacion, "VSR") ~ "VSR",
    str_detect(Tipo_Determinacion, "Genoma viral de Influenza") ~ "Influenza sin tipificar",
    TRUE ~ "Otro"
  )) %>%
  group_by(SEPI_CREADA, DETERMINACION) %>%
  summarise(
    Detectable = sum(str_to_lower(Resultado) %in% c("detectable", "positivo"), na.rm = TRUE),
    No_detectable = sum(str_to_lower(Resultado) %in% c("no detectable", "negativo"), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(Total_testeos = Detectable + No_detectable) %>%
  right_join(semanas_completas, by = "SEPI_CREADA") %>%
  complete(SEPI_CREADA, DETERMINACION, fill = list(Detectable = 0, No_detectable = 0, Total_testeos = 0)) %>%
  filter(!is.na(DETERMINACION)) %>%
  mutate(positividad = round(Detectable / Total_testeos * 100, 2))

# Métricas generales
N_testeos_positivos_UCI <- sum(CASOS_UCI_SE_det$Detectable, na.rm = TRUE)
POSITIVIDAD_UCI <- round(N_testeos_positivos_UCI / N_testeos_UCI * 100, 2)

# Tabla resumen
tabla_UCI <- data.frame(
  Evento = "Unidad Centinela de Infección Respiratoria Aguda Grave (UC-IRAG)",
  `Testeos positivos` = N_testeos_positivos_UCI,
  `Testeos totales` = N_testeos_UCI,
  Positividad = paste0(POSITIVIDAD_UCI, "%")
)

# Crear tabla resumen por virus
tabla_UCI_por_virus <- CASOS_UCI_SE_det %>%
  filter(DETERMINACION %in% c("Sars-Cov-2", "Influenza A", "Influenza B", "VSR", "Influenza sin tipificar")) %>%
  group_by(DETERMINACION) %>%
  summarise(
    `Testeos positivos` = sum(Detectable, na.rm = TRUE),
    `Testeos totales` = sum(Total_testeos, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    Positividad = round(`Testeos positivos` / `Testeos totales` * 100, 2),
    Positividad = paste0(Positividad, "%")
  ) %>%
  rename(Determinación = DETERMINACION)

# Mostrar tabla
tabla_UCI_por_virus

### CONTEO TOTAL POR SEPI ###
CASOS_UCI_SE_det_totales <- CASOS_UCI_SE_det %>%
  filter(DETERMINACION != "Otro") %>%
  group_by(SEPI_CREADA) %>%
  summarise(
    Total_testeos = sum(Total_testeos),
    Detectable = sum(Detectable),
    No_detectable = sum(No_detectable),
    .groups = "drop"
  ) %>%
  mutate(positividad = round(Detectable / Total_testeos * 100, 2))

### TABLA DE CASOS POR DICO CENTINELA ###
casos_sepi_graf1 <- IRA_UCI %>%
  filter(DETERMINACION_DICO_centinela %in% c("0", "1", "99")) %>%
  filter(AÑO %in% c(anio_de_analisis, anio_de_analisis - 1)) %>%
  group_by(SEPI_CREADA, AÑO, DETERMINACION_DICO_centinela) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(DETERMINACION_DICO_centinela = recode_factor(
    DETERMINACION_DICO_centinela, `1` = "Detectable", `0` = "No detectable", `99` = "Sin datos"
  )) %>%
  pivot_wider(names_from = DETERMINACION_DICO_centinela, values_from = n, values_fill = 0)

### TABLA DE CASOS POR DICO CENTINELA ###
casos_gru_edad_graf <- IRA_UCI %>%
  filter(DETERMINACION_DICO_centinela %in% c("0", "1", "99")) %>%
  filter(AÑO %in% c(anio_de_analisis)) %>%
  group_by(GRUPO_ETARIO2, AÑO, DETERMINACION_DICO_centinela) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(DETERMINACION_DICO_centinela = recode_factor(
    DETERMINACION_DICO_centinela, `1` = "Detectable", `0` = "No detectable", `99` = "Sin datos"
  )) %>%
  pivot_wider(names_from = DETERMINACION_DICO_centinela, values_from = n, values_fill = 0)

### CONTEO POR GRUPO ETARIO ###

grupos_edad_completos <- distinct(IRA_UCI, GRUPO_ETARIO2)

CONTEO_UCI_edad <- IRA_UCI %>%
  pivot_longer(cols = all_of(columnas_existentes), names_to = "Tipo_Determinacion", values_to = "Resultado") %>%
  mutate(DETERMINACION = case_when(
    str_detect(Tipo_Determinacion, "SARS-CoV-2") ~ "Sars-Cov-2",
    str_detect(Tipo_Determinacion, "Influenza A") ~ "Influenza A",
    str_detect(Tipo_Determinacion, "Influenza B") ~ "Influenza B",
    str_detect(Tipo_Determinacion, "VSR") ~ "VSR",
    TRUE ~ "Otro"
  )) %>%
  group_by(GRUPO_ETARIO2, DETERMINACION) %>%
  summarise(
    Detectable = sum(str_to_lower(Resultado) %in% c("detectable", "positivo"), na.rm = TRUE),
    No_detectable = sum(str_to_lower(Resultado) %in% c("no detectable", "negativo"), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  right_join(grupos_edad_completos, by = "GRUPO_ETARIO2") %>%
  complete(GRUPO_ETARIO2, DETERMINACION, fill = list(Detectable = 0, No_detectable = 0)) %>%
  mutate(Total_testeos = Detectable + No_detectable, 
         positividad = round(Detectable / Total_testeos * 100, 2))


columnas_determinacion <- names(VR_NOMINAL_EVENTOCASO) %>%
  str_subset("^DETERMINACION_")%>%
  setdiff(c("DETERMINACION_DICO",
            "DETERMINACION_DICO_centinela",
            "DETERMINACION_SIN_DATO"))


VR_NOMINAL_EVENTOCASO$DETERMINACION_SIN_DATO <- as.character(VR_NOMINAL_EVENTOCASO$DETERMINACION_SIN_DATO)

resultado_centinela <- analizar_determinaciones(
  data = IRA_UCI %>%
    filter(AÑO == anio_de_analisis), # Dataset tranformado
  columnas_determinacion = columnas_determinacion,# columnas determinacion creado arriba
  variable_agrupar = "GRUPO_ETARIO2",# variables de agrupacion principal
  #variable_cruce = "ANIO_EPI_APERTURA",# variables de agrupacion secundaria (opciona)
  clasificar = clasificar_virus # Clasificacion de virus creada arriba, opcional. 
)

head(resultado_centinela)


### CONTEO DE SÍNTOMAS EN CASOS POSITIVOS ###
# positivos <- IRA_UCI %>% filter(DETERMINACION_DICO == 1)
# 
# casos_sin_sintomas <- positivos %>%
#   filter(rowSums(select(., starts_with("SINTOMA_")), na.rm = TRUE) == 0) %>%
#   nrow()
# 
# CONTEO_UCI_sintomas <- positivos %>%
#   summarise(across(starts_with("SINTOMA_"), ~ sum(.x, na.rm = TRUE))) %>%
#   pivot_longer(cols = everything(), names_to = "Sintoma", values_to = "n") %>%
#   mutate(Sintoma = str_remove(Sintoma, "^SINTOMA_")) %>%
#   arrange(desc(n)) %>%
#   bind_rows(tibble(Sintoma = NA, n = casos_sin_sintomas))
# 
# ### CONTEO DE COMORBILIDADES EN POSITIVOS ###
# casos_sin_sintomas_c <- positivos %>%
#   filter(rowSums(select(., starts_with("COMORB_")), na.rm = TRUE) == 0) %>%
#   nrow()
# 
# CONTEO_UCI_comorbilidad <- positivos %>%
#   summarise(across(starts_with("COMORB_"), ~ sum(.x, na.rm = TRUE))) %>%
#   pivot_longer(cols = everything(), names_to = "Comorbilidad", values_to = "n") %>%
#   mutate(Comorbilidad = str_remove(Comorbilidad, "^COMORB_")) %>%
#   arrange(desc(n)) %>%
#   bind_rows(tibble(Comorbilidad = NA, n = casos_sin_sintomas_c))

source("scripts/upset_plots.R")

### TABLA DE INTERNACIÓN POR DETERMINACIÓN ###
internados <- IRA_UCI %>%
  filter(DETERMINACION_DICO == "1") %>%
  pivot_longer(cols = all_of(columnas_existentes), names_to = "Tipo_Determinacion", values_to = "Resultado") %>%
  mutate(DETERMINACION = case_when(
    str_detect(Tipo_Determinacion, "SARS-CoV-2") ~ "Sars-Cov-2",
    str_detect(Tipo_Determinacion, "Influenza A") ~ "Influenza A",
    str_detect(Tipo_Determinacion, "Influenza B") ~ "Influenza B",
    str_detect(Tipo_Determinacion, "VSR") ~ "VSR",
    TRUE ~ "Otro"
  )) %>%
  filter(str_to_lower(Resultado) %in% c("detectable", "positivo"), na.rm = TRUE)

Tabla_dias_internacion_determinacion <- internados %>%
  group_by(DETERMINACION) %>%
  summarise(
    `N° total de internados` = n_distinct(IDEVENTOCASO),
    `Promedio de días de internación` = round(mean(DIAS_TOTALES_INTERNACION, na.rm = TRUE), 1),
    `Requerimiento de UTI` = sum(CUIDADO_INTENSIVO == "SI", na.rm = TRUE),
    `Promedio de días de internación en UTI` = round(mean(DIAS_INTERNACION_UTI, na.rm = TRUE), 1),
    `N° total de fallecidos` = sum(FALLECIDO == "SI", na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(`Promedio de días de internación`))

# Fila de totales
fila_totales <- internados %>%
  summarise(
    DETERMINACION = "Totales",
    `N° total de internados` = n_distinct(IDEVENTOCASO),
    `Promedio de días de internación` = round(mean(DIAS_TOTALES_INTERNACION, na.rm = TRUE), 1),
    `Requerimiento de UTI` = sum(CUIDADO_INTENSIVO == "SI", na.rm = TRUE),
    `Promedio de días de internación en UTI` = round(mean(DIAS_INTERNACION_UTI, na.rm = TRUE), 1),
    `N° total de fallecidos` = sum(FALLECIDO == "SI", na.rm = TRUE),
    .groups = "drop"
  )

Tabla_dias_internacion_determinacion <- bind_rows(Tabla_dias_internacion_determinacion, fila_totales) %>%
  mutate(`Promedio de días de internación en UTI` = replace_na(`Promedio de días de internación en UTI`, 0))

### HISOPADOS EN EL HOSPITAL ###

INTERNADOS_HZ <- read.csv2("internadoshz.csv", encoding = "UTF-8", na.strings = c("", "*SIN DATO* (*SIN DATO*)"))

Tabla_servicios <- INTERNADOS_HZ %>%
  group_by(SERVICIO) %>%
  summarise(
    `Compatible con definición IRAG` = n(),
    Hisopados = sum(HISOPADO == "SI", na.rm = TRUE),
    `Porcentaje de hisopados` = round((Hisopados / `Compatible con definición IRAG`) * 100, 1)
  ) %>%
  bind_rows(
    summarise(.data = ., SERVICIO = "Totales",
              `Compatible con definición IRAG` = sum(`Compatible con definición IRAG`),
              Hisopados = sum(Hisopados),
              `Porcentaje de hisopados` = round((sum(Hisopados) / sum(`Compatible con definición IRAG`)) * 100, 1))
  ) %>%
  rename(Servicio = SERVICIO)




