
evaluar_determinaciones <- function(df, fecha_col) {
  # Identificar columnas que comienzan con 'DETERMINACION_'
  cols_determinacion <- grep("^DETERMINACION_", names(df), value = TRUE)
  
  # Crear o resetear la columna 'pendiente_de_revision'
  df[, pendiente_de_revision := 0]
  
  # Vector para almacenar los IDEVENTOCASO afectados antes de la modificación
  ids_algoritmo_aplicado <- c()
  
  # Iterar sobre las columnas de determinaciones
  for (col in cols_determinacion) {
    # Asegurar que la columna no tenga valores NA antes de aplicar grepl
    df[, (col) := as.character(get(col))]
    df[is.na(get(col)), (col) := ""]
    
    # Encontrar celdas con valores que contienen ';'
    condicion <- grepl(";", df[[col]], fixed = TRUE)
    
    # Guardar los IDEVENTOCASO afectados antes de la modificación
    ids_algoritmo_aplicado <- c(ids_algoritmo_aplicado, unique(df[condicion, IDEVENTOCASO]))
    
    # Aplicar condiciones para imputar valores
    df[condicion & !is.na(df[[fecha_col]]), (col) := "Detectable"]
    df[condicion & is.na(df[[fecha_col]]), (col) := paste0(.SD[[col]], ";Pendiente de revision"), .SDcols = col]
    
    # Marcar las filas con 'Pendiente de revision' en la nueva columna
    df[condicion & is.na(df[[fecha_col]]), pendiente_de_revision := 1]
  }
  
  # Guardar los IDEVENTOCASO afectados por la revisión pendiente
  ids_revision <- unique(df[pendiente_de_revision == 1, IDEVENTOCASO])
  
  return(list(df = df, ids_revision = ids_revision, ids_algoritmo_aplicado = unique(ids_algoritmo_aplicado)))
}


algoritmo_1 <- function(data, col_signos, col_comorbilidades, col_determinacion,
                                      col_resultado, col_tipo_lugar, col_antecedente, col_cobertura_social) {
  # Convertir el dataset a data.table para mejorar el rendimiento
  setDT(data)
  
  # Identificar los valores únicos en cada columna de comorbilidades y signos/síntomas
  unique_comorbilidades <- unique(na.omit(data[[col_comorbilidades]]))
  unique_signos <- unique(na.omit(data[[col_signos]]))
  
  # Crear columnas dicotómicas para cada comorbilidad
  for (comorbilidad in unique_comorbilidades) {
    nueva_col <- paste0("COMORB_", comorbilidad)
    data[, (nueva_col) := as.integer(get(col_comorbilidades) == comorbilidad)]
  }
  
  # Crear columnas dicotómicas para cada signo/síntoma
  for (signo in unique_signos) {
    nueva_col <- paste0("SINTOMA_", signo)
    data[, (nueva_col) := as.integer(get(col_signos) == signo)]
  }
  
  # Crear columnas para determinación y resultados
  unique_determinaciones <- unique(na.omit(data[[col_determinacion]]))
  
  for (determinacion in unique_determinaciones) {
    nueva_col <- paste0("DETERMINACION_", determinacion)
    data[, (nueva_col) := ifelse(get(col_determinacion) == determinacion, get(col_resultado), NA_character_)]
  }
  
  # Crear columnas para indicar ausencia de valores en determinaciones, signos/síntomas y comorbilidades
  data[, DETERMINACION_SIN_DATO := as.integer(!any(!is.na(.SD[[col_determinacion]]))), by = IDEVENTOCASO]
  data[, SINTOMA_SIN_DATO := as.integer(!any(!is.na(.SD[[col_signos]]))), by = IDEVENTOCASO]
  data[, COMORB_SIN_DATO := as.integer(!any(!is.na(.SD[[col_comorbilidades]]))), by = IDEVENTOCASO]
  
  
  
  # Verificar si 'IDEVENTOCASO' existe para agrupar y consolidar duplicados
  if ("IDEVENTOCASO" %in% names(data)) {
    # Obtener nombres de las columnas dicotómicas y de determinación
    dicotomic_cols <- grep("COMORB_|SINTOMA_", names(data), value = TRUE)
    determinacion_cols <- grep("DETERMINACION_", names(data), value = TRUE)
    
    # Consolidar dicotómicas sumando valores
    data <- data[, c(
      lapply(.SD[, ..dicotomic_cols, with = FALSE], sum, na.rm = TRUE),
      lapply(.SD[, ..determinacion_cols, with = FALSE], function(x) paste(na.omit(unique(x)), collapse = ";")),
      .(TIPO_LUGAR_OCURRENCIA = paste(na.omit(unique(.SD[[col_tipo_lugar]])), collapse = ";")),
      .(ANTECEDENTE_EPIDEMIOLOGICO = paste(na.omit(unique(.SD[[col_antecedente]])), collapse = ";")),
      .(COBERTURA_SOCIAL = paste(na.omit(unique(.SD[[col_cobertura_social]])), collapse = ";")),
      lapply(.SD[, !names(.SD) %in% c(dicotomic_cols, determinacion_cols, col_tipo_lugar, col_antecedente, col_cobertura_social), with = FALSE], function(x) x[1])
    ), by = IDEVENTOCASO]
    
    # Reemplazar valores mayores a 1 por 1 en las columnas dicotómicas
    data[, (dicotomic_cols) := lapply(.SD, function(x) pmin(x, 1, na.rm = TRUE)), .SDcols = dicotomic_cols]
  } else {
    warning("La columna 'IDEVENTOCASO' no está en los datos. Los duplicados no se consolidarán.")
  }
  
  # Aplicar la función evaluar_determinaciones y obtener los IDEVENTOCASO afectados
  resultado_evaluacion <- evaluar_determinaciones(data, "FECHA_ESTUDIO")
  data <- resultado_evaluacion$df
  ids_algoritmo_aplicado <- resultado_evaluacion$ids_algoritmo_aplicado
  ids_revision <- resultado_evaluacion$ids_revision
  
  
  # Guardar el mensaje en un objeto
  mensaje_revision <- paste(
    "Fue aplicado correctamente el algoritmo que transforma el dataset multiregistro para obtener un IDEVENTOCASO por fila (Ver documento xxx),\n",
    "Fueron corregidos (segun algoritmo detallado en la documentación) los ID que presentaban resultados diferentes para una misma determinacion. Estos IDs son:", 
    paste(ids_algoritmo_aplicado, collapse = ", "), "\n",
    "Aquellos IDs que no pudieron corregirse quedaron pendientes de revision:", 
    paste(ids_revision, collapse = ", ")
  )
  
  print(mensaje_revision)
  
  data <- data %>% dplyr::select(-DETERMINACION, -RESULTADO)
  
  return(list(data = data, 
              ids_revision = ids_revision, ids_algoritmo_aplicado = ids_algoritmo_aplicado, mensaje_revision = mensaje_revision
  ))
}


## Funcion para fecha

# Función para convertir a fecha solo si es necesario
# Función para convertir a fecha, detectando el formato
convertir_a_fecha <- function(columna) {
  if (inherits(columna, "Date")) {
    return(columna)  # Si ya es tipo Date, devolver como está
  }
  
  # Si no es Date, convertir
  columna <- as.character(columna)  # Asegurarse que sea character
  
  # Función interna para cada valor
  parsear_fecha <- function(x) {
    if (is.na(x) || x == "") {
      return(NA_Date_)  # Si es NA o vacío, devolver NA
    } else if (grepl("^\\d{4}-\\d{2}-\\d{2}$", x)) {
      # Formato ISO: Año-Mes-Día
      return(as.Date(x, format = "%Y-%m-%d"))
    } else if (grepl("^\\d{2}/\\d{2}/\\d{4}$", x)) {
      # Formato Día/Mes/Año
      return(as.Date(x, format = "%d/%m/%Y"))
    } else {
      warning(paste("Formato de fecha desconocido:", x))
      return(NA_Date_)  # Si no matchea ninguno, devuelve NA
    }
  }
  
  # Aplicar a toda la columna
  return(as.Date(sapply(columna, parsear_fecha), origin = "1970-01-01"))
}




procesar_edad <- function(dataset) {
  # Convertir fechas a formato Date si no lo están
  #dataset$FECHA_NACIMIENTO <- as.Date(dataset$FECHA_NACIMIENTO, format = "%Y-%d-%m")
  #dataset$FECHA_CREADA <- as.Date(dataset$FECHA_CREADA, format = "%d-%m-%Y")
  
  # Calcular edad en años para todos los casos, redondeando hacia abajo
  dataset$EDAD_ANOS <- as.numeric(difftime(dataset$FECHA_CREADA, dataset$FECHA_NACIMIENTO, units = "days")) %/% 365.25
  
  # Calcular edad inicial en años para identificar casos extremos
  dataset$EDAD <- dataset$EDAD_ANOS
  
  # Identificar casos extremos (edades negativas o mayores a 110)
  casos_extremos <- dataset$EDAD < 0 | dataset$EDAD > edad_max
  
  # Asignar NA a los valores extremos para revisión
  dataset$EDAD[casos_extremos] <- NA
  
  # Calcular edades en meses para menores de un año
  dataset$EDAD_MESES <- as.numeric(difftime(dataset$FECHA_CREADA, dataset$FECHA_NACIMIENTO, units = "days")) %/% 30.44
  
  # Crear variable UNIEDAD: 1 para meses, 2 para años
  dataset$UNIEDAD <- ifelse(dataset$EDAD_MESES < 12, 1, 2)
  
  # Ajustar EDAD para reflejar edades en meses si corresponde
  dataset$EDAD <- ifelse(dataset$UNIEDAD == 1, dataset$EDAD_MESES, dataset$EDAD)
  
  # Crear grupos etarios
  dataset$GRUPO_ETARIO2 <- dplyr::case_when(
    dataset$UNIEDAD == 1 & dataset$EDAD_MESES < 6 ~ "Menor de 6 meses",
    dataset$UNIEDAD == 1 & dataset$EDAD_MESES >= 6 & dataset$EDAD_MESES <=11 ~ "6 a 11 meses",
    dataset$UNIEDAD == 2 &  dataset$EDAD < 2 ~ "12 a 23 meses",
    dataset$UNIEDAD == 2 &  dataset$EDAD >= 2 & dataset$EDAD <= 4 ~ "2 a 4 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 5 & dataset$EDAD <= 9 ~ "5 a 9 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 10 & dataset$EDAD <= 14 ~ "10 a 14 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 15 & dataset$EDAD <= 19 ~ "15 a 19 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 20 & dataset$EDAD <= 24 ~ "20 a 24 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 25 & dataset$EDAD <= 29 ~ "25 a 29 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 30 & dataset$EDAD <= 34 ~ "30 a 34 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 35 & dataset$EDAD <= 39 ~ "35 a 39 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 40 & dataset$EDAD <= 44 ~ "40 a 44 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 45 & dataset$EDAD <= 49 ~ "45 a 49 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 50 & dataset$EDAD <= 54 ~ "50 a 54 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 55 & dataset$EDAD <= 59 ~ "55 a 59 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 60 & dataset$EDAD <= 64 ~ "60 a 64 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 65 & dataset$EDAD <= 69 ~ "65 a 69 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 70 & dataset$EDAD <= 74 ~ "70 a 74 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 75 & dataset$EDAD <= edad_max ~ "75 años y más",
    TRUE ~ "Sin Especificar"
  ) 
  
  dataset$GRUPO_ETARIO2 = factor(dataset$GRUPO_ETARIO2, levels = c(
    "Menor de 6 meses",
    "6 a 11 meses",
    "12 a 23 meses",
    "2 a 4 años",
    "5 a 9 años",
    "10 a 14 años",
    "15 a 19 años",
    "20 a 24 años",
    "25 a 29 años",
    "30 a 34 años",
    "35 a 39 años",
    "40 a 44 años",
    "45 a 49 años",
    "50 a 54 años",
    "55 a 59 años",
    "60 a 64 años",
    "65 a 69 años",
    "70 a 74 años",
    "75 años y más",
    "Sin Especificar"
    
  ))
  
  dataset$GRUPO_ETARIO3 <- dplyr::case_when(
    dataset$UNIEDAD == 1 & dataset$EDAD_MESES < 6 ~ "Menor de 6 meses",
    dataset$UNIEDAD == 1 & dataset$EDAD_MESES >= 6 & dataset$EDAD_MESES <= 11 ~ "De 6 a 11 meses",
    dataset$UNIEDAD == 2 & dataset$EDAD < 2 ~ "1 año",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 2 & dataset$EDAD <= 9 ~ "De 2 a 9 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 10 & dataset$EDAD <= 19 ~ "De 10 a 19 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 20 & dataset$EDAD <= 39 ~ "De 20 a 39 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 40 & dataset$EDAD <= 59 ~ "De 40 a 59 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 60 & dataset$EDAD <= 79 ~ "De 60 a 79 años",
    dataset$UNIEDAD == 2 & dataset$EDAD >= 80 ~ "80 años o más"
  )
  
  dataset$GRUPO_ETARIO3 <- factor(dataset$GRUPO_ETARIO3, levels = c(
    "Menor de 6 meses",
    "De 6 a 11 meses",
    "1 año",
    "De 2 a 9 años",
    "De 10 a 19 años",
    "De 20 a 39 años",
    "De 40 a 59 años",
    "De 60 a 79 años",
    "80 años o más"
  )
  
  )
  
  # Eliminar la variable auxiliar EDAD_MESES
  #dataset$EDAD_MESES <- NULL
  
  # Crear una tabla auxiliar para calcular diff
  dataset <- dataset %>% 
    mutate(diff = EDAD_ANOS - EDAD_APERTURA)
  
  # Crear el objeto mensaje_3 con los IDEVENTOCASO donde diff > 1 o diff < -1
  mensaje <- paste0(
    "ID de Casos que presentan mas de 1 año de difencia entre edad geenrada por el sistema y la edad codificada en el algoritmo.Para mas info ver XXX",
    paste(dataset$IDEVENTOCASO[(dataset$diff > 1 | dataset$diff < -1)& !is.na(dataset$IDEVENTOCASO)], collapse = ", ")
  )
  
  mensaje2 <- paste0("ID de registros con edades por fuera del rango Especificado (0-",edad_max,"). IDEVENTOCASO:",dataset$IDEVENTOCASO[casos_extremos])
  # Retornar el dataset procesado y el mensaje
  list(dataset = dataset, mensaje4 = mensaje, mensaje5 = mensaje2)
}

analizar_determinaciones <- function(data, 
                                     columnas_determinacion,
                                     variable_agrupar,
                                     variable_cruce = NULL,
                                     clasificar = NULL) {
  
  data_largo <- data %>%
    pivot_longer(cols = all_of(columnas_determinacion), 
                 names_to = "Tipo_Determinacion", 
                 values_to = "Resultado")
  
  # Agrupar determinaciones usando la función que define la categoría
  data_largo <- data_largo %>%
    mutate(DETERMINACION = if (!is.null(clasificar)) clasificar(Tipo_Determinacion) else Tipo_Determinacion)
  
  
  
  
  # Definir agrupadores
  agrupadores <- c(variable_agrupar, if (!is.null(variable_cruce)) variable_cruce, "DETERMINACION")
  
  # Agrupar y contar
  conteo <- data_largo %>%
    group_by(across(all_of(agrupadores))) %>%
    summarise(
      Detectable = sum(str_to_lower(Resultado) %in% c("detectable", "positivo"), na.rm = TRUE),
      No_detectable = sum(str_to_lower(Resultado) %in% c("no detectable", "negativo"), na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(Total_testeos = Detectable + No_detectable)
  
  return(conteo)
}
