


tabla_servicio <- datos_servicio %>% 
  group_by(SE, SERVICO_INGRESO, IRAG, IRAG_E) %>% 
  summarise(n= n())