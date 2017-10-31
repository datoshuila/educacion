# ---- Load al packages ----
require(pool)
require(data.table)
require(shinyjs)
require(shiny)
require(shinydashboard)
require(DT)

# ---- Set initial parameters ----
parameters <- list(""
    , credentials = ini::read.ini("../../../credentials.ini")$pgsql_analytics
    , title = "Educación"
    , logo = "../../../logos/logo.png"
    , favicon = "../../../logos/favicon.png"
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