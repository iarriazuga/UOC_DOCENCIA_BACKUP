CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG (
    -- ID_DIM_D NUMBER(20, 0) IDENTITY(1, 1), -- Auto-increment without sequence
    ID_DIM_D INT AUTOINCREMENT PRIMARY KEY,
    ID_ASSIGNATURA NUMBER(38, 0),
    ID_SEMESTRE NUMBER(38, 0),
    ID_CODI_RECURS NUMBER(38, 0),
    ID_PERSONA NUMBER(38, 0),

    DIM_PERSONA_KEY NUMBER(10,0),
    DIM_ASSIGNATURA_KEY VARCHAR(6),
    DIM_SEMESTRE_KEY NUMBER(38, 0),
    DIM_RECURSOS_APRENENTATGE_KEY VARCHAR(15),
    SOURCE_DADES_ACADEMIQUES VARCHAR(5),
    TIMES_USED NUMBER(18, 0),
    CREATION_DATE TIMESTAMP_NTZ(9) NOT NULL,
    UPDATE_DATE TIMESTAMP_NTZ(9) NOT NULL
)
;
 

CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG_LOADS()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS
BEGIN
    -- Declaració de variables
    LET start_time TIMESTAMP_NTZ := CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ);
    LET execution_time FLOAT;

    -- INSERT: Volcat de registres
    TRUNCATE TABLE DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG ;

    INSERT INTO DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG (
        id_assignatura
        , id_semestre
        , id_codi_recurs
        , id_persona
        , DIM_PERSONA_KEY
        , DIM_ASSIGNATURA_KEY
        , DIM_SEMESTRE_KEY
        , DIM_RECURSOS_APRENENTATGE_KEY
        , TIMES_USED
        , CREATION_DATE
        , UPDATE_DATE
    )
    SELECT 
        id_assignatura,
        id_semestre,
        id_codi_recurs,
        id_persona,
        DIM_PERSONA_KEY,
        DIM_ASSIGNATURA_KEY,
        DIM_SEMESTRE_KEY,
        DIM_RECURSOS_APRENENTATGE_KEY,
        COALESCE(TIMES_USED, 0) AS TIMES_USED,
        CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ),
        CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)
    FROM (
        WITH auxiliar AS (
            SELECT 
                dades_academiques.id_assignatura,   
                dades_academiques.id_semestre,
                dades_academiques.id_codi_recurs,    
                dades_academiques.id_persona,
                dades_academiques.DIM_PERSONA_KEY,
                dades_academiques.DIM_ASSIGNATURA_KEY,
                dades_academiques.DIM_SEMESTRE_KEY,
                dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY,
                dades_academiques.ORIGEN_DADES_ACADEMIQUES,
                COUNT(dades_academiques.EVENT_CODI_RECURS) AS TIMES_USED
            FROM DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS dades_academiques
            GROUP BY 
                dades_academiques.id_assignatura,
                dades_academiques.id_semestre,
                dades_academiques.id_codi_recurs,
                dades_academiques.id_persona,
                dades_academiques.DIM_PERSONA_KEY,
                dades_academiques.DIM_ASSIGNATURA_KEY,
                dades_academiques.DIM_SEMESTRE_KEY,
                dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY,
                dades_academiques.ORIGEN_DADES_ACADEMIQUES
        )
        SELECT
            id_assignatura,
            id_semestre,
            id_codi_recurs,
            id_persona,
            DIM_PERSONA_KEY,
            DIM_ASSIGNATURA_KEY,
            DIM_SEMESTRE_KEY,
            DIM_RECURSOS_APRENENTATGE_KEY,
            TIMES_USED
        FROM auxiliar
    ) AS datos_finales;

    -- LOGS
    execution_time := DATEDIFF(MILLISECOND, start_time, CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ));
    INSERT INTO db_uoc_prod.dd_od.procedures_log (
        id_log, procedure_name, executed_by, execution_date, execution_time, remarks
    )
    VALUES (
        db_uoc_prod.dd_od.sequencia_id_log.NEXTVAL, 'DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG',
        CURRENT_USER(), :start_time, :execution_time, 'DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG Success'
    );

    RETURN 'Update completed successfully';
END;

-- Consultes addicionals
CALL DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG_LOADS();



-- select * from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG