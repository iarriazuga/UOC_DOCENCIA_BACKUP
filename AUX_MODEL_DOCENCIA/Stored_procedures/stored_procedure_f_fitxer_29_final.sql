-- Creacio de la sequencia que donara peu a identificador unic de la taula.
-- describe table DB_UOC_PROD.DDP_UNEIX.fitxer29_final_final

-- SELECT * FROM DB_UOC_PROD.DDP_UNEIX.fitxer29_final

-- CREATE OR REPLACE sequence DB_UOC_PROD.DDP_UNEIX.fitxer29_final_ID_TEST start 1 increment 1;  -- not in a view 

-- Creacio de la taula fitxer29 amb les descripcions en els idiomes que es disponibilitzan i els atributs particulars.
-- Pendent de identificar nous requeriments a incloure a la dimensio.

CREATE OR REPLACE table db_uoc_prod.ddp_uneix.fitxer29_final(
        IDP NUMBER(38,0), 
        CODIUNIVERSITAT VARCHAR(10),
        CURSACADEMIC VARCHAR(10),
        CODICURSCATALA VARCHAR(10),
        CODINIVELLCATALA VARCHAR(10),
        NIF VARCHAR(10),
        APTECURS VARCHAR(1),
        NIFAMPLIAT VARCHAR(20),
        CODISEQUENCIADOR VARCHAR(10),
        TIPUSALUMNE NUMBER(38,0),
        ALUMNEMOBILITAT VARCHAR(10),
        IDENTIFICADORALUMNE VARCHAR(30),
        NOMESTUDIANT VARCHAR(15),
        PRIMERCOGNOM VARCHAR(20),
        SEGONCOGNOM VARCHAR(20),
        CODIGRUP VARCHAR(20),
        MODALITATCURS VARCHAR(5),
        APTEEXAMEN VARCHAR(5),
        ACREDITACIO VARCHAR(5),
        FECHA_CARREGA	    TIMESTAMP_NTZ(9)
); 


 

-- Creacio del procediment de carrega i/o actualització de dades programable
CREATE OR REPLACE procedure DB_UOC_PROD.DDP_UNEIX.fitxer29_final_LOADS()  --("ANY_ACADEMIC" VARCHAR(16777216)) 
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
        
        
        merge into db_uoc_prod.ddp_uneix.fitxer29_final
        using (
            SELECT      
                '0' AS IDP,
                '0' AS CODIUNIVERSITAT,
                '0' AS CURSACADEMIC,
                '0' AS CODICURSCATALA,
                '0' AS CODINIVELLCATALA,
                '0' AS NIF,
                '0' AS APTECURS,
                '0' AS NIFAMPLIAT,
                '0' AS CODISEQUENCIADOR,
                0   AS TIPUSALUMNE,
                '0' AS ALUMNEMOBILITAT,
                '0' AS IDENTIFICADORALUMNE,
                '0' AS NOMESTUDIANT,
                '0' AS PRIMERCOGNOM,
                '0' AS SEGONCOGNOM,
                '0' AS CODIGRUP,
                '0' AS MODALITATCURS,
                '0' AS APTEEXAMEN,
                '0' AS ACREDITACIO,
                convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)  AS FECHA_CARREGA
        
        
                    
        ) AS fitxer29_final_aux
        on db_uoc_prod.ddp_uneix.fitxer29_final.IDP = fitxer29_final_aux.IDP
        
         
        when matched
            then update set FECHA_CARREGA = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) 
            
        when not matched
        then insert (
                         IDP,
                         CODIUNIVERSITAT,
                         CURSACADEMIC,
                         CODICURSCATALA,
                         CODINIVELLCATALA,
                         NIF,
                         APTECURS,
                         NIFAMPLIAT,
                         CODISEQUENCIADOR,
                         TIPUSALUMNE,
                         ALUMNEMOBILITAT,
                         IDENTIFICADORALUMNE,
                         NOMESTUDIANT,
                         PRIMERCOGNOM,
                         SEGONCOGNOM,
                         CODIGRUP,
                         MODALITATCURS,
                         APTEEXAMEN,
                         ACREDITACIO,
                         FECHA_CARREGA
                        )
                values (
                        0,
                        '0', -- AS  CODIUNIVERSITAT,
                        '0', -- AS  CURSACADEMIC,
                        '0', -- AS  CODICURSCATALA,
                        '0', -- AS CODINIVELLCATALA,
                        '0', -- AS NIF,
                        '0', -- AS APTECURS,
                        '0', -- AS NIFAMPLIAT,
                        '0', -- AS CODISEQUENCIADOR,
                        0  , -- AS TIPUSALUMNE,
                        '0', -- AS ALUMNEMOBILITAT,
                        '0', -- AS IDENTIFICADORALUMNE,
                        '0', -- AS NOMESTUDIANT,
                        '0', -- AS PRIMERCOGNOM,
                        '0', -- AS SEGONCOGNOM,
                        '0', -- AS CODIGRUP,
                        '0', -- AS MODALITATCURS,
                        '0', -- AS APTEEXAMEN,
                        '0'
                        , -- AS ACREDITACIO,          
                        null -- convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) 
                    )
        
;

/*
-- -- Realización del merge desde la tabla origen fitxer_29 de dim_persona : 
-- transient :  normal pero solo un dia backup y no , fuera de timetravel --> 7 dias para recuperar anteriores como transient
-- crear temporary --> drop despues al cerrar sesion 
buscar procedimientos 
no hace falta merge + truncado e insert AS SELECT + revisar procesos 



*/
merge into ddp_uneix.fitxer29_final ---trunca
        using (
            SELECT 
                vf29p.IDP AS IDP,
                '054' AS CODIUNIVERSITAT,
                '22-23' AS CURSACADEMIC,
                vf29p.CODICURSCATALA AS CODICURSCATALA,  
                COALESCE(vf29p.CODINIVELLCATALA, 'ZZ') AS CODINIVELLCATALA, 
                
                -- duda si dim_persona: Existe end dim_persona y fitxer29 ---> cambiar a dim_persona: hibai e inigo 29_10_2024
                RPAD(vf29p.NIF, 10, '') AS NIF, -- cambio 
                vf29p.APTECURS AS APTECURS,
                RPAD(vf29p.NIFAMPLIAT, 20, '') AS NIFAMPLIAT,
                
                LPAD(TO_VARCHAR(vf29p.CODISEQUENCIADOR), 2, '0') AS CODISEQUENCIADOR,

                -- Elements dim persona
                '1' AS TIPUSALUMNE,
                '' AS ALUMNEMOBILITAT, 
                RPAD(TO_VARCHAR(vf29p.IDENTIFICADORALUMNE), 30, '') AS IDENTIFICADORALUMNE,
                
                dim_pers.NOMBRE_UNEIX_20 AS NOMESTUDIANT,
                dim_pers.APELLIDO1_UNEIX_20 AS PRIMERCOGNOM,
                dim_pers.APELLIDO2_UNEIX_20 AS SEGONCOGNOM,
                
                LPAD(vf29p.CODIGRUP, 10, '') AS CODIGRUP,
                
                '4' AS MODALITATCURS,
                '' AS APTEEXAMEN,  
                '' AS ACREDITACIO,
                -- DIM_PERSONA.NIF_UNEIX_LONG10
                FECHA_CARREGA AS FECHA_CARREGA -- current_timestamp() for timestamp if needed
 
            FROM
                db_uoc_prod.ddp_uneix.fitxer29_enriquida vf29p
 
 -- SELECT * FROM DB_UOC_PROD.DD_OD.DIM_PERSONA
                
            LEFT JOIN DB_UOC_PROD.DD_OD.DIM_PERSONA dim_pers -- ADD: DB_UOC_PROD.DD_OD.DIM_PERSONA
                ON dim_pers.IDP = vf29p.IDP
                
    )  AS fitxer29_final_aux
    on db_uoc_prod.ddp_uneix.fitxer29_final.IDP = fitxer29_final_aux.IDP  --- corrected here
 
    when matched then 
        update set 
            IDP = fitxer29_final_aux.IDP,
            CODIUNIVERSITAT = fitxer29_final_aux.CODIUNIVERSITAT,
            CURSACADEMIC = fitxer29_final_aux.CURSACADEMIC,
            CODICURSCATALA = fitxer29_final_aux.CODICURSCATALA,
            CODINIVELLCATALA = fitxer29_final_aux.CODINIVELLCATALA,
            NIF = fitxer29_final_aux.NIF,
            APTECURS = fitxer29_final_aux.APTECURS,
            NIFAMPLIAT = fitxer29_final_aux.NIFAMPLIAT,
            CODISEQUENCIADOR = fitxer29_final_aux.CODISEQUENCIADOR,
            TIPUSALUMNE = fitxer29_final_aux.TIPUSALUMNE,
            ALUMNEMOBILITAT = fitxer29_final_aux.ALUMNEMOBILITAT,
            IDENTIFICADORALUMNE = fitxer29_final_aux.IDENTIFICADORALUMNE,
            NOMESTUDIANT = fitxer29_final_aux.NOMESTUDIANT,
            PRIMERCOGNOM = fitxer29_final_aux.PRIMERCOGNOM,
            SEGONCOGNOM = fitxer29_final_aux.SEGONCOGNOM,
            CODIGRUP = fitxer29_final_aux.CODIGRUP,
            MODALITATCURS = fitxer29_final_aux.MODALITATCURS,
            APTEEXAMEN = fitxer29_final_aux.APTEEXAMEN,
            ACREDITACIO = fitxer29_final_aux.ACREDITACIO,
            FECHA_CARREGA = null --  convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)

    when not matched
        then insert (
                    IDP,
                    CODIUNIVERSITAT,
                    CURSACADEMIC,
                    CODICURSCATALA,
                    CODINIVELLCATALA,
                    NIF,
                    APTECURS,
                    NIFAMPLIAT,
                    CODISEQUENCIADOR,
                    TIPUSALUMNE,
                    ALUMNEMOBILITAT,
                    IDENTIFICADORALUMNE,
                    NOMESTUDIANT,
                    PRIMERCOGNOM,
                    SEGONCOGNOM,
                    CODIGRUP,
                    MODALITATCURS,
                    APTEEXAMEN,
                    ACREDITACIO,
                    FECHA_CARREGA
                )
        values (
                fitxer29_final_aux.IDP,
                fitxer29_final_aux.CODIUNIVERSITAT,
                fitxer29_final_aux.CURSACADEMIC,
                fitxer29_final_aux.CODICURSCATALA,
                fitxer29_final_aux.CODINIVELLCATALA,
                fitxer29_final_aux.NIF,
                fitxer29_final_aux.APTECURS,
                fitxer29_final_aux.NIFAMPLIAT,
                fitxer29_final_aux.CODISEQUENCIADOR,
                fitxer29_final_aux.TIPUSALUMNE,
                fitxer29_final_aux.ALUMNEMOBILITAT,
                fitxer29_final_aux.IDENTIFICADORALUMNE,
                fitxer29_final_aux.NOMESTUDIANT,
                fitxer29_final_aux.PRIMERCOGNOM,
                fitxer29_final_aux.SEGONCOGNOM,
                fitxer29_final_aux.CODIGRUP,
                fitxer29_final_aux.MODALITATCURS,
                fitxer29_final_aux.APTEEXAMEN,
                fitxer29_final_aux.ACREDITACIO,
                null -- convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)

            )
;

-- execution_time := datediff(millisecond, start_time, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

-- insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
--     values (db_uoc_prod.dd_od.sequencia_id_log.nextval, 'fitxer29_loads', CURRENT_USER(), :start_time, :execution_time, 'fitxer29 Success');
    
return 'Update completed successfully';

end
;


-- Comanda per executar el procediment enmagatzemat al entorn.
call DB_UOC_PROD.DDP_UNEIX.FITXER29_final_LOADS();

SELECT 'Worksheet de Snowflake almacenado.';


SELECT * FROM db_uoc_prod.ddp_uneix.fitxer29_final;


 




 







     