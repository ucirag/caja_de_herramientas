#####Parte a modificar#########

###parte 1, lectura de datos------------
#VR_NOMINAL



FORMATO_MULTIREGISTRO <-  "NO" # C("SI","NO")

VR_NOMINAL <- read.csv2("templates/VR_NOMINAL.csv",encoding = "UTF-8", na.strings = c("","*SIN DATO* (*SIN DATO*)"))
VR_NOMINAL_UCIRAG <-read.csv2("templates/UC_IRAG_CHUBUT.csv",encoding = "latin1", na.strings = c("","*SIN DATO* (*SIN DATO*)"))


dia_de_corte_de_datos <- "03-04-2025" # explicar que es en este formato

num_ultimas_semana_no_incluidas <- 2 #agregar en explicacion que son las semanas q no se incluyen en caso que se elija el anio actual.

# MAPEO LOCALIDAD
ruta_excel_area <- "templates/AREA PROGRAMA.xls"  

#mapas tabla de establecimientos (con template)
LISTADO_EFECTORES <- read_excel("templates/EFECTORES.xlsx")

##lectura de datos agrupados
carga_agrupada_ucirag <- read_excel("templates/UC IRAG - Carga Agrupada -Chubut- TRELEW MARGARA.xlsx")# Reemplazar por el nombre correcto del archivo segun la provincia analizada

# Datos por servicio opcional (Cantidad de iras y % de hisopados por servicio) - con template

datos_servicio <- read.csv("templates/INTERNACION POR SERVICIO.csv", sep=";")


###parte dos, parametros a madificar######

PROVINCIA <- 58 # CODIGO DE LA PROVINCIA DE nqn

filtro_depto_o_estab <- c("DEPARTAMENTO") #aca elegir poner o DEPTO o Establecimeinto,"DEPARTAMENTO" o "ESTABLECIMIENTO"

area_progama_depto_localidad <- c("LOCALIDAD") #aca elegir poner "DEPARTAMENTO"o "LOCALIDAD"

DEPTOS_ANALISIS <- c("58007","58021","58105","58112") # SELECCION DE LA REGION DEL PEHUEN A PARTIR DE LOS id de DEPTOS

EFECTOR_CARGA <- c("nombre completo de establecimiento1","nombre completo de establecimiento2")#### variables de nombre del establecimeinto."ESTABLECIMIENTO_CARGA"

area_seleccionada_titulos <- "Región del Pehuén"
nombre_establecimiento_centinela <- "Hospital de Zapala"

# Limite de edad para considerar a un registro sin dato de edad
edad_max <- 110

anio_de_analisis <- 2024 #agregar en algun lado que las dos sepis previas se borran


#Definir las columnas a evaluar para centinela
#cambiar nombre por determinacion_UCIRAG
# Importante!!! Verificar que este igual escritas que en el dataset original

determinacion_UCIRAG <- c(
  "Genoma viral SARS-CoV-2",
  "Genoma viral de Influenza B (sin linaje)",
  "Genoma viral de Influenza A (sin subtipificar)",
  "Genoma viral de VSR",
  "Genoma viral de VSR A",
  "Genoma viral de VSR B",
  "Genoma viral de Influenza A H3N2",
  "Genoma viral de Influenza A H1N1pdm",
  "Genoma viral de Influenza B, linaje Victoria",
  "Genoma viral de Influenza"
)

############# fin de parte a modificar#######