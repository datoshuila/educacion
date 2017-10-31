filterUI <- function(id){
    ns <- NS(id)
    
    municipio <- selectCheckboxGroupInput(
        id = ns("municipio")
        , label = "Selecciona el municipio"
        , choices = {
            query <- paste0("SELECT mun_nombre FROM public.municipio")
            pool::dbGetQuery(conn, query)$mun_nombre
        }
        , status = "danger"
    )
    tagList(list(""
        , column(width = 4
            , sidebarPanel(width = 12
                , h4("Filtros")
                , municipio
                , br()
            )
        )
    ))
        }
filter <- function(input, output, session){
    municipio <- callModule(selectCheckboxGroup, "municipio"
        , { 
            query <- paste0("SELECT mun_nombre FROM public.municipio")
            pool::dbGetQuery(conn, query)$mun_nombre
        }
    )
    return(reactive({
        paste0(
            " WHERE Municipio IN (", paste0("'", paste(municipio(), collapse = "','"), "'"), ")"
        )
    }))
}