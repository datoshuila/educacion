# ---- Server declaration ----
server <- function(input, output, session) {
    
    # Example taken from: https://rstudio.github.io/leaflet/shiny.html
    # filteredData <- reactive({
    #     quakes[quakes$mag >= input$range[1] & quakes$mag <= input$range[2],]
    # })
    # colorpal <- reactive({
    #     colorNumeric(input$colors, quakes$mag)
    # })
    output$map <- renderLeaflet({
        # leaflet(quakes) %>% addTiles() %>% 
        #     fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
        leaflet(
            ) %>% 
            setView(lng = -75.469968, lat = 2.5937904, zoom = 9
            ) %>%
            addTiles()
    })
    
    # observe({
    #     pal <- colorpal()
    #     leafletProxy("map"
    #         , data = filteredData()) %>% 
    #             clearShapes() %>% 
    #             addCircles(
    #                 radius = ~10^mag/10
    #                 , weight = 1
    #                 , color = "#777777"
    #                 , fillColor = ~pal(mag)
    #                 , fillOpacity = 0.7
    #                 , popup = ~paste(mag)
    #     )
    # })
    # observe({
    #     proxy <- leafletProxy("map", data = quakes)
    #     proxy %>% clearControls()
    #     if (input$legend) {
    #         pal <- colorpal()
    #         proxy %>% addLegend(position = "bottomright", pal = pal, values = ~mag)
    #     }
    # })
    
    # Declaration of initial variables
    values <- reactiveValues()
    observeEvent(input$municipio, values$municipio <- input$municipio)
    observeEvent(input$ano, values$ano <- input$ano)
    
    output$parrafo <- renderUI(expr = {
        if(length(values$municipio) == 0){
            tx <- "del departamento del Huila"
        } else if(length(values$municipio) == 1){
            tx <- paste0("del municipio de ", values$municipio)
        } else if(length(values$municipio) == 2){
            tx <- paste0("de los municipios de ", paste0(values$municipio, collapse = " y "))
        } else {
            tx <- paste0("de los municipios de ", paste0(values$municipio[1:(length(values$municipio)-1)], collapse = ", "))
            tx <- paste0(tx, " y ", tail(values$municipio, 1))
        }
        p(paste0("Información educativa "
                 , tx, " entre ", paste0(values$ano, collapse = " y ")))
    })
    output$fechas <- renderText(expr = paste0(values$ano, collapse = " - "))
    # Graph1
    output$graph <- renderPlotly(expr = {
        # municipio = paste(c("Neiva", "Garzón"), collapse = "|")
        # ano = c(2010, 2015)
        municipio <- paste(values$municipio, collapse = "|")
        ano <- values$ano
        
        # Cálculo para matriculados:
        m <- paste0("
        SELECT 
	        m.\"Ano\"
            , \"Tipo Institucion\"
            , sum(m.\"Numero Matriculas\") AS \"Numero Matriculas\"
                FROM (", parameters$q.matriculas, ") AS m
        WHERE \"Ano\" >= ", ano[1], " 
            AND \"Ano\" <= ", ano[2], " 
            AND \"Municipio\" SIMILAR TO '(", municipio, ")%'
        GROUP BY \"Ano\", \"Tipo Institucion\"
        ORDER BY \"Ano\"
        ")
        m <- data.table(pool::dbGetQuery(conn, m), key = "Ano")
        temp <- m[, sum(`Numero Matriculas`, na.rm = T), keyby = "Ano"]
        setnames(temp, old = "V1", new = "Numero Matriculas")        
        m <- temp[dcast.data.table(
            data=m
            , formula = "Ano ~`Tipo Institucion`"
            , value.var = "Numero Matriculas"
        )]
        
        # Calcular el porcentaje de cobertura como el número de estudiantes matriculas dividido el número de personas en edad de estudiar.
        cob <- paste0("
        SELECT 
            \"Ano\"
            , sum(\"Poblacion\") as \"Poblacion\"
        FROM (", parameters$q.poblacion, ") AS cob
        WHERE \"Municipio\" SIMILAR TO '(", municipio, ")%'
        GROUP BY \"Ano\"
        ORDER BY \"Ano\"
        ")
        cob <- data.table(pool::dbGetQuery(conn, cob), key = "Ano")
        
        # Cálculo de aprobados:
        a <- paste0("
        SELECT 
	        m.\"Ano\"
            , AVG(m.\"P_Aprobados\") AS \"P_Aprobados\"
                FROM (", parameters$q.aprobados, ") AS m
        WHERE \"Municipio\" SIMILAR TO '(", municipio, ")%'
        GROUP BY \"Ano\"
        ORDER BY \"Ano\"
        ")
        a <- data.table(pool::dbGetQuery(conn, a), key = "Ano")
        d <- cob[a[m]]
        d[, Cobertura:=100*`Numero Matriculas`/Poblacion]
        # Graficar
        plot_ly(
            data = d
            , y = ~Oficial
            , x = ~Ano
            , name = "Oficiales"
            , marker = list(color = "#3C3A2E")
            , type = "bar"
            , hoverinfo = "none"
            , text = ~paste0(
                "Año: ", `Ano`
                , "<br>Total Matriculas: ", `Numero Matriculas`
                , "<br>No Oficiales: ", `No Oficial`
                , "<br>Oficiales: ", `Oficial`
                , "<br>Porcentaje Aprobados: ", paste0(round(`P_Aprobados`), "%")
                , "<br>Porcentaje Cobertura: ", paste0(round(`Cobertura`), "%")
            )
        ) %>% add_trace(
            y = ~(`Numero Matriculas` - Oficial)
            , x = ~Ano
            , name = "No Oficiales"
            , type = "bar"
            , marker = list(color = "#FF9933")
            , hoverinfo = "text"
        ) %>% add_trace( # Add margin line:
            y = ~P_Aprobados
            , yaxis = "y2"
            , type = "scatter"
            , mode = "lines"
            , hoverinfo = "text"
            , name = "Aprobados (%)"
            , text = ~paste0(round(`P_Aprobados`, 1), "%")
        ) %>% add_trace( # Add margin line:
            y = ~Cobertura
            , yaxis = "y2"
            , type = "scatter"
            , mode = "lines"
            , hoverinfo = "text"
            , name = "Cobertura (%)"
            , text = ~paste0(round(`Cobertura`, 1), "%")
        ) %>% layout(
            title = "Matrículas"
            , xaxis = list(
                title = ""
                , tickangle = 330
                , zeroline = FALSE
                , showline = FALSE
                , type = 'category'
                , showgrid = FALSE
            ), yaxis = list(
                title = ""
                , zeroline = FALSE
                , showline = FALSE
                , showticklabels = TRUE
                , showgrid = FALSE
            ), yaxis2 = list(
                tickfont = list(color = "red"),
                overlaying = "y",
                side = "right"
            )
            , barmode = "stack"
            , showlegend = TRUE
            , legend = list(orientation = 'h', font=list(size=9))
        )
    })
        
    output$heatmap <- renderPlotly(expr={
        # values <- list(); values$ano <- c(2008,2015); values$municipio <- c("Neiva", "Garzón")
        municipio <- paste(values$municipio, collapse = "|")
        
        # Cálculo para matriculados:
        m <- paste0("
                    SELECT 
                    m.\"Ano\"
                    , m.\"Grado\"
                    , sum(m.\"Numero Matriculas\") AS \"Numero Matriculas\"
                    FROM (", parameters$q.matriculas, ") AS m
                    WHERE \"Ano\" >= ", values$ano[1], " 
                    AND \"Ano\" <= ", values$ano[2], " 
                    AND \"Municipio\" SIMILAR TO '(", municipio, ")%'
                    AND m.\"Grado\" IS NOT NULL
                GROUP BY \"Ano\", \"Grado\", \"Numero Grado\"
                ORDER BY \"Ano\", \"Numero Grado\"
            ")
        m <- data.table(pool::dbGetQuery(conn, m))
        m <- dcast.data.table(
            data = m
            , formula = "factor(Grado, levels=unique(Grado)) ~ Ano"
            , value.var = "Numero Matriculas")
        plot_ly(
            x = colnames(m)[-1]
            , y = (m$Grado)
            , z = as.matrix(m[, -1, with = FALSE])
            , type="heatmap"
            , colors = c("#d3ceaf", "#3C3A2E")
            # , colorscale = "Blackbody"
            # Available colors:
            # ['Blackbody',
            #     'Bluered',
            #     'Blues',
            #     'Earth',
            #     'Electric',
            #     'Greens',
            #     'Greys',
            #     'Hot',
            #     'Jet',
            #     'Picnic',
            #     'Portland',
            #     'Rainbow',
            #     'RdBu',
            #     'Reds',
            #     'Viridis',
            #     'YlGnBu',
            #     'YlOrRd']
        )
    })
    
    output$saveData <- downloadHandler(function() {
        # USE IT IN CASE THERE IS A SHARE FILE
        # t <- ifelse(input$fileType=="shp", "zip", input$fileType)
        # paste0("datos_", Sys.Date(), ".", t)
        paste0("datos_", Sys.Date(), ".csv")
    }, function(file) {

            municipio <- paste(values$municipio, collapse = "|")
            ano <- values$ano
            
            # Cálculo para matriculados:
            m <- paste0("
                        SELECT 
                        m.\"Ano\"
                        , \"Tipo Institucion\"
                        , sum(m.\"Numero Matriculas\") AS \"Numero Matriculas\"
                        FROM (", parameters$q.matriculas, ") AS m
                        WHERE \"Ano\" >= ", ano[1], " 
                        AND \"Ano\" <= ", ano[2], " 
                        AND \"Municipio\" SIMILAR TO '(", municipio, ")%'
                        GROUP BY \"Ano\", \"Tipo Institucion\"
                        ORDER BY \"Ano\"
                        ")
            m <- data.table(pool::dbGetQuery(conn, m), key = "Ano")
            temp <- m[, sum(`Numero Matriculas`, na.rm = T), keyby = "Ano"]
            setnames(temp, old = "V1", new = "Numero Matriculas")        
            m <- temp[dcast.data.table(
                data=m
                , formula = "Ano ~`Tipo Institucion`"
                , value.var = "Numero Matriculas"
            )]
            
            # Calcular el porcentaje de cobertura como el número de estudiantes matriculas dividido el número de personas en edad de estudiar.
            cob <- paste0("
                          SELECT 
                          \"Ano\"
                          , sum(\"Poblacion\") as \"Poblacion\"
                          FROM (", parameters$q.poblacion, ") AS cob
                          WHERE \"Municipio\" SIMILAR TO '(", municipio, ")%'
                          GROUP BY \"Ano\"
                          ORDER BY \"Ano\"
            ")
            cob <- data.table(pool::dbGetQuery(conn, cob), key = "Ano")
            
            # Cálculo de aprobados:
            a <- paste0("
            SELECT 
    	        m.\"Ano\"
                , AVG(m.\"P_Aprobados\") AS \"P_Aprobados\"
                    FROM (", parameters$q.aprobados, ") AS m
            WHERE \"Municipio\" SIMILAR TO '(", municipio, ")%'
            GROUP BY \"Ano\"
            ORDER BY \"Ano\"
            ")
            a <- data.table(pool::dbGetQuery(conn, a), key = "Ano")
            d <- cob[a[m]]
            d[, Cobertura:=100*`Numero Matriculas`/Poblacion]
        
            switch(input$fileType,
               csv = write.csv(d, file, row.names=F, na=""),
               shp = write.csv(d, file, row.names=F, na="")
        )
    })
    
    
    output$table <- renderRHandsontable({
        # values <- list(); values$ano <- c(2008,2015); values$municipio <- c("Neiva", "Garzón")
        municipio <- paste(values$municipio, collapse = "|")
        
        # Cálculo para matriculados:
        m <- paste0("
                    SELECT 
                    m.\"Ano\"
                    , m.\"Grado\"
                    , sum(m.\"Numero Matriculas\") AS \"Numero Matriculas\"
                    FROM (", parameters$q.matriculas, ") AS m
                    WHERE \"Ano\" >= ", values$ano[1], " 
                    AND \"Ano\" <= ", values$ano[2], " 
                    AND \"Municipio\" SIMILAR TO '(", municipio, ")%'
                    AND m.\"Grado\" IS NOT NULL
                GROUP BY \"Ano\", \"Grado\", \"Numero Grado\"
                ORDER BY \"Ano\", \"Numero Grado\"
            ")
        m <- data.table(pool::dbGetQuery(conn, m))
        m <- dcast.data.table(
            data = m
            , formula = "factor(Grado, levels=unique(Grado)) ~ Ano"
            , value.var = "Numero Matriculas")
        rhandsontable(m
                      # , colHeaders=
                      # , height=min(40+nrow(values$res$data)*22, 487)
                      , readOnly=T, width="100%", stretchH="all"
        )
    })
    session$onSessionEnded(stopApp) # Stop session when tab is closed.
}