# ====================================================
# SCRIPT: analisis_UCIRAG.R
# Objetivo: Calcular indicadores y generar tablas para informe UC-IRAG - Notificacion nominal
# ====================================================

### PARÁMETROS DE FILTRO TEMPORAL ###

# Fecha de corte y cantidad de semanas no incluidas
fecha_corte <- dmy(dia_de_corte_de_datos)
anio_corte <- year(fecha_corte)
semana_epi_corte <- epiweek(fecha_corte)
ultima_semana_valida <- semana_epi_corte - num_ultimas_semana_no_incluidas

### FILTRADO DE BASE: UC-IRAG ###
IRA_UCI <- VR_NOMINAL_EVENTOCASO %>%
  filter(EVENTO == "Unidad Centinela de Infección Respiratoria Aguda Grave (UC-IRAG)"|EVENTO=="UCIRAG") %>%
  filter(AÑO%in% anio_de_analisis | AÑO == anio_de_analisis[1] - 1) %>%
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


if (FORMATO_MULTIREGISTRO == "NO") {
  source("scripts/analisis_UCIRAG_eventocaso.R")
} else if (FORMATO_MULTIREGISTRO == "SI") {
  source("scripts/analisis_UCIRAG_multiregistro.R")
} else {
  stop("⚠️ El valor de FORMATO_MULTIREGISTRO debe ser 'SI' o 'NO'")
}




source("scripts/upset_plots.R")

### TABLA DE INTERNACIÓN POR DETERMINACIÓN ###
internados <- IRA_UCI %>%
  #filter(DETERMINACION_DICO_centinela == "1") %>%
  pivot_longer(cols = all_of(columnas_existentes), names_to = "Tipo_Determinacion", values_to = "Resultado") %>%
  mutate(DETERMINACION = case_when(
    str_detect(Tipo_Determinacion, "SARS-CoV-2|SARS_COV_2_PCR") ~ "Sars-Cov-2",
    str_detect(Tipo_Determinacion, "Influenza A|INFLUENZA_A") ~ "Influenza A",
    str_detect(Tipo_Determinacion, "Influenza B|INFLUENZA_B") ~ "Influenza B",
    str_detect(Tipo_Determinacion, "VSR") ~ "VSR",
    TRUE ~ "Otro"
  )) %>%
  filter(str_to_lower(Resultado) %in% c("detectable", "positivo", 1), na.rm = TRUE)

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

# ====================================================
# SCRIPT: analisis_UCIRAG.R
# Objetivo: Calcular indicadores y generar tablas para informe UC-IRAG - Notificacion agrupada
# ====================================================

carga_agrupada_ucirag <- carga_agrupada_ucirag[-1,]

larga_agrupada_ucirag <- carga_agrupada_ucirag %>%
  pivot_longer(
    cols = `0 a 2 m`:`Sin especificar`,   # todas las columnas de edad
    names_to = "grupo_edad",              # nombre de la nueva columna con los nombres originales
    values_to = "conteo"                  # valores que estaban en las columnas
  ) %>%
  mutate(
    conteo = as.numeric(conteo)           # convertir la variable conteo a numérica
  )
names(larga_agrupada_ucirag)

larga_agrupada_ucirag <- larga_agrupada_ucirag %>%
  filter(ANIO %in% anio_de_analisis | ANIO == anio_de_analisis[1] - 1) 

table(larga_agrupada_ucirag$NOMBREEVENTOAGRP)

# Crear tabla de semanas completas con ANIO como character
semanas_completas <- tibble(
  ANIO = as.character(anio_de_analisis[1]),
  SEMANA = as.character(1:53)
)

# Generar tabla resumen completa
tabla_agrupado1 <- larga_agrupada_ucirag%>%
  filter(NOMBREEVENTOAGRP %in% c(
    "Casos de IRAG entre los internados",
    "Casos de IRAG extendida entre los internados",
    "Pacientes internados por todas las causas"
  )) %>%
  mutate(
    tipo_ingreso = case_when(
      NOMBREEVENTOAGRP == "Casos de IRAG entre los internados" ~ "ingresos_irag",
      NOMBREEVENTOAGRP == "Casos de IRAG extendida entre los internados" ~ "ingresos_irag_ext",
      NOMBREEVENTOAGRP == "Pacientes internados por todas las causas" ~ "ingresos_totales"
    ),
    conteo = as.numeric(conteo)
  ) %>%
  filter(ANIO %in% anio_de_analisis) %>%
  group_by(ANIO, SEMANA, tipo_ingreso) %>%
  summarise(conteo_total = sum(conteo, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(
    names_from = tipo_ingreso,
    values_from = conteo_total,
    values_fill = 0
  ) %>%
  right_join(semanas_completas, by = c("ANIO", "SEMANA")) %>%
  replace_na(list(
    ingresos_irag = 0,
    ingresos_irag_ext = 0,
    ingresos_totales = 0
  )) %>%
  mutate(ANIO = as.numeric(ANIO),
         SEMANA= as.numeric(SEMANA)) %>% 
  arrange(ANIO, SEMANA) %>% 
  mutate(ingresos_otros= ingresos_totales - (ingresos_irag + ingresos_irag_ext ))

# Crear columna combinada para el eje X
tabla_agrupado1 <- tabla_agrupado1 %>%
  mutate(
    semana_label = paste(ANIO, "- SE", SEMANA),
    semana_label = factor(semana_label, levels = unique(semana_label[order(as.integer(SEMANA))]))
  )

n_tabla_agrupado1 <- sum(tabla_agrupado1$ingresos_totales)

