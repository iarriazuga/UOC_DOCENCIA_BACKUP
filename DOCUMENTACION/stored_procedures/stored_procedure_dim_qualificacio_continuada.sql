-- Creacio de la sequencia que donara peu a identificador unic de la taula de qualificacio continuada.

CREATE OR REPLACE sequence db_uoc_prod.dd_od.sequencia_id_qualificacio_continuada start 1 increment 1;

-- Creacio de la taula DIM_QUALIFICACIO amb les descripcions i atributs particulars.
-- Pendent de identificar nous requeriments a incloure a la dimensio.

CREATE OR REPLACE table db_uoc_prod.dd_od.dim_qualificacio_continuada 
(
id_qualificacio_continuada number(16) not null comment 'Clau unica i numerica que identifica els registres de la dimensio qualificacio'
,dim_qualificacio_continuada_key varchar(6) not null comment 'Codi UOC de qualificacio.'
,desc_qualificacio_continuada varchar(256) comment 'Descripcio completa de la qualificacio'
,ind_activo_continuada varchar(1) comment 'Valor que indica si la nota esta activa a l avaluacio.'
,ind_participa_continuada varchar(1) comment 'Valor que indica si l estudiant ha seguit l avaluacio continuada.'
,ind_supera_continuada varchar(1) comment 'Valor que indica si supera amb exit la qualificacio.'
,creation_date timestamp_ntz not null comment 'Data de creacio del registre de la informacio'
,update_date timestamp_ntz not null comment 'Data de carrega de la informacio'
) comment='Taula que conte la informacio rellevant de les qualificacions d avaluacio continuada.'
;

-- Creacio del procediment de carrega i/o actualització de dades programable
CREATE OR REPLACE procedure db_uoc_prod.dd_od.dim_qualificacio_continuada_loads()
returns varchar(16777216)
language SQL
execute AS caller
as 
begin
let start_time timestamp_ntz := convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz);
let execution_time float;

merge into db_uoc_prod.dd_od.dim_qualificacio_continuada
using (SELECT 0 AS id_qualificacio_continuada, 'ND' AS dim_qualificacio_continuada_key,'ND' AS desc_qualificacio_continuada, '-' AS ind_activo_continuada, '-' AS ind_participa_continuada, '-' AS ind_supera_continuada, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS creation_date, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS update_date) AS dim_qualificacio_repl
on db_uoc_prod.dd_od.dim_qualificacio_continuada.id_qualificacio_continuada = dim_qualificacio_repl.id_qualificacio_continuada
when matched
then update set update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
when not matched
then insert (id_qualificacio_continuada, dim_qualificacio_continuada_key, desc_qualificacio_continuada, ind_activo_continuada, ind_participa_continuada, ind_supera_continuada, creation_date,  update_date)
values (0, 'ND','ND', '-', '-', '-', convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz), convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz))
;

merge into db_uoc_prod.dd_od.dim_qualificacio_continuada
using (SELECT cod_calif_cont, desc_calificacion, ind_activo, ind_participa, ind_supera
FROM db_uoc_prod.stg_docencia.gat_calif_continuada
) AS dim_qualificacio_continuada_orig
on db_uoc_prod.dd_od.dim_qualificacio_continuada.dim_qualificacio_continuada_key = dim_qualificacio_continuada_orig.cod_calif_cont
when matched then
update set dim_qualificacio_continuada_key = dim_qualificacio_continuada_orig.cod_calif_cont, desc_qualificacio_continuada = dim_qualificacio_continuada_orig.desc_calificacion, ind_activo_continuada = dim_qualificacio_continuada_orig.ind_activo, ind_participa_continuada = dim_qualificacio_continuada_orig.ind_participa, ind_supera_continuada = dim_qualificacio_continuada_orig.ind_supera, update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
when not matched then
insert (id_qualificacio_continuada, dim_qualificacio_continuada_key, desc_qualificacio_continuada, ind_activo_continuada, ind_participa_continuada, ind_supera_continuada, creation_date,  update_date) 
values (db_uoc_prod.dd_od.sequencia_id_qualificacio_continuada.nextval, dim_qualificacio_continuada_orig.cod_calif_cont, dim_qualificacio_continuada_orig.desc_calificacion, dim_qualificacio_continuada_orig.ind_activo, dim_qualificacio_continuada_orig.ind_participa, dim_qualificacio_continuada_orig.ind_supera, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz), convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

execution_time := datediff(millisecond, start_time, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
    values (db_uoc_prod.dd_od.sequencia_id_log.nextval, 'dim_qualificacio_continuada_loads', CURRENT_USER(), :start_time, :execution_time, 'dim_qualificacio_continuada Success');
    
return 'Update completed successfully';

end
;

-- Comanda per executar el procediment enmagatzemat al entorn.
-- call db_uoc_prod.dd_od.dim_qualificacio_continuada_loads();
-- SELECT * FROM db_uoc_prod.dd_od.dim_qualificacio_continuada;
