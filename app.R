# ---- Run the app! ----
source("load.R", local = TRUE) 
shiny::shinyApp(ui = ui, server = server)