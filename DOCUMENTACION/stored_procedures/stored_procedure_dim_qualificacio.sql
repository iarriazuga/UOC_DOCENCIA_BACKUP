CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DD_OD.DIM_QUALIFICACIO_CONTINUADA_LOADS()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'begin
let start_time timestamp_ntz := convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz);
let execution_time float;

merge into db_uoc_prod.dd_od.dim_qualificacio_continuada
using (SELECT 0 AS id_qualificacio_continuada, ''ND'' AS dim_qualificacio_continuada_key,''ND'' AS desc_qualificacio_continuada, ''-'' AS ind_activo_continuada, ''-'' AS ind_participa_continuada, ''-'' AS ind_supera_continuada, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz) AS creation_date, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz) AS update_date) AS dim_qualificacio_repl
on db_uoc_prod.dd_od.dim_qualificacio_continuada.id_qualificacio_continuada = dim_qualificacio_repl.id_qualificacio_continuada
when matched
then update set update_date = convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz)
when not matched
then insert (id_qualificacio_continuada, dim_qualificacio_continuada_key, desc_qualificacio_continuada, ind_activo_continuada, ind_participa_continuada, ind_supera_continuada, creation_date,  update_date)
values (0, ''ND'',''ND'', ''-'', ''-'', ''-'', convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz), convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz))
;

merge into db_uoc_prod.dd_od.dim_qualificacio_continuada
using (SELECT cod_calif_cont, desc_calificacion, ind_activo, ind_participa, ind_supera
FROM db_uoc_prod.stg_docencia.gat_calif_continuada
) AS dim_qualificacio_continuada_orig
on db_uoc_prod.dd_od.dim_qualificacio_continuada.dim_qualificacio_continuada_key = dim_qualificacio_continuada_orig.cod_calif_cont
when matched then
update set dim_qualificacio_continuada_key = dim_qualificacio_continuada_orig.cod_calif_cont, desc_qualificacio_continuada = dim_qualificacio_continuada_orig.desc_calificacion, ind_activo_continuada = dim_qualificacio_continuada_orig.ind_activo, ind_participa_continuada = dim_qualificacio_continuada_orig.ind_participa, ind_supera_continuada = dim_qualificacio_continuada_orig.ind_supera, update_date = convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz)
when not matched then
insert (id_qualificacio_continuada, dim_qualificacio_continuada_key, desc_qualificacio_continuada, ind_activo_continuada, ind_participa_continuada, ind_supera_continuada, creation_date,  update_date) 
values (db_uoc_prod.dd_od.sequencia_id_qualificacio_continuada.nextval, dim_qualificacio_continuada_orig.cod_calif_cont, dim_qualificacio_continuada_orig.desc_calificacion, dim_qualificacio_continuada_orig.ind_activo, dim_qualificacio_continuada_orig.ind_participa, dim_qualificacio_continuada_orig.ind_supera, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz), convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz));

execution_time := datediff(millisecond, start_time, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz));

insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
    values (db_uoc_prod.dd_od.sequencia_id_log.nextval, ''dim_qualificacio_continuada_loads'', CURRENT_USER(), :start_time, :execution_time, ''dim_qualificacio_continuada Success'');
    
return ''Update completed successfully'';

end';