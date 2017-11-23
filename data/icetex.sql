SELECT 
    j.ice_anio as "Ano"
    , j1.lic_nombre as "Linea Credito"
    , j2.esc_nombre as "Estado Credito"
    , j.ice_num_credito as "Numero Creditos"
    , j.ice_valor_credito as "Valor Credito"
FROM "Educacion".icetex as j
	LEFT JOIN "Educacion".linea_credito as j1 on j.ice_linea_credito = j1.lic_codigo
    LEFT JOIN "Educacion".estado_credito as j2 on j.ice_estado_credito = j2.esc_codigo