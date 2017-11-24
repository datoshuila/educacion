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
e2_1 <- dcast.data.table(data = e2
    , formula = "Municipio ~ Ano"
    , value.var = "P_Aprobados"
    , fun.aggregate = length)
write.table(x = e2_1, file = "bi/e2_1.csv", sep = ",", row.names = F, na = "")
# La mayoría de las cifras son de colegios Oficiales (públicos)

e2_2 <- dcast.data.table(data = e2
    , formula = "Municipio ~ `Tipo Institucion` + Ano"
    , value.var = "P_Aprobados"
    , fun.aggregate = function(x){
        paste(x, collapse = ", ")
    }
)
write.table(x = e2_2, file = "bi/e2_2.csv", sep = ",", row.names = F, na = "")
# El año 2008 es el único que tiene cifras de Colegio No Oficiales y solo en algunos municipios

# Calculamos el ranking de los mejores municipios
e2_3 <- dcast.data.table(data = e2
     , formula = "Municipio ~ Ano"
     , value.var = "P_Aprobados"
     , fun.aggregate = function(x){
         round(mean(x, na.rm = TRUE), 1)
     }
)
write.table(x = e2_3, file = "bi/e2_3.csv", sep = ",", row.names = F, na = "")
e2_4 <- e2_3
e2_4[, `2007` := frankv(`2007`, order = -1)]
e2_4[, `2008` := frankv(`2008`, order = -1)]
e2_4[, `2009` := frankv(`2009`, order = -1)]
e2_4[, `2010` := frankv(`2010`, order = -1)]
e2_4[, `2011` := frankv(`2011`, order = -1)]
e2_4[, `2012` := frankv(`2012`, order = -1)]
e2_4[, `2013` := frankv(`2013`, order = -1)]
e2_4[, `2014` := frankv(`2014`, order = -1)]
e2_4 <- melt.data.table(e2_4, id.vars = "Municipio", variable.name = "Ano", value.name = "Ranking")
write.table(x = e2_4, file = "bi/e2_4.csv", sep = ",", row.names = F, na = "")

# Ranking generado solo con los números, no con los porcentajes. No se encontró nada raro.
plot_ly(e2_4, x = ~Ano, y = ~Ranking, color = ~Municipio) %>%
    add_lines()

# Pitalito y Palermo han estado entre los últimos puestos en los últimos años.
# Neiva no tiene datos consistentes y la mayoría son nulos. 
# Paicol iba bien en el ranking y en el 2013 desmejoró sustancialmente pero en el 2014 se recuperó
# Isnos siempre estuvo entre los top 10 (a excepción del 2010 que estuvo de 16) pero en el 2014 llegó al puesto 30.5. 

# ---- Directivos Docentes ----
e3 <- educacion$directivos_docentes
e3_1<- dcast.data.table(data= e3, formula = "Categoria ~ Ano", fun.aggregate = function(x){sum(x, na.rm = TRUE)}, value.var = "Numero")
write.table(x = e3_1, file = "bi/e3_1.csv", sep = ",", row.names = F, na = "")
# La cifra de Coordinadores y Rectores se han mantenido constante en los últimos años
# Director rural y Directores se podrían combinar (?)
# Docente aula y Docentes se podrían combinar (?)
# La categoría de Director de Núcleo no aparece sino hasta el 2016.
# La Categoría Docente apoyo comenzó a recolectarse desde el 2012.

# Hay una cifra atípica en el 2012 en la categoría de Orientador: 6182 es demasiado elevado en comparación con los años que lo rodean
e3_2 <- dcast.data.table(data= e3[Categoria %in% "Orientador"], formula = "Municipio ~ Ano", fun.aggregate = function(x){sum(x, na.rm = TRUE)}, value.var = "Numero")
write.table(x = e3_2, file = "bi/e3_2.csv", sep = ",", row.names = F, na = "")
# Al mirar la data pueden estar pasando dos cosas: El 2012 fue en el único año en el que se recolectó juiciosamente la información
# O el 2012 tiene información  mezclada de otras categorías que los demás años no tienen.

# Gráfica de las categorias a los largo de los años.
plot_ly(
    data = e3[, sum(Numero, na.rm = TRUE), keyby = c("Ano", "Categoria")]
    , x = ~Ano, y = ~V1, color = ~Categoria) %>%
    add_lines()
# Mezclando Directores y Director rural la tendencia es a la baja.
# En el 2009 hubo una caída brusca del número de docentes y se recuperó

# Gráfica del Número de Directivos docentes en cada municipio a lo largo de los años.
plot_ly(
    data = e3[, sum(Numero, na.rm = TRUE), keyby = c("Ano", "Municipio")]
    , x = ~Ano, y = ~V1, color = ~Municipio) %>%
    add_lines()
# Neiva, Garzón, La Plata y Pitalito son los municipios que significatiavamente tienen más docentes que los demás municipios.
# Es evidente el aumento en el número de datos del 2012. Algo sucedió. 
# Hay que correlacionar el número de docentes con el desempeño de los estudiantes y el presupuesto para cada municipio. ¿existe correlación?

# ---- Docentes de las Universidades ----
e4 <- educacion$docentes_universidades
