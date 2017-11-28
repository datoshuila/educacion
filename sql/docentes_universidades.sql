-- Directivos docentes de Universidades
SELECT
    dou_anio as "Ano"
    , j1.ined_nombre as "Universidad"
    , j2.sem_nombre as "Semestre"
    , j3.tpne_nombre as "Nivel Educativo"
    , j4.pro_nombre as "Programa"
    , j5.cpu_nombre as "Categoria Docentes"
    , j6.gen_nombre as "Genero"
    , "dou_num_personalU" as "Numero"
    
FROM "Educacion".docentes_universidades as j
	LEFT JOIN "Educacion".instituciones_educativas as j1 on j1.ined_codigo = j.dou_universidad
    LEFT JOIN public.semestre as j2 on j2.sem_codigo = j.dou_semestre
    LEFT JOIN "Educacion".tipo_nivel_educativo as j3 on j3.tpne_codigo = j.dou_nivel_educacion_superior
    LEFT JOIN "Educacion".programa as j4 on j4.pro_codigo = j.dou_programa
    LEFT JOIN "Educacion".categoria_personal as j5 on j5.cpu_codigo = j."dou_categoria_personalU"
    LEFT JOIN public.genero as j6 on j6.gen_codigo = j.dou_genero
