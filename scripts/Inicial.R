

# Activo paquetes y carlo los inputs
source("scripts/install.packages.R")
source("scripts/input.R")

#LEO LAS FUNCIONES Y aplico algoritmo 1 al dataset multiregistro
source("scripts/funciones.R")

# Evaluá la condición


if (FORMATO_MULTIREGISTRO == "NO") {
  source("scripts/procesamiento_IRA_eventocaso.R")
} else if (FORMATO_MULTIREGISTRO == "SI") {
  source("scripts/procesamiento_IRA.R")
} else {
  stop("⚠️ El valor de FORMATO_MULTIREGISTRO debe ser 'SI' o 'NO'")
}
