# Obtener la fecha actual en formato YYYY-MM-DD
fecha_actual <- format(Sys.Date(), "%Y-%m-%d")

# Definir el nombre del archivo con la fecha
output_file <- paste0("salidas/Consideraciones_", fecha_actual, ".txt")

# Si el archivo ya existe, lo elimina para comenzar limpio
if (file.exists(output_file)) {
  file.remove(output_file)
}

# Función para agregar mensajes al archivo
guardar_mensaje <- function(mensaje) {
  write(paste0(mensaje, "\n\n"), file = output_file, append = TRUE)
}

# Ejemplo de mensajes
mensajes <- c(mensaje1,
              mensaje2,
              mensaje3,
              mensaje4,
              mensaje5,
              mensaje7,
              mensaje8
)

# Itera por los mensajes y los guarda en el archivo
for (mensaje in mensajes) {
  guardar_mensaje(mensaje)
}

# Imprime el nombre del archivo generado
print(paste("Los mensajes se han guardado en:", output_file))
