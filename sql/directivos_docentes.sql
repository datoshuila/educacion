-- Número de Directivos Docentes en cada Institución de Bachillerato
SELECT 
     u.ddo_anio as "Ano"
    , mun.mun_nombre as "Municipio"
    , cat.cdd_nombre as "Categoria"
    , u.ddo_num_directivo_docente as "Numero"
FROM "Educacion".directivos_docentes as u
	LEFT JOIN "public"."municipio" AS mun ON u."ddo_codMunicipio" = mun.mun_codigo
    LEFT JOIN "Educacion"."categoria_directivo_docente" AS cat ON u.ddo_categoria_directivo_docente = cat.cdd_codigo
