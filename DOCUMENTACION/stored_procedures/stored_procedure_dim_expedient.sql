CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DD_OD.DIM_EXPEDIENT_LOADS()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'begin
let start_time timestamp_ntz := convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz);
let execution_time float;

merge into db_uoc_prod.dd_od.dim_expedient
using (SELECT 0 AS id_expedient, 0 AS dim_expedient_key, 0 AS cod_centre, ''ND'' AS codi_pla, ''ND'' AS provinent_adaptacio , ''ND'' AS tipologia_titol_previ, 0 AS numero_versio_pla, ''19000'' AS semestre_apertura, ''ND'' AS codi_node_arrel, ''-'' AS ind_estat_expedient, ''-'' AS ind_inconsistent, ''-'' AS ind_carrega_inicial, 0 AS ind_situacio, ''ND'' AS observacions, 0 AS num_control, null AS nota_mitjana, ''19000'' AS semestre_titulacio, 0 AS motiu_estat, ''-'' AS ind_estat_expedient_2, 0 AS num_expedient_rel_1, 0 AS num_expedient_rel_2, null AS nota_mitjana_punts, 0 AS super_expedient_v1,convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz) AS creation_date,convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz) AS update_date) AS dim_expedient_repl
on db_uoc_prod.dd_od.dim_expedient.id_expedient = dim_expedient_repl.id_expedient
when matched
then update set update_date = convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz)
when not matched
then insert (id_expedient, dim_expedient_key, cod_centre, codi_pla, provinent_adaptacio, tipologia_titol_previ, numero_versio_pla, semestre_apertura, codi_node_arrel, ind_estat_expedient, ind_inconsistent, ind_carrega_inicial, ind_situacio, observacions, num_control, nota_mitjana, semestre_titulacio, motiu_estat, ind_estat_expedient_2, num_expedient_rel_1, num_expedient_rel_2, nota_mitjana_punts, super_expedient_v1, creation_date, update_date)
values (0, 0, 0, ''ND'', ''ND'', ''ND'', 0, ''19000'', ''ND'', ''-'', ''-'', ''-'', 0, ''ND'', 0, null, ''19000'', 0, ''-'', 0, 0, null, 0, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz), convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz))
;


merge into db_uoc_prod.dd_od.dim_expedient
using (WITH expediente_origen_relacionado AS (
    SELECT 
        e.NUM_EXPEDIENTE,
        COALESCE(e.NUM_EXPEDIENTE_REL1, MIN(e.NUM_EXPEDIENTE) OVER (PARTITION BY e.IDP, pd.COD_ESTUDIOS)) AS super_expediente
    FROM DB_UOC_PROD.STG_MAT.GAT_EXPEDIENTES e
    LEFT JOIN DB_UOC_PROD.STG_MAT.GAT_PLAN_DATOS pd ON e.COD_PLAN = pd.COD_PLAN
    WHERE e.ind_estado_expediente <> ''E'' 
    ), expediente_origen_relacionado2 AS (
        SELECT 
            eor1.num_expediente,
            eor2.super_expediente,
        FROM expediente_origen_relacionado eor1
        LEFT JOIN expediente_origen_relacionado eor2 ON eor1.super_expediente = eor2.num_expediente 
    ) 
SELECT
gat_expedientes.num_expediente
,gat_expedientes.cod_centro
,gat_expedientes.cod_plan
,CASE WHEN gat_expedientes.num_expediente = gat_exp_adapt.num_expediente_rel2 THEN ''Sí'' ELSE ''No'' end AS provinent_adaptacio
,program.des_tipologia_ca AS tipologia_titol_previ
,gat_expedientes.num_version_plan
,gat_expedientes.any_acad_apertura
,gat_expedientes.cod_nodo_raiz
,gat_expedientes.ind_estado_expediente
,gat_expedientes.ind_inconsistente
,gat_expedientes.ind_carga_inicial
,gat_expedientes.ind_situacion
,gat_expedientes.observaciones
,gat_expedientes.num_control
,gat_expedientes.nota_media
,gat_expedientes.any_acad_titulo
,gat_expedientes.motivo_estado
,gat_expedientes.ind_estado_expediente2
,gat_expedientes.num_expediente_rel1
,gat_expedientes.num_expediente_rel2
,gat_expedientes.nota_media_puntos
,ifnull (expediente_origen_relacionado2.super_expediente,gat_expedientes.num_expediente) AS super_expedient_v1
FROM
db_uoc_prod.stg_mat.gat_expedientes
left join db_uoc_prod.stg_mat.gat_expedientes AS gat_exp_adapt
on gat_expedientes.num_expediente = gat_exp_adapt.num_expediente_rel2 and
   gat_exp_adapt.ind_estado_expediente = ''Q''
left join db_uoc_prod.stg_mat.gat_plan_datos
on gat_exp_adapt.cod_plan = gat_plan_datos.cod_plan
left join db_uoc_prod.mdd_program.program
on gat_plan_datos.id_prog_bof = program.id_bof
left join expediente_origen_relacionado2 
on gat_expedientes.num_expediente = expediente_origen_relacionado2.num_expediente
) AS dim_expedient_orig
on db_uoc_prod.dd_od.dim_expedient.dim_expedient_key = dim_expedient_orig.num_expediente
when matched then update set dim_expedient_key = dim_expedient_orig.num_expediente, cod_centre = dim_expedient_orig.cod_centro, codi_pla = dim_expedient_orig.cod_plan, provinent_adaptacio = dim_expedient_orig.provinent_adaptacio, tipologia_titol_previ = dim_expedient_orig.tipologia_titol_previ,  numero_versio_pla = dim_expedient_orig.num_version_plan, semestre_apertura = dim_expedient_orig.any_acad_apertura, codi_node_arrel =  dim_expedient_orig.cod_nodo_raiz, ind_estat_expedient = dim_expedient_orig.ind_estado_expediente, ind_inconsistent = dim_expedient_orig.ind_inconsistente, ind_carrega_inicial = dim_expedient_orig.ind_carga_inicial, ind_situacio = dim_expedient_orig.ind_situacion, observacions = dim_expedient_orig.observaciones, num_control = dim_expedient_orig.num_control, nota_mitjana = dim_expedient_orig.nota_media, semestre_titulacio = dim_expedient_orig.any_acad_titulo, motiu_estat =dim_expedient_orig.motivo_estado, ind_estat_expedient_2 = dim_expedient_orig.ind_estado_expediente2, num_expedient_rel_1 = dim_expedient_orig.num_expediente_rel1, num_expedient_rel_2 = dim_expedient_orig.num_expediente_rel2, nota_mitjana_punts = dim_expedient_orig.nota_media_puntos, super_expedient_v1 = dim_expedient_orig.super_expedient_v1, update_date = convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz)
when not matched then
insert (id_expedient, dim_expedient_key, cod_centre, codi_pla, provinent_adaptacio, tipologia_titol_previ, numero_versio_pla, semestre_apertura, codi_node_arrel, ind_estat_expedient, ind_inconsistent, ind_carrega_inicial, ind_situacio, observacions, num_control, nota_mitjana, semestre_titulacio, motiu_estat, ind_estat_expedient_2, num_expedient_rel_1, num_expedient_rel_2, nota_mitjana_punts, super_expedient_v1, creation_date, update_date) values (db_uoc_prod.dd_od.sequencia_id_expedient.nextval, dim_expedient_orig.num_expediente, dim_expedient_orig.cod_centro, dim_expedient_orig.cod_plan, dim_expedient_orig.provinent_adaptacio, dim_expedient_orig.tipologia_titol_previ, dim_expedient_orig.num_version_plan, dim_expedient_orig.any_acad_apertura, dim_expedient_orig.cod_nodo_raiz, dim_expedient_orig.ind_estado_expediente, dim_expedient_orig.ind_inconsistente, dim_expedient_orig.ind_carga_inicial, dim_expedient_orig.ind_situacion, dim_expedient_orig.observaciones , dim_expedient_orig.num_control, dim_expedient_orig.nota_media, dim_expedient_orig.any_acad_titulo, dim_expedient_orig.motivo_estado, dim_expedient_orig.ind_estado_expediente2, dim_expedient_orig.num_expediente_rel1, dim_expedient_orig.num_expediente_rel2, dim_expedient_orig.nota_media_puntos, dim_expedient_orig.super_expedient_v1, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz), convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz));

execution_time := datediff(millisecond, start_time, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz));

insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
    values (db_uoc_prod.dd_od.sequencia_id_log.nextval, ''dim_expedient_loads'', CURRENT_USER(), :start_time, :execution_time, ''dim_expedient Success'');
    
return ''Update completed successfully'';

end';