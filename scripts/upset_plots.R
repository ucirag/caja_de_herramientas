
# ========================
# 🔹 Análisis de síntomas
# ========================

# Filtrar casos positivos
positivos <- IRA_UCI %>% filter(DETERMINACION_DICO_centinela == 1)

# Seleccionar variables de síntomas y renombrar sin prefijo
datos_sintomas <- positivos %>%
  select(starts_with("SINTOMA_")) %>%
  rename_with(~ str_remove(.x, "^SINTOMA_")) %>%
  mutate(ID = row_number()) %>%
  relocate(ID)

# Filtrar columnas que tienen al menos una presencia
datos_sintomas_filtrados <- datos_sintomas %>%
  select(ID, where(~ any(. == 1, na.rm = TRUE)))

# Identificar síntomas por combinación (para agrupar luego por colores)
datos_sintomas_filtrados$combo_id <- apply(
  datos_sintomas_filtrados[,-1],
  1,
  function(row) paste(names(row)[row == 1], collapse = "&")
)

# Crear tabla con el color de cada combinación
tabla_colores <- datos_sintomas_filtrados %>%
  distinct(combo_id) %>%
  mutate(
    grupo_color = ifelse(
      str_detect(combo_id, "SIN_DATO"),
      "Sin dato",
      "Con dato de signo/síntoma"
    )
  )

# Unir color al dataset original
datos_sintomas_coloreado <- datos_sintomas_filtrados %>%
  left_join(tabla_colores, by = "combo_id")

# Nombres de los síntomas
vars_sintomas <- colnames(datos_sintomas_filtrados)[-1]

# Graficar UpSet de síntomas con colores

signos_upset <- upset(
  datos_sintomas_coloreado,
  intersect = vars_sintomas,
  name = "Signos y Síntomas",
  
  base_annotations = list(
    'Intersecciones' = intersection_size(
      mapping = aes(fill = grupo_color, col = "black"),
      text = list(size = 7)
    ) +
      scale_fill_manual(values = c(
        "Sin dato" = "blue",
        "Con dato de signo/síntoma" = "#87CEEB"
      )) +
      theme(
        legend.position = "top",
        legend.title = element_blank(),
        legend.text = element_text(size = 18) 
        
      )
  ),
  
  themes = upset_modify_themes(
    list(
      'intersections_matrix' = theme(
        axis.text.y = element_text(size = 18),
        axis.title.x = element_text(size=)
      ),
      'overall_sizes' = theme(
        axis.text.x = element_text(angle = 90, size=14)
      )
    )
  )
)


# ==========================
# 🔹 Análisis de comorbilidades
# ==========================

# Preparar dataset de comorbilidades
datos_comorb <- positivos %>%
  select(starts_with("COMORB_")) %>%
  rename_with(~ str_remove(.x, "^COMORB_")) %>%
  mutate(ID = row_number()) %>%
  relocate(ID)

# Filtrar columnas con al menos un caso presente
datos_comorb_filtrados <- datos_comorb %>%
  select(ID, where(~ any(. == 1, na.rm = TRUE)))

# Identificar combinaciones por fila
datos_comorb_filtrados$combo_id <- apply(
  datos_comorb_filtrados[,-1],
  1,
  function(row) paste(names(row)[row == 1], collapse = "&")
)

# Categorizar por tipo de combinación
tabla_colores_comorb <- datos_comorb_filtrados %>%
  distinct(combo_id) %>%
  mutate(
    grupo_color = case_when(
      combo_id == "Sin comorbilidades" ~ "Sin comorbilidades",
      str_detect(combo_id, "SIN_DATO") ~ "Sin dato de comorbilidad",
      TRUE ~ "Con dato de comorbilidad"
    )
  )

# Unir color al dataset original
datos_comorb_coloreado <- datos_comorb_filtrados %>%
  left_join(tabla_colores_comorb, by = "combo_id")

# Nombres de comorbilidades
vars_comorb <- colnames(datos_comorb_filtrados)[-c(1, ncol(datos_comorb_filtrados))]

# Graficar UpSet de comorbilidades
comorb_upset <- upset(
  datos_comorb_coloreado,
  intersect = vars_comorb,
  name = "Comorbilidades",
  
  base_annotations = list(
    'Intersecciones' = intersection_size(
      mapping = aes(fill = grupo_color, col = "black"),
      text = list(size = 7)  # igual que en signos_upset
    ) +
      scale_fill_manual(values = c(
        "Sin comorbilidades" = "#4682B4",
        "Sin dato de comorbilidad" = "blue",
        "Con dato de comorbilidad" = "#87CEEB"
      )) +
      theme(
        legend.position = "top",
        legend.title = element_blank(),
        legend.text = element_text(size = 18)  # igual que en signos_upset
      )
  ),
  
  themes = upset_modify_themes(
    list(
      'intersections_matrix' = theme(
        axis.text.y = element_text(size = 18),
        axis.title.x = element_text(size = 13)  # completamos el valor que faltaba
      ),
      'overall_sizes' = theme(
        axis.text.x = element_text(angle = 90, size = 14)
      )
    )
  )
)
