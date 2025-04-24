
# Transformar variables
# Definir columnas a renombrar
sintomas_vars <- c(
  "DOLOR_TORACICO", "DOLOR_MUSCULAR", "DOLOR_ABDOMINAL", "VOMITO", "DIARREA",
  "RECHAZO_ALIMENTO", "TIRAJE", "TOS", "FIEBRE_MAY_38", "FIEBRE_MENOR_38",
  "SIN_FIEBRE", "DISNEA", "DOLOR_GARGANTA", "RINITIS", "INYECCION_CONJUNTIVAL",
  "DIFICULTAD_PARA_RESPIRAR", "SIBILANCIAS", "APNEA", "HIPOXEMIA", "DISGEUSIA",
  "AGEUSIA", "ANOSMIA", "DOLOR_DE_CABEZA", "MALESTAR_GENERAL", "CONFUSION",
  "IRRITABILIDAD", "CONVULSIONES", "TAQUIPNEA"
)

comorbilidades_vars <- c(
  "DIABETES", "BAJO_PESO_NACIMIENTO", "ASMA", "TUBERCULOSIS", "ENF_RESPIRATORIA",
  "CARDIOPATIA_CONGENITA", "VIH", "ASPLENIA", "DESNUTRICION", "CANCER",
  "TRASPLANTADO", "BRONQUIOLITIS_PREVIA", "EMBARAZO_PUERPERIO", "EMBARAZO_COMORBILIDAD",
  "ENF_NEUROLOGICA_CRONICA", "ENF_HEPATICA", "HIPERTENSION", "ENF_CEREBROVASCULAR",
  "ENF_NEUROMUSCULAR", "DISCAPACIDAD_INTELECTUAL", "ENF_CARDIACA", "ENF_REUMATOLOGICA",
  "DBP", "ASPIRINA", "ENF_RENAL", "OBESIDAD", "PREMATURIDAD_MEN33SG",
  "PREMATURIDAD_33A36SG", "RN_TERMINO", "INMUNOCOMPROMETIDO_OTRAS_CAUSAS", "S_DOWN",
  "FUMADOR", "OTRAS_COMORBILIDADES", "SIN_COMORBILIDADES"
)

determinaciones_vars <- c(
  "VSR_PCR", "VSR_A_PCR", "VSR_B_PCR", "VSR_ANTIGENO", "INFLUENZA",
  "GENOMA_INFLUENZA_A_SIN_SUBTIPIFICAR", "INFLUENZA_A_H1N1", "INFLUENZA_A_H3N2",
  "GENOMA_VIRAL_DE_INFLUENZA_B_SIN_LINAJE", "INFLUENZA_B_VICTORIA", "INFLUENZA_B_YAMAGATA",
  "ANTIGENO_INFLUENZA_A_SIN_SUBTIPIFICAR", "ANTIGENO_INFLUENZA_B_SIN_LINAJE",
  "SARS_COV_2_PCR", "OVR"
)

# Generar objeto mapeado
# Reemplazar 9 por NA en las variables sintomáticas, comórbidas y de determinaciones
VR_NOMINAL_EVENTOCASO <- VR_NOMINAL_UCIRAG %>%
  mutate(
    GRUPO_ETARIO = EDAD_UC_IRAG,
    FECHA_CREADA = as.Date(FECHA_MINIMA),
    SEPI_CREADA = SEPI_FECHA_MINIMA,
    ANIO_EPI_APERTURA = ANIO_APERTURA,
    AÑO =ANIO_FECHA_MINIMA,
    EVENTO = "UCIRAG"
  ) %>%
  mutate(across(
    all_of(c(sintomas_vars, comorbilidades_vars, determinaciones_vars)),
    ~ na_if(as.numeric(.), 9)  # <- conversión explícita y robusta
  )) %>%
  rename_with(~ paste0("SINTOMA_", .x), all_of(sintomas_vars)) %>%
  rename_with(~ paste0("COMORB_", .x), all_of(comorbilidades_vars)) %>%
  rename_with(~ paste0("DETERMINACION_", .x), all_of(determinaciones_vars))

# 
# VR_NOMINAL_EVENTOCASO <-VR_NOMINAL_EVENTOCASO %>%
#   mutate(
#     FECHA_CONSULTA = convertir_a_fecha(FECHA_CONSULTA),
#     FIS = convertir_a_fecha(FIS),
#     FECHA_APERTURA = convertir_a_fecha(FECHA_APERTURA),
#     FECHA_ALTA_MEDICA = convertir_a_fecha(FECHA_ALTA_MEDICA),
#     FECHA_INTERNACION = convertir_a_fecha(FECHA_INTERNACION),
#     FECHA_CUI_INTENSIVOS = convertir_a_fecha(FECHA_CUI_INTENSIVOS),
#     FECHA_FALLECIMIENTO = convertir_a_fecha(FECHA_FALLECIMIENTO)
#     
#   )


niveles_ordenados <- c(
  "0 a 2 Meses",
  "3 a 5 Meses",
  "6 a 11 Meses",
  "12 a 23 Meses",
  "02 a 04 Años",
  "05 a 09 Años",
  "10 a 14 Años",
  "20 a 24 Años",
  "25 a 29 Años",
  "30 a 34 Años",
  "35 a 39 Años",
  "40 a 44 Años",
  "45 a 49 Años",
  "55 a 59 Años",
  "60 a 64 Años",
  "70 a 74 Años",
  "75 y más Años"
)

VR_NOMINAL_EVENTOCASO<- VR_NOMINAL_EVENTOCASO %>%
  mutate(GRUPO_ETARIO = factor(GRUPO_ETARIO, levels = niveles_ordenados, ordered = TRUE)) %>%
  arrange(GRUPO_ETARIO)
VR_NOMINAL_EVENTOCASO <-VR_NOMINAL_EVENTOCASO %>%
  mutate(
    FECHA_CONSULTA = ymd(FECHA_CONSULTA),
    FIS = ymd(FIS),
    FECHA_APERTURA = ymd(FECHA_APERTURA),
    FECHA_ALTA_MEDICA = ymd(FECHA_ALTA_MEDICA),
    FECHA_INTERNACION = ymd(FECHA_INTERNACION),
    FECHA_CUI_INTENSIVOS = ymd(FECHA_CUI_INTENSIVOS),
    FTM = ymd(FTM),
    FECHA_FALLECIMIENTO = ymd(FECHA_FALLECIMIENTO)

  )
