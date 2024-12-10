



CREATE OR REPLACE sequence db_uoc_prod.dd_od.sequencia_via_opc_acces start 1 increment 1;

CREATE OR REPLACE table db_uoc_prod.dd_od.dim_acces
(id_acces numeric (16) not null comment 'Clau única i numèrica que identifica els registres de la dimensió viàs opc acces'
,dim_acces_key varchar (500) not null comment 'Es la clau primaria de la taula'
,tipo_docencia varchar(5) not null
,acces_titol_propi varchar(2) not null
,tipo_acces varchar(256) not null comment 'Identifica si es tracta de accés a grau'
,via_acces varchar (256) not null comment 'Via accés del estudiant a la universitat'
,opcio_acces varchar(256) not null comment 'Pendent definició'
,acces_sue varchar (3) not null comment 'Identifica sí és el seu primer accés al sistema universitàri español: classificació mitjançant via accés'
,via_siiu  varchar (256) not null comment 'Per cada combinatòria entre via i opció classifica la seva equivalència en la via accés definida pel SIIU.'
,via_oficina varchar(256) not null comment 'Per cada combinatòria entre via i opció classifica la seva equivalència en la via accés definida per la oficina de preinscripció'
,creation_date timestamp_ntz not null comment 'Data de creacio del registre de la informacio'
,update_date timestamp_ntz not null comment 'Data de carrega de la informacio'
);



CREATE OR REPLACE procedure db_uoc_prod.dd_od.dim_acces_loads()
returns varchar(16777216)
language SQL
execute AS caller
as 
begin
let start_time timestamp_ntz := convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz);
let execution_time float;

-- Carga del registro 0
merge into db_uoc_prod.dd_od.dim_acces
using (SELECT 0 AS id_acces, 'ND'  AS dim_acces_key, 'ND' AS tipo_docencia, 'ND' AS acces_titol_propi, 'ND' AS via_acces, 'ND' AS opcio_acces,'ND' AS tipo_acces, 'ND' AS acces_sue, 'ND' AS via_siiu, 'ND' via_oficina,convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS creation_date,convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS update_date) AS dim_residencia_repl
on db_uoc_prod.dd_od.dim_acces.id_acces = dim_residencia_repl.id_acces
when matched 
then update set update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
when not matched 
then insert (id_acces, dim_acces_key, tipo_docencia, acces_titol_propi, via_acces, opcio_acces, tipo_acces, acces_sue, via_siiu, via_oficina, creation_date, update_date)
values (0,'ND', 'ND' , 'ND', 'ND' ,'ND', 'ND', 'ND', 'ND', 'ND', convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz), convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

-- Cargar/actualizar datos

merge into db_uoc_prod.dd_od.dim_acces
using (SELECT distinct
            tipo_docencia_detalle AS tipo_docencia, --CP
            gpd.ind_titulaciones_propias AS acces_titol_propi, -- CP
            pac.Via_acces AS Via_acc, --CP
            pac.DESCRIPCION AS opcio_acc, -- CP
            CONCAT(tipo_docencia,acces_titol_propi,Via_acc,opcio_acc) AS dim_acces_key,
            case when tipo_docencia_detalle = 'GR' AND ind_titulaciones_propias ='N' then 'Accès Graus oficials'
                 else 'Altres' end AS tipo_acces,
            case when evue.acces_sue is null AND tipo_acces = 'Accès Graus oficials' then 'ND' -- Pendiente de clasificar
                 when evue.acces_sue is null AND tipo_acces <> 'Accès Graus oficials' then 'NA'
                 else evue.acces_sue end AS acces_sue,
            case when evue.via_siiu is null AND tipo_acces = 'Accès Graus oficials' then 'ND' -- Pendiente de clasificar
                 when evue.via_siiu is null AND tipo_acces <> 'Accès Graus oficials' then 'NA'
                 else evue.via_siiu end AS via_siiu,
            case when via_oficina is null AND tipo_acces = 'Accès Graus oficials' then 'ND' -- Pendiente de clasificar
                 when via_oficina is null AND tipo_acces <> 'Accès Graus oficials' then 'NA'
                 else via_oficina end AS via_oficina
        FROM
            STG_MAT.GAT_CAB_SOLICITUD_ACC csa
        LEFT JOIN (SELECT pa.cod_opc_Acc, pa.DESCRIPCION ,pa.COD_PLAN,pa.COD_CENTRO, va.DESCRIPCION AS Via_acces
                        FROM STG_MAT.gat_plan_accesos pa
                        LEFT JOIN STG_MAT.gat_vias_acc va ON pa.cod_via_acc = va.cod_via_acc
            ) pac ON pac.cod_opc_Acc = csa.cod_opc_acc AND pac.COD_CENTRO = csa.COD_CENTRO AND pac.COD_PLAN = csa.COD_PLAN
        left join stg_mat.gat_plan_datos AS gpd on csa.cod_plan= gpd.cod_plan
        left join stg_mat.gat_estudios AS ges on gpd.cod_estudios = ges.cod_estudios
        left join db_uoc_prod.dd_od.equivalencias_viasopcs_uoc_externas AS evue on  pac.Via_acces = evue.via_acces AND  
                                                                                    pac.descripcion = evue.opcio_acces AND tipo_acces = 'Accès Graus oficials') AS origen
on origen.dim_acces_key =  db_uoc_prod.dd_od.dim_acces.dim_acces_key 
when matched 
then update set dim_acces_key = origen.dim_acces_key, tipo_docencia = origen.tipo_docencia, tipo_acces = origen.tipo_acces, via_acces = origen.Via_acc, opcio_acces= origen.opcio_acc, acces_sue = origen.acces_sue, via_siiu = origen.via_siiu, via_oficina = origen.via_oficina, update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
when not matched
then insert (id_acces, dim_acces_key, tipo_docencia, acces_titol_propi,  via_acces, opcio_acces, tipo_acces, acces_sue,  via_siiu, via_oficina, creation_date, update_date)
values (db_uoc_prod.dd_od.sequencia_via_opc_acces.nextval, origen.dim_acces_key, origen.tipo_docencia, origen.acces_titol_propi , origen.Via_acc, origen.opcio_acc, origen.tipo_acces, origen.acces_sue, origen.via_siiu, origen.via_oficina, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz), convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

execution_time := datediff(millisecond, start_time, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
    values (db_uoc_prod.dd_od.sequencia_id_log.nextval, 'dim__loads_dim_vias_opc_acces', CURRENT_USER(), :start_time, :execution_time, 'dim_vias_acces Success');
    
return 'Update completed successfully';

end
;

call db_uoc_prod.dd_od.dim_acces_loads();



SELECT * FROM db_uoc_prod.dd_od.dim_acces where via_oficina = 'ND' AND  tipo_acces = 'Accès Graus oficials';

SELECT * FROM db_uoc_prod.dd_od.dim_acces where tipo_acces = 'Accès Graus oficials' AND  via_acces LIKE 'Títol universitari oficial espanyol% ' AND opcio_acces LIKE 'Máster universitario español%';

SELECT * FROM db_uoc_prod.dd_od.equivalencias_viasopcs_uoc_externas where via_acces = 'Títol universitari oficial espanyol i altres estudis oficials sense finalitzar (trasllat expedient)' AND opcio_acces = 'Máster universitario español y otros estudios universitarios iniciados' ;

SELECT * FROM db_uoc_prod.dd_od.equivalencias_viasopcs_uoc_externas;

SELECT via_acces, opcio_acces, count (*) FROM db_uoc_prod.dd_od.equivalencias_viasopcs_uoc_externas 
group by 1,2 
order by 3 desc;

SELECT * FROM db_uoc_prod.dd_od.equivalencias_viasopcs_uoc_externas 
where via_oficina = 'ND' ;


SELECT * FROM STG_MAT.GAT_CAB_SOLICITUD_ACC limit 10;
SELECT * FROM STG_MAT.gat_expedientes;