/* select 
	j1.mun_nombre as "Municipio"
    , j.educ_anio as "Ano"
    , j2.tpne_nombre as "Nivel Educativo"
    , j3.tpe_nombre as "Tipo Institucion"
    , j.educ_grado as "Grado"
    , j4.are_nombre as "Area"
    , j.educ_num_matriculas as "Matricula"
FROM "Educacion".educacion_adultos as j
	LEFT JOIN public.municipio as j1 on j1.mun_codigo = j.educ_municipio
    LEFT JOIN "Educacion".tipo_nivel_educativo as j2 on j2.tpne_codigo = j.educ_nivel_educativo
    LEFT JOIN "Educacion".tipo_plantel_educativo as j3 on j3.tpe_codigo = j.educ_tipo_institucion
    LEFT JOIN public.area as j4 on j4.are_codigo = j.educ_area
ESTE CÓDIGO NO ESTÁ LISTO. HAY QUE LIMPIAR LAS COLUMNAS.
*/
