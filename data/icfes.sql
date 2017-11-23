-- 
SELECT 
   icf_anio as "Ano"
   , j1.alc_nombre as "Alcance"
   , j2.sem_nombre as "Semestre"
   , j3.mate_nombre as "Materia"
   , icf_puntaje_prom as "Puntaje Prom"
   , icf_desviacion_est as "Desv. Est"
FROM "Educacion".icfes as j
	LEFT JOIN "public".alcance as j1 on j1.alc_codigo = j.icf_alcance
    LEFT JOIN "public".semestre as j2 on j2.sem_codigo = j.icf_semestre
    LEFT JOIN "Educacion".materias as j3 on j3.mate_codigo = j.icf_materias