
# Leer el Excel
provincias_df <- read_excel("templates/codigos_indec_provincias_argentina.xlsx")

provincias_df$codigo_indec <- as.numeric(provincias_df$codigo_indec)
# Buscar el nombre de la provincia correspondiente al código
nombre_provincia <- provincias_df$provincia[provincias_df$codigo_indec == PROVINCIA]


