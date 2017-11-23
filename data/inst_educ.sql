-- INSTITUCIONES EDUCATIVAS
SELECT
	j1.mun_nombre as "Municipio"
    , j2.ani_nombre as "Ano"
    , j3.tpin_nombre as "Tipo Institucion"
    , j4.tpe_nombre as "Plantel"
    , j5.are_nombre as "Area"
    , ine_num_instituciones as "Numero"
FROM "Educacion".instituciones_educativas as j
	LEFT JOIN "public"."municipio" as j1 on j1.mun_codigo = j."ine_codMunicipio"
    LEFT JOIN "public".anio as j2 on j2.ani_codigo = j.ine_anio
    LEFT JOIN "Educacion".tipo_institucion as j3 on j3.tpin_codigo = j.ine_tipo_institucion
    LEFT JOIN "Educacion".tipo_plantel_educativo as j4 on j4.tpe_codigo = j.ine_tipo_plantel
    LEFT JOIN "public".area as j5 on j5.are_codigo = j.ine_area