# Educación
Análisis del Sector Educativo en el Departamento del Huila

# Metodología

## 1. Levantamiento de la información

La información de este tablero de control proviene de los archivos CSV enviados por la Secretaría de Educación al Departamento Administrativo de Planeación.

## 2. Alistamiento de la información

1. Desarrollo de un modelo de datos para la data.
2. Creación de Vistas dentro de la base de datos para acelerar el proceso de consulta.
3. Subida de los archivos CSV a una base de datos PostgreSQL.
4. Lectura de los datos a través del archivo "analysis.R" en la carpeta "bi".

Algunos hallazgos relevantes:
1. En la tabla "matriculas" es necesario incluir la institución educativa a la que hace parte cada fila. 
2. En la tabla "matriculas_usco" para los años 2015 y 2016 es necesario que los datos estén organizados por género para saber el total de matriculados.
3. En la tabla "matriculas_usco" es necesario incluir el municipio de procedencia para los departamentos diferentes al Huila. Para aquellos estudiantes que provienen del Huila ya existe un municipio asignado. 

## 3. Objetivos de negocio

El objetivo es entregar las métricas del desempeño en educación para que la Secretaría tome decisiones de inversión en el Departamento. 

1. ¿cuál ha sido el desempeño escolar del Departamento en los últimos años?
2. ¿qué proporción de matriculados históricamente hay desglosado por múltiples categorías?
3. ¿de dónde son los estudiantes de la Surcolombiana?
4. ¿cuál es la carrera más apetecida en el Huila por municipio y año?
5. ¿cuál es el porcentaje de cobertura escolar por municipio en cada año?
6. ¿qué sector económico tiene el mayor número de cursos en el SENA? ¿a qué nivel de formación?

## 4. Procesamiento de los datos y generación de modelos

1. Configuración del código
    1. Creación del archivo "requirements.sh" para instalar todos los paquetes necesarios para correr el procesamiento. 

## 5. Visualización de datos

1. Definición de la conexión a la base de datos:
    1. Flujo de conexión a la base de datos.
    2. Protocolos de seguridad (SSL, Encriptación).
    3. Cargue de datos en cliente o servidor. 
2. Definición de las gráficas:
    1. Nombres.
    2. Contenidos.
    3. Tipo (barchart, piechart, timeseries, etc).
    4. Filtros locales y globales. 
3. Contenido de los textos:
    1. Información relevantes.
    2. Filtros locales y globales. 
    3. Referencias a otros portales.