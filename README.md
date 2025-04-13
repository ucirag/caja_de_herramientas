

# **<span style="text-decoration:underline;">Caja de herramientas para el análisis epidemiológico de infecciones respiratorias agudas graves (IRAG) utilizando información del Sistema Nacional de Vigilancia</span>**[^1]

**Esta caja de herramientas IRAG es el resultado de la colaboración entre OPS/OMS Argentina y la Unidad Centinela de IRAG del Hospital Zapala “Dr. Juan J. Pose”, Provincia de Neuquén. Abril, año 2025.**

## **_Introducción_**

Las decisiones en salud pública deben basarse en la mejor evidencia científica disponible. En este sentido, las emergencias sanitarias como la gripe A(H1N1)pdm09 o la pandemia de COVID-19 resaltaron la importancia de la información generada a partir de la vigilancia rutinaria como evidencia para las recomendaciones y orientación de decisiones en la prevención y control de las infecciones respiratorias agudas (IRA). No obstante, el uso rutinario de la información epidemiológica para contribuir a la toma de estas decisiones de salud pública en la práctica diaria es limitado. 

En Argentina, la información que aportan las unidades centinela de vigilancia de infecciones respiratorias agudas permite monitorear la incidencia de las IRA, caracterizar la situación epidemiológica, detectar nuevas variantes de virus y evaluar el impacto sobre el sistema de salud y de las intervenciones adoptadas, como es el caso de la vacunación contra influenza y virus sincicial respiratorio (VSR). Desde marzo de 2024, Argentina ha incorporado esta última vacunación al calendario nacional, siendo pionera en la Región de las Américas, lo que subraya la importancia de realizar estudios de efectividad para documentar la reducción de hospitalizaciones en recién nacidos y lactantes.

Considerando la importancia de contar con establecimientos de salud que aporten información de calidad, particularmente para los mencionados estudios de efectividad nacional y regional de las vacunas contra influenza y VSR, la Organización Panamericana de la Salud (OPS/OMS) apoyó al país en el fortalecimiento de la Red Argentina de Vigilancia Centinela de Infecciones Respiratorias Agudas Graves (IRAG) durante el año 2024.

Al implementar las distintas estrategias de fortalecimiento, se observó que las herramientas de análisis de las que disponen los equipos de salud y los procesos de trabajo involucrados allí implican una alta carga de trabajo y un bajo grado de control en la precisión de los procesos. En consecuencia, se observó la necesidad de robustecer las competencias y capacidades de los equipos de epidemiología locales y jurisdiccionales en el uso de herramientas avanzadas y métodos eficientes para la gestión de datos epidemiológicos de IRA, mediante la incorporación de nuevas herramientas informáticas para el análisis de datos, visualizaciones y generación de reportes automatizados.  

Tomando en consideración lo antedicho, para fortalecer la competencia en datos y respaldar la toma de decisiones basadas en evidencia, la OPS/OMS propone compartir una caja de herramientas para el análisis epidemiológico de las infecciones respiratorias agudas graves (IRAG) utilizando los datos del SNVS 2.0 y aplicando herramientas gratuitas y de código abierto como R y Quarto.

Esta caja de herramientas no sólo ofrece orientación práctica, sino que también funciona como un repositorio de referencia esencial para la Red Argentina de Vigilancia Centinela de IRAG, compilando documentos técnicos, guías, lineamientos operativos, y marcos de referencia nacionales y regionales. Aquí encontrarás acceso a directrices y guías actualizadas, así como a publicaciones claves y otros recursos valiosos relacionados con esta crucial iniciativa de salud pública.

## **_Objetivo de la caja de herramientas IRAG_**

Apoyar en el  análisis de datos a los equipos de salud de la Red Argentina de Vigilancia Centinela de IRAG al facilitar códigos en R modularizados para el procesamiento, visualización y elaboración de reportes automatizados epidemiológicos de IRAG.

## **_Propósito_**

El propósito de esta caja de herramientas involucra dejar capacidad instalada en los equipos de los establecimientos de salud que desempeñan tareas de vigilancia epidemiológica de IRAG para el análisis de datos en Rstudio, la generación de visualizaciones efectivas y la utilización de herramientas de automatización de reportes como Quarto, contribuyendo de esta forma a la adherencia a la estrategia y actuación coordinada de los componentes de laboratorio, epidemiología y clínica, además de contribuir a la toma de decisiones por parte de las autoridades locales y/o jurisdiccionales. 

## **_Destinatarios_**

La presente caja de herramientas está orientada a profesionales de distintas disciplinas o integrantes de los equipos de salud y de gestión de la salud que deseen obtener un reporte epidemiológico de la vigilancia centinela de IRAG utilizando la información del SNVS 2.0. 

Como requerimientos mínimos para poder utilizar esta caja de herramientas se necesita la disponibilidad de una computadora con la instalación del programa R y RStudio con permisos para instalar paquetes nuevos. Es valorado el conocimiento básico de manejo de bases de datos y conocimientos en R. Como complemento para el manejo básico de R, ver apartado de “Enlaces de utilidad”.

## **_Contenido de la caja de herramientas_**

La caja de herramientas contempla una serie de documentos para la ejecución práctica de una base de datos depurada y un reporte automatizado de la información de IRAG:



* **Guía Operativa:** De manera resumida se indican los pasos a seguir para realizar el análisis epidemiológico de IRAG.
* **Guía teórica-conceptual: **Detalla las variables que las bases de datos contienen, sus respectivas definiciones, las decisiones metodológicas tomadas en el curso del análisis y las consideraciones que hay que tener en cuenta al ejecutar la caja de herramienta IRAG.
* Código en R modularizado: Scripts en extensiones .R y .qmd. Ver detalle en la **_Guía operativa_**.
* Template para ingreso de los datos en excel. Ver detalle en la **_Guía operativa_**.

# **_Productos esperados _**

Se espera que los/as profesionales puedan elaborar un informe automatizado en formato html o pdf utilizando la información de vigilancia centinela de IRAG. Además, este documento se acompañará con un repositorio de materiales y documentación, un reporte de calidad de datos y de verificación de los procesos, y un dataset limpio y depurado para análisis adicionales (Figura 1). Se incentiva la adecuación y la reutilización de estos materiales y productos a las necesidades de cada provincia, establecimiento de salud y/o unidad centinela de IRAG, tanto para analizar la información de los virus respiratorios como para otros eventos de salud de importancia sanitaria.

**Figura 1: Diagrama de flujo sobre los documentos y procesos necesarios para la obtención de determinados resultados al utilizar la caja de herramientas.**

IMAGEN


Fuente: Elaboración propia.


# **_Descarga de caja de herramientas_**

Para dar comienzo a la ejecución de la caja de herramientas, se debe comenzar con su descarga. Para ello, existen dos opciones que se detallan a continuación:


# 
    **1) Navegador Web**


    Si se desea descargar la caja de herramientas desde el navegador web:



1. Ingresar al repositorio de github [[https://github.com/Oliversinn/polio-risk](https://github.com/Oliversinn/polio-risk)].
2. Presionar el botón verde que dice "Code" o "Código".
3. Presionar el botón de "Download Zip" o "Descargar Zip".
4. Descomprimir archivo zip.

## 
    **2) Utilizando git**


    git clone https://github.com/ucirag/caja_de_herramientas


    ```
Es importante destacar que todos los documentos deben estar contenidos en una única carpeta de trabajo, denominada "Caja de herramientas IRAG".
```



**_¡Comencemos!_**

Para dar comienzo al uso de la caja de herramientas, se debe leer y seguir los pasos descriptos en la **<span style="text-decoration:underline;">Guía Operativa.</span>**

**_Enlaces de utilidad para quienes se inician en R_**

A continuación encontrarán enlaces de módulos, denominados “cápsulas”, que agrupan contenidos y habilidades de manera encadenada para el desarrollo de proyectos de automatización de reportes. Dichos materiales sientan las bases necesarias para un manejo básico del software R, facilitando la ejecución de la presente caja de herramientas.



* ["Cápsula 1": Introducción básica a R y Rstudio.](https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%201/C%C3%A1psula%201.html)
* ["Cápsula 2": Objetos, funciones, principales paquetes y librerías.](https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%201/C%C3%A1psula%202.html)
* ["Cápsula 3": Factores, datos faltantes, Pipe (tuberías), creación de proyecto en R y rutas de directorios de trabajo.](https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%201/C%C3%A1psula%203.html)
* ["Cápsula 4": Importación de datos con diferentes paquetes y formatos.](https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%202/C%C3%A1psula%204.html)
* ["Cápsula 5": Limpieza y normalización de datos: manejo de datos faltantes, trabajo con caracteres y fechas, y exportación de dataframes.](https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%202/C%C3%A1psula%205.html)
* ["Cápsula 6": Procesamiento de datos: filtrado y manejo de duplicados.](https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%202/C%C3%A1psula%206.html)
* ["Cápsula 7": Procesamiento de datos: modificación de columnas, creación de variables condicionales, rangos y agrupamientos.](https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%202/C%C3%A1psula%207.html)
* ["Material funciones": Guía visual para la sintaxis de las principales funciones de procesamiento de datos.](https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%202/Material_funciones.html)
* ["Cápsula 8": Unión de datos.](https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%203/C%C3%A1psula%208.html)
* ["Cápsula 9": Pivoteo de datos para la creación de gráficos.](https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%203/C%C3%A1psula%209.html)
* ["Cápsula tablas": Formatos y visualización de tablas](https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%203/C%C3%A1psula%20tablas.html)

[https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%204/mapas_neuquen.html](https://vigilanciaenr.github.io/VigilanciaenR/Sesi%C3%B3n%204/mapas_neuquen.html)

**_Enlaces nacionales y regionales de utilidad sobre la prevención, vigilancia y control de IRA_**



* 

<!-- Footnotes themselves at the bottom. -->
## Notes

[^1]:
     Esta caja de herramientas se denominará de forma abreviada en el documento como **“Caja de herramientas IRAG”**.
