SELECT 
    j1.ani_nombre as "Ano"
    , j2.dep_nombre as "Departamento"
    , j3.mun_nombre as "Municipio"
    , j4.gen_nombre as "Genero"
    , j5.tpne_nombre as "Nivel Educativo"
    , j6.pro_nombre as "Programa"
    , j7.sem_nombre as "Semestre"
    , j.matu_num_matricula as "Num Matrículas"
FROM "Educacion".matriculas_usco as j
	LEFT JOIN "public".anio as j1 on j1.ani_codigo = j.matu_anio
    LEFT JOIN "public".departamento as j2 on j2.dep_codigo = j.matu_departamento
    LEFT JOIN "public".municipio as j3 on j3.mun_codigo = j."matu_codMunicipio"
    LEFT JOIN "public".genero as j4 on j4.gen_codigo = j.matu_genero
    LEFT JOIN "Educacion".tipo_nivel_educativo as j5 on j5.tpne_codigo = j.matu_tipo_nivel_educacion_superior
    LEFT JOIN "Educacion".programa as j6 on j6.pro_codigo = j.matu_programa
    LEFT JOIN "public".semestre as j7 on j7.sem_codigo = j.matu_semestre
