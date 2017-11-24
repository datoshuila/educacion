-- Desempeño de los estudiantes (aprobados, reprobados, desertores) por municipio, año, tipo institución (oficinal, no oficial). 
SELECT
    m.mun_nombre as "Municipio"
    , c.coal_anio as "Ano"
    , ti.tpin_nombre as "Tipo Institucion"
    , c.coal_aprobados as "N_Aprobados"
    , c.coal_reprobados as "N_Reprobados"
    , c.coal_desertores as "N_Desertores"
    , c.coal_traslados as "N_Traslados"
    , c.coal_porce_aprobados as "P_Aprobados"
    , c.coal_porce_reprobados as "P_Reprobados"
    , c.coal_porce_desertores as "P_Desertores"
    , c.coal_porce_traslados as "P_Traslados"
FROM "Educacion"."comportamiento_alumnos" AS c
LEFT JOIN "public"."municipio" AS m ON c."coal_codMunicipio" = m.mun_codigo
LEFT JOIN "Educacion"."tipo_institucion" AS ti ON c."coal_tipo_institucion" = ti.tpin_codigo
