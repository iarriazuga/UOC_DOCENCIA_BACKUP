-- Creacio de la sequencia que donara peu a identificador unic de la taula.

CREATE OR REPLACE sequence db_uoc_prod.dd_od.sequencia_id_semestre start 1 increment 1;

-- Creacio de la taula ANY_ACADEMIC (SEMESTRE) amb els atributs particulars.
-- Pendent de identificar si es possible vincular-la a la dimensio de data estandar.

CREATE OR REPLACE table db_uoc_prod.dd_od.dim_semestre 
(
id_semestre number(16) not null comment 'Clau unica i numerica que identifica els registres de la dimensio any academic'
,dim_semestre_key varchar(6) not null comment 'Codi UOC any academic. Els anys academics es poden anomenar semestres en alguns equips i departaments. En alguns casos existeix el concepte de 3er any academic, que correspon a formacions adicionals i/o seminaris'
,descripcio varchar(256) not null comment 'Descripcio completa anya academic'
,any_natural number(4) not null comment 'Any natural al que pertany un any academic determinat'
,semestre number(1) not null comment 'Camp numeric que identifica el semestre al que pertany un any academic'
,descripcio_visual varchar(256) not null comment 'Descripcio simple i resumida dels anys academics'
,data_inici timestamp_ntz not null comment 'Data que dona inici a un any academic determinat'
,data_fi timestamp_ntz not null comment 'Data fi per a un any academic determinat'
,creation_date timestamp_ntz not null comment 'Data de creacio del registre de la informacio'
,update_date timestamp_ntz not null comment 'Data de carrega de la informacio'
) comment='Taula que conte la informacio rellevant dels anys academics/semestres per a qualsevol projecte de disponibilitzacio'
;

/*
-- Crea el registre amb ID_ANY_ACADEMIC = 0 per poder assignar a qualsevol registre que no estigui correctament identificat.
-- !!! Aquesta insercio queda obsoleta en el proces d afegir un valor mestre sense representacio. S ha d incorporar el merge descrit a continuacio per mantenir la idempotencia de les execucions. 
insert into db_uoc_prod.dd_od.dim_semestre
values (0,1900,'ND',1900,0,'ND','1900-01-01 00:00:00.000','1900-01-01 00:00:00.000',convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz),convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz))
;
*/

-- Proces que incorpora el registre 0 a la dimensio. Aquest registre aglutinara totes aquelles transaccions que no tinguin un semestre ben informat.
merge into db_uoc_prod.dd_od.dim_semestre
using (SELECT 0 AS id_semestre, 19000 AS dim_semestre_key,'ND' AS descripcio,1900 AS any_natural,0 AS semestre,'ND' AS descripcio_visual,'1900-01-01 00:00:00.000' AS data_inici,'1900-01-01 00:00:00.000' AS data_fi,convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS creation_date,convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS update_date) AS dim_semestre_repl
on db_uoc_prod.dd_od.dim_semestre.id_semestre = dim_semestre_repl.semestre
when matched
then update set update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
when not matched
then insert (id_semestre, dim_semestre_key, descripcio, any_natural, semestre, descripcio_visual, data_inici, data_fi, creation_date, update_date)
values (0,19000,'ND',1900,0,'ND','1900-01-01 00:00:00.000','1900-01-01 00:00:00.000',convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz),convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz))
;

-- SELECT 0 AS id_any_academic, 1900 AS dim_any_academic_key,'ND' AS descripcio,1900 AS any_natural,0 AS semestre,'ND' AS descripcio_visual,'1900-01-01 00:00:00.000' AS data_inici,'1900-01-01 00:00:00.000' AS data_fi,convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS creation_date,convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS update_date;

-- desc table db_uoc_prod.dd_od.dim_any_academic;
-- SELECT count(1) FROM db_uoc_prod.dd_od.dim_any_academic; -- 82+1 registres
-- SELECT * FROM db_uoc_prod.dd_od.dim_any_academic;

-- Creacio de la sequencia autonumerica pel registre de les execucions de OD i reseteja els numeros per tal que comenci de nou.
-- CREATE OR REPLACE sequence db_uoc_prod.dd_od.sequencia_id_log;
CREATE OR REPLACE sequence db_uoc_prod.dd_od.sequencia_id_log start 1 increment 1;

-- Taula de registre de les execucions de les taules de OD
CREATE OR REPLACE table db_uoc_prod.dd_od.procedures_log
(
id_log number(38) not null
,procedure_name varchar(255)
,executed_by varchar(255)
,execution_date timestamp_ntz
,execution_time number(10) comment 'milisegons'
,remarks varchar(512)
,primary key (id_log)
);

-- Creacio del procediment de carrega i/o actualització de dades programable
CREATE OR REPLACE procedure db_uoc_prod.dd_od.dim_semestre_loads()
returns varchar(16777216)
language SQL
execute AS caller
as 
begin
let start_time timestamp_ntz := convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz);
let execution_time float;

merge into db_uoc_prod.dd_od.dim_semestre
using (SELECT 0 AS id_semestre, 19000 AS dim_semestre_key,'ND' AS descripcio,1900 AS any_natural,0 AS semestre,'ND' AS descripcio_visual,'1900-01-01 00:00:00.000' AS data_inici,'1900-01-01 00:00:00.000' AS data_fi,convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS creation_date,convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS update_date) AS dim_semestre_repl
on db_uoc_prod.dd_od.dim_semestre.id_semestre = dim_semestre_repl.semestre
when matched
then update set update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
when not matched
then insert (id_semestre, dim_semestre_key, descripcio, any_natural, semestre, descripcio_visual, data_inici, data_fi, creation_date, update_date)
values (0,19000,'ND',1900,0,'ND','1900-01-01 00:00:00.000','1900-01-01 00:00:00.000',convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz),convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz))
;

merge into db_uoc_prod.dd_od.dim_semestre
using db_uoc_prod.stg_docencia.gat_anys_academicos
on db_uoc_prod.dd_od.dim_semestre.dim_semestre_key = db_uoc_prod.stg_docencia.gat_anys_academicos.any_academico
when matched then update set dim_semestre_key = db_uoc_prod.stg_docencia.gat_anys_academicos.any_academico, descripcio = db_uoc_prod.stg_docencia.gat_anys_academicos.descripcion, any_natural = db_uoc_prod.stg_docencia.gat_anys_academicos.any_natural, semestre =  db_uoc_prod.stg_docencia.gat_anys_academicos.semestre, descripcio_visual =  db_uoc_prod.stg_docencia.gat_anys_academicos.desc_visual, data_inici = db_uoc_prod.stg_docencia.gat_anys_academicos.fecha_inicio, data_fi =  db_uoc_prod.stg_docencia.gat_anys_academicos.fecha_final, update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
when not matched then
insert (id_semestre, dim_semestre_key, descripcio, any_natural, semestre, descripcio_visual, data_inici, data_fi, creation_date, update_date) values (db_uoc_prod.dd_od.sequencia_id_semestre.nextval,  db_uoc_prod.stg_docencia.gat_anys_academicos.any_academico, db_uoc_prod.stg_docencia.gat_anys_academicos.descripcion, db_uoc_prod.stg_docencia.gat_anys_academicos.any_natural, db_uoc_prod.stg_docencia.gat_anys_academicos.semestre, db_uoc_prod.stg_docencia.gat_anys_academicos.desc_visual, db_uoc_prod.stg_docencia.gat_anys_academicos.fecha_inicio, db_uoc_prod.stg_docencia.gat_anys_academicos.fecha_final, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz), convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

execution_time := datediff(millisecond, start_time, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
    values (db_uoc_prod.dd_od.sequencia_id_log.nextval, 'dim_semestre_loads', CURRENT_USER(), :start_time, :execution_time, 'dim_semestre Success');
    
return 'Update completed successfully';

end
;

-- Comanda per executar el procediment enmagatzemat al entorn.
-- call db_uoc_prod.dd_od.dim_semestre_loads();

SELECT * FROM db_uoc_prod.stg_docencia.gat_anys_academicos;
