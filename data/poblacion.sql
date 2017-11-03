SELECT 
	m.mun_nombre as "Municipio"
	, p.ped_anio as "Ano"
	, pe.pes_nombre as "Rango"
	, p.ped_num_poblacion_escolar as "Poblacion"
FROM "Educacion"."poblacion_edad_escolar" as p
LEFT JOIN "Educacion"."poblacion_escolar" as pe on pe.pes_codigo = p.ped_poblacion_escolar
LEFT JOIN "public"."municipio" as m on m.mun_codigo = p."ped_codMunicipio"
