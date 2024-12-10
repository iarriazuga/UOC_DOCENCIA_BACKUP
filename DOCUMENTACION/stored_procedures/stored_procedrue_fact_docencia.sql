-- Creem la taula de STAGE que contindra tots els IDs de les diferents dimensions

CREATE OR REPLACE table db_uoc_prod.dd_od.fact_docencia (
	id_docencia number(20,0),
    id_semestre number(16,0) comment 'Aquest ID correspon a la taula DIM_SEMESTRE.',
    id_assignatura number(16,0) comment 'Aquest ID correspon a la taula DIM_ASSIGNATURA.',
    id_qualificacio number(16,0) comment 'Aquest ID correspon a la taula DIM_QUALIFICACIO.',
    id_qualificacio_continuada number(16,0) comment 'Aquest ID correspon a la taula DIM_QUALIFICACIO_CONTINUADA.',
    id_expedient number(16,0) comment 'Aquest ID correspon a la taula DIM_EXPEDIENT.',
    id_matricula number(16,0) comment 'Aquest ID correspon a la taula DIM_MATRICULA.',
    id_portafoli_pa number(16,0) comment 'Aquest ID correspon a la taula DIM_PORTAFOLI_PA.', -- JLP 17/07/2024
    id_persona_estudiant number(16,0) comment 'Aquest ID correspon a la taula DIM_PERSONA_ESTUDIANT.',
    id_pais_nacionalitat number(16,0) comment 'Aquest ID correspon a la taula DIM_PAIS_NACIONALITAT.',
    id_pais_naixement number(16,0) comment 'Aquest ID correspon a la taula DIM_PAIS_NAIXEMENT.',
    id_pais_residencia number(16,0)comment 'Aquest ID correspon a la taula DIM_PAIS_RESIDENCIA.',
    id_acces number(16,0) comment 'Aquest ID correspon a la taula DIM_ACCES.',
    id_persona_tutor number(16,0) comment 'Aquest ID correspon a la taula DIM_PERSONA_TUTOR.',
    -- SUPER_EXPEDIENT NUMBER(10,0),
	-- idp number(10,0),
	-- cod_pla varchar(16777216),
	-- idp_tutor number(10,0),
	-- num_sol_acc number(10,0),
	nota_mitjana number(15,4),
	nota_mitjana_punts number(15,4),
	-- any_acad_titol varchar(16777216),
	-- any_acad_valida varchar(16777216),
    assignatura_cursada number(1),
    num_credits number(4,1),
    num_credits_teorics number(3,1),
    num_credits_practics number(3,1),
    num_matriculas_assignatura number(3),
    -- tipus_estudiant_assignatura varchar(256),
    semestre_relatiu_expedient number(3),
    -- tipus_matricula varchar(256),
    semestre_relatiu_super_expedient number (3),
    semestre_relatiu_uoc number(3),
    -- tipus_matricula_uoc varchar(256),
	-- assigna_clase varchar(1),
	-- cod_aula number(10,0),
	-- cod_tfc varchar(8),
	-- ind_sols_examen varchar(1),
	qualif_num_cont number(22,2),
	qualif_num_cont_final number(22,2),
	qualif_numerica number(22,2),
	qualif_numerica_pub number(22,2),
	qualif_num_practica number(22,2),
	qualif_num_pres number(22,2),
	qualif_num_prop number(22,2),
	qualif_num_teorica number(22,2),
	-- qualif_practica varchar(2),
	-- qualif_teorica varchar(2),
	-- cod_qualif_conf varchar(2),
	dim_qualificacio_continuada_key varchar(2),
	cod_qualif_cont_final varchar(2),
    dim_qualificacio_key varchar(2),
    -- ind_supera varchar(1),
    supera_assignatura number(1),
    no_supera_assignatura number(1),
	-- cod_qualificacio_pub varchar(2),
	-- cod_qualif_pres varchar(2),
	-- cod_qualif_prop varchar(2),
	-- cod_examen number(22,0),
	-- idp_corrector number(22,0),
    matricula_anulada number(1,0),
    assignatura_anulada number(1,0),
    assignatura_convalidada number (1,0),
    --SEC_SOLICITUD NUMBER (10,0),
    --NUM_RECONEIXEMENT NUMBER (5,0),
    edat_relativa number(4,0) comment 'És l''edat relativa de la persona en el moment de l''esdeveniment. Per calcular-ho s''agafa l''any natural del semestre associat a l''esdeveniment i es resta a l''any de la data de naixement de l''alumne',
    grup_edat varchar(15),
    grup_edat_2 varchar(15),
	creation_date timestamp_ntz(9) not null comment 'Data de creacio del registre de la informacio',
	update_date timestamp_ntz(9) not null comment 'Data de carrega de la informacio'
);

-- truncate table db_uoc_prod.dd_od.fact_docencia;

-- A aquesta taula s han d inserir tots els registres de la taula STAGE_DOCENCIA. Es aixi per garantir la coherencia de les dades. De moment s agraguen tots els registres des de origen, i quan es puguin fer carregues incrementals continuara funcionant igual.
/*
insert into db_uoc_prod.dd_od.fact_docencia
(id_docencia, id_semestre, id_assignatura, id_qualificacio, id_expedient, nota_mitjana, nota_mitjana_punts, assignatura_cursada, num_matriculas_assignatura, semestre_relatiu_expedient, qualif_num_cont, qualif_num_cont_final,  qualif_numerica, qualif_numerica_pub, qualif_num_practica, qualif_num_pres, qualif_num_prop, qualif_num_teorica, supera_assignatura, no_supera_assignatura, creation_date, update_date)
SELECT
id_docencia, id_semestre, id_assignatura, id_qualificacio, id_expedient, nota_mitjana, nota_mitjana_punts, assignatura_cursada, num_matriculas_assignatura, semestre_relatiu_expedient, qualif_num_cont, qualif_num_cont_final,  qualif_numerica, qualif_numerica_pub, qualif_num_practica, qualif_num_pres, qualif_num_prop, qualif_num_teorica, supera_assignatura, no_supera_assignatura, creation_date, CONVERT_TIMEZONE('America/Los_Angeles','Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)
FROM db_uoc_prod.dd_od.stage_docencia_post
;
*/

-- Creacio del procediment que carregara i actualitzara els camps necessaris de la taula, actualitzant els IDs de les dimensions que siguin necessaris.
CREATE OR REPLACE procedure db_uoc_prod.dd_od.fact_docencia_loads()
returns varchar(16777216)
language sql
execute AS caller
as begin
let start_time timestamp_ntz := convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz);
let execution_time float;

-- Carrega de la taula amb tots els registres de la taula STAGE_DOCENCIA

-- Carrega de la taula FACT_DOCENCIA des de la taula STAGE_DOCENCIA_POST. En aquest objecte eliminem qualsevol referencia als codis original i mantenim unicament la informacio dels IDs de les dimensions i els fets quantitatius del proces.
-- El procediment esta pensat com a INSERT or UPDATE es a dir, si existeix el registre actualitza el camp de UPDATE mentre que si no existeix insereix la informacio i actualitza tant el camp de INSERT com el de UPDATE de la taula.
-- Quan estiguem en disposicio de poder actualitzar nomes els registres del periode carregat (malgrat inicialment es carrega tota la informacio des de origen per a cada dia) el procediment funcionara i millorara el seu rendiment de forma optima.

merge into
    db_uoc_prod.dd_od.fact_docencia
using
(SELECT
ifnull(id_docencia, 0) AS id_docencia, ifnull(id_semestre, 0) AS id_semestre, ifnull(id_assignatura, 0) AS id_assignatura, ifnull(id_qualificacio, 0) AS id_qualificacio, ifnull(id_qualificacio_continuada, 0) AS id_qualificacio_continuada, ifnull(id_expedient, 0) AS id_expedient, ifnull(id_matricula, 0) AS id_matricula, ifnull(id_portafoli_pa, 0) AS id_portafoli_pa, ifnull(id_persona_estudiant, 0) AS id_persona_estudiant, ifnull(id_pais_nacionalitat, 0) AS id_pais_nacionalitat, ifnull(id_pais_naixement, 0) AS id_pais_naixement, ifnull(id_pais_residencia, 0) AS id_pais_residencia, ifnull(id_acces, 0) AS id_acces, ifnull(id_persona_tutor, 0) AS id_persona_tutor,nota_mitjana,nota_mitjana_punts,any_acad_titol,any_academic,any_acad_valida,cod_assignatura,assignatura_cursada,num_credits,num_credits_teorics,num_credits_practics,num_matriculas_assignatura,semestre_relatiu_expedient,semestre_relatiu_super_expedient,semestre_relatiu_uoc,assigna_clase,cod_aula,cod_tfc,ind_sols_examen,qualif_num_cont,qualif_num_cont_final,qualif_numerica,qualif_numerica_pub,qualif_num_practica,qualif_num_pres,qualif_num_prop,qualif_num_teorica,qualif_practica,qualif_teorica,cod_qualif_conf,dim_qualificacio_continuada_key,cod_qualif_cont_final,dim_qualificacio_key,ind_supera,supera_assignatura,no_supera_assignatura,cod_qualificacio_pub,cod_qualif_pres,cod_qualif_prop,cod_examen,idp_corrector,matricula_anulada,assignatura_anulada,assignatura_convalidada,edat_relativa,grup_edat,grup_edat_2,creation_date,update_date
FROM db_uoc_prod.dd_od.stage_docencia_post) stage_docencia_post
on fact_docencia.id_docencia = stage_docencia_post.id_docencia
when matched then
    update
    set
        id_semestre = stage_docencia_post.id_semestre, id_assignatura = stage_docencia_post.id_assignatura, id_qualificacio = stage_docencia_post.id_qualificacio, id_qualificacio_continuada = stage_docencia_post.id_qualificacio_continuada, id_expedient = stage_docencia_post.id_expedient, id_matricula = stage_docencia_post.id_matricula, id_portafoli_pa = stage_docencia_post.id_portafoli_pa, id_persona_estudiant = stage_docencia_post.id_persona_estudiant, id_pais_nacionalitat = stage_docencia_post.id_pais_nacionalitat, id_pais_naixement = stage_docencia_post.id_pais_naixement, id_pais_residencia = stage_docencia_post.id_pais_residencia, id_acces = stage_docencia_post.id_acces, id_persona_tutor = stage_docencia_post.id_persona_tutor ,nota_mitjana = stage_docencia_post.nota_mitjana, nota_mitjana_punts = stage_docencia_post.nota_mitjana_punts, assignatura_cursada = stage_docencia_post.assignatura_cursada, num_credits = stage_docencia_post.num_credits, num_credits_teorics = stage_docencia_post.num_credits_teorics, num_credits_practics = stage_docencia_post.num_credits_practics,semestre_relatiu_expedient= stage_docencia_post.semestre_relatiu_expedient,semestre_relatiu_super_expedient= stage_docencia_post.semestre_relatiu_super_expedient, semestre_relatiu_uoc = stage_docencia_post.semestre_relatiu_uoc, num_matriculas_assignatura = stage_docencia_post.num_matriculas_assignatura, qualif_num_cont = stage_docencia_post.qualif_num_cont, qualif_num_cont_final = stage_docencia_post.qualif_num_cont_final, qualif_numerica = stage_docencia_post.qualif_numerica, qualif_numerica_pub = stage_docencia_post.qualif_numerica_pub, qualif_num_practica = stage_docencia_post.qualif_num_practica, qualif_num_pres = stage_docencia_post.qualif_num_pres, qualif_num_prop = stage_docencia_post.qualif_num_prop, qualif_num_teorica = stage_docencia_post.qualif_num_teorica, dim_qualificacio_continuada_key = stage_docencia_post.dim_qualificacio_continuada_key, cod_qualif_cont_final = stage_docencia_post.cod_qualif_cont_final, dim_qualificacio_key = stage_docencia_post.dim_qualificacio_key, supera_assignatura = stage_docencia_post.supera_assignatura, no_supera_assignatura = stage_docencia_post.no_supera_assignatura, matricula_anulada = stage_docencia_post.matricula_anulada, assignatura_anulada = stage_docencia_post.assignatura_anulada,assignatura_convalidada= stage_docencia_post.assignatura_convalidada, edat_relativa = stage_docencia_post.edat_relativa, grup_edat = stage_docencia_post.grup_edat, grup_edat_2 = stage_docencia_post.grup_edat_2, update_date = CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)
WHEN NOT MATCHED THEN
    INSERT
        (
id_docencia,id_semestre,id_assignatura,id_qualificacio,id_qualificacio_continuada,id_expedient,id_matricula,id_portafoli_pa,id_persona_estudiant,id_pais_nacionalitat,id_pais_naixement,id_pais_residencia,id_acces,id_persona_tutor,nota_mitjana,nota_mitjana_punts,assignatura_cursada,num_credits,num_credits_teorics,num_credits_practics,semestre_relatiu_expedient,semestre_relatiu_super_expedient,semestre_relatiu_uoc,num_matriculas_assignatura,qualif_num_cont,qualif_num_cont_final,qualif_numerica,qualif_numerica_pub,qualif_num_practica,qualif_num_pres,qualif_num_prop,qualif_num_teorica,dim_qualificacio_continuada_key,cod_qualif_cont_final,dim_qualificacio_key,supera_assignatura,no_supera_assignatura,matricula_anulada,assignatura_anulada,assignatura_convalidada,edat_relativa,grup_edat,grup_edat_2,creation_date,update_date
        )
    values
        (	stage_docencia_post.id_docencia,stage_docencia_post.id_semestre,stage_docencia_post.id_assignatura,stage_docencia_post.id_qualificacio,stage_docencia_post.id_qualificacio_continuada,stage_docencia_post.id_expedient,stage_docencia_post.id_matricula,stage_docencia_post.id_portafoli_pa,stage_docencia_post.id_persona_estudiant,stage_docencia_post.id_pais_nacionalitat,stage_docencia_post.id_pais_naixement,stage_docencia_post.id_pais_residencia,stage_docencia_post.id_acces,stage_docencia_post.id_persona_tutor,stage_docencia_post.nota_mitjana,stage_docencia_post.nota_mitjana_punts,stage_docencia_post.assignatura_cursada,stage_docencia_post.num_credits,stage_docencia_post.num_credits_teorics,stage_docencia_post.num_credits_practics,stage_docencia_post.semestre_relatiu_expedient,stage_docencia_post.semestre_relatiu_super_expedient,stage_docencia_post.semestre_relatiu_uoc,stage_docencia_post.num_matriculas_assignatura,stage_docencia_post.qualif_num_cont,stage_docencia_post.qualif_num_cont_final,stage_docencia_post.qualif_numerica,stage_docencia_post.qualif_numerica_pub,stage_docencia_post.qualif_num_practica,stage_docencia_post.qualif_num_pres,stage_docencia_post.qualif_num_prop,stage_docencia_post.qualif_num_teorica,stage_docencia_post.dim_qualificacio_continuada_key,stage_docencia_post.cod_qualif_cont_final,stage_docencia_post.dim_qualificacio_key,stage_docencia_post.supera_assignatura,stage_docencia_post.no_supera_assignatura,stage_docencia_post.matricula_anulada,stage_docencia_post.assignatura_anulada,stage_docencia_post.assignatura_convalidada,stage_docencia_post.edat_relativa,stage_docencia_post.grup_edat,stage_docencia_post.grup_edat_2,stage_docencia_post.creation_date, CONVERT_TIMEZONE('America/Los_Angeles','Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)
        )
;

execution_time := datediff(millisecond, start_time, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
    values (db_uoc_prod.dd_od.sequencia_id_log.nextval, 'full_full_docencia_data_load', current_user(), :start_time, :execution_time, 'full_docencia_data_load Success');
    
return 'Update completed successfully';

end
;



-- call db_uoc_prod.dd_od.fact_docencia_loads();
SELECT * FROM db_uoc_prod.dd_od.fact_docencia
where id_assignatura is null;
;
7549988

SELECT pais, FROM fact_docencia
left join db_uoc_prod.dd_od.dim_pais_residencia using (id_pais_residencia)
where dim_pais_residencia.id_pais_residencia = 0;


SELECT * FROM db_uoc_prod.dd_od.dim_pais_residencia where cod_postal ='99999';

SELECT id_assignatura, dim_assignatura_key FROM db_uoc_prod.dd_od.fact_docencia
left join dim_assignatura using (id_assignatura)
where dim_assignatura_key is null;
