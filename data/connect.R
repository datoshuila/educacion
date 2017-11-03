# ---- Load functions ----
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
    # Command to list all connection opened: all_cons <- RPostgreSQL::dbListConnections(drv = PostgreSQL())
    # command to close all connections: for(con in all_cons) dbDisconnect(con)
    # close the connection dbDisconnect(conn)
}

# ---- PostgreSQL Get Queries ----
parameters$q.matriculas <- getSQL("data/matriculas.sql")
parameters$q.aprobados <- getSQL("data/aprobados.sql")
parameters$q.poblacion <- getSQL("data/poblacion.sql")

# ---- Close all connections when app is closed ----
onStop(function() {
    pool::poolClose(conn)
})

# ---- Remove global variables ----
rm(getSQL)