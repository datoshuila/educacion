-- Clasificación ICFES establecimientos educativos
SELECT 
	a.ani_nombre as "Ano"
    , s.sem_nombre as "Semestre"
    , i.cies_puesto as "Puesto"
    , i.cies_institucion_educativa as "Colegio"
    , mun.mun_nombre as "Municipio"
    , ti.tpin_nombre as "Tipo"
    , i.cies_indice as "Indice"
    , i.cies_categoria as "Categoria"
FROM "Educacion".clasificacion_icfes_estab_educativos as i
	LEFT JOIN "public"."municipio" AS mun ON i."cies_codMunicipio" = mun.mun_codigo
	LEFT JOIN "public"."anio" AS a ON i."cies_anio" = a.ani_codigo
    LEFT JOIN "public"."semestre" AS s ON s.sem_codigo = i.cies_semestre
	LEFT JOIN "Educacion"."tipo_institucion" AS ti ON i.cies_tipo_institucion = ti.tpin_codigo