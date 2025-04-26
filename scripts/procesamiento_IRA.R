


mensaje1 <-  paste0("La provincia seleccionada para este análisis es:  ", PROVINCIA)


# APLICO FILTROS Y TRANSFORMO VARIABLES
VR_NOMINAL <- VR_NOMINAL %>%
  dplyr::filter(ID_PROV_INDEC_RESIDENCIA == PROVINCIA)

if (filtro_depto_o_estab == "DEPARTAMENTO") {
  VR_NOMINAL <- VR_NOMINAL %>%
    dplyr::filter(ID_DEPTO_INDEC_RESIDENCIA %in% DEPTOS_ANALISIS)
  mensaje2 <- paste0("Los deptos. incluidos en este análisis fueron: ", paste(DEPTOS_ANALISIS, collapse = ", "))
} else if (filtro_depto_o_estab == "ESTABLECIMIENTO") {
  VR_NOMINAL <- VR_NOMINAL %>%
    dplyr::filter(ESTABLECIMIENTO_CARGA %in% EFECTOR_CARGA)
  mensaje2 <- paste0("Los efectores incluidos en este análisis fueron: ", paste(EFECTOR_CARGA, collapse = ", "))
} else {
  stop("El valor de 'filtro_depto_o_estab' debe ser 'DEPARTAMENTO' o 'ESTABLECIMIENTO'")
}


# TRANSFORMACIÓN DE VARIABLES
VR_NOMINAL <- VR_NOMINAL %>%
  mutate(
    SEXO = factor(SEXO),
    DEPARTAMENTO_RESIDENCIA = factor(DEPARTAMENTO_RESIDENCIA),
    CLASIFICACION_MANUAL = factor(CLASIFICACION_MANUAL),
    EVENTO = factor(EVENTO),
    GRUPO_ETARIO = factor(GRUPO_ETARIO)
  )

                                     

#asigno area programa
# Asignación de AREA PROGRAMA (cuando corresponda)

if (area_progama_depto_localidad == "LOCALIDAD") {
  
  df_mapeo_localidad_region <- readxl::read_excel(ruta_excel_area) %>%
    mutate(
      LOCALIDAD_RESIDENCIA = toupper(`LOCALIDAD DE RESIDENCIA / DEPARTAMENTO DE RESIDENCIA`),
      AREA_PROGRAMA = toupper(`AREA PROGRAMA`)
    )
  
  VR_NOMINAL <- VR_NOMINAL %>%
    mutate(LOCALIDAD_RESIDENCIA = toupper(LOCALIDAD_RESIDENCIA))
  
  # Mapeo por LOCALIDAD
  VR_NOMINAL <- VR_NOMINAL %>%
    left_join(df_mapeo_localidad_region, by = "LOCALIDAD_RESIDENCIA")
  
  no_encontrados <- VR_NOMINAL %>%
    anti_join(df_mapeo_localidad_region, by = "LOCALIDAD_RESIDENCIA")
  
  mensaje3 <- paste(
    "Localidades no encontradas para asignar un Área Programa:",
    paste(unique(no_encontrados$LOCALIDAD_RESIDENCIA), collapse = ", ")
  )
  
  registros_sin_localidad <- VR_NOMINAL %>%
    dplyr::filter(is.na(LOCALIDAD_RESIDENCIA)) %>%
    select(IDEVENTOCASO, DEPARTAMENTO_RESIDENCIA, ID_DEPTO_INDEC_RESIDENCIA) %>%
    unique()
  
  mensaje4 <- paste(
    "IDEVENTOCASO de registros sin dato de Localidad de Residencia. Se lista ID - nombre Depto (ID depto):\n",
    paste0(
      "ID: ", registros_sin_localidad$IDEVENTOCASO, " - ",
      registros_sin_localidad$DEPARTAMENTO_RESIDENCIA,
      " (", registros_sin_localidad$ID_DEPTO_INDEC_RESIDENCIA, ")"
    ),
    collapse = "\n"
  )
  
} else if (area_progama_depto_localidad == "DEPARTAMENTO") {
  
  df_mapeo_localidad_region <- readxl::read_excel(ruta_excel_area) %>%
    rename(DEPARTAMENTO_RESIDENCIA = `LOCALIDAD DE RESIDENCIA / DEPARTAMENTO DE RESIDENCIA`,
           AREA_PROGRAMA = `AREA PROGRAMA`) %>%
    mutate(DEPARTAMENTO_RESIDENCIA = toupper(DEPARTAMENTO_RESIDENCIA),
           AREA_PROGRAMA = toupper(AREA_PROGRAMA))
  
  # Convertir a mayúsculas
  VR_NOMINAL <- VR_NOMINAL %>%
    mutate(DEPARTAMENTO_RESIDENCIA = toupper(DEPARTAMENTO_RESIDENCIA))
  
  
  # Renombrar columnas del Excel
  # df_mapeo_localidad_region <- df_mapeo_localidad_region %>%
  #   select(-AREA_PROGRAMA) %>%
  #   rename(DEPARTAMENTO_RESIDENCIA = `LOCALIDAD DE RESIDENCIA / DEPARTAMENTO DE RESIDENCIA`,
  #          AREA_PROGRAMA = `AREA PROGRAMA`)
  
  # Unir por departamento
  VR_NOMINAL <- VR_NOMINAL %>%
    left_join(df_mapeo_localidad_region, by = "DEPARTAMENTO_RESIDENCIA")
  
  # Departamentos no encontrados
  no_encontrados <- VR_NOMINAL %>%
    dplyr::filter(is.na(AREA_PROGRAMA)) %>%
    select(DEPARTAMENTO_RESIDENCIA) %>%
    distinct()
  
  mensaje3 <- paste(
    "Departamentos no encontrados para asignar un Área Programa:",
    paste(unique(no_encontrados$DEPARTAMENTO_RESIDENCIA), collapse = ", ")
  )
  
  # Registros con NA en departamento
  registros_sin_departamento <- VR_NOMINAL %>%
    dplyr::filter(is.na(DEPARTAMENTO_RESIDENCIA)) %>%
    select(IDEVENTOCASO, DEPARTAMENTO_RESIDENCIA) %>%
    unique()
  
  mensaje4 <- paste(
    "IDEVENTOCASO de registros sin dato de Departamento de Residencia. Se lista ID - Localidad:\n",
    paste0(
      apply(registros_sin_departamento, 1, function(x) {
        paste0("ID: ", x["IDEVENTOCASO"], " - ", x["DEPARTAMENTO_RESIDENCIA"])
      }),
      collapse = "\n"
    )
  )
  
} else {
  stop("El valor de 'area_progama_depto_localidad' debe ser 'LOCALIDAD' o 'DEPARTAMENTO'")
}

# Aplicar la conversión a fecha solo si es necesario
VR_NOMINAL <- VR_NOMINAL %>%
  mutate(
    FECHA_CONSULTA = convertir_a_fecha(FECHA_CONSULTA),
    FIS = convertir_a_fecha(FIS),
    FECHA_APERTURA = convertir_a_fecha(FECHA_APERTURA),
    FECHA_ALTA_MEDICA = convertir_a_fecha(FECHA_ALTA_MEDICA),
    FECHA_INTERNACION = convertir_a_fecha(FECHA_INTERNACION),
    FECHA_CUI_INTENSIVOS = convertir_a_fecha(FECHA_CUI_INTENSIVOS),
    FECHA_FALLECIMIENTO = convertir_a_fecha(FECHA_FALLECIMIENTO),
    FECHA_NACIMIENTO = convertir_a_fecha(FECHA_NACIMIENTO),
    FECHA_ESTUDIO = convertir_a_fecha(FECHA_ESTUDIO)
  )


###creo una nueva variable de fecha 

VR_NOMINAL <- VR_NOMINAL %>% 
  mutate(FECHA_CREADA = coalesce(FIS, FECHA_CONSULTA, FECHA_ESTUDIO, FECHA_APERTURA),
         AÑO= year(FECHA_CREADA),
         SEPI_CREADA= epiweek(FECHA_CREADA))


resultado_algoritmo_1 <- algoritmo_1(data=VR_NOMINAL,
                                     col_signos = "SIGNO_SINTOMA",
                                     col_comorbilidades = "COMORBILIDAD",
                                     col_determinacion= "DETERMINACION", 
                                     col_resultado= "RESULTADO",
                                     col_tipo_lugar =  "TIPO_LUGAR_OCURRENCIA",
                                     col_antecedente = "ANTECEDENTE_EPIDEMIOLOGICO",
                                     col_cobertura_social = "COBERTURA_SOCIAL"
                                     )

VR_NOMINAL_EVENTOCASO <-resultado_algoritmo_1$data

table(VR_NOMINAL_EVENTOCASO$EVENTO)
mensaje5 <- resultado_algoritmo_1$mensaje_revision


## APLICO FUNCION PARA PROCESAR EDAD
VR_NOMINAL_EVENTOCASO_RESULTADO <- procesar_edad(VR_NOMINAL_EVENTOCASO)
VR_NOMINAL_EVENTOCASO <-VR_NOMINAL_EVENTOCASO_RESULTADO$dataset

VR_NOMINAL_EVENTOCASO$UNIEDAD
VER <-  VR_NOMINAL_EVENTOCASO[is.na(VR_NOMINAL_EVENTOCASO$GRUPO_ETARIO2),
                              c("GRUPO_ETARIO","UNIEDAD","EDAD_MESES","EDAD","EDAD_APERTURA")]
  

mensaje6 <- VR_NOMINAL_EVENTOCASO_RESULTADO$mensaje4
mensaje7 <- VR_NOMINAL_EVENTOCASO_RESULTADO$mensaje5


VR_NOMINAL_EVENTOCASO <- VR_NOMINAL_EVENTOCASO %>%
  mutate(
    DETERMINACION_DICO = case_when(
      DETERMINACION_SIN_DATO == 1 ~ "99",  # Si DETERMINACION_NINGUNA es 1, asignar 99
      rowSums(across(starts_with("DETERMINACION_"), 
                     ~  str_to_lower(.) %in% c("positivo", "detectable"))) > 0 ~ "1",  # Si hay al menos un Positivo o Detectable, asignar 1
      rowSums(across(starts_with("DETERMINACION_"), 
                     ~ str_to_lower(.) %in% c("negativo", "no detectable"))) > 0 ~ "0",  # Si solo hay Negativo o No detectable, asignar 0
      TRUE ~ "99"  # Si no hay información, asignar NA
    )
  )

## centinela ----------

# Verificamos qué columnas de 'columnas_centinela' existen en el dataframe

columnas_prefijadas <- paste0("DETERMINACION_", determinacion_UCIRAG)
columnas_existentes <- columnas_prefijadas [columnas_prefijadas %in% colnames(VR_NOMINAL_EVENTOCASO)]
columnas_faltantes <- setdiff(columnas_prefijadas , columnas_existentes)

# Paso 2: Generamos el mensaje con las columnas faltantes
# Quitar prefijo para mostrar nombres limpios
det_incluidas <- gsub("^DETERMINACION_", "", columnas_existentes)
det_excluidas <- gsub("^DETERMINACION_", "", columnas_faltantes)

# Convertir a listado entre comillas
det_incluidas_listado <- paste0('"', det_incluidas, '"', collapse = "\n")
det_excluidas_listado <- paste0('"', det_excluidas, '"', collapse = ", ")

if (length(columnas_faltantes) > 0) {
  mensaje8 <- paste0(
    "Las siguientes determinaciones incluidas para Estrategia Centinela no existen en el dataframe y fueron omitidas.\n",
    "Es importante revisar que no existan errores de tipeo:\n",
    paste(det_excluidas_listado, collapse = ", "), "\n\n",
    "Determinaciones incluidas utilizadas en el análisis:\n",
    paste(det_incluidas_listado, collapse = ", ")
  )
} else {
  mensaje8 <- paste0(
    "Todas las determinaciones incluidas para Estrategia de vigilancia Centinela existen en la base de datos original.\n\n",
    "Determinaciones incluidas para Estrategia de vigilancia Centinela y utilizadas en este análisis:\n",
    paste(det_incluidas_listado, collapse = ", ")
  )
}


# Paso 3: Aplicamos el mutate solo con las columnas existentes
VR_NOMINAL_EVENTOCASO <- VR_NOMINAL_EVENTOCASO %>%
  mutate(
    DETERMINACION_DICO_centinela = case_when(
      DETERMINACION_SIN_DATO == 1 ~ "99",
      length(columnas_existentes) > 0 &
        rowSums(across(all_of(columnas_existentes),
                       ~ str_to_lower(.) %in% c("positivo", "detectable"))) > 0 ~ "1",
      length(columnas_existentes) > 0 &
        rowSums(across(all_of(columnas_existentes),
                       ~ str_to_lower(.) %in% c("negativo", "no detectable"))) > 0 ~ "0",
      TRUE ~ "99"
    )
  )

# aCA DEFINIR QUE OTRAS DETERMINACION AGRUPADAS HAY: POR EJEMPLO INFLUENZA a, COVID. aRMARLAS D ELA MISMA FORMA



VR_NOMINAL_EVENTOCASO$DETERMINACION_SIN_DATO <- as.character(VR_NOMINAL_EVENTOCASO$DETERMINACION_SIN_DATO)



# Obtener la fecha de GRUPO_ETARIO3# Obtener la fecha de hoy en formato YYYY-MM-DD
fecha_hoy <- Sys.Date()
nombre_archivo <- paste0("salidas/VR_NOMINAL_EVENTOCASO_generado_el_", fecha_hoy, ".xlsx")

# Guardar el archivo
write_xlsx(VR_NOMINAL_EVENTOCASO, nombre_archivo)
VR_NOMINAL_EVENTOCASO$GRUPO_ETARIO <- VR_NOMINAL_EVENTOCASO$GRUPO_ETARIO2## aca elegir con que grupo etario graficar

source("scripts/output_file_consideraciones.R")


