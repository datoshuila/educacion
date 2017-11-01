# ---- User Interface declaration ----
ui <- function(){shinyUI(fluidPage(
    title= paste0(parameters$title, " | ", parameters$subtitle)
    , tagList(
        tags$head(
            tags$link(rel = "shortcut icon", href= parameters$favicon , tags$title("Favicon"))
        )
    )
    , theme= "bootstrap.css"
    # tags$head(includeScript("../assets/ga.js")),
    
    # Header
    , fluidRow(class="hc"
        , column(8, h3(parameters$title, tags$small(parameters$subtitle)))
        , column(2, offset=2, h5(a(href=parameters$url, title="Inicio" , img(src=parameters$logo, alt="Inicio"        ))))
    )
    
    # Map
    , fluidRow(style="position:relative;"
        , leafletOutput("map", height=380, width="100%")
        , absolutePanel(
            top = 5
            , right = 5
            , sliderInput("range", "Magnitudes", min(quakes$mag), max(quakes$mag), value = range(quakes$mag), step = 0.1)
            , selectInput("colors", "Color Scheme", rownames(subset(brewer.pal.info, category %in% c("seq", "div"))))
            , checkboxInput("legend", "Show legend", TRUE)
        )
    )
    
    # Body
    , fluidRow(
        # Firt Column
        column(4
            , p(br())
            , p("Use this tool to send and compare results from (bulk) requests to travel distance APIs provided
            by Google, HERE, MAPZEN, and OpenStreetMap.")
            , hr()
            , p("You will need to provide", strong("your own API keys"), "to send larger requests to"
            , a("Google", href="https://developers.google.com/maps/documentation/distance-matrix/usage-limits"),
            "and", a("HERE", href="https://developer.here.com/rest-apis/documentation/routing/topics/quick-start.html"),
            "or", a("MAPZEN", href="https://mapzen.com/documentation/mobility/matrix/api-reference/"),
            "APIs. Without a key requests are limited to 200 pairs of locations. Please use the
            links here and register if needed.")
            , textInput("txtKeyGOOG", "Your Google API key",
                         placeholder="Sign in with Google and enter your API key")
            , actionLink("btnKeyGOOG", "update key", icon("refresh"))
            , p(br())
            , textInput("txtKeyMAPZ", "Your Mapzen API key",
                         placeholder="Sign in with Mapzen and enter your API key")
            , actionLink("btnKeyMAPZ", "update key", icon("refresh"))
            , p(br(), "HERE API requires both an App ID and an App Code.")
            , textInput("txtKeyHEREid","Your HERE App ID", placeholder="Sign in with HERE and enter your API key")
            , textInput("txtKeyHEREcode","Your HERE App Code",placeholder="Sign in with HERE and enter your API key")
            , actionLink("btnKeyHERE", "update key", icon("refresh"))
            , hr()
            , includeMarkdown("www/credits.md")
            , p(br())
        )
        # Second Column
        , column(8
            , h3("Origins and Destinations")
            , p("Use a CSV notation with at least a", code("X"), code("Y"), "and", code("ID"), "columns.")
            , p(br())
            , fluidRow(
                column(6,
                       h4("Population Trends", tags$small("2000-2020 (headcount)")),
                       p("Urban and rural population growth and projected trends in coastal and inland areas.
                        Coastal areas are within", em("150 km", "of the nearest coastline.")),
                       ggvisOutput("graph"))
                , column(6
                    # Destinations
                    , actionLink("btnTo", "Map destination locations", icon("globe"), style="float:right;")
                    , div(class="fix", textAreaInput("txtTo", width="100%", rows=9, resize="vertical", label="Destination locations"
                        , value='
                            "X", "Y", "ID"
                            35.85439, -5.085751, "Loc 03"
                            39.25198, -6.860888, "Loc 04"
                            36.72286, -6.456619, "Loc 05"'
                        )
                    )
                    , bsAlert("alertTo")
                )
            )
            , actionButton("btnMain", "Generate Travel Times", icon("exchange"), class="btn-primary")
            # Results
            , h3("Travel Times")
            , p("Results are shown in the table below. The entire API response in JSON format
        is also available. Use the download options below to save your results.
        You can also use your keyboard Crtl+C/Ctrl+V to copy and paste entries.")
            , tabsetPanel(
                tabPanel("Table", p(br(), "Driving time for each pair of locations.")
                    , rHandsontableOutput("tbResults", width="100%")
                    , helpText(br(), textOutput("txtNoteHERE", inline=T), class="small")
                )
                , tabPanel("JSON Response", p(br(), "Entire JSON response.")
                            # , jsoneditOutput("jsResults", height="280px")
                )
            )
            , p(br())
            # Export
            , div(style="float: left; margin-right: 15px;",
                selectInput("fileType", "Choose Export Format"
                    , choices=c(`ESRI Shapefile`="shp"
                        , `Comma-separated (CSV)`="csv")
                        , selected="csv"
                )
            )
            , HTML("<label>&nbsp;</label><br />")
            , downloadButton("btnSave", "Save Results", class="btn-info")
            , p(br(clear="left"), "Choose ESRI Shapefile to save the point locations
        shown on the maps, CSV to export a table of travel time statistics for the
        selected pairs of points.")
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