# ---- Server declaration ----
server <- function(input, output, session) {
    # Choose which tab to update
    output$menu <- renderMenu({
        sidebarMenu(id = "menu"
            # General tab:
            , if (parameters$menu$tab1$active) {
                menuItem(
                    parameters$menu$tab1$name
                    , tabName = parameters$menu$tab1$tab
                    , icon = icon(parameters$menu$tab1$icon)
                )
            }
        )
    })
    
    # Activate the tab
    output$navtabs <- renderUI({
        if(parameters$menu$tab1$active){callModule(mod1, "matriculas")}

        # tabItems(
        tabItem(
            tabName = parameters$menu$tab1$tab
            , if (parameters$menu$tab1$active) mod1UI('matriculas'))
        # )
    })
    
    # plot(xtabs(data = d, formula = "`Numero Matriculas` ~ Municipio"))
    
    session$onSessionEnded(stopApp) # Stop session when tab is closed.
}