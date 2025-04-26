# Primero verificar si el objeto ruta_datos_servicios existe
if (exists("ruta_datos_servicios")) {
  
  # Segundo verificar si el archivo en esa ruta existe
  if (file.exists(ruta_datos_servicios)) {
    
    datos_servicios <- readxl::read_excel(ruta_datos_servicios)
    
    if (nrow(datos_servicios) >= 2) {
      
      # 🛠️ Tu script se ejecuta normalmente:
      
      # Paso 1: Procesamiento de datos y conteo de casos
      datos_servicios <- datos_servicios %>%
        mutate(
          FECHA_INGRESO = as.Date(as.numeric(FECHA_INGRESO), origin = "1899-12-30")
        )
      
      df_sum <- datos_servicios %>%
        mutate(
          FECHA_INGRESO = as.Date(FECHA_INGRESO),
          ANIO = isoyear(FECHA_INGRESO),
          SEMANA = sprintf("%02d", SE),
          SEPI_SEMANA = paste0(ANIO, "-SE ", SEMANA),
          IRAG = tolower(IRAG),
          IRAG_E = tolower(IRAG_E),
          SERVICIO_INGRESO = toupper(SERVICIO_INGRESO),
          cuenta = ifelse(IRAG == "si" | IRAG_E == "si", 1, 0)
        ) %>%
        dplyr::filter(cuenta == 1) %>%
        group_by(SEPI_SEMANA, ANIO, SEMANA, SERVICIO_INGRESO) %>%
        summarise(casos = sum(cuenta), .groups = "drop")
      
      # Paso 2: Crear grilla completa entre semana mínima y máxima por año
      rango_semanas <- df_sum %>%
        group_by(ANIO) %>%
        summarise(
          semana_min = min(as.integer(SEMANA)),
          semana_max = max(as.integer(SEMANA)),
          .groups = "drop"
        )
      
      grilla_completa <- rango_semanas %>%
        rowwise() %>%
        mutate(
          semanas = list(sprintf("%02d", semana_min:semana_max))
        ) %>%
        unnest(semanas) %>%
        rename(SEMANA = semanas) %>%
        select(ANIO, SEMANA) %>%
        distinct() %>%
        crossing(SERVICIO_INGRESO = unique(df_sum$SERVICIO_INGRESO)) %>%
        mutate(SEPI_SEMANA = paste0(ANIO, "-SE ", SEMANA))
      
      # Paso 3: Completar datos y ordenar
      df_sum_completo <- grilla_completa %>%
        left_join(df_sum, by = c("SEPI_SEMANA", "ANIO", "SEMANA", "SERVICIO_INGRESO")) %>%
        mutate(casos = replace_na(casos, 0)) %>%
        arrange(ANIO, SEMANA, SERVICIO_INGRESO)
      
      cat("✅ Datos de servicios procesados correctamente.\n")
      
    } else {
      cat("⚠️ El archivo de servicios existe pero tiene menos de 2 filas. No se ejecuta el procesamiento.\n")
    }
    
  } else {
    cat("❌ El archivo de datos de servicios no existe. No se incluye en el análisis.\n")
  }
  
} else {
  cat("❌ El objeto `ruta_datos_servicios` no está definido. No se ejecuta el procesamiento.\n")
}
