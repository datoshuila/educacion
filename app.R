# ---- Load al packages ----
require(pool)
require(data.table)
require(shinyjs)
require(shiny)
require(shinydashboard)
require(DT)
require(leaflet)
require(ggvis)

require(RColorBrewer)
require(shinyBS)
require(rhandsontable)
require(jsonlite)

# ---- Set initial parameters ----
parameters <- list(""
    , credentials = ini::read.ini("../credentials.ini")$pgsql_analytics
    , title = "Secretaría de Educación"
    , subtitle = "Matriculados Bachilleres del Huila"
    , url = "http://sirhuila.gov.co"
    , logo = "logo.png"
    , favicon = "favicon.ico"
    , footer = list(
        sir = list(""
            , color = "color:#3C3A2E;"
            , url = "http://sirhuila.gov.co/"
            , img = "footer_sir.png"
            , title = "Sistema de Información Regional del Huila"
        ), gob = list(""
            , color = "color:#3C3A2E;"
            , url = "http://huila.gov.co/"
            , img = "footer_gob.png"
            , title = "Gobernación del Huila"
        )
    )
    , default_tab = "general"
    , menu = list(""
        , tab1 = list(""
            , active = TRUE
            , tab = "tab-1"
            , name = "Matrículas"
            , icon = "paper-plane-o"
        )
    )
)

# ---- Load functions, files and modules ----
for (file in list.files(c("data","functions", "src")
    , pattern="\\.(r|R)$"
    , recursive = TRUE
    , full.names = TRUE)) {
        source(file, local = TRUE) 
}

# ---- Run the app! ----
shiny::shinyApp(ui = ui, server = server)