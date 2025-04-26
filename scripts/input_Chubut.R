#####Parte a modificar#########

###parte 1, lectura de datos------------

# primero seleccionar si se usa dataset multirestro si o no- Importante
FORMATO_MULTIREGISTRO <-  "SI" # C("SI","NO")

#LUEGO CARGAR UNA DE LAS DOS DATASET Y COMENTAR LA QUE NO SE USA

# VR NOMINAL (MULTIREGISTRO)
VR_NOMINAL <- read.csv2("templates/VR_NOMINAL_Chubut.csv",encoding = "latin1", na.strings = c("","*SIN DATO* (*SIN DATO*)"))

#UC_IRAG
VR_NOMINAL_UCIRAG <- read.csv2("templates/UC_IRAG_CHUBUT.csv", sep = ";" ,encoding = "latin1", na.strings = c("","*SIN DATO* (*SIN DATO*)"))

# MAPEO LOCALIDAD SOLO NECESARIO SI SE CARGA LA MILTIREGISTRO
ruta_excel_area <- "templates/AREA PROGRAMA.xls"  

#mapas tabla de establecimientos (con template)
#LISTADO_EFECTORES <- read_excel("templates/EFECTORESCHUBUT.xlsx")
LISTADO_EFECTORES <- readxl::read_excel("templates/EFECTORES.xlsx")#SIMEPRE NECESARIO

##lectura de datos agrupados SIMPRE NECESARIO
carga_agrupada_ucirag <- readxl::read_excel("templates/UC IRAG - Carga Agrupada -Chubut- TRELEW MARGARA2.xlsx")# Reemplazar por el nombre correcto del archivo segun la provincia analizada

# Datos por servicio opcional (Cantidad de iras y % de hisopados por servicio) - con template

#datos_servicios <- readxl::read_excel("templates/INTERNACION_POR_SERVICIO.xlsx")


###parte dos, parametros a madificar######

PROVINCIA <- 26 # CODIGO DE LA PROVINCIA DE chubut

filtro_depto_o_estab <- c("ESTABLECIMIENTO") #aca elegir poner o DEPTO o Establecimeinto,"DEPARTAMENTO" o "ESTABLECIMIENTO"

area_progama_depto_localidad <- c("DEPARTAMENTO") #aca elegir poner "DEPARTAMENTO"o "LOCALIDAD"

#DEPTOS_ANALISIS <- c("58007","58021","58105","58112") # SELECCION DE LA REGION DEL PEHUEN A PARTIR DE LOS id de DEPTOS

EFECTOR_CARGA <- c("HOSPITAL ZONAL TRELEW DR. ADOLFO MARGARA")#### variables de nombre del establecimeinto."ESTABLECIMIENTO_CARGA"

area_seleccionada_titulos <- "Trelew"
nombre_establecimiento_centinela <- "HOSPITAL ZONAL TRELEW DR. ADOLFO MARGARA"

# Limite de edad para considerar a un registro sin dato de edad
edad_max <- 110

anio_de_analisis <- c(2025) #agregar en algun lado que las dos sepis previas se borran

dia_de_corte_de_datos <- "21-04-2025" # IMPORTANTE PONER ESTE CORTE

num_ultimas_semana_no_incluidas <- 1 #agregar en explicacion que son las semanas q no se incluyen en caso que se elija el anio actual.


#Definir las columnas a evaluar para centinela SE DEJA LO QUE ESTA COMO PREDEFINIDO , SOLO PARA LA MULTIREGISTRO YA QUE CONTIENE OTROS EVENTOS ADEMAS DE CENTINELA
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