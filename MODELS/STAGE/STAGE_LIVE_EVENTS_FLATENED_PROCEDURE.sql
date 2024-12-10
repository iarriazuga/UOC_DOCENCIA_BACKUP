
-- -- #################################################################################################
-- -- #################################################################################################
-- -- STAGE_LIVE_EVENTS_FLATENED_
-- -- #################################################################################################
-- -- #################################################################################################

CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED (
 
    DIM_ASSIGNATURA_KEY VARCHAR(6),  
    DIM_SEMESTRE_KEY INT, 
    -- DIM_RECURSOS_APRENENTATGE_KEY VARCHAR(15),  -- not valid : francesc -->  incluir 
    CODI_RECURS INT, 
    Origen_events VARCHAR(6),
    -- SOURCE2 VARCHAR(6),  -- removed
    EVENT_TIME DATETIME, 
    EVENT_DATE DATE, 
    ACCIO VARCHAR(16777216),
    NOM_ACTOR VARCHAR(16777216),
    ACTOR_TIPUS VARCHAR(16777216),
    usuari_dAcces VARCHAR(16777216),
    id_sistema_usuari VARCHAR(16777216),
    titol_assignatura VARCHAR(16777216),
    id_curs_canvas VARCHAR(16777216),
    id_sistema_curs VARCHAR(16777216),
    ROL VARCHAR(16777216),
    estat_membre VARCHAR(16777216),
    titol_recurs VARCHAR(16777216),
    enllac VARCHAR(16777216),
    OBJECT_MEDIATYPE VARCHAR(16777216),
    tipus_recurs VARCHAR(16777216),
    format_recurs VARCHAR(16777216),
    enllac_url VARCHAR(16777216)
);


CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED_LOADS() 
RETURNS VARCHAR(16777216) 
LANGUAGE SQL 
EXECUTE AS CALLER AS 
BEGIN
    -- Declaración de variables
    LET start_time TIMESTAMP_NTZ := CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ); 
    LET execution_time FLOAT;

    -- INSERT: Volcat de registres
    TRUNCATE TABLE DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED ;

    INSERT INTO DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED  (
        DIM_ASSIGNATURA_KEY,
        DIM_SEMESTRE_KEY,
        CODI_RECURS,
        Origen_events,
        EVENT_TIME,
        EVENT_DATE,
        ACCIO,
        NOM_ACTOR,
        ACTOR_TIPUS,
        usuari_dAcces,
        id_sistema_usuari,
        titol_assignatura,
        id_curs_canvas,
        id_sistema_curs,
        ROL,
        estat_membre,
        titol_recurs,
        enllac,
        OBJECT_MEDIATYPE,
        tipus_recurs,
        format_recurs,
        enllac_url
    )
    WITH aux_cte_table AS (
        SELECT 
            GET_PATH(JSON, 'data[0]:object.extensions."edu.uoc.ralti".materialid')::string AS CODI_RECURS,
            GET_PATH(JSON, 'data[0]:extensions."edu.uoc.ralti".subjectCode')::string AS DIM_ASSIGNATURA_KEY, 
            GET_PATH(JSON, 'data[0]:extensions."edu.uoc.ralti".semester')::string AS DIM_SEMESTRE_KEY,
            JSON:sendTime::datetime AS event_time,
            JSON:sendTime::date AS event_date,
            JSON:data[0]:ACCIO::string AS ACCIO,
            GET_PATH(JSON, 'data[0]:actor.name')::string AS NOM_ACTOR,
            GET_PATH(JSON, 'data[0]:actor.type')::string AS ACTOR_TIPUS,  
            GET_PATH(JSON, 'data[0]:actor.extensions."com.instructure.canvas".user_login')::string AS usuari_dAcces,
            GET_PATH(JSON, 'data[0]:actor.extensions."com.instructure.canvas".id_sistema_usuari')::string AS id_sistema_usuari,    
            GET_PATH(JSON, 'data[0]:group.name')::string AS titol_assignatura,  
            GET_PATH(JSON, 'data[0]:extensions."edu.uoc.ralti".id_curs_canvas')::string AS id_curs_canvas,   
            GET_PATH(JSON, 'data[0]:extensions."edu.uoc.ralti".id_sistema_curs')::string AS id_sistema_curs, 
            GET_PATH(JSON, 'data[0]:membership.roles.roles')::string AS rol,
            GET_PATH(JSON, 'data[0]:membership.status')::string AS estat_membre,
            GET_PATH(JSON, 'data[0]:object.name')::string AS titol_recurs,
            GET_PATH(JSON, 'data[0]:object.id')::string AS enllac,
            GET_PATH(JSON, 'data[0]:object.mediatype')::string AS object_mediatype,
            GET_PATH(JSON, 'data[0]:object.type')::string AS tipus_recurs,
            GET_PATH(JSON, 'data[0]:object.extensions."edu.uoc.ralti".format')::string AS format_recurs,
            upper(GET_PATH(JSON, 'data[0]:object.extensions."edu.uoc.ralti".source')::string) AS Origen_events,
            GET_PATH(JSON, 'data[0]:object.extensions."edu.uoc.ralti".url')::string AS enllac_url 
        FROM DB_UOC_PROD.STG_DADESRA.LIVE_EVENTS_CALIPER_DUMMY le 
        WHERE GET_PATH(JSON, 'data[0]:object.extensions."edu.uoc.ralti".materialid')::string IS NOT NULL
        AND GET_PATH(JSON, 'data[0]:extensions."edu.uoc.ralti".subjectCode')::string IS NOT NULL
        AND GET_PATH(JSON, 'data[0]:extensions."edu.uoc.ralti".semester')::string IS NOT NULL
    )
    SELECT 
        LEFT(DIM_ASSIGNATURA_KEY, 6) AS DIM_ASSIGNATURA_KEY,
        TRY_CAST(DIM_SEMESTRE_KEY AS INT) AS DIM_SEMESTRE_KEY, 
        TRY_CAST(CODI_RECURS AS INT) AS CODI_RECURS, 
        Origen_events, 
        EVENT_TIME, 
        EVENT_DATE, 
        ACCIO, 
        NOM_ACTOR, 
        ACTOR_TIPUS, 
        usuari_dAcces, 
        id_sistema_usuari, 
        titol_assignatura, 
        id_curs_canvas, 
        id_sistema_curs, 
        ROL, 
        estat_membre, 
        titol_recurs, 
        enllac, 
        OBJECT_MEDIATYPE, 
        tipus_recurs, 
        format_recurs, 
        enllac_url
    FROM aux_cte_table
    WHERE DIM_ASSIGNATURA_KEY IS NOT NULL
    AND DIM_SEMESTRE_KEY IS NOT NULL
    AND CODI_RECURS IS NOT NULL;


    -- LOGS
    EXECUTION_TIME := DATEDIFF(MILLISECOND, START_TIME, CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ));
    INSERT INTO DB_UOC_PROD.DD_OD.PROCEDURES_LOG (
        ID_LOG, PROCEDURE_NAME, EXECUTED_BY, EXECUTION_DATE, EXECUTION_TIME, REMARKS
    )
    VALUES (
        DB_UOC_PROD.DD_OD.SEQUENCIA_ID_LOG.NEXTVAL, 
        'DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED', 
        CURRENT_USER(), 
        :START_TIME, 
        :EXECUTION_TIME, 
        'DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED Success'
    );

    RETURN 'Update completed successfully';
END;

 

-- Procedure Execution
CALL DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED_LOADS();


 -- select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED