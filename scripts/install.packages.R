# Lista de paquetes necesarios
paquetes <- c(
  "tidyverse", "skimr", "janitor", "DataExplorer", "summarytools", 
  "dlookr", "lubridate", "anytime", "kableExtra", "data.table", 
  "pyramid", "viridisLite", "viridis", "ggthemes", "hrbrthemes", 
  "googlesheets4", "httpuv", "ggplot2", "tidyr", "flextable", "readxl","openxlsx",
  "highcharter","flextable","officer","sf","ows4R", "glue","ComplexUpset",
  "stringr", "quarto", "readxl","leaflet", "readr", "writexl","scales"
)

# Función para instalar y cargar paquetes
instalar_y_cargar <- function(paquete) {
  if (!requireNamespace(paquete, quietly = TRUE)) {
    install.packages(paquete, dependencies = TRUE)
  }
  library(paquete, character.only = TRUE)
}

# Aplicar la función a todos los paquetes
sapply(paquetes, instalar_y_cargar)

