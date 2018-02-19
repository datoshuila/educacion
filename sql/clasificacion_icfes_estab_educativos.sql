-- Clasificación ICFES establecimientos educativos
SELECT 
	a.ani_nombre as "Ano"
    , s.sem_nombre as "Semestre"
    , j.cies_puesto as "Puesto"
    , j5.ined_nombre as "Colegio"
    , mun.mun_nombre as "Municipio"
    , ti.tpin_nombre as "Tipo"
    , j.cies_indice as "Indice"
    , j.cies_categoria as "Categoria"
FROM "Educacion".clasificacion_icfes_estab_educativos as j
	LEFT JOIN "public"."municipio" AS mun ON j."cies_codMunicipio" = mun.mun_codigo
	LEFT JOIN "public"."anio" AS a ON j."cies_anio" = a.ani_codigo
    LEFT JOIN "public"."semestre" AS s ON s.sem_codigo = j.cies_semestre
	LEFT JOIN "public"."tipo_institucion_educativa" AS ti ON j.cies_tipo_institucion = ti.tpin_codigo
    LEFT JOIN "Educacion".instituciones_educativas as j5 on j.cies_institucion_educativa = j5.ined_codigo
