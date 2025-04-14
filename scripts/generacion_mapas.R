
descargar_departamentos_por_in1_prefijo <- function(prefijo = "58") {
  base_url <- "https://wms.ign.gob.ar/geoserver/ign/ows?"
  type_name <- "ign:departamento"
  
  # Armar CQL con prefijo
  cql <- paste0("in1 LIKE '", prefijo, "%'")
  
  # Construir URL
  url <- paste0(
    base_url,
    "service=WFS&version=1.1.0&request=GetFeature&",
    "typeName=", type_name,
    "&outputFormat=application/json&",
    "CQL_FILTER=", URLencode(cql)
  )
  
  # Descargar
  st_read(url, quiet = TRUE)
}

PROVINCIA <- as.character(PROVINCIA)

# Departamentos de provincia con códigos que comienzan en 58
DEPTOS_dataframe <- descargar_departamentos_por_in1_prefijo(PROVINCIA)

plot(DEPTOS_dataframe$id)

head(DEPTOS_dataframe)
