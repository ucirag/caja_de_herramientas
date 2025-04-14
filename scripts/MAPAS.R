library(sf)
library(tidyverse)
library(readxl)
library(DT)
library(classInt)  # Para calcular los Natural Breaks en mapas
library(scales)
library(RColorBrewer)
library(leaflet)
library(htmltools)
library(ggspatial)
library(prettymapr)

options(scipen = 999)

# Leer el archivo SHP localmente
departamentos <- read_sf("capa_deptos.shp")
regiones <- read_sf("capa_region.shp")
# Visualizar los primeros registros del shapefile
head(departamentos)
head(regiones)
# Ver el CRS de cada objeto
st_crs(departamentos)
# Ver el CRS de cada objeto
st_crs(departamentos)
#Veamos que variables tiene mi dataset
#plot(regiones)
#plot(departamentos)

####AMBULATORIOS####
#leo mi dataset con casos positivos por departamento

#leo mi dataset con casos positivos por departamento

CONTEO_AMBULATORIOS_localidad_mapa <- read.csv("C:/Users/Salud/Documents/ZONA II/Boletin ZSII/Unidad-Centinela/CONTEO_AMBULATORIOS_localidad.csv")



tabla1 <- CONTEO_AMBULATORIOS_localidad_mapa %>% mutate(
    DEPARTAMENTO_match = case_when(
      `LOCALIDAD_RESIDENCIA` == "ZAPALA" ~ "Zapala",
      `LOCALIDAD_RESIDENCIA` == "MARIANO MORENO" ~ "Zapala",
      `LOCALIDAD_RESIDENCIA` == "LAS COLORADAS" ~ "Catán Lil",
      `LOCALIDAD_RESIDENCIA` == "ALUMINE" ~ "Aluminé",
      `LOCALIDAD_RESIDENCIA` == "LAS LAJAS" ~ "Picunches"  ))
  


#Union de datasets
casos_ambulatorios_mapa <- departamentos %>%
  left_join(tabla1, by = c( "nombre"="DEPARTAMENTO_match"))

DT::datatable(casos_ambulatorios_mapa)


# Calcular los cortes utilizando quantiles
breaks <- classInt::classIntervals(casos_ambulatorios_mapa$`n`, n = 3, style = "quantile",cutlabels=F)$brks

breaks

# Crear las categorías basadas en los Natural Breaks
casos_ambulatorios_mapa <- casos_ambulatorios_mapa %>%
  mutate(n_categoria = cut(`n`, 
                              breaks = breaks,
                              dig.lab = 5,
                              include.lowest = T))

table(casos_ambulatorios_mapa$n_categoria)
CONTEO_AMBULATORIOS_localidad_mapa <- read.csv("C:/Users/Salud/Documents/ZONA II/Boletin ZSII/Unidad-Centinela/CONTEO_AMBULATORIOS_localidad.csv")


tabla1 <- CONTEO_AMBULATORIOS_localidad_mapa %>% mutate(
    DEPARTAMENTO_match = case_when(
      `LOCALIDAD_RESIDENCIA` == "ZAPALA" ~ "Zapala",
      `LOCALIDAD_RESIDENCIA` == "MARIANO MORENO" ~ "Zapala",
      `LOCALIDAD_RESIDENCIA` == "LAS COLORADAS" ~ "Catán Lil",
      `LOCALIDAD_RESIDENCIA` == "ALUMINE" ~ "Aluminé",
      `LOCALIDAD_RESIDENCIA` == "LAS LAJAS" ~ "Picunches"  ))
  


#Union de datasets
casos_ambulatorios_mapa <- departamentos %>%
  left_join(tabla1, by = c( "nombre"="DEPARTAMENTO_match"))

DT::datatable(casos_ambulatorios_mapa)


# Calcular los cortes utilizando quantiles
breaks <- classInt::classIntervals(casos_ambulatorios_mapa$`n`, n = 3, style = "quantile",cutlabels=F)$brks

breaks

# Crear las categorías basadas en los Natural Breaks
casos_ambulatorios_mapa <- casos_ambulatorios_mapa %>%
  mutate(n_categoria = cut(`n`, 
                              breaks = breaks,
                              dig.lab = 5,
                              include.lowest = T))

table(casos_ambulatorios_mapa$n_categoria)


#####INTERNADOS####
#leo mi dataset con casos positivos por departamento

CONTEO_INTERNADOS_localidad_mapa <- read.csv("C:/Users/Salud/Documents/ZONA II/Boletin ZSII/Unidad-Centinela/CONTEO_INTERNADOS_localidad.csv")


tabla2 <- CONTEO_INTERNADOS_localidad_mapa %>% mutate(
  DEPARTAMENTO_match = case_when(
    `LOCALIDAD_RESIDENCIA` == "ZAPALA" ~ "Zapala",
    `LOCALIDAD_RESIDENCIA` == "MARIANO MORENO" ~ "Zapala",
    `LOCALIDAD_RESIDENCIA` == "LAS COLORADAS" ~ "Catán Lil",
    `LOCALIDAD_RESIDENCIA` == "ALUMINE" ~ "Aluminé",
    `LOCALIDAD_RESIDENCIA` == "LAS LAJAS" ~ "Picunches"  ))


#Union de datasets
casos_internados_mapa <- departamentos %>%
  left_join(tabla2, by = c( "nombre"="DEPARTAMENTO_match"))

DT::datatable(casos_internados_mapa)


# Calcular los cortes utilizando quantiles
breaks <- classInt::classIntervals(casos_internados_mapa$`n`, n = 3, style = "quantile",cutlabels=F)$brks

breaks

# Crear las categorías basadas en los Natural Breaks
casos_internados_mapa <- casos_internados_mapa %>%
  mutate(n_categoria = cut(`n`, 
                           breaks = breaks,
                           dig.lab = 5,
                           include.lowest = T))

table(casos_internados_mapa$n_categoria)
