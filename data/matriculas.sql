SELECT
	m.mat_anio AS "Ano"
	, mun.mun_nombre AS "Municipio"
	, ti.tpin_nombre AS "Tipo Institucion"
	, a.are_nombre AS "Area"
	, tne.tpne_nombre AS "Tipo Nivel Educativo"
	, g.gra_nombre AS "Grado"
	, g.gra_codigo - 1 AS "Numero Grado"
	, m.mat_num_matriculas AS "Numero Matriculas"
	, m.mat_porce_cobertura as "Porcentaje de Cobertura"
FROM "Educacion"."matriculas" AS m
LEFT JOIN "public"."municipio" AS mun ON m."mat_codMunicipio" = mun.mun_codigo
LEFT JOIN "public"."area" AS a ON m."mat_area" = a.are_codigo
LEFT JOIN "Educacion"."tipo_institucion" AS ti ON m."mat_tipo_institucion" = ti.tpin_codigo
LEFT JOIN "Educacion"."tipo_nivel_educativo" AS tne ON m."mat_tipo_nivel_educativo" = tne.tpne_codigo
LEFT JOIN "Educacion"."grado" AS g ON m."mat_grado" = g.gra_codigo
