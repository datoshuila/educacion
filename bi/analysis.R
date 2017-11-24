# Análisis de datos

source("load.R", local = TRUE) 

# Get all file names in SQL format
ts <- list.files(c("sql"), pattern="\\.(sql|SQL)$", recursive = TRUE, full.names = FALSE)

# Store all data.tables into one single list and at the end name them.
educacion <- lapply(X = ts, FUN = function(x){
    query <- getSQL(paste0("sql/", x))
    data.table(pool::dbGetQuery(conn, query))
}) ; names(educacion) <- unlist(strsplit(ts, ".sql"))

# ---- Clasificación Icfes Establecimiento Educativos ----
# Ranking de los mejores colegios en el Departamento
e1 <- educacion$clasificacion_icfes_estab_educativos
e1[, Resultante := paste(Colegio, Municipio, Tipo)]
t1 <- dcast.data.table(e1, formula = "Puesto ~ Ano", value.var = "Resultante")
write.table(x = t1, file = "bi/e1.csv", sep = ",", row.names = F, na = "")
# TODO: Incluir esta tabla en el top de los colegios en la sección de Bachillerato. 
# Especificar cómo es calculado el índice y de dónde viene cada categoría. En el 2012
# las categorías eran "Muy Superior" y "Alto" y luego son letras: "A+", "A". 
# Todos los colegios en el Huila tienen calendario B (Semestre).
# El top de colegios

# ---- Comportamiento de los Alumnos ----
e2 <- educacion$comportamiento_alumnos
dcast.data.table(data = e2
    , formula = "Municipio ~ `Tipo Institucion` + Ano"
    , value.var = "P_Aprobados"
    , fun.aggregate = function(x){
        paste(x, collapse = ", ")
    }
)
# La mayoría de las cifras son de colegios Oficiales (públicos)
# El año 2008 es el único que tiene cifras de Colegio No Oficiales y solo en algunos municipios
