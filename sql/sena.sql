
SELECT
	sen_anio as "Ano"
    , j1.mun_nombre as "Municipio"
    , j2.sec_nombre as "Sector Economico"
    , j3.nfs_nombre as "Nivel Formacion"
    , sen_num_cursos as "Numero Cursos"
    , "sen_num_aprendicesHombres" as "Aprendices Hombres"
    , "sen_num_aprendicesMujeres" as "Aprendices Mujeres"
FROM "Educacion".sena as j
	LEFT JOIN "public".municipio as j1 on j1.mun_codigo = j."sen_codMunicipio"
    LEFT JOIN "Educacion".sector_economico_sena as j2 on j2.sec_codigo = j.sen_sector_economico
    LEFT JOIN "Educacion".nivel_formacion_sena as j3 on j3.nfs_codigo = j.sen_nivel_formacion_sena
