CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS (
    -- ID_DIM_D.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS NUMBER(20,0) AUTOINCREMENT START 1 INCREMENT 1 COMMENT 'Clau subrogada que identifica de forma única els registres de la taula.',
    ID_ASSIGNATURA NUMBER(16,0),
    ID_SEMESTRE NUMBER(16,0),
    ID_CODI_RECURS NUMBER(1,0),
    ID_PERSONA NUMBER(16,0),
    
    DIM_PERSONA_KEY NUMBER(10,0),
    DIM_ASSIGNATURA_KEY VARCHAR(6),
    DIM_SEMESTRE_KEY NUMBER(38,0),
    DIM_RECURSOS_APRENENTATGE_KEY VARCHAR(15),

    ORIGEN_DADES_ACADEMIQUES VARCHAR(5),
    CODI_RECURS NUMBER(38,0),
    EVENT_CODI_RECURS NUMBER(38,0),
    EVENT_TIME VARCHAR(16777216),
    EVENT_DATE VARCHAR(16777216),
    ACCIO VARCHAR(16777216),
    NOM_ACTOR VARCHAR(16777216),
    ACTOR_TIPUS VARCHAR(16777216),
    USUARI_DACCES VARCHAR(16777216),
    ID_SISTEMA_USUARI VARCHAR(16777216),
    TITOL_ASSIGNATURA VARCHAR(16777216),
    ID_CURS_CANVAS VARCHAR(16777216),
    ID_SISTEMA_CURS VARCHAR(16777216),
    ROL VARCHAR(16777216),
    ESTAT_MEMBRE VARCHAR(16777216),
    TITOL_RECURS VARCHAR(16777216),
    ENLLAC VARCHAR(16777216),
    OBJECT_MEDIATYPE VARCHAR(16777216),
    TIPUS_RECURS VARCHAR(16777216),
    FORMAT_RECURS VARCHAR(16777216),
    ORIGEN_EVENTS VARCHAR(6),
    ENLLAC_URL VARCHAR(16777216),
    CREATION_DATE TIMESTAMP_NTZ(9) NOT NULL COMMENT 'Data de creació del registre de la informació.',
    UPDATE_DATE TIMESTAMP_NTZ(9) NOT NULL COMMENT 'Data de càrrega de la informació.'
);

CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_LOADS() 
RETURNS VARCHAR(16777216) 
LANGUAGE SQL 
EXECUTE AS CALLER AS 
BEGIN
    -- Declaración de variables
    LET start_time TIMESTAMP_NTZ := CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ); 
    LET execution_time FLOAT;

    -- INSERT: Volcat de registres
    TRUNCATE TABLE DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS;

    INSERT INTO DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS (
        ID_ASSIGNATURA
        , ID_SEMESTRE
        , ID_CODI_RECURS
        , ID_PERSONA

        , DIM_PERSONA_KEY
        , DIM_ASSIGNATURA_KEY
        , DIM_SEMESTRE_KEY
        , DIM_RECURSOS_APRENENTATGE_KEY
        
        , ORIGEN_DADES_ACADEMIQUES
        , CODI_RECURS
        , EVENT_CODI_RECURS
        , EVENT_TIME
        , EVENT_DATE
        , ACCIO
        , NOM_ACTOR
        , ACTOR_TIPUS
        , USUARI_DACCES
        , ID_SISTEMA_USUARI
        , TITOL_ASSIGNATURA
        , ID_CURS_CANVAS
        , ID_SISTEMA_CURS
        , ROL
        , ESTAT_MEMBRE
        , TITOL_RECURS
        , ENLLAC
        , OBJECT_MEDIATYPE
        , TIPUS_RECURS
        , FORMAT_RECURS
        , ORIGEN_EVENTS
        , ENLLAC_URL
        , CREATION_DATE
        , UPDATE_DATE 
    )

    SELECT 
        asignatura.id_assignatura,
        semestre.id_semestre,
        recursos.id_codi_recurs,
        dim_persona.id_persona,

        aux_temporary_table.DIM_PERSONA_KEY,
        aux_temporary_table.DIM_ASSIGNATURA_KEY,
        aux_temporary_table.DIM_SEMESTRE_KEY,
        aux_temporary_table.DIM_RECURSOS_APRENENTATGE_KEY,

        aux_temporary_table.ORIGEN_DADES_ACADEMIQUES,
        aux_temporary_table.CODI_RECURS,
        aux_temporary_table.CODI_RECURS AS EVENT_CODI_RECURS,
        aux_temporary_table.EVENT_TIME,
        aux_temporary_table.EVENT_DATE,
        aux_temporary_table.ACCIO,
        aux_temporary_table.NOM_ACTOR,
        aux_temporary_table.ACTOR_TIPUS,
        aux_temporary_table.usuari_dAcces,
        aux_temporary_table.id_sistema_usuari,
        aux_temporary_table.titol_assignatura,
        aux_temporary_table.id_curs_canvas,
        aux_temporary_table.id_sistema_curs,
        aux_temporary_table.ROL,
        aux_temporary_table.estat_membre,
        aux_temporary_table.titol_recurs,
        aux_temporary_table.enllac,
        aux_temporary_table.OBJECT_MEDIATYPE,
        aux_temporary_table.tipus_recurs,
        aux_temporary_table.format_recurs,
        aux_temporary_table.Origen_events,
        aux_temporary_table.enllac_url,
        CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ),
        CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)
    FROM (
        SELECT 
            dades_academiques.DIM_PERSONA_KEY,
            dades_academiques.DIM_ASSIGNATURA_KEY,
            dades_academiques.DIM_SEMESTRE_KEY,
            dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY,
            dades_academiques.ORIGEN_DADES_ACADEMIQUES,
            dades_academiques.CODI_RECURS,
            events.CODI_RECURS AS EVENT_CODI_RECURS,
            events.EVENT_TIME,
            events.EVENT_DATE,
            events.ACCIO,
            events.NOM_ACTOR,
            events.ACTOR_TIPUS,
            events.usuari_dAcces,
            events.id_sistema_usuari,
            events.titol_assignatura,
            events.id_curs_canvas,
            events.id_sistema_curs,
            events.ROL,
            events.estat_membre,
            events.titol_recurs,
            events.enllac,
            events.OBJECT_MEDIATYPE,
            events.tipus_recurs,
            events.format_recurs,
            events.Origen_events,
            events.enllac_url
        FROM DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES dades_academiques
        LEFT JOIN DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED events
            ON dades_academiques.DIM_ASSIGNATURA_KEY = events.DIM_ASSIGNATURA_KEY
            AND dades_academiques.DIM_SEMESTRE_KEY = events.DIM_SEMESTRE_KEY
            AND dades_academiques.CODI_RECURS = events.CODI_RECURS
    
    ) aux_temporary_table
    
    LEFT JOIN DB_UOC_PROD.DD_OD.DIM_ASSIGNATURA asignatura 
        ON asignatura.DIM_ASSIGNATURA_KEY = aux_temporary_table.DIM_ASSIGNATURA_KEY
    LEFT JOIN DB_UOC_PROD.DD_OD.DIM_SEMESTRE semestre 
        ON semestre.DIM_SEMESTRE_KEY = aux_temporary_table.DIM_SEMESTRE_KEY
    LEFT JOIN DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE recursos 
        ON recursos.DIM_RECURSOS_APRENENTATGE_KEY = aux_temporary_table.DIM_RECURSOS_APRENENTATGE_KEY
    LEFT JOIN DB_UOC_PROD.DD_OD.DIM_PERSONA dim_persona 
        ON dim_persona.DIM_PERSONA_KEY = aux_temporary_table.DIM_PERSONA_KEY
    ;
 


    -- LOGS
    EXECUTION_TIME := DATEDIFF(MILLISECOND, START_TIME, CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ));
    INSERT INTO DB_UOC_PROD.DD_OD.PROCEDURES_LOG (
        ID_LOG, PROCEDURE_NAME, EXECUTED_BY, EXECUTION_DATE, EXECUTION_TIME, REMARKS
    )
    VALUES (
        DB_UOC_PROD.DD_OD.SEQUENCIA_ID_LOG.NEXTVAL, 
        'DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS', 
        CURRENT_USER(), 
        :START_TIME, 
        :EXECUTION_TIME, 
        'DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS Success'
    );

    RETURN 'Update completed successfully';
END;

 

-- Procedure Execution
CALL DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_LOADS();



-- select * from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS