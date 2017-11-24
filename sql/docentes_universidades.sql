-- Directivos docentes de Universidades
SELECT
    dau_anio
    , j1.uni_nombre as "Universidad"
    , j2.sem_nombre as "Semestre"
    , j3.tpne_nombre as "Nivel Educativo"
    , j4.pro_nombre as "Programa"
    , j5.cpu_nombre as "Categoria Docentes"
    , j6.gen_nombre as "Genero"
    , "dau_num_personalU" as "Numero"
FROM "Educacion".docentes_universidades j
	LEFT JOIN "Educacion".universidad as j1 on j1.uni_codigo = j.dau_universidad
    LEFT JOIN public.semestre as j2 on j2.sem_codigo = j.dau_semestre
    LEFT JOIN "Educacion".tipo_nivel_educativo as j3 on j3.tpne_codigo = j.dau_nivel_educacion_superior
    LEFT JOIN "Educacion".programa as j4 on j4.pro_codigo = j.dau_programa
    LEFT JOIN "Educacion".categoria_personal as j5 on j5.cpu_codigo = j."dau_categoria_personalU"
    LEFT JOIN public.genero as j6 on j6.gen_codigo = j.dau_genero
