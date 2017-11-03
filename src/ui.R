# ---- User Interface declaration ----
ui <- function(){shinyUI(fluidPage(
    title= paste0(parameters$title, " | ", parameters$subtitle)
    , tagList(
        tags$head(
            tags$link(rel = "shortcut icon", href= parameters$favicon , tags$title("Favicon"))
        )
    ), theme= "bootstrap.css"
    # tags$head(includeScript("../assets/ga.js"))
    
    # Header
    , fluidRow(class="hc"
        , column(8, h3(parameters$title, tags$small(parameters$subtitle)))
        , column(2, offset=2, h5(a(href=parameters$url, title="Inicio" , img(src=parameters$logo, alt="Inicio"        ))))
    )
    
    # Map
    , fluidRow(style="position:relative;"
        , leafletOutput("map", height=380, width="100%")
        # , absolutePanel(
        #     top = 5
        #     , right = 5
        #     , sliderInput("range", "Magnitudes", min(quakes$mag), max(quakes$mag), value = range(quakes$mag), step = 0.1)
        #     , selectInput("colors", "Color Scheme", rownames(subset(brewer.pal.info, category %in% c("seq", "div"))))
        #     , checkboxInput("legend", "Show legend", TRUE)
        # )
    )
    
    # Body
    , fluidRow(
        # Firt Column
        column(3
            , p(br())
            , p("Utiliza esta herramienta para conocer la información estadística de matrículas del 
                Departamento del Huila. Usa el filtro por municipio para conocer sus cifras de 
                educación (matrículas, índice de aprobados y cobertura).")
            , hr()
            , wellPanel(
                selectInput("municipio", label = "Selecciona el municipio", choices = {
                    query <- "SELECT mun_nombre FROM public.municipio ORDER BY mun_nombre"
                    data.table(pool::dbGetQuery(conn, query))$mun_nombre
                }, multiple = TRUE)
                , p("La herramienta por defecto agrupa todos los municipios. Si quieres filtrar
                    un municipio en específico utiliza el filtro.")
                , hr()
                , sliderInput("ano", label = "Filtra por rango de años", min = {
                    query <- "SELECT min(mat_anio) from \"Educacion\".\"matriculas\""
                    data.table(pool::dbGetQuery(conn, query))$min
                }, max = {
                    query <- "SELECT max(mat_anio) from \"Educacion\".\"matriculas\""
                    data.table(pool::dbGetQuery(conn, query))$max
                }, value = {
                    query <- "SELECT max(mat_anio) from \"Educacion\".\"matriculas\""
                    max <- data.table(pool::dbGetQuery(conn, query))$max
                    c(max - 7, max)
                }, sep = "", step = 1)
            )
            , hr()
            , includeMarkdown("www/credits.md")
            , p(br())
        )
        # Second Column
        , column(9
            , h3("Bachillerato en el Huila")
            , p("Los matriculados se categorizan por tipo de institución (Oficiales y No Oficiales)
                con el propósito de conocer la proporción de la oferta educativa en cada 
                municipio. En formato de líneas está la información disponible sobre el porcentaje de 
                cobertura por año y por municipio. Se calculado como el número de matriculados dividido
                por el número de personas en edad de estudiar. El porcentaje de aprobados se calcula como 
                la proporción de estudiantes que aprobaron contra los que reprobaron.")
            , p(br())
            , fluidRow(
                column(9,
                    h4("Desempeño ", tags$small(textOutput("fechas", inline = TRUE)))
                    , htmlOutput("parrafo")
                    , plotlyOutput("graph")
                ) , column(3
                    # Export
                    , div(
                        # style="float: left; margin-right: 15px;",
                     selectInput("fileType", "Escoge el formato para exportar"
                                 , choices=c(`Separado por comas (CSV)`="csv"
                                             , `Archivos Shape ESRI`= "esri")
                                 , selected="csv"
                        )
                    )
                    , HTML("<label>&nbsp;</label><br />")
                    , downloadButton("saveData", "Guardar resultados", class="btn-info")
                    , p(br(clear="left"), "Escoge el formato Shape ESRI para guardar las ubicaciones (puntos)
                        mostrados en el mapa. Escoge Archivos separados por comas (CSV) para exportar las estadísticas
                        de educación bachilleto del departamento usando los filtros seleccionados.")
                    , p(br())
                )
            )
            
            , h3("Grados")
            , p("A continuación la tabla del desempeño de los estudiantes por año y por grado.
                Hay dos visualizaciones posibles: tabla y gráfica")
            , tabsetPanel(
                tabPanel("Gráfica", p(br(), "Gráfica de grados de estudio en el bachillerato."
                    , plotlyOutput("heatmap", width ="100%"))
                )
                , tabPanel("Tabla", p(br(), "Tabla de grados de estudio en el bachillerato.")
                    , rHandsontableOutput("table", width="100%")
                )
            )
            , p(br())
        )
    )

    # Footer
    , fluidRow(class="hc-footer"
        , column(4
            , p("El Equipo SIR-SIGDEHU recolecta, procesa, analiza y visualiza la información estadística y geográfica
                del Departamento del Huila para facilitar el proceso de toma de decisiones de inversión del Estado y sus ciudadanos.")
        ) , column(4
            , p("Equipo SIR-SIGDEHU/Gobernación del Huila, 2017. Código fuente disponible en "
                , a(href="https://github.com/datoshuila/educacion", "GitHub."), "Respaldado por "
                , a(href="http://shiny.rstudio.com/", "RStudio Shiny"), " y ", ".Código y conjuntos 
                de datos licenciados bajo la ", a(href="http://creativecommons.org/licenses/by-nc-sa/4.0/"
                , target="_blank", "Licencia Internacional Creative Commons Attribution-NonCommercial-ShareAlike 4.0."))
        ) , column(2
            , a(style=parameters$footer$sir$color, href=parameters$footer$sir$url, img(src=parameters$footer$sir$img)
                , title=parameters$footer$sir$title)
        ) , column(2
            , a(style=parameters$footer$gob$color, href=parameters$footer$gob$url, img(src=parameters$footer$gob$img)
                , title=parameters$footer$gob$title)
        )
    )
))}