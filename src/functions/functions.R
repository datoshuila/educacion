# ---- Load functions ----

# ---- getSQL: get a filepath to an SQL file and converts it into string
getSQL <- function(filepath){
    con = file(filepath, "r")
    sql.string <- ""
    
    while ( TRUE ){
        line <- readLines(con, n = 1)
        if ( length(line) == 0 ) { break }
        line <- gsub("\\t", " ", line)
        if(grepl("--",line) == TRUE){
            line <- paste(sub("--","/*",line),"*/")
        }
        sql.string <- paste(sql.string, line)
    }
    
    close(con)
    return(sql.string)
}

renderBox <- function(title, icon, color, data){
    renderValueBox({ valueBox(
        value = tags$p(title, style = "font-size: 60%;")
        , subtitle = tags$p(data(), style = "font-size: 135%;")
        , icon = icon(icon)
        , color = color
    )})    
}
render_tables <- function(data, currency = NULL, percentage = NULL, round = NULL, dom = 'ftirp'){
    DT::renderDataTable(expr = {
        if(!is.null(currency)){
            currency <- currency[currency %in% colnames(data())]
        } else if(!is.null(percentage)){
            percentage <- percentage[percentage %in% colnames(data())]
        } else if(!is.null(round)){
            round <- round[round %in% colnames(data())]
        }
        datatable(data()
                  , rownames = FALSE
                  , escape = FALSE
                  , options = list(
                      pageLength = 25
                      , dom = dom
                      , scrollX = TRUE
                      
                  ) # Reference for dom: https://datatables.net/reference/option/dom
        ) %>%
            formatCurrency(currency, digits = 0) %>%
            formatPercentage(percentage, digits = 1) %>%
            formatRound(round, digits = 0)
    }, options = list(
        lengthChange = TRUE
    ))
}
