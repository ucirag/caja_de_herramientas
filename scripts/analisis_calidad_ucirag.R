library(dplyr)
library(openxlsx)

# --- 1. Filtrar por el último año disponible ---
ultimo_anio <- max(VR_NOMINAL_EVENTOCASO$AÑO, na.rm = TRUE)
VR_NOMINAL_EVENTOCASO_filtrada <- VR_NOMINAL_EVENTOCASO %>%
  filter(AÑO == ultimo_anio)

# --- 2. Calcular indicadores para todo el año ---
VR_NOMINAL_EVENTOCASO_filtrada <- VR_NOMINAL_EVENTOCASO_filtrada %>%
  mutate(
    diff_apertura_internacion = ifelse(is.na(FECHA_APERTURA) | is.na(FECHA_INTERNACION), NA, as.numeric(FECHA_APERTURA - FECHA_INTERNACION)),
    diff_muestra_internacion = ifelse(is.na(FTM) | is.na(FECHA_INTERNACION), NA, as.numeric(FTM - FECHA_INTERNACION))
  )

mediana_apertura_internacion <- median(VR_NOMINAL_EVENTOCASO_filtrada$diff_apertura_internacion, na.rm = TRUE)
mediana_muestra_internacion  <- median(VR_NOMINAL_EVENTOCASO_filtrada$diff_muestra_internacion, na.rm = TRUE)
porcentaje_na_apertura <- mean(is.na(VR_NOMINAL_EVENTOCASO_filtrada$diff_apertura_internacion)) * 100
porcentaje_na_muestra  <- mean(is.na(VR_NOMINAL_EVENTOCASO_filtrada$diff_muestra_internacion)) * 100

casos_irag <- VR_NOMINAL_EVENTOCASO_filtrada %>%
  filter(CLASIFICACION_MANUAL == "Infección respiratoria aguda grave (IRAG)")

total_irag <- nrow(casos_irag)

clasificados_con_resultado <- casos_irag %>%
  filter(
      SINTOMA_FIEBRE_MAY_38== 1 &
        SINTOMA_TOS== 1
  ) %>%
  nrow()

porcentaje_resultados_irag <- (clasificados_con_resultado / total_irag) * 100

# --- 3. Crear tabla para todo el año ---
tabla_anual <- tibble(
  `Tipo de base` = c("Nominal", "Nominal", "Nominal"),
  `Tipo de indicador` = c("Oportunidad", "Oportunidad", "Consistencia"),
  `Variables` = c("De la notificación", "De la toma de muestra", "Clasificación Manual como IRAG correctamente clasificadas"),
  `Definición del indicador` = c(
    "Mediana de la fecha de apertura MENOS la fecha de internación",
    "Mediana de la fecha de toma de muestra MENOS la fecha de internación",
    "IRAG notificadas con presencia de las variables TOS y FIEBRE+38 / total de registros IRAG * 100"
  ),
  `Indicador` = c(mediana_apertura_internacion, mediana_muestra_internacion, round(porcentaje_resultados_irag, 1)),
  `% de NA` = c(round(porcentaje_na_apertura, 1), round(porcentaje_na_muestra, 1), NA)
)

# --- 4. Calcular tabla para las últimas 4 semanas ---
max_semana <- max(VR_NOMINAL_EVENTOCASO_filtrada$SEPI_CREADA, na.rm = TRUE)

ultimas_4s <- VR_NOMINAL_EVENTOCASO_filtrada %>%
  filter(SEPI_CREADA >= (max_semana - 3)) %>%
  mutate(
    diff_apertura_internacion = ifelse(is.na(FECHA_APERTURA) | is.na(FECHA_INTERNACION), NA, as.numeric(FECHA_APERTURA - FECHA_INTERNACION)),
    diff_muestra_internacion = ifelse(is.na(FTM) | is.na(FECHA_INTERNACION), NA, as.numeric(FTM - FECHA_INTERNACION))
  )

mediana_apertura_4s <- median(ultimas_4s$diff_apertura_internacion, na.rm = TRUE)
mediana_muestra_4s  <- median(ultimas_4s$diff_muestra_internacion, na.rm = TRUE)
porcentaje_na_apertura_4s <- mean(is.na(ultimas_4s$diff_apertura_internacion)) * 100
porcentaje_na_muestra_4s  <- mean(is.na(ultimas_4s$diff_muestra_internacion)) * 100

casos_irag_4s <- ultimas_4s %>%
  filter(CLASIFICACION_MANUAL == "Infección respiratoria aguda grave (IRAG)")

total_irag_4s <- nrow(casos_irag_4s)

# clasificados_con_resultado_4s <- casos_irag_4s %>%
#   filter(
#     INFLUENZA_FINAL != "Sin resultado" &
#       COVID_19_FINAL != "Sin resultado" &
#       VSR_FINAL != "Sin resultado"
#   ) %>%
#   nrow()

casos_irag_4s$SINTOMA_FIEBRE_MAY_38
casos_irag_4s$SINTOMA_TOS

clasificados_con_resultado_4s <- casos_irag_4s %>%
  filter(
    SINTOMA_FIEBRE_MAY_38== 1 &
      SINTOMA_TOS== 1
  ) %>%
  nrow()

porcentaje_resultados_irag_4s <- (clasificados_con_resultado_4s / total_irag_4s) * 100

tabla_4s <- tibble(
  `Tipo de base` = c("Nominal", "Nominal", "Nominal"),
  `Tipo de indicador` = c("Oportunidad", "Oportunidad", "Consistencia"),
  `Variables` = c("De la notificación", "De la toma de muestra", "Clasificación Manual como IRAG correctamente clasificadas"),
  `Definición del indicador` = c(
    "Mediana de la fecha de apertura MENOS la fecha de internación",
    "Mediana de la fecha de toma de muestra MENOS la fecha de internación",
    "IRAG notificadas con presencia de las variables TOS y FIEBRE+38 / total de registros IRAG * 100"
  ),
  `Indicador` = c(mediana_apertura_4s, mediana_muestra_4s, round(porcentaje_resultados_irag_4s, 1)),
  `% de NA` = c(round(porcentaje_na_apertura_4s, 1), round(porcentaje_na_muestra_4s, 1), NA)
)

# --- 5. Crear Excel con formato y dos hojas ---
wb <- createWorkbook()
addWorksheet(wb, "Indicadores")
addWorksheet(wb, "Ultimas-4SE")

# Estilos
header_style <- createStyle(textDecoration = "bold", border = "TopBottomLeftRight", halign = "center")
cell_style <- createStyle(border = "TopBottomLeftRight")
wrap_style <- createStyle(border = "TopBottomLeftRight", wrapText = TRUE, valign = "top")
titulo_style <- createStyle(fontSize = 14, textDecoration = "bold", halign = "left")

# Hoja 1 - Anual
titulo_anual <- paste0("Tabla de Indicadores de Calidad - Año: ", ultimo_anio)
writeData(wb, sheet = "Indicadores", x = titulo_anual, startRow = 1, startCol = 1)
addStyle(wb, "Indicadores", titulo_style, rows = 1, cols = 1, gridExpand = TRUE)

writeData(wb, "Indicadores", tabla_anual, startRow = 3, headerStyle = header_style)
addStyle(wb, "Indicadores", cell_style, rows = 4:(nrow(tabla_anual)+3), cols = c(1,2,5,6), gridExpand = TRUE)
addStyle(wb, "Indicadores", wrap_style, rows = 4:(nrow(tabla_anual)+3), cols = c(3,4), gridExpand = TRUE)
setColWidths(wb, "Indicadores", cols = 2, widths = 20)
setColWidths(wb, "Indicadores", cols = 3, widths = 35)
setColWidths(wb, "Indicadores", cols = 4, widths = 60)

# Hoja 2 - Últimas 4 semanas
titulo_4s <- paste0("Tabla de Indicadores de Calidad - Últimas 4 semanas - Año: ", ultimo_anio)
writeData(wb, sheet = "Ultimas-4SE", x = titulo_4s, startRow = 1, startCol = 1)
addStyle(wb, "Ultimas-4SE", titulo_style, rows = 1, cols = 1, gridExpand = TRUE)

writeData(wb, "Ultimas-4SE", tabla_4s, startRow = 3, headerStyle = header_style)
addStyle(wb, "Ultimas-4SE", cell_style, rows = 4:(nrow(tabla_4s)+3), cols = c(1,2,5,6), gridExpand = TRUE)
addStyle(wb, "Ultimas-4SE", wrap_style, rows = 4:(nrow(tabla_4s)+3), cols = c(3,4), gridExpand = TRUE)
setColWidths(wb, "Ultimas-4SE", cols = 2, widths = 20)
setColWidths(wb, "Ultimas-4SE", cols = 3, widths = 35)
setColWidths(wb, "Ultimas-4SE", cols = 4, widths = 60)

# --- 6. Guardar con fecha en el nombre ---
fecha_analisis <- format(Sys.Date(), "%d%b%Y")
nombre_archivo <- paste0("salidas/indicadores_calidad_", ultimo_anio, "_", fecha_analisis, ".xlsx")
saveWorkbook(wb, nombre_archivo, overwrite = TRUE)