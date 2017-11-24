# Load everything

# ---- Load all packages ----
require(pool)
require(data.table)
require(shinyjs)
require(shiny)
require(shinydashboard)
require(plotly)
require(DT)
require(leaflet)
require(ggvis)

require(d3heatmap)
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
                                  , style = "color:#3C3A2E; text-align:center;"
                                  , url = "http://sirhuila.gov.co/"
                                  , img = "footer_sir.png"
                                  , title = "Sistema de Información Regional del Huila"
                       ), gob = list(""
                                     , style = "color:#3C3A2E; text-align:center;"
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
for (file in list.files(c("data", "src")
    , pattern="\\.(r|R)$"
    , recursive = TRUE
    , full.names = TRUE)) {
        source(file, local = TRUE) 
}

# ---- Connect to Database ----
if(!exists('conn')){
    conn <- pool::dbPool(
        drv = RPostgreSQL::PostgreSQL()
        , host = parameters$credentials$host
        , port = as.numeric(parameters$credentials$port)
        , user = parameters$credentials$user
        , password = parameters$credentials$password
        , dbname = parameters$credentials$database
    )
    # # Command to list all connection opened:
    # all_cons <- RPostgreSQL::dbListConnections(drv = RPostgreSQL::PostgreSQL())
    # # command to close all connections:
    # for(con in all_cons) RPostgreSQL::dbDisconnect(con)
    # # close the connection
    # RPostgreSQL::dbDisconnect(conn)
}

# ---- Close all connections when app is closed ----
onStop(function() {
    pool::poolClose(conn)
})
# ---- PostgreSQL Get Queries ----
parameters$q.matriculas <- getSQL("sql/matriculas.sql")
parameters$q.aprobados <- getSQL("sql/comportamiento_alumnos.sql")
parameters$q.poblacion <- getSQL("sql/poblacion_edad_escolar.sql")
