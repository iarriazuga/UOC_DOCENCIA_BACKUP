-- Creacio de la sequencia que donara peu a identificador unic de la taula.

CREATE OR REPLACE sequence db_uoc_prod.dd_od.dim_aula_id_aula start 1 increment 1;

-- Creacio de la taula DIM_AULA amb les descripcions en els idiomes que es disponibilitzan i els atributs particulars.
-- Pendent de identificar nous requeriments a incloure a la dimensio.

CREATE OR REPLACE TABLE db_uoc_prod.dd_od.dim_aula (

	COD_AULA NUMBER(10,0)
	,COD_ASIGNATURA VARCHAR(8)
	,ID_AULA_KEY VARCHAR(18)
    ,CREATION_DATE TIMESTAMP_NTZ(9)
    ,UPDATE_DATE TIMESTAMP_NTZ(9)
);


-- Creacio del procediment de carrega i/o actualització de dades programable
CREATE OR REPLACE procedure db_uoc_prod.dd_od.dim_aula_loads()
    returns varchar(16777216)
    language SQL
    execute AS caller
    AS 
    begin
    
    let start_time timestamp_ntz := convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz);
    let execution_time float;


/*
-- Crea el registre amb ID_AULA_KEY = 0 per poder assignar a qualsevol registre que no estigui correctament identificat.
*/

-- merge into db_uoc_prod.dd_od.dim_aula --inser registro 0
-- using (
--         SELECT 
--             '0' AS ID_AULA_KEY, -- convert innto 
--             '0' AS COD_ASIGNATURA,
--             0 AS COD_AULA,
 
--             convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS CREATION_DATE,
--             convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS UPDATE_DATE
--     ) AS dim_aula_rep 
--         on db_uoc_prod.dd_od.dim_aula.ID_AULA_KEY = dim_aula.ID_AULA_KEY
    
--     when matched
--         then update set update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)

--     when not matched
--         then insert (
--                 ID_AULA_KEY,
--                 COD_ASIGNATURA,
--                 COD_AULA,
                
--                 CREATION_DATE,
--                 UPDATE_DATE
--                 )
--         values (
--                 '0'
--                 ,'0'
--                 , 0
--                 , convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
--                 ,convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
--             )
-- ;



merge into db_uoc_prod.dd_od.dim_aula
using (
        SELECT
            dim_aula_orig.COD_AULA || dim_aula_orig.COD_ASIGNATURA AS ID_AULA_KEY, 
            dim_aula_orig.COD_ASIGNATURA,
            dim_aula_orig.COD_AULA,
            dim_aula_orig.FECHA_CREACION AS CREATION_DATE,
            dim_aula_orig.TS_CARGA AS UPDATE_DATE
        FROM DB_UOC_PROD.STG_DOCENCIA.GAT_AULAS_ASIG dim_aula_orig
    ) AS dim_aula_orig
    on db_uoc_prod.dd_od.dim_aula.ID_AULA_KEY = dim_aula_orig.ID_AULA_KEY  --- corrected here
when matched then 
    update set 
    ID_AULA_KEY = dim_aula_orig.ID_AULA_KEY,
    COD_ASIGNATURA = dim_aula_orig.COD_ASIGNATURA,
    COD_AULA = dim_aula_orig.COD_AULA, 
    CREATION_DATE = dim_aula_orig.CREATION_DATE,
    update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
when not matched then
    insert (
        ID_AULA_KEY,
        COD_ASIGNATURA,
        COD_AULA,
        CREATION_DATE,
        UPDATE_DATE
    ) 
    values (
        dim_aula_orig.ID_AULA_KEY,
        dim_aula_orig.COD_ASIGNATURA,
        dim_aula_orig.COD_AULA,
        convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz), 
        convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
    );


execution_time := datediff(millisecond, start_time, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
    values (db_uoc_prod.dd_od.sequencia_id_log.nextval, 'dim_aula_loads', CURRENT_USER(), :start_time, :execution_time, 'dim_aula Success');
    
return 'Update completed successfully';

end
;


-- Comanda per executar el procediment enmagatzemat al entorn.
call db_uoc_prod.dd_od.dim_aula_loads();

SELECT 'Worksheet de Snowflake almacenado.';

SELECT * FROM db_uoc_prod.dd_od.dim_aula;

--############################################################################################################################################
/**AUX_VALIDATION_CODE**/ 
--############################################################################################################################################

-- with aux_aula AS ( 
-- SELECT  
--     COD_AULA, 
--     cod_asignatura, 
--     COD_AULA || cod_asignatura AS ID_AULA_KEY, 
--     count(*)
    
-- FROM DB_UOC_PROD.STG_DOCENCIA.GAT_AULAS_ASIG
-- group by 1,2,3

-- ) 
-- SELECT count(*) FROM aux_aula;   --- 30179 

/** related tables **/ 
-- SELECT * FROM DB_UOC_PROD.STG_DOCENCIA.GAT_AULAS_ASIG
-- DB_UOC_PROD.STG_DOCENCIA.GAT_PLAN_ASIGNATURAS
-- DB_UOC_PROD.STG_DOCENCIA.GAT_EXP_AULAS_ASIG_ESTUDIANTES


-- SELECT * FROM DB_UOC_PROD.STG_DOCENCIA.GAT_AULAS_ASIG

-- CREATE OR REPLACE TRANSIENT TABLE DB_UOC_PROD.STG_DOCENCIA.aux_aula (

-- 	COD_AULA NUMBER(10,0),
-- 	COD_ASIGNATURA VARCHAR(8),
-- 	ID_AULA_KEY  VARCHAR(18),
-- );

-- SELECT * FROM STG_ENQUESTES.ENQUESTES2_UFI_ITERATIVA_INSTIT_ASIGN LIMIT 100;

 