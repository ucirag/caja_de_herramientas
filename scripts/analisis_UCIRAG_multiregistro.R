### TABLA DE TESTEOS POR DETERMINACIÓN Y SE ###
# Transformación larga y conteo de resultados
semanas_completas <- tibble(SEPI_CREADA = seq(SE_MIN_UCI, SE_MAX_UCI, 1))

CONTEO_IRA_UCI_SE <- IRA_UCI %>%
  pivot_longer(cols = all_of(columnas_existentes), names_to = "Tipo_Determinacion", values_to = "Resultado") %>%
  group_by(SEPI_CREADA, Tipo_Determinacion) %>%
  summarise(
    Detectable = sum(str_to_lower(Resultado) %in% c("detectable", "positivo",), na.rm = TRUE),
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
  filter(AÑO %in% c(anio_de_analisis, anio_de_analisis[1] - 1)) %>%
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
  group_by(GRUPO_ETARIO, AÑO, DETERMINACION_DICO_centinela) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(DETERMINACION_DICO_centinela = recode_factor(
    DETERMINACION_DICO_centinela, `1` = "Detectable", `0` = "No detectable", `99` = "Sin datos"
  )) %>%
  pivot_wider(names_from = DETERMINACION_DICO_centinela, values_from = n, values_fill = 0)

### CONTEO POR GRUPO ETARIO ###

grupos_edad_completos <- distinct(IRA_UCI, GRUPO_ETARIO)

CONTEO_UCI_edad <- IRA_UCI %>%
  filter(AÑO%in% anio_de_analisis) %>% 
  pivot_longer(cols = all_of(columnas_existentes), names_to = "Tipo_Determinacion", values_to = "Resultado") %>%
  mutate(DETERMINACION = case_when(
    str_detect(Tipo_Determinacion, "SARS-CoV-2") ~ "Sars-Cov-2",
    str_detect(Tipo_Determinacion, "Influenza A") ~ "Influenza A",
    str_detect(Tipo_Determinacion, "Influenza B") ~ "Influenza B",
    str_detect(Tipo_Determinacion, "VSR") ~ "VSR",
    TRUE ~ "Otro"
  )) %>%
  group_by(GRUPO_ETARIO, DETERMINACION) %>%
  summarise(
    Detectable = sum(str_to_lower(Resultado) %in% c("detectable", "positivo"), na.rm = TRUE),
    No_detectable = sum(str_to_lower(Resultado) %in% c("no detectable", "negativo"), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  right_join(grupos_edad_completos, by = "GRUPO_ETARIO") %>%
  complete(GRUPO_ETARIO, DETERMINACION, fill = list(Detectable = 0, No_detectable = 0)) %>%
  mutate(Total_testeos = Detectable + No_detectable, 
         positividad = round(Detectable / Total_testeos * 100, 2))


columnas_determinacion <- names(VR_NOMINAL_EVENTOCASO) %>%
  str_subset("^DETERMINACION_")%>%
  setdiff(c("DETERMINACION_DICO",
            "DETERMINACION_DICO_centinela",
            "DETERMINACION_SIN_DATO"))

clasificar_virus <- function(x) {
  case_when(
    str_detect(x, "Genoma viral de VSR") ~ "VSR",
    str_detect(x,  "Genoma viral de VSR A") ~ "VSR",
    str_detect(x,  "Genoma viral de VSR B") ~ "VSR",
    str_detect(x, "Genoma viral SARS-CoV-2") ~ "SARS-CoV-2",
    str_detect(x, "Genoma viral de Influenza") ~ "Influenza",
    TRUE ~ "Otro"
  )
}

VR_NOMINAL_EVENTOCASO$DETERMINACION_SIN_DATO <- as.character(VR_NOMINAL_EVENTOCASO$DETERMINACION_SIN_DATO)

resultado_centinela <- analizar_determinaciones(
  data = IRA_UCI %>%
    filter(AÑO %in% anio_de_analisis), # Dataset tranformado
  columnas_determinacion = columnas_determinacion,# columnas determinacion creado arriba
  variable_agrupar = "GRUPO_ETARIO",# variables de agrupacion principal
  #variable_cruce = "ANIO_EPI_APERTURA",# variables de agrupacion secundaria (opciona)
  clasificar = clasificar_virus # Clasificacion de virus creada arriba, opcional. 
)

head(resultado_centinela)

