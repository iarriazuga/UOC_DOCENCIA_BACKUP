CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DD_OD.DIM_ASSIGNATURA_LOADS()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'begin
let start_time timestamp_ntz := convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz);
let execution_time float;

merge into db_uoc_prod.dd_od.dim_assignatura
using (SELECT 0 AS id_assignatura, ''00.000'' AS dim_assignatura_key,''19000'' AS semestre_inici_doc,''19000'' AS semestre_extincio,''19000'' AS semestre_ini_eees,''ND'' AS idioma_docencia,''ND'' AS desc_cat,''ND'' AS desc_cas,''ND'' AS desc_ang,''ND'' AS desc_fra,''-'' AS ind_tfc,''-'' AS ind_practicum,''-'' AS ind_arees,''-'' AS ind_anual,''ND'' AS descripcio_assignatura,0 AS tipus_assignatura,0 AS num_credits,0 AS num_credits_teorics,0 AS num_credits_practics,''ND'' AS valor_assignatura,''ND'' AS ind_eval_continuada,''ND'' AS ind_exa_presencial,''ND'' AS ind_prova_conf,''ND'' AS cod_estudis_area,''ND'' AS tipus_educacio,''ND'' AS tipus_docencia_detall, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz) AS creation_date,convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz) AS update_date) AS dim_assignatura_repl
on db_uoc_prod.dd_od.dim_assignatura.id_assignatura = dim_assignatura_repl.id_assignatura
when matched
then update set update_date = convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz)
when not matched
then insert (id_assignatura, dim_assignatura_key, semestre_inici_doc, semestre_extincio, semestre_ini_eees, idioma_docencia, desc_cat, desc_cas, desc_ang, desc_fra, ind_tfc, ind_practicum, ind_arees, ind_anual, descripcio_assignatura, tipus_assignatura, num_credits, num_credits_teorics, num_credits_practics, valor_assignatura, ind_eval_continuada, ind_exa_presencial, ind_prova_conf, cod_estudis_area, tipus_educacio, tipus_docencia_detall, creation_date, update_date)
values (0,''00.000'',''19000'',''19000'',''1900'',''ND'',''ND'',''ND'',''ND'',''ND'',''-'',''-'',''-'',''-'',''ND'',0,0,0,0,''ND'',''ND'',''ND'',''ND'',''ND'',''ND'',''ND'',convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz),convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz))
;

merge into db_uoc_prod.dd_od.dim_assignatura
using (
SELECT
load_assignatures.cod_assignatura,
load_assignatures.any_acad_inicio_doc,
load_assignatures.any_acad_extincion,
load_assignatures.any_acad_ini_eees,
load_assignatures.idioma_docencia,
load_assignatures."''CAT''" AS desc_cat,
load_assignatures."''CAS''" AS desc_cas,
load_assignatures."''ANG''" AS desc_ang,
load_assignatures."''FRA''" AS desc_fra,
load_assignatures.ind_tfc,
load_assignatures.ind_practicum,
load_assignatures.ind_arees,
load_assignatures.ind_anual,
load_assignatures.descripcio_assignatura,
load_assignatures.tipus_assignatura,
load_assignatures.num_credits,
load_assignatures.num_credits_teorics,
load_assignatures.num_credits_practics,
load_assignatures.valor_assignatura,
load_assignatures.ind_eval_continuada,
load_assignatures.ind_exa_presencial,
load_assignatures.ind_prova_conf,
load_assignatures.cod_estudis_area,
load_assignatures.tipus_educacio,
load_assignatures.tipus_docencia_detall
FROM
(
SELECT
ifnull(db_uoc_prod.stg_dadesra.gat_asignaturas.cod_asignatura,ifnull(db_uoc_prod.stg_docencia.gat_asig_semestres.cod_asignatura,trim(db_uoc_prod.stg_docencia.gat_descripciones.clave))) AS cod_assignatura,
db_uoc_prod.stg_docencia.gat_asig_semestres.any_acad_inicio_doc,
db_uoc_prod.stg_docencia.gat_asig_semestres.any_acad_extincion,
db_uoc_prod.stg_docencia.gat_asig_semestres.any_acad_ini_eees,
ifnull(db_uoc_prod.stg_docencia.gat_asig_semestres.idioma_docencia,''ND'') AS idioma_docencia,
db_uoc_prod.stg_docencia.gat_descripciones.cod_idioma,
db_uoc_prod.stg_docencia.gat_descripciones.descripcion,
db_uoc_prod.stg_docencia.gat_descripciones.clave,
db_uoc_prod.stg_docencia.gat_asig_semestres.ind_tfc,
db_uoc_prod.stg_docencia.gat_asig_semestres.ind_practicum,
db_uoc_prod.stg_docencia.gat_asig_semestres.ind_arees,
db_uoc_prod.stg_docencia.gat_asig_semestres.ind_anual,
db_uoc_prod.stg_dadesra.gat_asignaturas.desc_asignatura AS descripcio_assignatura,
db_uoc_prod.stg_dadesra.gat_asignaturas.tipo_asignatura AS tipus_assignatura,
db_uoc_prod.stg_dadesra.gat_asignaturas.num_creditos AS num_credits,
db_uoc_prod.stg_dadesra.gat_asignaturas.num_creditos_teoricos AS num_credits_teorics,
db_uoc_prod.stg_dadesra.gat_asignaturas.num_creditos_practicos AS num_credits_practics,
db_uoc_prod.stg_dadesra.gat_asignaturas.valor_asignatura AS valor_assignatura,
db_uoc_prod.stg_dadesra.gat_asignaturas.ind_eval_continuada,
db_uoc_prod.stg_dadesra.gat_asignaturas.ind_exa_presencial,
db_uoc_prod.stg_dadesra.gat_asignaturas.ind_prueba_conf AS ind_prova_conf,
db_uoc_prod.stg_dadesra.gat_asignaturas.cod_estudios_area AS cod_estudis_area,
db_uoc_prod.stg_dadesra.gat_asignaturas.tipo_educacion AS tipus_educacio,
db_uoc_prod.stg_dadesra.gat_asignaturas.tipo_docencia_detalle AS tipus_docencia_detall,
db_uoc_prod.stg_docencia.gat_descripciones.nom_tabla,
db_uoc_prod.stg_docencia.gat_descripciones.nom_campo
FROM 
db_uoc_prod.stg_dadesra.gat_asignaturas
left join db_uoc_prod.stg_docencia.gat_asig_semestres
on db_uoc_prod.stg_docencia.gat_asig_semestres.cod_asignatura = db_uoc_prod.stg_dadesra.gat_asignaturas.cod_asignatura
left join db_uoc_prod.stg_docencia.gat_descripciones
on db_uoc_prod.stg_dadesra.gat_asignaturas.cod_asignatura = db_uoc_prod.stg_docencia.gat_descripciones.clave -- Anteriormente la clave tenia un trim. En la tabla descripciones algunas claves esta duplicadas lo unico que algunas con 7 caracteres (un espacio extra) y otras 6. Eso hacia duplicar resultados y dar errores
and db_uoc_prod.stg_docencia.gat_descripciones.nom_tabla = ''ASIGNATURAS''
and db_uoc_prod.stg_docencia.gat_descripciones.nom_campo = ''DESC_ASIGNATURA''
)
PIVOT (
max(descripcion) for cod_idioma
in (SELECT distinct cod_idioma FROM db_uoc_prod.stg_docencia.gat_descripciones where nom_tabla = ''ASIGNATURAS'' AND nom_campo = ''DESC_ASIGNATURA'' )
) AS load_assignatures
where nom_tabla = ''ASIGNATURAS''
and nom_campo = ''DESC_ASIGNATURA''
) AS dim_assignatura_orig
on db_uoc_prod.dd_od.dim_assignatura.dim_assignatura_key = dim_assignatura_orig.cod_assignatura
and db_uoc_prod.dd_od.dim_assignatura.semestre_inici_doc = dim_assignatura_orig.any_acad_inicio_doc
and db_uoc_prod.dd_od.dim_assignatura.idioma_docencia = dim_assignatura_orig.idioma_docencia


when matched then 
update set 
dim_assignatura_key = dim_assignatura_orig.cod_assignatura, semestre_inici_doc = dim_assignatura_orig.any_acad_inicio_doc, semestre_extincio = dim_assignatura_orig.any_acad_extincion, semestre_ini_eees = dim_assignatura_orig.any_acad_ini_eees, idioma_docencia = dim_assignatura_orig.idioma_docencia, desc_cat = dim_assignatura_orig.desc_cat, desc_cas = dim_assignatura_orig.desc_cas, desc_ang = dim_assignatura_orig.desc_ang, desc_fra = dim_assignatura_orig.desc_fra, ind_tfc = dim_assignatura_orig.ind_tfc, ind_practicum = dim_assignatura_orig.ind_practicum, ind_arees = dim_assignatura_orig.ind_arees, ind_anual = dim_assignatura_orig.ind_anual, descripcio_assignatura = dim_assignatura_orig.descripcio_assignatura, tipus_assignatura = dim_assignatura_orig.tipus_assignatura, num_credits = dim_assignatura_orig.num_credits, num_credits_teorics = dim_assignatura_orig.num_credits_teorics, num_credits_practics = dim_assignatura_orig.num_credits_practics, valor_assignatura = dim_assignatura_orig.valor_assignatura, ind_eval_continuada = dim_assignatura_orig.ind_eval_continuada, ind_exa_presencial = dim_assignatura_orig.ind_exa_presencial, ind_prova_conf = dim_assignatura_orig.ind_prova_conf, cod_estudis_area = dim_assignatura_orig.cod_estudis_area, tipus_educacio = dim_assignatura_orig.tipus_educacio, tipus_docencia_detall = dim_assignatura_orig.tipus_docencia_detall,  update_date = convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz)
when not matched then
insert (id_assignatura, dim_assignatura_key, semestre_inici_doc, semestre_extincio, semestre_ini_eees, idioma_docencia, desc_cat, desc_cas, desc_ang, desc_fra, ind_tfc, ind_practicum, ind_arees, ind_anual, descripcio_assignatura, tipus_assignatura, num_credits, num_credits_teorics, num_credits_practics, valor_assignatura, ind_eval_continuada, ind_exa_presencial, ind_prova_conf, cod_estudis_area, tipus_educacio, tipus_docencia_detall, creation_date, update_date) values (db_uoc_prod.dd_od.sequencia_id_assignatura.nextval, dim_assignatura_orig.cod_assignatura, dim_assignatura_orig.any_acad_inicio_doc, dim_assignatura_orig.any_acad_extincion, dim_assignatura_orig.any_acad_ini_eees, dim_assignatura_orig.idioma_docencia, dim_assignatura_orig.desc_cat, dim_assignatura_orig.desc_cas, dim_assignatura_orig.desc_ang, dim_assignatura_orig.desc_fra, dim_assignatura_orig.ind_tfc, dim_assignatura_orig.ind_practicum, dim_assignatura_orig.ind_arees, dim_assignatura_orig.ind_anual, dim_assignatura_orig.descripcio_assignatura, dim_assignatura_orig.tipus_assignatura, dim_assignatura_orig.num_credits, dim_assignatura_orig.num_credits_teorics, dim_assignatura_orig.num_credits_practics, dim_assignatura_orig.valor_assignatura, dim_assignatura_orig.ind_eval_continuada, dim_assignatura_orig.ind_exa_presencial, dim_assignatura_orig.ind_prova_conf, dim_assignatura_orig.cod_estudis_area, dim_assignatura_orig.tipus_educacio, dim_assignatura_orig.tipus_docencia_detall, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz), convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz));

execution_time := datediff(millisecond, start_time, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz));

insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
    values (db_uoc_prod.dd_od.sequencia_id_log.nextval, ''dim_assignatura_loads'', CURRENT_USER(), :start_time, :execution_time, ''dim_assignatura Success'');
    
return ''Update completed successfully'';

end';