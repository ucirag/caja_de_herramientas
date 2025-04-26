
# Separar coordenadas en latitud y longitud
LISTADO_EFECTORES <- LISTADO_EFECTORES %>%
  mutate(
    lat = as.numeric(sub(",.*", "", Coordenadas)),
    lon = as.numeric(sub(".*,", "", Coordenadas))
  )

# Crear mapa base
mapa_efectores <- leaflet() %>%
  addTiles() %>% 
  addProviderTiles(providers$CartoDB.Positron)

# Agregar hospitales (azules)
mapa_efectores <- mapa_efectores %>%
  addCircleMarkers(
    data = LISTADO_EFECTORES %>% dplyr::filter(`tipo de establecimiento` == "HOSPITAL"),
    ~lon, ~lat,
    popup = ~paste0("<b>Nombre:</b> ", Nombre, "<br>",
                    "<b>Código SISA:</b> ", `Código SISA EFECTOR`, "<br>",
                    "<b>Nivel Complejidad:</b> ", `NIVEL COMPL`, "<br>",
                    "<b>Zona Sanitaria:</b> ", `zona sanitaria`, "<br>",
                    "<b>Localidad:</b> ", LOCALIDAD, "<br>",
                    "<b>Tipo de Establecimiento:</b> ", `tipo de establecimiento`, "<br>",
                    "<b>Estrategia:</b> ", Estrategia),
    color = "blue",
    radius = 5,
    fillOpacity = 0.7
  )

# Agregar laboratorios (verdes y más pequeños)
mapa_efectores <- mapa_efectores %>%
  addCircleMarkers(
    data = LISTADO_EFECTORES %>% dplyr::filter(`tipo de establecimiento` == "LABORATORIO"),
    ~lon, ~lat,
    popup = ~paste0("<b>Nombre:</b> ", Nombre, "<br>",
                    "<b>Código SISA:</b> ", `Código SISA EFECTOR`, "<br>",
                    "<b>Nivel Complejidad:</b> ", `NIVEL COMPL`, "<br>",
                    "<b>Zona Sanitaria:</b> ", `zona sanitaria`, "<br>",
                    "<b>Localidad:</b> ", LOCALIDAD, "<br>",
                    "<b>Tipo de Establecimiento:</b> ", `tipo de establecimiento`, "<br>",
                    "<b>Estrategia:</b> ", Estrategia),
    color = "#04cc97",
    radius = 3,  # Más pequeño
    fillOpacity = 1
  )

# Agregar otros establecimientos (naranja y gris)
mapa_efectores <- mapa_efectores %>%
  addCircleMarkers(
    data = LISTADO_EFECTORES %>% dplyr::filter(!`tipo de establecimiento` %in% c("HOSPITAL", "LABORATORIO")),
    ~lon, ~lat,
    popup = ~paste0("<b>Nombre:</b> ", Nombre, "<br>",
                    "<b>Código SISA:</b> ", `Código SISA EFECTOR`, "<br>",
                    "<b>Nivel Complejidad:</b> ", `NIVEL COMPL`, "<br>",
                    "<b>Zona Sanitaria:</b> ", `zona sanitaria`, "<br>",
                    "<b>Localidad:</b> ", LOCALIDAD, "<br>",
                    "<b>Tipo de Establecimiento:</b> ", `tipo de establecimiento`, "<br>",
                    "<b>Estrategia:</b> ", Estrategia),
    color = ~case_when(
      `tipo de establecimiento` == "CENTRO DE SALUD RURAL" ~ "orange",
      TRUE ~ "gray"
    ),
    radius = 5,
    fillOpacity = 0.7
  )

# Agregar los establecimientos centinela (cruces rojas)
mapa_efectores <- mapa_efectores %>%
  addAwesomeMarkers(
    data = LISTADO_EFECTORES %>% dplyr::filter(Estrategia == "CENTINELA"),
    ~lon, ~lat,
    popup = ~paste0("<b>Nombre:</b> ", Nombre, "<br>",
                    "<b>Código SISA:</b> ", `Código SISA EFECTOR`, "<br>",
                    "<b>Nivel Complejidad:</b> ", `NIVEL COMPL`, "<br>",
                    "<b>Zona Sanitaria:</b> ", `zona sanitaria`, "<br>",
                    "<b>Localidad:</b> ", LOCALIDAD, "<br>",
                    "<b>Tipo de Establecimiento:</b> ", `tipo de establecimiento`, "<br>",
                    "<b>Estrategia:</b> ", Estrategia),
    icon = awesomeIcons(
      icon = "plus",
      library = "fa",
      markerColor = "red"
    )
  )

# Agregar leyenda
# mapa_efectores <- mapa_efectores %>%
#   addLegend(
#     position = "bottomright",
#     colors = c("blue", "orange", "green", "gray"),
#     labels = c("Hospital", "Centro de Salud Rural", "Laboratorio", "Otro"),
#     title = "Tipos de Establecimientos",
#     opacity = 1
#   )

# Leyenda personalizada con HTML
# Leyenda personalizada con HTML y cruz negra
custom_legend <- htmltools::HTML('
<div style="background:white; padding: 10px; border-radius: 5px; box-shadow: 2px 2px 6px rgba(0,0,0,0.3); font-size: 14px;">
  <b>Tipos de Establecimientos</b><br>
  <i style="background:blue; width: 12px; height: 12px; display:inline-block; border-radius:50%; margin-right:6px;"></i> Hospital<br>
  <i style="background:orange; width: 12px; height: 12px; display:inline-block; border-radius:50%; margin-right:6px;"></i> Centro de Salud Rural<br>
  <i style="background:#04cc97; width: 12px; height: 12px; display:inline-block; border-radius:50%; margin-right:6px;"></i> Laboratorio<br>
  <i style="background:gray; width: 12px; height: 12px; display:inline-block; border-radius:50%; margin-right:6px;"></i> Otro<br>
  <i class="fa fa-plus" style="color:black; background:#cc0415; border-radius: 50%; padding: 2px 5px; margin-right:6px;"></i> Unidad Centinela de IRAG
</div>
')

mapa_efectores <- mapa_efectores %>%
  addControl(custom_legend, position = "bottomright")

