css_template <- glue::glue("
body {{
  font-family: '{parametros_css$fuente_principal}', sans-serif;
  font-size: {parametros_css$tamanio_letra};
  background-color: {parametros_css$color_fondo};
  color: {parametros_css$color_texto};
}}

a {{
  color: {parametros_css$color_link};
  text-decoration: none;
}}
a:hover {{
  color: {parametros_css$color_link_hover};
  text-decoration: underline;
}}

table {{
  width: 100%;
  border-collapse: collapse;
  background-color: {parametros_css$color_tabla_fondo};
}}
th {{
  background-color: {parametros_css$color_tabla_encabezado};
  color: {parametros_css$color_tabla_encabezado_texto};
  padding: 10px;
}}
td {{
  padding: 8px;
  border: 1px solid {parametros_css$color_tabla_borde};
}}

.recuadro-transparente {{
  background-color: rgba(135, 206, 235, 0.3); /* celeste claro con transparencia */
  border: 1px solid rgba(135, 206, 235, 0.9); /* borde más fuerte */
  padding: 15px;
  margin: 20px 0;
  border-radius: 6px;
  font-style: italic;
}}

button, .btn {{
  background-color: {parametros_css$color_boton};
  color: {parametros_css$color_boton_texto};
  border: none;
  padding: 10px 20px;
  font-weight: bold;
  cursor: pointer;
}}
button:hover, .btn:hover {{
  background-color: {parametros_css$color_boton_hover};
  color: {parametros_css$color_boton_texto};
}}
")


# Guardamos como styles.css
writeLines(css_template, "templates/CSS/styles.css")
