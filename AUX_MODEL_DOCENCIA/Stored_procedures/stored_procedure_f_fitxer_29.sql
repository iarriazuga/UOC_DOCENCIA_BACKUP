-- Creacio de la sequencia que donara peu a identificador unic de la taula.
-- describe table DB_UOC_PROD.DDP_UNEIX.fitxer29_valors_base

-- SELECT * FROM DB_UOC_PROD.DDP_UNEIX.fitxer29_valors_base

CREATE OR REPLACE sequence DB_UOC_PROD.DDP_UNEIX.FITXER29_VALORS_BASE_ID_TEST start 1 increment 1;  -- not in a view 

-- Creacio de la taula fitxer29 amb les descripcions en els idiomes que es disponibilitzan i els atributs particulars.
-- Pendent de identificar nous requeriments a incloure a la dimensio.

CREATE OR REPLACE TEMPORARY table DB_UOC_PROD.DDP_UNEIX.FITXER29_VALORS_BASE(
 
    IDP	                NUMBER(38,0),
    ANY_ACADEMICO	    VARCHAR(9),
    CURS_ACADEMIC	    VARCHAR(9),
    DNI	                VARCHAR(20),
    COD_PLAN	        VARCHAR(4),
    COD_ASIGNATURA	    VARCHAR(6),
    DESC_ASIGNATURA	    VARCHAR(300), 
    NIVELL	            VARCHAR(2),  
    COD_CALIFICACION	VARCHAR(2),
    IND_SUPERA	        VARCHAR(1),
    N	                NUMBER(4,0),
    COD_AULA	        NUMBER(38,0),
    CODIGRUP	        VARCHAR(8),
    FECHA_CARREGA	    TIMESTAMP_NTZ(9)
); 



SELECT * FROM DB_UOC_PROD.DDP_UNEIX.FITXER29_VALORS_BASE;

-- Creacio del procediment de carrega i/o actualització de dades programable
CREATE OR REPLACE procedure DB_UOC_PROD.DDP_UNEIX.FITXER29_VALORS_BASE_LOADS()  --("ANY_ACADEMIC" VARCHAR(16777216)) 
    returns varchar(16777216)
    language SQL
    execute AS caller
    AS 
    begin
    
    let start_time timestamp_ntz:= convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz);
    let execution_time float;


        /*
        -- Crea el registre amb ID_PREGUNTA = 0 per poder assignar a qualsevol registre que no estigui correctament identificat.
        */
        
        merge into db_uoc_prod.DDP_UNEIX.FITXER29_VALORS_BASE
        using (
            SELECT      
            
                        0 AS IDP,
                        '0' AS ANY_ACADEMICO,
                        '0' AS CURS_ACADEMIC,
                        '0' AS DNI,
                        '0' AS COD_PLAN,
                        '0' AS COD_ASIGNATURA,
                        '0' AS DESC_ASIGNATURA,
                        '0' AS NIVELL,
                        '0' AS COD_CALIFICACION,
                        '0' AS IND_SUPERA,
                        0 AS N,
                        0 AS COD_AULA,
                        '0' AS CODIGRUP,
                       
                       convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)  AS FECHA_CARREGA
        
        
                    
        ) AS fitxer29_base
        on db_uoc_prod.DDP_UNEIX.FITXER29_VALORS_BASE.IDP = fitxer29_base.IDP
        
         
        when matched
        then update set FECHA_CARREGA = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) 
        when not matched
        then insert (
                    	IDP,
                    	ANY_ACADEMICO,
                        CURS_ACADEMIC,
                    	DNI,
                    	COD_PLAN,
                    	COD_ASIGNATURA,
                    	DESC_ASIGNATURA,
                    	NIVELL,
                    	COD_CALIFICACION,
                    	IND_SUPERA,
                    	N,
                    	COD_AULA,
                    	CODIGRUP,
                        FECHA_CARREGA
                        )
                values (
                
                        0        -- IDP	                NUMBER(38,0),
                        ,'0'     -- ANY_ACADEMICO	    VARCHAR(9),
                        ,'0'     -- CURS_ACADEMIC	    VARCHAR(9),
                        ,'0'     -- DNI	                VARCHAR(10),
                        ,'0'     -- COD_PLAN	        VARCHAR(4),
                        ,'0'     -- COD_ASIGNATURA	    VARCHAR(6),
                        ,'0'     -- DESC_ASIGNATURA	    VARCHAR(300), 
                        ,'0'     -- NIVELL	            VARCHAR(2),  
                        ,'0'     -- COD_CALIFICACION	VARCHAR(2), 
                        ,'0'     -- IND_SUPERA	        VARCHAR(1),  
                        , 0      -- N	                NUMBER(4,0),
                        , 0      -- COD_AULA	        NUMBER(38,0),
                        ,'0'     -- CODIGRUP	        VARCHAR(8),             
                        , convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) 
                    )
        ;

/*
-- Realización del merge desde la tabla origen STG y posterior PIVOT a la tabla de dim_pregunta
*/
merge into db_uoc_prod.DDP_UNEIX.FITXER29_VALORS_BASE --inser registro 0
using (
        SELECT 
                e.idp AS IDP,
                em.ANY_ACADEMICO,
                d_sem.CURS_ACADEMIC,
                dp.DNI, -- Revisar por tipo documento
                e.COD_PLAN,
                a.cod_asignatura,
                a.desc_asignatura,
                CASE
                    WHEN a.COD_ASIGNATURA = '00.202' THEN 'CE'
                    WHEN a.cod_asignatura = '00.062' THEN 'C1'
                    WHEN a.cod_asignatura = '00.065' THEN 'C1'
                    WHEN a.cod_asignatura = '00.064' THEN 'C2'

                END AS Nivell,
                eac.cod_calificacion,
                c.ind_supera,
                '2' AS n,
                eam.COD_AULA,
                'null' AS CodiGrup,
                convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)  AS FECHA_CARREGA
                
            FROM  stg_mat.gat_expedientes e
                JOIN STG_MAT.GAT_EXP_MATRICULAS em ON e.num_expediente = em.num_expediente
                JOIN STG_DADESRA.GAT_exp_asig_matriculas eam ON em.num_expediente = eam.num_expediente AND em.any_academico = eam.any_academico
                JOIN STG_DADESRA.gat_asignaturas a ON eam.cod_asignatura = a.cod_asignatura
                LEFT JOIN STG_DOCENCIA.gat_exp_asig_calificaciones eac ON eam.num_expediente = eac.num_expediente AND eac.any_academico = eam.any_academico AND eac.cod_asignatura = eam.cod_asignatura
                LEFT JOIN STG_Docencia.gat_calificaciones c ON eac.cod_calificacion = c.cod_calificacion
                LEFT JOIN STG_MAT.TERCERS_DATOS_PERSONAS dp ON dp.IDP = e.IDP
                LEFT JOIN DB_UOC_PROD.DD_OD.DIM_SEMESTRE d_sem ON d_sem.ANY_NATURAL= left(eam.ANY_ACADEMICO,4) AND  d_sem.semestre= right(eam.ANY_ACADEMICO,1) -- review

            WHERE 1=1 
                AND em.fecha_anulacion IS NULL
                AND eam.fecha_anulacion IS NULL
                AND eam.any_academico IN ('20221', '20222')
                AND a.cod_asignatura IN ('00.132', '00.183', '00.028', '00.062', '00.065', '00.029', '00.098', '00.064', '00.202') --- change in the future  table 
                
    )  AS fitxer29_base
    on db_uoc_prod.DDP_UNEIX.FITXER29_VALORS_BASE.IDP = fitxer29_base.IDP  --- corrected here
 
    when matched then 
        update set 
            IDP= fitxer29_base.IDP,
            ANY_ACADEMICO= fitxer29_base.ANY_ACADEMICO,
            CURS_ACADEMIC= fitxer29_base.CURS_ACADEMIC,
            DNI= fitxer29_base.DNI,
            COD_PLAN= fitxer29_base.COD_PLAN,
            COD_ASIGNATURA= fitxer29_base.COD_ASIGNATURA,
            DESC_ASIGNATURA= fitxer29_base.DESC_ASIGNATURA,
            NIVELL= fitxer29_base.NIVELL,
            COD_CALIFICACION= fitxer29_base.COD_CALIFICACION,
            IND_SUPERA= fitxer29_base.IND_SUPERA,
            N= fitxer29_base.N,
            COD_AULA= fitxer29_base.COD_AULA,
            CODIGRUP= fitxer29_base.CODIGRUP,
            FECHA_CARREGA = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)

    when not matched
        then insert (
            	IDP,
            	ANY_ACADEMICO,
                CURS_ACADEMIC,
            	DNI,
            	COD_PLAN,
            	COD_ASIGNATURA,
            	DESC_ASIGNATURA,
            	NIVELL,
            	COD_CALIFICACION,
            	IND_SUPERA,
            	N,
            	COD_AULA,
            	CODIGRUP,
                FECHA_CARREGA
                )
        values (
             	fitxer29_base.IDP,
            	fitxer29_base.ANY_ACADEMICO,
                fitxer29_base.CURS_ACADEMIC,
            	fitxer29_base.DNI,
            	fitxer29_base.COD_PLAN,
            	fitxer29_base.COD_ASIGNATURA,
            	fitxer29_base.DESC_ASIGNATURA,
            	fitxer29_base.NIVELL,
            	fitxer29_base.COD_CALIFICACION,
            	fitxer29_base.IND_SUPERA,
            	fitxer29_base.N,
            	fitxer29_base.COD_AULA,
            	fitxer29_base.CODIGRUP,
                convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)

            )
;

 
execution_time := datediff(millisecond, start_time, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
    values (db_uoc_prod.dd_od.sequencia_id_log.nextval, 'fitxer29_loads', CURRENT_USER(), :start_time, :execution_time, 'fitxer29 Success');
    
return 'Update completed successfully';

end
;


-- Comanda per executar el procediment enmagatzemat al entorn.
call DB_UOC_PROD.DDP_UNEIX.FITXER29_VALORS_BASE_LOADS();

SELECT 'Worksheet de Snowflake almacenado.';


SELECT * FROM DB_UOC_PROD.DDP_UNEIX.FITXER29_VALORS_BASE;


 
















     