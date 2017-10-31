# ---- General module: MATRÍCULAS ----
mod1UI <- function(id){
    ns <- NS(id)
    
    main <- list(""
        , fluidRow(""
            , filterUI(ns("filter"))
            , column(width = 4
                , valueBoxOutput(ns("box1"), width = 12)
                , valueBoxOutput(ns("box2"), width = 12)
                , valueBoxOutput(ns("box3"), width = 12)
            )
            , column(width = 4
                , valueBoxOutput(ns("box4"), width = 12)
                , valueBoxOutput(ns("box5"), width = 12)
                , valueBoxOutput(ns("box6"), width = 12)
            )
         )
        , fluidRow(
            tabBox(id = "gerencia_tabs"
                , title = 'Tablas'
                , tabPanel("Matriculas"
                    , p('Matrículas')
                    , DT::dataTableOutput(ns("matriculas"))
                )
            , width = 12)
        ) 
        
    )
    tagList(main)
}

mod1 <- function(input, output, session){
    mod1_filter <- callModule(filter, "filter")
    
    # ValueBox 1
    output$box1 <- renderBox("Venta proyectada", "dollar", "red", reactive({
        "1"
    }))
    
    # ValueBox 2
    output$box2 <- renderBox("Utilidad proyectada", "credit-card", "green", reactive({
        "1"
    }))
    
    # ValueBox 3. Margen Promedio
    output$box3 <- renderBox("Margen promedio", "line-chart", "maroon", reactive({
        "1"
    }))
    
    # ValueBox 4. Ticket Promedio
    output$box4 <- renderBox("Ticket promedio", "fire", "purple", reactive({
        "1"
    }))
    
    # ValueBox 5. DIas promedio en facturar
    output$box5 <- renderBox("Días en facturar", "flash", "yellow", reactive({
        "1"
    }))
    
    # ValueBox 6. Número de oportunidades
    output$box6 <- renderBox("Oportunidades", "credit-card", "black", reactive({
        "1"
    }))
    
    output$matriculas <- render_tables(
        data = reactive({
            query <- parameters$q.matriculas
            data.table(pool::dbGetQuery(conn, query))
        })
        , currency = NULL
        , percentage = NULL
        , round = NULL
    )
}