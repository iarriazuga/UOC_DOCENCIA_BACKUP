CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DD_OD.STAGE_DOCENCIA_POST_LOADS()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'begin
let start_time timestamp_ntz := convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz);
let execution_time float;

 
CREATE OR REPLACE temporary table db_uoc_prod.dd_od.semestres_relatius_temporary_table AS
with p AS (
SELECT idp,
       super_expedient,
       num_expedient, 
       any_academic, 
       count (case when assignatura_convalidada = 0 AND assignatura_anulada = 0 then cod_assignatura  end ) AS num_ass_no_convalidada,
       count (case when assignatura_convalidada = 1 AND assignatura_anulada = 0 then cod_assignatura  end ) AS num_ass_convalidada
FROM db_uoc_prod.dd_od.stage_docencia
where matricula_anulada = 0 
group by idp,super_expedient,num_expedient, any_academic
having num_ass_no_convalidada >= 1
)
SELECT *,
       dense_rank () over (partition by num_expedient order by any_academic asc) AS semestre_relatiu_expedient,
       dense_rank () over (partition by super_expedient order by any_academic asc) AS semestre_relatiu_super_expedient,
       dense_rank () over (partition by idp order by any_academic asc) AS semestre_relatiu_uoc
FROM p
order by 1, 2, 3, 4, 7, 8, 9;

 

merge into
    db_uoc_prod.dd_od.stage_docencia_post
using
(
    
    
    SELECT stage_docencia.id_docencia,
        stage_docencia.num_expedient,
        stage_docencia.super_expedient,
        stage_docencia.num_matricula,
        stage_docencia.idp,
        ifnull(stage_docencia.nacionalitat,''ND'') AS nacionalitat,
        ifnull(stage_docencia.pais_naixement,''ND'') AS pais_naixement,
        case 
        when stage_docencia.pais_residencia is null then ''ND''
        else stage_docencia.pais_residencia
        end AS pais_residencia_dim,
        case 
        when stage_docencia.pais_residencia <> ''Espanya'' then 99999
        else stage_docencia.codi_postal
        end AS codi_postal_dim,
        concat (pais_residencia_dim, ifnull(codi_postal_dim,0), ifnull (stage_docencia.ind_localitzacio,0)) AS dim_pais_residencia, 
        concat (stage_docencia.tipus_docencia,stage_docencia.titulacio_propia,stage_docencia.via_acces,stage_docencia.opcio_acces) AS dim_acces_key,
        stage_docencia.cod_pla,
        concat (idp_tutor,tipus_tutor) AS dim_persona_tutor_key,
        stage_docencia.idp_tutor,
        stage_docencia.tipus_tutor,
        stage_docencia.num_sol_acc,
        stage_docencia.nota_mitjana,
        stage_docencia.nota_mitjana_punts,
        stage_docencia.any_acad_titol,
        stage_docencia.any_academic,
        stage_docencia.any_acad_valida,
        stage_docencia.cod_assignatura,
        stage_docencia.assignatura_cursada,
        stage_docencia.num_credits,
        stage_docencia.num_credits_teorics,
        stage_docencia.num_credits_practics,
        case 
        when stage_docencia.matricula_anulada = 1 or stage_docencia.assignatura_anulada = 1 then null
        else stage_docencia.any_academic
        end AS any_acad_calculos,
        case 
        when any_acad_calculos is null then null 
        else dense_rank() over (partition by  stage_docencia.super_expedient, stage_docencia.cod_assignatura order by any_acad_calculos asc) 
        end AS num_matriculas_assignatura,
        case
        when num_matriculas_assignatura = 1 then ''NOU''
        when num_matriculas_assignatura > 1 then ''REPETIDOR''
        else ''ND''
        end AS tipus_estudiant_assignatura,
        semestres_relatius_temporary_table.semestre_relatiu_expedient,
        case
        when semestres_relatius_temporary_table.semestre_relatiu_expedient = 1 then ''NOU''
        when semestres_relatius_temporary_table.semestre_relatiu_expedient > 1 then ''REMATRICULA''
        else ''ND''
        end AS tipus_matricula,
        semestres_relatius_temporary_table.semestre_relatiu_super_expedient,
        semestres_relatius_temporary_table.semestre_relatiu_uoc,
        case
        when semestres_relatius_temporary_table.semestre_relatiu_uoc = 1 then ''NOU''
        when semestres_relatius_temporary_table.semestre_relatiu_uoc > 1 then ''NO_NOU_A_LA_UOC''
        else ''ND''
        end AS tipus_matricula_uoc,
        stage_docencia.assigna_clase,
        stage_docencia.cod_aula,
        stage_docencia.cod_tfc,
        stage_docencia.ind_sols_examen,
        stage_docencia.qualif_num_cont,
        stage_docencia.qualif_num_cont_final,
        stage_docencia.qualif_numerica,
        stage_docencia.qualif_numerica_pub,
        stage_docencia.qualif_num_practica,
        stage_docencia.qualif_num_pres,
        stage_docencia.qualif_num_prop,
        stage_docencia.qualif_num_teorica,
        stage_docencia.qualif_practica,
        stage_docencia.qualif_teorica,
        stage_docencia.cod_qualif_conf,
        stage_docencia.cod_qualif_cont,
        stage_docencia.cod_qualif_cont_final,
        stage_docencia.cod_qualificacio,
        stage_docencia.ind_supera,
        case
        when stage_docencia.ind_supera = ''S'' then 1
        else 0
        end supera_assignatura,
        case
        when stage_docencia.ind_supera = ''N'' then 1
        else 0
        end no_supera_assignatura,
        stage_docencia.cod_qualificacio_pub,
        stage_docencia.cod_qualif_pres,
        stage_docencia.cod_qualif_prop,
        stage_docencia.cod_examen,
        stage_docencia.idp_corrector,
        stage_docencia.matricula_anulada,
        stage_docencia.assignatura_anulada,
        stage_docencia.assignatura_convalidada,
        CAST (lpad(stage_docencia.any_academic,4) - year (stage_docencia.data_naixement) AS integer) AS edat_relativa,
        case 
        when edat_relativa < 15 then ''edat errònia''
        when edat_relativa <= 19 then ''19 o menys''
        when edat_relativa <= 24 then ''20 a 24''
        when edat_relativa <= 29 then ''25 a 29''
        when edat_relativa <= 34 then ''30 a 34''
        when edat_relativa <= 39 then ''35 a 39''
        when edat_relativa <= 44 then ''40 a 44''
        when edat_relativa <= 49 then ''45 a 49''
        when edat_relativa <= 100 then ''50 o més''
        when edat_relativa > 100 then ''edat errònia'' 
        end AS grup_edat,
        case 
        when edat_relativa < 15 then ''edat errònia''
        when edat_relativa <= 24 then ''18 a 24''
        when edat_relativa <= 29 then ''25 a 29''
        when edat_relativa <= 39 then ''30 a 39''
        when edat_relativa <= 49 then ''40 a 49''
        when edat_relativa <= 100 then ''majors 50''
        when edat_relativa > 100 then ''edat errònia'' 
        end AS grup_edat_2,
        stage_docencia.creation_date,
        stage_docencia.update_date
FROM db_uoc_prod.dd_od.stage_docencia
left join db_uoc_prod.dd_od.semestres_relatius_temporary_table
on stage_docencia.num_expedient = semestres_relatius_temporary_table.num_expedient 
and stage_docencia.any_academic = semestres_relatius_temporary_table.any_academic
) AS stage_docencia
on stage_docencia_post.id_docencia = stage_docencia.id_docencia
when matched then
    update
    set
       dim_expedient_key = stage_docencia.num_expedient, dim_matricula_key = concat(to_char(stage_docencia.num_expedient), to_varchar(stage_docencia.any_academic), to_char(stage_docencia.num_matricula)), dim_portafoli_pa_key = stage_docencia.cod_pla, idp = stage_docencia.idp, dim_pais_nacionalitat_key = stage_docencia.nacionalitat, dim_pais_naixement_key = stage_docencia.pais_naixement, dim_pais_residencia_key = stage_docencia.dim_pais_residencia,dim_acces_key = stage_docencia.dim_acces_key, dim_persona_tutor_key = stage_docencia.dim_persona_tutor_key,super_expedient = stage_docencia.super_expedient, cod_pla = stage_docencia.cod_pla, idp_tutor = stage_docencia.idp_tutor, tipus_tutor = stage_docencia.tipus_tutor,num_sol_acc = stage_docencia.num_sol_acc, nota_mitjana = stage_docencia.nota_mitjana, nota_mitjana_punts = stage_docencia.nota_mitjana_punts, any_acad_titol = stage_docencia.any_acad_titol, any_academic = stage_docencia.any_academic, any_acad_valida = stage_docencia.any_acad_valida, cod_assignatura = stage_docencia.cod_assignatura, assignatura_cursada = stage_docencia.assignatura_cursada, num_credits = stage_docencia.num_credits, num_credits_teorics = stage_docencia.num_credits_teorics, num_credits_practics = stage_docencia.num_credits_practics, num_matriculas_assignatura = stage_docencia.num_matriculas_assignatura, tipus_estudiant_assignatura= stage_docencia.tipus_estudiant_assignatura, semestre_relatiu_expedient= stage_docencia.semestre_relatiu_expedient, tipus_matricula=stage_docencia.tipus_matricula,semestre_relatiu_super_expedient = stage_docencia.semestre_relatiu_super_expedient,semestre_relatiu_uoc = stage_docencia.semestre_relatiu_uoc, tipus_matricula_uoc =stage_docencia.tipus_matricula_uoc, assigna_clase = stage_docencia.assigna_clase, cod_aula = stage_docencia.cod_aula, cod_tfc = stage_docencia.cod_tfc, ind_sols_examen = stage_docencia.ind_sols_examen, qualif_num_cont = stage_docencia.qualif_num_cont, qualif_num_cont_final = stage_docencia.qualif_num_cont_final, qualif_numerica = stage_docencia.qualif_numerica, qualif_numerica_pub = stage_docencia.qualif_numerica_pub, qualif_num_practica = stage_docencia.qualif_num_practica, qualif_num_pres = stage_docencia.qualif_num_pres, qualif_num_prop = stage_docencia.qualif_num_prop, qualif_num_teorica = stage_docencia.qualif_num_teorica, qualif_practica = stage_docencia.qualif_practica, qualif_teorica = stage_docencia.qualif_teorica, cod_qualif_conf = stage_docencia.cod_qualif_conf, dim_qualificacio_continuada_key = stage_docencia.cod_qualif_cont, cod_qualif_cont_final = stage_docencia.cod_qualif_cont_final, dim_qualificacio_key = stage_docencia.cod_qualificacio, ind_supera = stage_docencia.ind_supera, supera_assignatura = stage_docencia.supera_assignatura, no_supera_assignatura = stage_docencia.no_supera_assignatura, cod_qualificacio_pub = stage_docencia.cod_qualificacio_pub, cod_qualif_pres = stage_docencia.cod_qualif_pres, cod_qualif_prop = stage_docencia.cod_qualif_prop, cod_examen = stage_docencia.cod_examen, idp_corrector = stage_docencia.idp_corrector, matricula_anulada = stage_docencia.matricula_anulada, assignatura_anulada = stage_docencia.assignatura_anulada, assignatura_convalidada= stage_docencia.assignatura_convalidada, edat_relativa = stage_docencia.edat_relativa, grup_edat = stage_docencia.grup_edat, grup_edat_2 = stage_docencia.grup_edat_2, update_date = CONVERT_TIMEZONE(''America/Los_Angeles'',''Europe/Madrid'', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)
 
;
 