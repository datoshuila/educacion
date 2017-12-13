# Análisis de datos

source("load.R", local = TRUE) 

# Get all file names in SQL format
ts <- list.files(c("sql"), pattern="\\.(sql|SQL)$", recursive = TRUE, full.names = FALSE)

# Store all data.tables into one single list and at the end name them.
educacion <- lapply(X = ts, FUN = function(x){
    query <- getSQL(paste0("sql/", x))
    print(paste0("leyendo ", x))
    data.table(pool::dbGetQuery(conn, query))
}) ; names(educacion) <- unlist(strsplit(ts, ".sql"))
saveRDS(educacion, "educacion.RDS")


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
write.table(x = e2, file = "bi/e2.csv", sep = ",", row.names = F, na = "")

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
write.table(x = e3, file = "bi/e3.csv", sep = ",", row.names = F, na = "")

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
e3_2_1 <- plot_ly(
    data = e3[, sum(Numero, na.rm = TRUE), keyby = c("Ano", "Categoria")]
    , x = ~Ano, y = ~V1, color = ~Categoria) %>%
    add_lines()
# Mezclando Directores y Director rural la tendencia es a la baja.
# En el 2009 hubo una caída brusca del número de docentes y se recuperó

# Gráfica del Número de Directivos docentes en cada municipio a lo largo de los años.
e3_2_2 <- plot_ly(
    data = e3[, sum(Numero, na.rm = TRUE), keyby = c("Ano", "Municipio")]
    , x = ~Ano, y = ~V1, color = ~Municipio) %>%
    add_lines()
# Neiva, Garzón, La Plata y Pitalito son los municipios que significatiavamente tienen más docentes que los demás municipios.
# Es evidente el aumento en el número de datos del 2012. Algo sucedió. 
# Hay que correlacionar el número de docentes con el desempeño de los estudiantes y el presupuesto para cada municipio. ¿existe correlación?

# ---- Docentes de las Universidades ----
e4 <- educacion$docentes_universidades
write.table(x = e4, file = "bi/e4.csv", sep = ",", row.names = F, na = "")

# A continuación el número de DATOS (no docentes) 
e4_1 <- plot_ly(
    data = e4[, .N, keyby = .(`Ano`, `Nivel Educativo`)]
    , x = ~Ano, y = ~N, color = ~`Nivel Educativo`, type = "bar") %>% 
    layout(yaxis = list(title = 'Número')
           , xaxis = list(title = 'Año'), barmode = 'stack', title = "Docentes Universidades")
# No hay información del año 2005. En el 2008 hubo significativamente menos DATOS que en los demás años
# El 2009 estuvo bajo de DATOS

e4_2 <- plot_ly(
    data = e4[, sum(Numero, na.rm = TRUE), keyby = .(`Ano`, `Nivel Educativo`)]
    , x = ~Ano, y = ~V1, color = ~`Nivel Educativo`, type = "bar") %>% 
    layout(
        yaxis = list(title = 'Número')
        , xaxis = list(title = 'Año'), barmode = 'stack', title = "Docentes Universidades")
# El 2013 y 2014 tuvieron significativamente más directivos docentes que los demás años.
# Este incremento se puede deber a mejor recolección de los datos o un aumento verídico del número de docentes.

e4_3 <- plot_ly(data= e4[, sum(Numero, na.rm = TRUE), keyby = Universidad], labels = ~Universidad, values = ~V1, type = 'pie') %>%
    layout(title = 'Docentes por Universidad',
           xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
           yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
# La universidad Surcolombiana (43.8%), La Cooperativa (20.7%) y la Corhuila (19.9%) acumulan el 83.5% de los docentes en el Departamento. 

# Gráfica del Número de docentes en cada municipio a lo largo de los años.
e4_4 <- e4[, sum(Numero, na.rm = TRUE), keyby = .(`Ano`, `Semestre`)]
e4_4[is.na(e4_4$Semestre), Semestre := "Sin Registro"]
plot_ly(
    data = e4_4
    , x = ~Ano, y = ~V1, color = ~`Semestre`, type = "bar") %>% 
    layout(yaxis = list(title = 'Número')
           , xaxis = list(title = 'Año'), barmode = 'stack', title = "Docentes Universidades")
# Efra: ¿qué significa que sea Semestre A o Semestre B? Si es el número en cada semestre por qué hay años que tienen Semestre A, Semestre B y valores nulos?
# Realmente son pocos los años que tienen información por semestre. 
# En el caso de 2013 y 2014 el Semestre A y el Semestre B tienen la misma información por lo que no aporta mucho
# De nuevo el 2015 no tiene datos. 

# Gráfica del Número de docentes coloreado por género a lo largo de los años.
e4_5 <- e4[, sum(Numero, na.rm = TRUE), keyby = .(`Ano`, `Genero`)]
e4_5[is.na(e4_5$Genero), Genero := "Sin Registro"]
plot_ly(
    data = e4_5
    , x = ~Ano, y = ~V1, color = ~`Genero`, type = "bar") %>% 
    layout(yaxis = list(title = 'Número')
           , xaxis = list(title = 'Año'), barmode = 'stack', title = "Docentes Universidades")
# Son escazos los años que tienen información de género. 
# A excepción del 2003 y 2006, los hombres son mayoría en la docencia.

# Gráfica del Número de docentes coloreado por Categoría de Docente a lo largo de los años.
e4_6 <- e4[, sum(Numero, na.rm = TRUE), keyby = .(`Ano`, `Categoria Docentes`)]
e4_6[is.na(e4_6$`Categoria Docentes`), `Categoria Docentes` := "Sin Registro"]
plot_ly(
    data = e4_6
    , x = ~Ano, y = ~V1, color = ~`Categoria Docentes`, type = "bar") %>% 
    layout(yaxis = list(title = 'Número')
           , xaxis = list(title = 'Año'), barmode = 'stack', title = "Docentes Universidades")
# Hasta el 2006 existieron "Docentes Ocasionales"

# Gráfica del Número de docentes coloreado por Categoría de Docente a lo largo de los años.
e4_7 <- e4[, sum(Numero, na.rm = TRUE), keyby = .(`Ano`, `Universidad`, `Programa`)]
e4_7[is.na(e4_7$`Programa`), `Programa` := "Sin Registro"]

e4_7_1 <- plot_ly(
    data = e4_7[Universidad %in% "Universidad Cooperativa de Colombia", .(Ano, Programa, V1)][order(Ano, V1, decreasing = TRUE)]
    , x = ~Ano, y = ~V1, color = ~`Programa`, type = "bar") %>% 
    layout(yaxis = list(title = 'Número de Docentes')
           , xaxis = list(title = 'Año'), barmode = 'stack', title = "Programas Universidad Cooperativa de Colombia")
# Esta gráfica hay que colocarla en el dashboard para filtrarlo por Universidad y rando de año e identificar los programas que más inscritos tienen. 
# Esta gráfica en el dashboard nos funciona como argumento para solicitar ayuda a las Universidades en la recolección de la información 

#¡HACER UN BOX PLOT PARA EL PROMEDIO!
e5 <- educacion$icetex
write.table(x = e5, file = "bi/e5.csv", sep = ",", row.names = F, na = "")

e5_1 <- plot_ly(
    data = e5[, sum(`Numero Creditos`), keyby = .(`Ano`, `Estado Credito`)]
    , x = ~Ano, y = ~`V1`, color = ~`Estado Credito`, type = "bar") %>% 
    layout(title = "Número de Créditos otorgados por el ICETEX"
           , yaxis = list(title = 'Número de Créditos')
           , xaxis = list(title = 'Año')
           #, barmode = 'stack'
           )
# El número de créditos creció significativamente en el 2013 y 2014 tanto para créditos nuevos como para renovados
# Siempre el número de créditos nuevos ha sido mayor que el de renovados. 
# Al parecer los estudiantes no logran mantener el crédito o los montos por los que lo piden son pequeños

e5_2 <- plot_ly(
    data = e5[, sum(`Valor Credito`), keyby = .(`Ano`, `Estado Credito`)]
    , x = ~Ano, y = ~`V1`, color = ~`Estado Credito`, type = "bar") %>% 
    layout(title = "Créditos otorgados por el ICETEX"
           , yaxis = list(title = 'Valor de Créditos')
           , xaxis = list(title = 'Año')
           #, barmode = 'stack'
           )
# El crecimiento en el número de créditos fue directamente proporcional al valor de dichos créditos. 
# Se conservan las proporciones de créditos nuevos como renovados

# PROMEDIO DE CRÉDITO OTORGADO
e5_3 <- plot_ly(data = e5, x = ~`Promedio Credito`, type = "histogram")
# La mayoría de promedios está en entre 1 y 5 millones. 

e5_3_1 <- plot_ly(alpha = 0.6) %>%
    add_histogram(x = ~e5[, `Promedio Credito`]) %>%
    layout(barmode = "overlay"
           , xaxis = list(title = 'Promedio Crédito')
           , yaxis = list(title = 'Frecuencia de Créditos')
           )
# Tener cuidado con esta cifra: esta frecuencia de créditos no es la original sino que es por línea de crédito. Si tuviésemos crédito por crédito sería verídica esta cifra.

e5_3_2 <- plot_ly(
    data = e5[, sum(`Valor Credito`) / sum(`Numero Creditos`), keyby = .(`Ano`, `Estado Credito`)]
    , x = ~Ano, y = ~`V1`, color = ~`Estado Credito`, type = "bar") %>% 
    layout(title = "Créditos otorgados por el ICETEX"
           , yaxis = list(title = 'Promedio de Crédito')
           , xaxis = list(title = 'Año')
           #, barmode = 'stack'
    )
# Hay una tencendia al alza en los créditos asignados. Aún así, el promedio de crédito está entre los 2.5 millones y 3 millones. 

e5_3_3 <- plot_ly(
    data = e5[, sum(`Valor Credito`) / sum(`Numero Creditos`), keyby = .(`Ano`, `Linea Credito`)]
    , x = ~Ano, y = ~`V1`, color = ~`Linea Credito`, type = "bar") %>% 
    layout(title = "Créditos otorgados por el ICETEX"
           , yaxis = list(title = 'Promedio de Crédito')
           , xaxis = list(title = 'Año')
           #, barmode = 'stack'
    )
e5_3_4 <- e5[, sum(`Valor Credito`) / sum(`Numero Creditos`), keyby = .(`Ano`, `Linea Credito`)][order(V1, decreasing = TRUE)]
write.table(x = e5_3_4, file = "bi/e5_3_4.csv", sep = ",", row.names = F, na = "")
# En promedio los créditos más grandes los dan a estudios en el exterior:
# Pasantías intercambio 20/80: 16 millones
# Exterior Perfeccionamiento en Idiomas 20/80: 15 millones
# Exterior US$16000-20/80: 15 millones
# Exterior US$8000-20/80: 14 millones
# Luego vienen los créditos para postgrado en el país sin deudor: 7 millones, con deudor: 6.7 millones. 
# La brecha entre los créditos al exterior y nacional es de casi el doble. 
# El promedio de créditos para postgrado sin deudor ha ido en aumento más rápido que con deudor. 
# Luego vienen los Cursos Oficiales y Suboficiales: oscilan entre los 4.5 millones y 5. No fluctúan mucho. 
# En la categoría ECAES con Deudor solo hay cifras del 2011 (4 millones en promedio): ¿se dejó de continuar el programa? o ¿no hay cifras?
# LA siguiente categoría es "Maestria" en donde el promedio de crédito es 4 millones. 

e6 <- educacion$icfes
write.table(x = e6, file = "bi/e6.csv", sep = ",", row.names = F, na = "")

e6_1 <- plot_ly(
    data = e6[, mean(`Puntaje Prom`), keyby = .(`Ano`, `Materia`)]
    , x = ~Ano, y = ~`V1`, color = ~`Materia`, type = "bar") %>% 
    layout(title = "Créditos otorgados por el ICETEX"
           , yaxis = list(title = 'Promedio de Crédito')
           , xaxis = list(title = 'Año')
           #, barmode = 'stack'
    )
# Se calcula un promedio porque no tenemos los datos originales. Tener cuidado con esta cifra
e6_1_1 <- e6[, mean(`Puntaje Prom`), keyby = .(`Ano`, `Materia`)][order(V1, decreasing = TRUE)]
write.table(x = e6_1_1, file = "bi/e6_1_1.csv", sep = ",", row.names = F, na = "")

# RANKING
# Para realizar un ranking eliminamos :
# Ciencias Naturales
# Razonamiento Cuantitativo 
# Competencia ciudadana
# Lectura crítica
# porque solo hay datos del 2014.
logic <- !e6$Materia %in% c("Competencia Ciudadana", "Razonamiento cuantitativo", "Ciencias Naturales", "Lectura crítica")

# Cálculo del ranking:
e6_2 <-dcast.data.table(data = e6[logic]
    , formula = "Materia ~ Ano"
    , value.var = "Puntaje Prom"
    , fun.aggregate = function(x){
        round(mean(x, na.rm = FALSE), 1)
    }
)
write.table(x = e6_2, file = "bi/e6_2.csv", sep = ",", row.names = F, na = "")
e6_2_1 <- plot_ly(
    data = e6[logic, mean(`Puntaje Prom`, na.rm  = FALSE), keyby = .(Materia, Ano)][order(V1, decreasing = T)]
    , x = ~factor(Ano), y = ~V1, color = ~Materia) %>% add_lines()  %>%
    layout(title = 'Materias')

e6_3 <- e6_2
e6_3[, `2011` := frankv(`2011`, order = -1)]
e6_3[, `2012` := frankv(`2012`, order = -1)]
e6_3[, `2013` := frankv(`2013`, order = -1)]
e6_3[, `2014` := frankv(`2014`, order = -1)]
e6_3 <- melt.data.table(e6_3, id.vars = "Materia", variable.name = "Ano", value.name = "Ranking")
write.table(x = e6_3, file = "bi/e6_3.csv", sep = ",", row.names = F, na = "")

# Ranking generado solo con los números, no con los porcentajes. No se encontró nada raro.
e6_3_1 <- plot_ly(e6_3, x = ~Ano, y = ~Ranking, color = ~Materia) %>% add_lines()
# Inglés saltó 5 puestos en el Ranking y llegó de 2. 
# Matemáticas saltó 2 y llegó de primero
# Química retrocedió 4 puestos y terminó de 6. 
# Filosofía siempre ha sido el útlimo de todas las materias. 

# Análisis de la desviación estándar
e6_4 <- e6[order(`Desv. Est`, decreasing = T)]
# Las materias con mayor desviación estándar son filosofía, matemáticas y física. 
# Esto quiere decir que hay mayor dispersión en los datos (son más los que sacan muy bajo puntaje o muy alto puntaje)
# Esto implica una dispersión mayor en la educación de estas materias. 
# LAs materias con menor dispersión son inglés, biología, química y lenguaje. 
# Esto significa que son materias que no tienen mucha dispersión entre las calificaciones de los estudiantes.

e7 <- educacion$instituciones_educativas
write.table(x = e7, file = "bi/e7.csv", sep = ",", row.names = F, na = "")
# Es la tabla de instituciones educativas y no se le hará análisis. 

e8 <- educacion$matriculas
write.table(x = e8, file = "bi/e8.csv", sep = ",", row.names = F, na = "")

label = c("Tipo Institucion", "Area", "Tipo Nivel Educativo", "Numero Grado", "Municipio")[3]
e8$label <- e8[, label, with = FALSE]

plot_ly(
    data = e8[
        # Ano %in% c(2015, 2014, 2013) & 
        # Municipio %in% "Garzón"
        , sum(`Numero Matriculas`, na.rm = TRUE)
        , keyby = .(Ano, label)]
    , x = ~Ano
    , y = ~V1
    , color = ~label
    , colors = c("#d3ceaf", "#3C3A2E")
    , type = "bar"
    , hoverinfo = "text"
    , text = ~paste0(
        "Año: ", `Ano`
        , "<br>Texto : ", label
        , "<br>Total Matriculas: ", V1
    )
) %>% layout(barmode = "stack")
