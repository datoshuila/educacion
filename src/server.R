# ---- Server declaration ----
server <- function(input, output, session) {
    
    # Example taken from: https://rstudio.github.io/leaflet/shiny.html
    filteredData <- reactive({quakes[quakes$mag >= input$range[1] & quakes$mag <= input$range[2],]})
    colorpal <- reactive({colorNumeric(input$colors, quakes$mag)})
    output$map <- renderLeaflet({leaflet(quakes) %>% addTiles() %>% fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))})
    observe({
        pal <- colorpal()
        leafletProxy("map", data = filteredData()) %>% clearShapes() %>% addCircles(radius = ~10^mag/10, weight = 1, color = "#777777", fillColor = ~pal(mag), fillOpacity = 0.7, popup = ~paste(mag))
    })
    observe({
        proxy <- leafletProxy("map", data = quakes)
        proxy %>% clearControls()
        if (input$legend) {
            pal <- colorpal()
            proxy %>% addLegend(position = "bottomright", pal = pal, values = ~mag)
        }
    })
    
    # Graph1
    bind_shiny(vis = {
        d <- data.table(pool::dbGetQuery(conn, parameters$q.matriculas))
        # d <- d[, lapply(.SD, sum, na.rm = TRUE), keyby = .(Ano, `Tipo Institucion`), .SDcols = "Numero Matriculas"]
        d <- d[, lapply(.SD, sum, na.rm = TRUE), keyby = .(Ano), .SDcols = "Numero Matriculas"]
        ggvis(
            # data = d, x = ~Ano, y = ~`Numero Matriculas`, fill = ~`Tipo Institucion`) %>%
            # group_by(`Tipo Institucion`) %>%
            data = d, x = ~Ano, y = ~`Numero Matriculas`) %>%
            layer_bars(width = 0.5, opacity := 0.6) %>%
            
            #details for right axis i.e. the bars
            add_axis("y", orient = "right", title = "My bars" ,title_offset = 50) %>%
            
            #details for left axis i.e. the lines + plotting of lines 
            add_axis("y", 'ylines' , orient = "left", title= "My lines" , grid=F ) %>%
            layer_lines(stroke := 'red',   prop('y', ~`Numero Matriculas`, scale='ylines'))

    }, plot_id = "graph")

    session$onSessionEnded(stopApp) # Stop session when tab is closed.
}