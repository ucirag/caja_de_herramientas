# 1. Definir columnas de determinación válidas
columnas_determinacion <- names(IRA_UCI) %>%
  str_subset("^DETERMINACION_") %>%
  setdiff(c("DETERMINACION_DICO", "DETERMINACION_DICO_centinela", "DETERMINACION_SIN_DATO",
            "DETERMINACION_VSR_ANTIGENO","DETERMINACION_ANTIGENO_INFLUENZA_A_SIN_SUBTIPIFICAR",
            "DETERMINACION_ANTIGENO_INFLUENZA_B_SIN_LINAJE","DETERMINACION_OVR" ))

# 2. Crear variable centinela: al menos un resultado "1" → TRUE
IRA_UCI <- IRA_UCI %>%
  mutate(
    DETERMINACION_DICO_centinela = case_when(
      if_any(all_of(columnas_determinacion), ~ . == 1) ~ 1,
        if_any(all_of(columnas_determinacion), ~ . == 0) ~ 0,
      TRUE ~ 99
    )
  )

table(IRA_UCI$DETERMINACION_DICO_centinela)

# 3. Tabla con conteos por tipo de determinación y semana
SE_MAX_UCI <- max(IRA_UCI$SEPI_CREADA, na.rm = TRUE)

# IRA_UCI <- IRA_UCI %>%
#   mutate(SEPI_CREADA = as.integer(SEPI_CREADA))

semanas_completas <- IRA_UCI %>%
  distinct(SEPI_CREADA, AÑO) %>%
  complete(SEPI_CREADA = 1:SE_MAX_UCI, AÑO = unique(IRA_UCI$AÑO))

CONTEO_IRA_UCI_SE <- IRA_UCI %>%
  pivot_longer(cols = all_of(columnas_determinacion),
               names_to = "Tipo_Determinacion",
               values_to = "Resultado") %>%
  group_by(SEPI_CREADA, Tipo_Determinacion) %>%
  summarise(
    Detectable = sum(Resultado == 1, na.rm = TRUE),
    No_detectable = sum(Resultado == 0, na.rm = TRUE),
    Sin_resultado = sum(is.na(Resultado)),
    .groups = "drop"
  ) %>%
  right_join(semanas_completas, by = "SEPI_CREADA") %>%
  complete(SEPI_CREADA,AÑO, Tipo_Determinacion,
           fill = list(Detectable = 0, No_detectable = 0, Sin_resultado = 0)) %>%
  mutate(Total_testeos = Detectable + No_detectable)

# 4. Clasificación por virus y resumen general
CASOS_UCI_SE_det <- IRA_UCI %>%
  pivot_longer(cols = all_of(columnas_determinacion),
               names_to = "Tipo_Determinacion",
               values_to = "Resultado") %>%
  mutate(DETERMINACION = case_when(
    str_detect(Tipo_Determinacion, "SARS_COV_2|SARS-CoV-2") ~ "Sars-Cov-2",
    str_detect(Tipo_Determinacion, "Influenza_A|INFLUENZA_A") ~ "Influenza A",
    str_detect(Tipo_Determinacion, "Influenza_B|INFLUENZA_B") ~ "Influenza B",
    str_detect(Tipo_Determinacion, "VSR") ~ "VSR",
    str_detect(Tipo_Determinacion, "INFLUENZA.*SIN_LINAJE") ~ "Influenza sin tipificar",
    TRUE ~ "Otro"
  )) %>%
  group_by(SEPI_CREADA, DETERMINACION,AÑO) %>%
  summarise(
    Detectable = sum(Resultado == 1, na.rm = TRUE),
    No_detectable = sum(Resultado == 0, na.rm = TRUE),
    Sin_resultado = sum(is.na(Resultado)),
    .groups = "drop"
  ) %>%
  mutate(Total_testeos = Detectable + No_detectable) %>%
  right_join(semanas_completas, by = c("SEPI_CREADA","AÑO")) %>%
  complete(SEPI_CREADA, AÑO, DETERMINACION,
           fill = list(Detectable = 0, No_detectable = 0,
                       Sin_resultado = 0, Total_testeos = 0)) %>%
  filter(!is.na(DETERMINACION)) %>%
  mutate(positividad = round(Detectable / Total_testeos * 100, 2)) %>% 
  arrange(AÑO, SEPI_CREADA)

# 5. Métricas generales
N_testeos_UCI <- sum(CASOS_UCI_SE_det$Total_testeos, na.rm = TRUE)
N_testeos_positivos_UCI <- sum(CASOS_UCI_SE_det$Detectable, na.rm = TRUE)
POSITIVIDAD_UCI <- round(N_testeos_positivos_UCI / N_testeos_UCI * 100, 2)

# 6. Tabla resumen general
tabla_UCI <- data.frame(
  Evento = "Unidad Centinela de Infección Respiratoria Aguda Grave (UC-IRAG)",
  `Testeos positivos` = N_testeos_positivos_UCI,
  `Testeos totales` = N_testeos_UCI,
  Positividad = paste0(POSITIVIDAD_UCI, "%")
)

# 7. Tabla por virus
tabla_UCI_por_virus <- CASOS_UCI_SE_det %>%
  filter(DETERMINACION %in% c("Sars-Cov-2", "Influenza A", "Influenza B", "VSR", "Influenza sin tipificar")) %>%
  group_by(DETERMINACION) %>%
  summarise(
    `Testeos positivos` = sum(Detectable, na.rm = TRUE),
    `Testeos totales` = sum(Total_testeos, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    Positividad = paste0(round(`Testeos positivos` / `Testeos totales` * 100, 2), "%")
  ) %>%
  rename(Determinación = DETERMINACION)


CASOS_UCI_SE_det_totales <- CASOS_UCI_SE_det %>%
  filter(DETERMINACION != "Otro") %>%
  group_by(SEPI_CREADA, AÑO) %>%
  summarise(
    Total_testeos = sum(Total_testeos, na.rm = TRUE),
    Detectable = sum(Detectable, na.rm = TRUE),
    No_detectable = sum(No_detectable, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    positividad = round(Detectable / Total_testeos * 100, 2),
    positividad = ifelse(is.nan(positividad), 0, positividad)
  )%>%
  arrange(AÑO, SEPI_CREADA)


casos_sepi_graf1 <- IRA_UCI %>%
  filter(DETERMINACION_DICO_centinela %in% c(0, 1, 99)) %>%
  filter(AÑO %in% c(anio_de_analisis, anio_de_analisis[1] - 1)) %>%
  group_by(SEPI_CREADA, AÑO, DETERMINACION_DICO_centinela) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(DETERMINACION_DICO_centinela = fct_recode(as.factor(DETERMINACION_DICO_centinela),
                                                   "Detectable" = "1", "No detectable" = "0", "Sin datos" = "99")) %>%
  pivot_wider(names_from = DETERMINACION_DICO_centinela, values_from = n, values_fill = 0)


casos_gru_edad_graf <- IRA_UCI %>%
  filter(DETERMINACION_DICO_centinela %in% c(0, 1, 99)) %>%
  filter(AÑO%in% anio_de_analisis) %>%
  group_by(GRUPO_ETARIO, DETERMINACION_DICO_centinela) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(DETERMINACION_DICO_centinela = fct_recode(as.factor(DETERMINACION_DICO_centinela),
                                                   "Detectable" = "1", "No detectable" = "0", "Sin datos" = "99")) %>%
  pivot_wider(names_from = DETERMINACION_DICO_centinela, values_from = n, values_fill = 0)

grupos_edad_completos <- distinct(IRA_UCI, GRUPO_ETARIO)

CONTEO_UCI_edad <- IRA_UCI %>%
  filter(AÑO%in% anio_de_analisis) %>% 
  pivot_longer(cols = all_of(columnas_determinacion),
               names_to = "Tipo_Determinacion",
               values_to = "Resultado") %>%
  mutate(DETERMINACION = case_when(
    str_detect(Tipo_Determinacion, "SARS_COV_2|SARS-CoV-2") ~ "Sars-Cov-2",
    str_detect(Tipo_Determinacion, "Influenza_A|INFLUENZA_A") ~ "Influenza A",
    str_detect(Tipo_Determinacion, "Influenza_B|INFLUENZA_B") ~ "Influenza B",
    str_detect(Tipo_Determinacion, "VSR") ~ "VSR",
    str_detect(Tipo_Determinacion, "INFLUENZA.*SIN_LINAJE") ~ "Influenza sin tipificar",
    TRUE ~ "Otro"
  )) %>%
  group_by(GRUPO_ETARIO, DETERMINACION) %>%
  summarise(
    Detectable = sum(Resultado == 1, na.rm = TRUE),
    No_detectable = sum(Resultado == 0, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  right_join(grupos_edad_completos, by = "GRUPO_ETARIO") %>%
  complete(GRUPO_ETARIO, DETERMINACION, fill = list(Detectable = 0, No_detectable = 0)) %>%
  mutate(
    Total_testeos = Detectable + No_detectable,
    positividad = round(Detectable / Total_testeos * 100, 2)
  )


# 1. Columnas de determinación (excluyendo las no relevantes)


# 2. Clasificador de virus
clasificar_virus <- function(x) {
  case_when(
    str_detect(x, "VSR_PCR") ~ "VSR",
    str_detect(x, "VSR_A") ~ "VSR",
    str_detect(x, "VSR_B") ~ "VSR",
    str_detect(x, "VSR") ~ "VSR",  # extra: para que funcione con columnas VSR_PCR, etc.
    str_detect(x, "SARS_COV_2_PCR") ~ "SARS-CoV-2",
    str_detect(x, "INFLUENZA_A") ~ "Influenza A",
    str_detect(x, "INFLUENZA_B") ~ "Influenza B",
    str_detect(x, "INFLUENZA") ~ "Influenza sin tipificar",
    TRUE ~ "Otro"
  )
}

# 3. Generar tabla de resultados centinela por grupo etario y virus
resultado_centinela <- VR_NOMINAL_EVENTOCASO %>%
  filter(AÑO%in% anio_de_analisis) %>%
  pivot_longer(cols = all_of(columnas_determinacion),
               names_to = "Tipo_Determinacion",
               values_to = "Resultado") %>%
  mutate(DETERMINACION = clasificar_virus(Tipo_Determinacion)) %>%
  group_by(GRUPO_ETARIO, DETERMINACION) %>%
  summarise(
    Detectable = sum(Resultado == 1, na.rm = TRUE),
    No_detectable = sum(Resultado == 0, na.rm = TRUE),
    Sin_resultado = sum(is.na(Resultado)),
    .groups = "drop"
  ) %>%
  mutate(
    Total_testeos = Detectable + No_detectable,
    positividad = round(Detectable / Total_testeos * 100, 2)
  )

columnas_existentes <- columnas_determinacion
