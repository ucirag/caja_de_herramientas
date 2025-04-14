# source("scripts/install.packages.R")
# source("scripts/input.R")
# ────────────────────────────────────────────────────────────────────────────────
table(CLI_agrupados$NOMBREEVENTOAGRP[CLI_agrupados$ANIO==2024])
# ────────────────────────────────────────────────────────────────────────────────
# Parámetros de tiempo actuales
# ────────────────────────────────────────────────────────────────────────────────
mes_actual <- month(Sys.Date())
anio_actual <- year(Sys.Date())

# Definir años a incluir: año actual + anterior si estamos entre enero y mayo
anios_incluidos <- if (mes_actual <= 5) {
  c(anio_actual - 1, anio_actual)
} else {
  c(anio_actual)
}

# ────────────────────────────────────────────────────────────────────────────────
# Construcción de datos: internaciones IRAG y por otras causas
# ────────────────────────────────────────────────────────────────────────────────

# Total internaciones por todas las causas (adultos)
adultos_todas <- CLI_agrupados %>%
  filter(NOMBREEVENTOAGRP == "Pacientes adultos en internación general por TODAS las causas") %>%
  group_by(ANIO, SEMANA) %>%
  summarise(camas_todas = sum(CANTIDAD, na.rm = TRUE), .groups = "drop")

# Internaciones IRAG (adultos)
adultos_irag <- CLI_agrupados %>%
  filter(NOMBREEVENTOAGRP == "Pacientes en internacion general por Infección Respiratoria Aguda") %>%
  group_by(ANIO, SEMANA) %>%
  summarise(camas_irag = sum(CANTIDAD, na.rm = TRUE), .groups = "drop")

# Unir ambos conjuntos y calcular "otras causas"
internaciones <- full_join(adultos_todas, adultos_irag, by = c("ANIO", "SEMANA")) %>%
  mutate(
    camas_irag = replace_na(camas_irag, 0),
    camas_todas = replace_na(camas_todas, 0),
    camas_otras = camas_todas - camas_irag
  )

# Transformar a formato largo para graficar
internaciones_largo <- internaciones %>%
  select(ANIO, SEMANA, camas_irag, camas_otras) %>%
  pivot_longer(cols = c(camas_irag, camas_otras), names_to = "tipo", values_to = "cantidad") %>%
  mutate(
    tipo = recode(tipo, camas_irag = "IRAG", camas_otras = "OTRAS causas"),
    tipo = factor(tipo, levels = c("IRAG", "OTRAS causas")),
    semana_anio = paste0(ANIO, "-W", sprintf("%02d", SEMANA))
  )

# ────────────────────────────────────────────────────────────────────────────────
# Filtrado final: excluir últimas 2 semanas del año actual y aplicar años incluidos
# ────────────────────────────────────────────────────────────────────────────────

# Filtrar por años definidos
internaciones_filtrado <- internaciones_largo %>%
  filter(ANIO %in% anios_incluidos)

# Calcular últimas 2 semanas del año actual
ultimas_semanas <- internaciones_filtrado %>%
  filter(ANIO == anio_actual) %>%
  distinct(SEMANA) %>%
  arrange(desc(SEMANA)) %>%
  slice(1:2) %>%
  pull(SEMANA)

# Excluir esas semanas
internaciones_filtrado <- internaciones_filtrado %>%
  filter(!(ANIO == anio_actual & SEMANA %in% ultimas_semanas))

# ────────────────────────────────────────────────────────────────────────────────
# Generar gráfico
# ────────────────────────────────────────────────────────────────────────────────

# Definir cortes del eje X cada 4 semanas
ticks_cada_4 <- internaciones_filtrado %>%
  distinct(semana_anio) %>%
  arrange(semana_anio) %>%
  pull(semana_anio) %>%
  {.[seq(1, length(.), by = 4)]}

# Colores personalizados
colores_personalizados <- c("IRAG" = "#1f78b4", "OTRAS causas" = "#a6cee3")

# Crear gráfico
grafico_1 <- ggplot(internaciones_filtrado, aes(x = semana_anio, y = cantidad, fill = tipo)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = colores_personalizados) +
  scale_x_discrete(breaks = ticks_cada_4) +
  labs(
    title = "Ocupación de camas por IRAG y otras causas",
    #subtitle = paste("Años incluidos:", paste(anios_incluidos, collapse = ", ")),
    x = "Semana epidemiológica",
    y = "Cantidad de camas ocupadas",
    fill = ""
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, vjust = 0.5, size = 7),
    legend.position = "bottom",
    plot.background = element_rect(fill = "transparent", color = NA),
    panel.background = element_rect(fill = "transparent", color = NA),
    legend.background = element_rect(fill = "transparent", color = NA),
    legend.box.background = element_rect(fill = "transparent", color = NA)
  )

# ────────────────────────────────────────────────────────────────────────────────
# Obtener texto con la última semana incluida en el análisis
# ────────────────────────────────────────────────────────────────────────────────
ultima_semana_incluida <- internaciones_filtrado %>%
  arrange(desc(ANIO), desc(SEMANA)) %>%
  slice(1) %>%
  mutate(texto = paste0("Semana ", SEMANA, " del año ", ANIO)) %>%
  pull(texto)
