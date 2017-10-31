selectCheckboxGroupInput <- function(id, choices, selected = choices, label = "Selecciona", status = "success"){
    
    ns <- NS(id)
    
    dropdownButton <- function(label = "", status = c("default", "primary", "success", "info", "warning", "danger"), ..., width = NULL) {
        status <- match.arg(status)
        # dropdown button content
        html_ul <- list(
            class = "dropdown-menu",
            style = if (!is.null(width)) 
                paste0("width: ", validateCssUnit(width), ";"),
            lapply(X = list(...), FUN = tags$li, style = "margin-left: 10px; margin-right: 10px;")
        )
        # dropdown button apparence
        html_button <- list(
            class = paste0("btn btn-", status," dropdown-toggle"),
            type = "button", 
            `data-toggle` = "dropdown"
        )
        html_button <- c(html_button, list(label))
        html_button <- c(html_button, list(tags$span(class = "caret")))
        # final result
        tags$div(
            class = "dropdown",
            do.call(tags$button, html_button),
            do.call(tags$ul, html_ul),
            tags$script(
                "$('.dropdown-menu').click(function(e) {
                e.stopPropagation();
            });"
        )
    )
    }
    
    dropdownButton(
        label = label
        , status = status
        # , width = "120px"
        , actionButton(
            inputId = ns("all")
            , label = "(De)Seleccionar todos"
        )
        , br()
        , actionButton(
            inputId = ns("a2z")
            , label = "Ordenar A -> Z"
            , icon = icon("sort-alpha-asc")
        )
        , actionButton(
            inputId = ns("z2a")
            , label = "Ordenar Z -> A"
            , icon = icon("sort-alpha-desc")
        )
        , br()
        , checkboxGroupInput(
            inputId = ns("check2")
            , label = "Opciones"
            , choices = choices
            , selected = selected
        )
    )    
}

selectCheckboxGroup <- function(input, output, session, choices){
    ns <- session$ns
    # Sorting asc
    observeEvent(input$a2z, {
        updateCheckboxGroupInput(
            session = session
            , inputId = "check2"
            , choices = choices
            , selected = input$check2
        )
    })
    # Sorting desc
    observeEvent(input$z2a, {
        updateCheckboxGroupInput(
            session = session
            , inputId = "check2"
            , choices = rev(choices)
            , selected = input$check2
        )
    })
    
    # Select all / Unselect all
    observeEvent(input$all, {
        if (is.null(input$check2)) {
            updateCheckboxGroupInput(
                session = session
                , inputId = "check2"
                , selected = choices
            )
        } else {
            if(all(choices %in% input$check2)){
                updateCheckboxGroupInput(
                    session = session
                    , inputId = "check2"
                    , selected = ""
                )
            } else {
                updateCheckboxGroupInput(
                    session = session
                    , inputId = "check2"
                    , selected = choices
                )
            }
        }
    })
    return(reactive(input$check2))
}