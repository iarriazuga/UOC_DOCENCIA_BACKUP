CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DD_OD.STAGE_DOCENCIA_NO_CONVALIDADAS_LOADS()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'begin
let start_time timestamp_ntz := convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz);
let execution_time float;


merge into
    db_uoc_prod.dd_od.stage_docencia
using
(
SELECT 
gat_expedientes.num_expediente,
dim_expedient.super_expedient_v1 AS super_expedient,
gat_exp_matriculas.num_matricula,
gat_expedientes.idp,
tercers_paisos_nacionalitat.desc_nacionalidad AS nacionalitat,
tercers_paisos_naixement.descripcion AS pais_naixement,
tercers_paisos_residencia.descripcion AS pais_residencia,
tercers_direcciones.cod_postal AS codi_postal,
tercers_direcciones.ind_localizacion AS ind_localitzacio,
gat_expedientes.cod_plan,
gat_plan_datos.ind_titulaciones_propias AS titulacio_propia, --CP_dim_acces
gat_estudios.tipo_docencia_detalle AS tipus_docencia, -- CP_dim_acces
pac.via_acces AS via_acces, -- CP dim_acces
pac.descripcion AS opcio_acces, --CP dim_acces
tutor_unic_periode_hist.idp_tutor,
tutor_unic_periode_hist.tipo_tutor,
gat_expedientes.num_sol_acc,
gat_expedientes.nota_media,
gat_expedientes.nota_media_puntos,
gat_expedientes.any_acad_titulo,
gat_exp_matriculas.any_academico,
gat_exp_matriculas.any_acad_valida,
gat_exp_asig_matriculas.cod_asignatura,
1 AS assignatura_cursada,
gat_asignaturas.num_creditos,
gat_asignaturas.num_creditos_teoricos,
gat_asignaturas.num_creditos_practicos,
gat_exp_asig_matriculas.asigna_clase,
gat_exp_asig_matriculas.cod_aula,
gat_exp_asig_matriculas.cod_tfc,
gat_exp_asig_matriculas.ind_solo_examen,
gat_exp_asig_calificaciones.calif_num_cont,
gat_exp_asig_calificaciones.calif_num_cont_final,
gat_exp_asig_calificaciones.calif_numerica,
gat_exp_asig_calificaciones.calif_numerica_pub,
gat_exp_asig_calificaciones.calif_num_practica,
gat_exp_asig_calificaciones.calif_num_pres,
gat_exp_asig_calificaciones.calif_num_prop,
gat_exp_asig_calificaciones.calif_num_teorica,
gat_exp_asig_calificaciones.calif_practica,
gat_exp_asig_calificaciones.calif_teorica,
gat_exp_asig_calificaciones.cod_calif_conf,
gat_exp_asig_calificaciones.cod_calif_cont,
gat_exp_asig_calificaciones.cod_calif_cont_final,
gat_exp_asig_calificaciones.cod_calificacion,
gat_calificaciones.ind_supera,
gat_exp_asig_calificaciones.cod_calificacion_pub,
gat_exp_asig_calificaciones.cod_calif_pres,
gat_exp_asig_calificaciones.cod_calif_prop,
gat_exp_asig_calificaciones.cod_examen,
gat_exp_asig_calificaciones.idp_corrector,
iff(to_number(ifnull(to_char(gat_exp_matriculas.fecha_anulacion,''yyyymmdd''::string),0))=0,0,1) AS matricula_anulada,
iff(to_number(ifnull(to_char(gat_exp_asig_matriculas.fecha_anulacion,''yyyymmdd''::string),0))=0,0,1) AS assignatura_anulada,
0 AS assignatura_convalidada,
0 AS sec_solicitud,
0 AS num_reconocimiento,
tercers_datos_personas.fecha_nacim
FROM
db_uoc_prod.stg_mat.gat_expedientes
inner join db_uoc_prod.stg_mat.gat_exp_matriculas
on gat_expedientes.num_expediente = gat_exp_matriculas.num_expediente
inner join db_uoc_prod.stg_dadesra.gat_exp_asig_matriculas -- Al hacer un INNER estamos dejando fuera las matriculas de los estudiantes que convalidan. Cuando queramos incorporarlos necesitaremos hacer un left
on gat_exp_matriculas.num_expediente = gat_exp_asig_matriculas.num_expediente
and gat_exp_matriculas.any_academico = gat_exp_asig_matriculas.any_academico
left outer join db_uoc_prod.stg_docencia.gat_exp_asig_calificaciones
on gat_exp_asig_matriculas.num_expediente = gat_exp_asig_calificaciones.num_expediente
and gat_exp_asig_matriculas.any_academico = gat_exp_asig_calificaciones.any_academico
and gat_exp_asig_matriculas.cod_asignatura = gat_exp_asig_calificaciones.cod_asignatura
left outer join db_uoc_prod.stg_docencia.gat_calificaciones
on gat_exp_asig_calificaciones.cod_calificacion = db_uoc_prod.stg_docencia.gat_calificaciones.cod_calificacion
left outer join db_uoc_prod.stg_dadesra.gat_asignaturas
on db_uoc_prod.stg_docencia.gat_exp_asig_calificaciones.cod_asignatura = db_uoc_prod.stg_dadesra.gat_asignaturas.cod_asignatura
left outer join db_uoc_prod.stg_mat.tercers_datos_personas
on db_uoc_prod.stg_mat.gat_expedientes.idp = db_uoc_prod.stg_mat.tercers_datos_personas.idp
left join db_uoc_prod.stg_mat.tercers_paises AS tercers_paisos_nacionalitat -- son left no iners
on db_uoc_prod.stg_mat.tercers_datos_personas.cod_pais_nacion = tercers_paisos_nacionalitat.cod_pais
left join db_uoc_prod.stg_mat.tercers_paises AS tercers_paisos_naixement -- son left no iners / codigo añadido por mi
on db_uoc_prod.stg_mat.tercers_datos_personas.cod_pais_nacim = tercers_paisos_naixement.cod_pais
left join db_uoc_prod.stg_mat.tercers_ref_direcciones 
on gat_expedientes.idp = tercers_ref_direcciones.cod_elemento
left join db_uoc_prod.stg_mat.tercers_direcciones
on tercers_ref_direcciones.num_direccion = tercers_direcciones.num_direccion
left join db_uoc_prod.stg_mat.tercers_paises AS tercers_paisos_residencia
on tercers_direcciones.cod_pais = tercers_paisos_residencia.cod_pais
left join stg_mat.gat_plan_datos
on gat_expedientes.cod_plan = gat_plan_datos.cod_plan
left join stg_mat.gat_estudios 
on gat_plan_datos.cod_estudios = gat_estudios.cod_estudios
left join stg_mat.gat_cab_solicitud_acc
on gat_expedientes.num_expediente = gat_cab_solicitud_acc.num_expediente AND gat_cab_solicitud_acc.num_expediente  not in (505356, 520316) -- esos dos expedientes tienen 2 accesos y eso hace multiplicar los registros, se deberia corregir en origen.
left join (SELECT distinct pa.cod_opc_Acc, pa.DESCRIPCION ,pa.COD_PLAN,pa.COD_CENTRO, va.DESCRIPCION AS Via_acces 
                        FROM STG_MAT.gat_plan_accesos pa
                        inner JOIN STG_MAT.gat_vias_acc va ON pa.cod_via_acc = va.cod_via_acc
            ) pac -- desc vias i desc opciones acceso
on pac.cod_opc_Acc = gat_cab_solicitud_acc.cod_opc_acc AND pac.COD_CENTRO = gat_cab_solicitud_acc.COD_CENTRO AND pac.COD_PLAN = gat_cab_solicitud_acc.COD_PLAN
left join dim_expedient 
on gat_expedientes.num_expediente = dim_expedient.dim_expedient_key
left join db_uoc_prod.dd_od.tutor_unic_periode_hist
on gat_expedientes.num_expediente = tutor_unic_periode_hist.num_expedient and
   (gat_exp_matriculas.any_academico >= any_acad_alta AND (gat_exp_matriculas.any_academico < any_acad_baja or any_acad_baja is null))
) AS load_docencia
on stage_docencia.num_expedient = load_docencia.num_expediente
and stage_docencia.idp =  load_docencia.idp
and stage_docencia.cod_pla = load_docencia.cod_plan
and stage_docencia.any_academic = ifnull(load_docencia.any_academico,''19000'')
and stage_docencia.cod_assignatura = ifnull(load_docencia.cod_asignatura,''00.000'')
and stage_docencia.num_reconeixement = ifnull(load_docencia.num_reconocimiento,0)
and stage_docencia.sec_solicitud = ifnull(load_docencia.sec_solicitud,0)
when matched then

    update set
        num_expedient = load_docencia.num_expediente, super_expedient = load_docencia.super_expedient, num_matricula = load_docencia.num_matricula, idp = load_docencia.idp, nacionalitat = load_docencia.nacionalitat, pais_naixement = load_docencia.pais_naixement, pais_residencia = load_docencia.pais_residencia, codi_postal = load_docencia.codi_postal, ind_localitzacio = load_docencia.ind_localitzacio, cod_pla = load_docencia.cod_plan, titulacio_propia = load_docencia.titulacio_propia, tipus_docencia = load_docencia.tipus_docencia, via_acces= load_docencia.via_acces, opcio_acces =load_docencia.opcio_acces,  idp_tutor = load_docencia.idp_tutor, tipus_tutor = load_docencia.tipo_tutor, num_sol_acc = load_docencia.num_sol_acc, nota_mitjana = load_docencia.nota_media, nota_mitjana_punts = load_docencia.nota_media_puntos, any_acad_titol = load_docencia.any_acad_titulo, any_academic = ifnull(load_docencia.any_academico,''19000''), any_acad_valida = load_docencia.any_acad_valida, cod_assignatura = ifnull(load_docencia.cod_asignatura,''00.000''), assignatura_cursada = load_docencia.assignatura_cursada, num_credits = load_docencia.num_creditos, num_credits_teorics = load_docencia.num_creditos_teoricos, num_credits_practics = load_docencia.num_creditos_practicos, assigna_clase = load_docencia.asigna_clase, cod_aula = load_docencia.cod_aula, cod_tfc = load_docencia.cod_tfc, ind_sols_examen = load_docencia.ind_solo_examen, qualif_num_cont = load_docencia.calif_num_cont, qualif_num_cont_final = load_docencia.calif_num_cont_final, qualif_numerica = load_docencia.calif_numerica, qualif_numerica_pub = load_docencia.calif_numerica_pub, qualif_num_practica = load_docencia.calif_num_practica, qualif_num_pres = load_docencia.calif_num_pres, qualif_num_prop = load_docencia.calif_num_prop, qualif_num_teorica = load_docencia.calif_num_teorica, qualif_practica = load_docencia.calif_practica, qualif_teorica = load_docencia.calif_teorica, cod_qualif_conf = load_docencia.cod_calif_conf, cod_qualif_cont = load_docencia.cod_calif_cont, cod_qualif_cont_final = load_docencia.cod_calif_cont_final, cod_qualificacio = load_docencia.cod_calificacion, ind_supera = load_docencia.ind_supera, cod_qualificacio_pub = load_docencia.cod_calificacion_pub, cod_qualif_pres = load_docencia.cod_calif_pres, cod_qualif_prop = load_docencia.cod_calif_prop, cod_examen = load_docencia.cod_examen, idp_corrector = load_docencia.idp_corrector, matricula_anulada = load_docencia.matricula_anulada, assignatura_anulada = load_docencia.assignatura_anulada, assignatura_convalidada = load_docencia.assignatura_convalidada, sec_solicitud = load_docencia.sec_solicitud, num_reconeixement = load_docencia.num_reconocimiento, data_naixement = load_docencia.fecha_nacim, update_date = convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz)
when not matched then
    insert
        (
        id_docencia,
    	num_expedient,
        super_expedient,
        num_matricula,
    	idp,
        nacionalitat,
        pais_naixement,
        pais_residencia,
        codi_postal,
        ind_localitzacio,
    	cod_pla,
        titulacio_propia, 
        tipus_docencia, 
        via_acces, 
        opcio_acces,
    	idp_tutor,
        tipus_tutor,
    	num_sol_acc,
    	nota_mitjana,
    	nota_mitjana_punts,
    	any_acad_titol,
    	any_academic,
    	any_acad_valida,
    	cod_assignatura,
        assignatura_cursada,
        num_credits,
        num_credits_teorics,
        num_credits_practics,
    	assigna_clase,
    	cod_aula,
    	cod_tfc,
    	ind_sols_examen,
    	qualif_num_cont,
    	qualif_num_cont_final,
    	qualif_numerica,
    	qualif_numerica_pub,
    	qualif_num_practica,
    	qualif_num_pres,
    	qualif_num_prop,
    	qualif_num_teorica,
    	qualif_practica,
    	qualif_teorica,
    	cod_qualif_conf,
    	cod_qualif_cont,
    	cod_qualif_cont_final,
    	cod_qualificacio,
        ind_supera,
    	cod_qualificacio_pub,
    	cod_qualif_pres,
    	cod_qualif_prop,
    	cod_examen,
    	idp_corrector,
        matricula_anulada,
        assignatura_anulada,
        assignatura_convalidada,
        sec_solicitud,
        num_reconeixement,
        data_naixement,
    	creation_date,
    	update_date
        )
    values
        (
        db_uoc_prod.dd_od.sequencia_id_stage_docencia.nextval,
        load_docencia.num_expediente,
        load_docencia.super_expedient,
        load_docencia.num_matricula,
        load_docencia.idp,
        load_docencia.nacionalitat,
        load_docencia.pais_naixement,
        load_docencia.pais_residencia,
        load_docencia.codi_postal,
        load_docencia.ind_localitzacio,
        load_docencia.cod_plan,
        load_docencia.titulacio_propia, 
        load_docencia.tipus_docencia, 
        load_docencia.via_acces, 
        load_docencia.opcio_acces,
        load_docencia.idp_tutor,
        load_docencia.tipo_tutor,
        load_docencia.num_sol_acc,
        load_docencia.nota_media,
        load_docencia.nota_media_puntos,
        load_docencia.any_acad_titulo,
        ifnull(load_docencia.any_academico,''19000''),
        load_docencia.any_acad_valida,
        ifnull(load_docencia.cod_asignatura,''00.000''),
        load_docencia.assignatura_cursada,
        load_docencia.num_creditos,
        load_docencia.num_creditos_teoricos,
        load_docencia.num_creditos_practicos,
        load_docencia.asigna_clase,
        load_docencia.cod_aula,
        load_docencia.cod_tfc,
        load_docencia.ind_solo_examen,
        load_docencia.calif_num_cont,
        load_docencia.calif_num_cont_final,
        load_docencia.calif_numerica,
        load_docencia.calif_numerica_pub,
        load_docencia.calif_num_practica,
        load_docencia.calif_num_pres,
        load_docencia.calif_num_prop,
        load_docencia.calif_num_teorica,
        load_docencia.calif_practica,
        load_docencia.calif_teorica,
        load_docencia.cod_calif_conf,
        load_docencia.cod_calif_cont,
        load_docencia.cod_calif_cont_final,
        load_docencia.cod_calificacion,
        load_docencia.ind_supera,
        load_docencia.cod_calificacion_pub,
        load_docencia.cod_calif_pres,
        load_docencia.cod_calif_prop,
        load_docencia.cod_examen,
        load_docencia.idp_corrector,
        load_docencia.matricula_anulada,
        load_docencia.assignatura_anulada,
        load_docencia.assignatura_convalidada,
        load_docencia.sec_solicitud,
        load_docencia.num_reconocimiento,
        load_docencia.fecha_nacim,
        convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz),
        convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz)
        )
;

execution_time := datediff(millisecond, start_time, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz));

insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
    values (db_uoc_prod.dd_od.sequencia_id_log.nextval, ''stage_docencia_no_convalidadas_loads'', CURRENT_USER(), :start_time, :execution_time, ''stage_docencia Success'');
    
return ''Update completed successfully'';

end';