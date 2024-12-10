-- -- #################################################################################################
-- -- #################################################################################################
-- -- STAGE_DADES_ACADEMIQUES_DIMAX
-- -- #################################################################################################
-- -- #################################################################################################

CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX (
    -- ID_DIM_D_DDP_DOCENCIA_STAGE_DADES_ACADEMIQUES_COCO NUMBER(20,0),
    DIM_ASSIGNATURA_KEY VARCHAR(255),
    DIM_SEMESTRE_KEY VARCHAR(6),
    DIM_RECURSOS_APRENENTATGE_KEY VARCHAR(19),
    CODI_RECURS VARCHAR(12),
    CREATION_DATE TIMESTAMP_NTZ(9),
    UPDATE_DATE TIMESTAMP_NTZ(9)
);


CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO_LOADS() 
RETURNS VARCHAR(16777216) 
LANGUAGE SQL 
EXECUTE AS CALLER AS 
BEGIN
    -- Declaración de variables
    LET start_time TIMESTAMP_NTZ := CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ); 
    LET execution_time FLOAT;

    -- INSERT: Volcat de registres
    TRUNCATE TABLE DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES;

 
    INSERT INTO DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX(
        DIM_ASSIGNATURA_KEY,
        DIM_SEMESTRE_KEY,
        DIM_RECURSOS_APRENENTATGE_KEY,
        CODI_RECURS, 
        CREATION_DATE,
        UPDATE_DATE
    )
    WITH dimax_resofite_path_unified AS (  
        SELECT DISTINCT
            node_recurs,  
            node_cami
        FROM db_uoc_prod.stg_dadesra.dimax_resofite_path
    ),
    node_structure_aplanation AS ( 
        SELECT   
            dimax_item_dimax.cami_node,
            dimax_resofite_path_unified.node_cami,
            dimax_resofite_path_unified.node_recurs,
            dimax_item_dimax.titol,
            ARRAY_SIZE(SPLIT(dimax_item_dimax.cami_node, ';')) AS length_resources
        FROM dimax_resofite_path_unified
        LEFT JOIN db_uoc_prod.stg_dadesra.dimax_item_dimax 
            ON dimax_resofite_path_unified.node_recurs = dimax_item_dimax.id
        WHERE  
            ARRAY_SIZE(SPLIT(dimax_item_dimax.cami_node, ';')) = 5 
            OR dimax_item_dimax.titol LIKE '%Root Node:PV%'
    ),
    node_structure_asignaturas AS ( 
        SELECT DISTINCT
            SUBSTR(titol, 0, 6) AS DIM_ASSIGNATURA_KEY,
            NODE_CAMI,
            SPLIT_PART(CAMI_NODE, ';', ARRAY_SIZE(SPLIT(CAMI_NODE, ';'))-1) AS NODE_RECURS_SEMESTRE  
        FROM node_structure_aplanation
        WHERE length_resources = 5
    ),
    node_structure_semestres AS ( 
        SELECT DISTINCT  
            NODE_RECURS AS NODE_RECURS_SEMESTRE,
            REPLACE(titol, 'Root Node:PV', '') AS DIM_SEMESTRE_KEY 
        FROM node_structure_aplanation
        WHERE titol LIKE '%Root Node:PV%'
    )
    SELECT  
        'DIMAX-' || node_structure_asignaturas.node_cami AS DIM_RECURSOS_APRENENTATGE_KEY,
        node_structure_semestres.DIM_SEMESTRE_KEY,
        node_structure_asignaturas.DIM_ASSIGNATURA_KEY,
        node_structure_asignaturas.node_cami AS CODI_RECURS, 
        CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ),
        CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)
    FROM node_structure_asignaturas   
    INNER JOIN node_structure_semestres 
        ON node_structure_asignaturas.NODE_RECURS_SEMESTRE = node_structure_semestres.NODE_RECURS_SEMESTRE;
 


    -- LOGS
    EXECUTION_TIME := DATEDIFF(MILLISECOND, START_TIME, CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ));
    INSERT INTO DB_UOC_PROD.DD_OD.PROCEDURES_LOG (
        ID_LOG, PROCEDURE_NAME, EXECUTED_BY, EXECUTION_DATE, EXECUTION_TIME, REMARKS
    )
    VALUES (
        DB_UOC_PROD.DD_OD.SEQUENCIA_ID_LOG.NEXTVAL, 
        'DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO', 
        CURRENT_USER(), 
        :START_TIME, 
        :EXECUTION_TIME, 
        'DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO Success'
    );

    RETURN 'Update completed successfully';
END;

 

-- Procedure Execution
CALL DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO_LOADS();


-- select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO
/**

,
        CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ),
        CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)


*/


select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX