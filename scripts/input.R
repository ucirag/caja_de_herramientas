################################################################################
# IMPORTANTE - LEER ANTES DE EDITAR
################################################################################

# ⚠️ ATENCIÓN:
# Solo debe modificar las variables dentro de la sección "CONFIGURACIÓN INICIAL".
# No debe cambiar el nombre de los objetos que están antes de la flecha de asignación "<-".
# Es decir, modificar SOLO el valor que está a la derecha del "<-", pero NO el nombre de la variable.
#
# Ejemplo correcto:
#   PROVINCIA <- 26     # (✅ Correcto: cambiar el número)
#
# Ejemplo incorrecto:
#   PROVINCIA_CHUBUT <- 26    # (❌ Incorrecto: NO cambiar el nombre de PROVINCIA)

# Verán este simbolo 🛑 en loa campos obligatorios de modificar o cargar

################################################################################
# CONFIGURACIÓN INICIAL: SOLO EDITAR ESTA SECCIÓN
################################################################################

### 1. FORMATO DE DATOS --------------------------------------------------------

# ¿El dataset nominal es MULTIREGISTRO? ("SI" o "NO")
FORMATO_MULTIREGISTRO <- "SI" #🛑

### 2. ARCHIVOS A CARGAR -------------------------------------------------------

# Dataset nominal (cargar uno solo y comentar el otro)🛑

VR_NOMINAL <- read.csv2("templates/VR_NOMINAL_Chubut.csv", encoding = "latin1", na.strings = c("", "*SIN DATO* (*SIN DATO*)"))

VR_NOMINAL_UCIRAG <- read.csv2("templates/UC_IRAG_CHUBUT.csv", sep = ";", encoding = "latin1", na.strings = c("", "*SIN DATO* (*SIN DATO*)"))

# Mapeo de Área Programa (solo necesario si es multiregistro) No es necesario comentarlo
ruta_excel_area <- "templates/AREA PROGRAMA.xls"

# Listado de efectores (siempre necesario)🛑
LISTADO_EFECTORES <- readxl::read_excel("templates/EFECTORES.xlsx")

# Datos por servicio (opcional)
archivo_datos_servicios <- "templates/INTERNACION_POR_SERVICIO.xlsx"

# Carga agrupada (siempre necesario)🛑
carga_agrupada_ucirag <- readxl::read_excel("templates/UC IRAG - Carga Agrupada -Chubut- TRELEW MARGARA2.xlsx")

# Datos por servicio (opcional) No es necesario comentarlo. Si no existe no se utiliza.
#⚠️ LA COLUMNA FECHA DEBE ESTAR EN FORMATO **FECHA CORTA** DESDE EL EXCEL"
ruta_datos_servicios <- "templates/INTERNACION_POR_SERVICIO.xlsx"

### 3. PARÁMETROS DEL ANÁLISIS -------------------------------------------------

PROVINCIA <- 26  # 🛑Código de provincia (Chubut = 26)

# Definir qué filtro usar ("DEPARTAMENTO" o "ESTABLECIMIENTO")🛑
filtro_depto_o_estab <- "ESTABLECIMIENTO"

# Definir agrupador para áreas ("DEPARTAMENTO" o "LOCALIDAD")🛑
area_progama_depto_localidad <- "DEPARTAMENTO"

# Nombre del establecimiento centinela
EFECTOR_CARGA <- "HOSPITAL ZONAL TRELEW DR. ADOLFO MARGARA"#🛑
nombre_establecimiento_centinela <- "HOSPITAL ZONAL TRELEW DR. ADOLFO MARGARA"#🛑

# Nombre de la región para títulos y gráficos que luego se vera en el reporte
area_seleccionada_titulos <- "Trelew"#🛑

# Configuraciones adicionales
edad_max <- 110  # Edad máxima aceptada
anio_de_analisis <- 2025  # Año del análisis🛑
dia_de_corte_de_datos <- "21-04-2025"  # 🛑 Fecha de corte de datos IMPORTANTE: NO OLVIDAR⚠️
num_ultimas_semana_no_incluidas <- 1  # Número de semanas previas a excluir

# Listado de determinaciones centinela.
# Deben estar escritas igual que en el dataset. 
# SOLO NECESARIO PARA MULTIREGISTRO.
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

################################################################################
# LECTURA AUTOMÁTICA DE DATOS: FIN DE SECCION PARA EDITAR. 
################################################################################

