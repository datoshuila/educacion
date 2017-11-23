-- Matrículas por año, municipio, tipo de institución, área (urbana o rural), nivel educativo (preescolar, bachillerato), y grado.
SELECT
	j.mat_anio AS "Ano"
	, j2.mun_nombre AS "Municipio"
	, j4.tpin_nombre AS "Tipo Institucion"
	, j3.are_nombre AS "Area"
	, j5.tpne_nombre AS "Tipo Nivel Educativo"
	, j6.gra_nombre AS "Grado"
	, j6.gra_codigo - 1 AS "Numero Grado"
	, j.mat_num_matriculas AS "Numero Matriculas"
FROM "Educacion".matriculas AS j
    LEFT JOIN public.municipio AS j2 ON j."mat_codMunicipio" = j2.mun_codigo
    LEFT JOIN public.area AS j3 ON j.mat_area = j3.are_codigo
    LEFT JOIN "Educacion".tipo_institucion AS j4 ON j."mat_tipo_institucion" = j4.tpin_codigo
    LEFT JOIN "Educacion"."tipo_nivel_educativo" AS j5 ON j."mat_tipo_nivel_educativo" = j5.tpne_codigo
    LEFT JOIN "Educacion"."grado" AS j6 ON j."mat_grado" = j6.gra_codigo
