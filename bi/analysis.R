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
# La mayoría de las cifras son de colegios Oficiales (públicos). 
# El 2008 es el único año que tiene datos de entidades No Oficiales

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
e2_3_1 <- plot_ly(e2[, mean(P_Aprobados, na.rm  = FALSE), keyby = .(Municipio, Ano)]
                  , x = ~Ano, y = ~V1, color = ~Municipio) %>% add_lines()  %>%
    layout(title = 'Porcentaje Aprobados')
e2_3_2 <- plot_ly(e2[Municipio %in% c("Neiva", "Pitalito", "Garzón", "La Plata", "Campoalegre"), mean(P_Aprobados, na.rm  = FALSE), keyby = .(Municipio, Ano)]
                  , x = ~Ano, y = ~V1, color = ~Municipio) %>% add_lines() %>%
    layout(title = 'Porcentaje Aprobados')
# Neiva y Pitalito no reportan información a la Secretaría, por eso no hay datos de ellos. 

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
e2_5 <- plot_ly(e2_4, x = ~Ano, y = ~Ranking, color = ~Municipio) %>% add_lines()
e2_6 <- plot_ly(e2_4[Municipio %in% c("Neiva", "Pitalito", "Garzón", "La Plata", "Campoalegre")], x = ~Ano, y = ~Ranking, color = ~Municipio) %>% add_lines()

# Los datos del 2011 y del 2012 son iguales
# Pitalito y Palermo han estado entre los últimos puestos en los últimos años.
# Neiva tiene datos inconsistentes y la mayoría son nulos. 
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

# A continuación el número de DATOS (no docentes) 
e4_1 <- plot_ly(
    data = e4[, .N, keyby = .(`dau_anio`, `Nivel Educativo`)]
    , x = ~dau_anio, y = ~N, color = ~`Nivel Educativo`, type = "bar") %>% 
    layout(yaxis = list(title = 'Número')
           , xaxis = list(title = 'Año'), barmode = 'stack', title = "Docentes Universidades")
# No hay información del año 2005. En el 2008 hubo significativamente menos DATOS que en los demás años
# El 2009 estuvo bajo de DATOS

e4_2 <- plot_ly(data = e4[, sum(Numero, na.rm = TRUE), keyby = .(`dau_anio`, `Nivel Educativo`)], x = ~dau_anio, y = ~V1, color = ~`Nivel Educativo`, type = "bar") %>% layout(yaxis = list(title = 'Número'), xaxis = list(title = 'Año'), barmode = 'stack', title = "Docentes Universidades")
# El 2013 y 2014 tuvieron significativamente más directivos docentes que los demás años.
# Este incremento se puede deber a mejor recolección de los datos o un aumento verídico del número de docentes.

e4_3 <- plot_ly(data= e4[, sum(Numero, na.rm = TRUE), keyby = Universidad], labels = ~Universidad, values = ~V1, type = 'pie') %>%
    layout(title = 'Docentes por Universidad',
           xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
           yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
# La universidad Surcolombiana (43.8%), La Cooperativa (20.7%) y la Corhuila (19.9%) acumulan el 83.5% de los docentes en el Departamento. 

# Gráfica del Número de docentes en cada municipio a lo largo de los años.
e4_4 <- e4[, sum(Numero, na.rm = TRUE), keyby = .(`dau_anio`, `Semestre`)]
e4_4[is.na(e4_4$Semestre), Semestre := "Sin Registro"]
plot_ly(
    data = e4_4
    , x = ~dau_anio, y = ~V1, color = ~`Semestre`, type = "bar") %>% 
    layout(yaxis = list(title = 'Número')
           , xaxis = list(title = 'Año'), barmode = 'stack', title = "Docentes Universidades")
# Efra: ¿qué significa que sea Semestre A o Semestre B? Si es el número en cada semestre por qué hay años que tienen Semestre A, Semestre B y valores nulos?
# Realmente son pocos los años que tienen información por semestre. 
# En el caso de 2013 y 2014 el Semestre A y el Semestre B tienen la misma información por lo que no aporta mucho
# De nuevo el 2015 no tiene datos. 

# Gráfica del Número de docentes coloreado por género a lo largo de los años.
e4_5 <- e4[, sum(Numero, na.rm = TRUE), keyby = .(`dau_anio`, `Genero`)]
e4_5[is.na(e4_5$Genero), Genero := "Sin Registro"]
plot_ly(
    data = e4_5
    , x = ~dau_anio, y = ~V1, color = ~`Genero`, type = "bar") %>% 
    layout(yaxis = list(title = 'Número')
           , xaxis = list(title = 'Año'), barmode = 'stack', title = "Docentes Universidades")
# Son escazos los años que tienen información de género. 
# A excepción del 2003 y 2006, los hombres son mayoría en la docencia.

# Gráfica del Número de docentes coloreado por Categoría de Docente a lo largo de los años.
e4_6 <- e4[, sum(Numero, na.rm = TRUE), keyby = .(`dau_anio`, `Categoria Docentes`)]
e4_6[is.na(e4_6$`Categoria Docentes`), `Categoria Docentes` := "Sin Registro"]
plot_ly(
    data = e4_6
    , x = ~dau_anio, y = ~V1, color = ~`Categoria Docentes`, type = "bar") %>% 
    layout(yaxis = list(title = 'Número')
           , xaxis = list(title = 'Año'), barmode = 'stack', title = "Docentes Universidades")
# Hasta el 2006 existieron "Docentes Ocasionales"

# Gráfica del Número de docentes coloreado por Categoría de Docente a lo largo de los años.
e4_7 <- e4[, sum(Numero, na.rm = TRUE), keyby = .(`dau_anio`, `Universidad`, `Programa`)]
e4_7[is.na(e4_7$`Programa`), `Programa` := "Sin Registro"]
