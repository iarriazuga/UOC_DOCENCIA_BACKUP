-- -- #################################################################################################
-- -- #################################################################################################
-- -- STAGE_DADES_ACADEMIQUES_COCO
-- -- #################################################################################################
-- -- #################################################################################################
CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO (
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

    INSERT INTO DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO(
        DIM_ASSIGNATURA_KEY,
        DIM_SEMESTRE_KEY,
        DIM_RECURSOS_APRENENTATGE_KEY,
        CODI_RECURS, 
        CREATION_DATE,
        UPDATE_DATE
    )
    WITH cross_semestre_asignatura AS (
        SELECT DISTINCT
            semestre.DIM_SEMESTRE_KEY,
            asignatura.codi_final AS DIM_ASSIGNATURA_KEY
        FROM DB_UOC_PROD.DD_OD.dim_semestre semestre
        CROSS JOIN db_uoc_prod.stg_dadesra.autors_element_formacio asignatura
        WHERE semestre.DIM_SEMESTRE_KEY IS NOT NULL
        AND asignatura.codi_final IS NOT NULL
    ),
    semestres_informados AS (
        SELECT DISTINCT
            semestre.CODI_EXTERN AS DIM_SEMESTRE_KEY,
            LEFT(asignatura.CODI_FINAL, 6) AS DIM_ASSIGNATURA_KEY,
            coco_products.codi_recurs AS CODI_RECURS,
            coco_products.titol_recurs AS TITOL_RESOURCE
        FROM db_uoc_prod.stg_dadesra.autors_productes_versions productos_plan_publicacion
        INNER JOIN Db_uoc_prod.stg_dadesra.autors_versio plan_publicacion
            ON plan_publicacion.id = productos_plan_publicacion.versio_id
        INNER JOIN Db_uoc_prod.stg_dadesra.autors_element_formacio asignatura
            ON asignatura.id = plan_publicacion.fk_element_formacio_element_id
        INNER JOIN db_uoc_prod.stg_dadesra.autors_periode semestre
            ON semestre.id = plan_publicacion.FK_PERIODE_PERIODE_ID
        INNER JOIN DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_COCO_PRODUCT_MODULS coco_products
            ON coco_products.codi_recurs = productos_plan_publicacion.PRODUCTE_ID
    ),
    cross_semestres_informados AS (
        SELECT
            cross_semestre_asignatura.DIM_ASSIGNATURA_KEY,
            cross_semestre_asignatura.DIM_SEMESTRE_KEY,
            semestres_informados.CODI_RECURS,
            semestres_informados.TITOL_RESOURCE
        FROM cross_semestre_asignatura
        LEFT JOIN semestres_informados
            ON cross_semestre_asignatura.DIM_ASSIGNATURA_KEY = semestres_informados.DIM_ASSIGNATURA_KEY
        AND cross_semestre_asignatura.DIM_SEMESTRE_KEY = semestres_informados.DIM_SEMESTRE_KEY
    ),
    informed_semesters AS (
        SELECT DISTINCT
            DIM_ASSIGNATURA_KEY,
            DIM_SEMESTRE_KEY AS informed_DIM_SEMESTRE_KEY,
            CODI_RECURS,
            TITOL_RESOURCE
        FROM cross_semestres_informados
        WHERE TITOL_RESOURCE IS NOT NULL
    ),
    ultimo_semestre_informado AS (
        SELECT
            csi.DIM_ASSIGNATURA_KEY AS DIM_ASSIGNATURA_KEY,
            csi.DIM_SEMESTRE_KEY AS DIM_SEMESTRE_KEY,
            csi.CODI_RECURS AS CODI_RECURS,
            csi.TITOL_RESOURCE AS TITOL_RESOURCE,
            CASE 
                WHEN csi.TITOL_RESOURCE IS NOT NULL THEN NULL
                ELSE (
                    SELECT MAX(is2.informed_DIM_SEMESTRE_KEY)
                    FROM informed_semesters is2
                    WHERE is2.DIM_ASSIGNATURA_KEY = csi.DIM_ASSIGNATURA_KEY
                    AND is2.informed_DIM_SEMESTRE_KEY <= csi.DIM_SEMESTRE_KEY
                )
            END AS last_informed_semestre
        FROM cross_semestres_informados csi
    ),
    propagacion_ultimo_semestre_informado AS (
        SELECT DISTINCT
            swr.DIM_ASSIGNATURA_KEY,
            swr.DIM_SEMESTRE_KEY,
            COALESCE(swr.CODI_RECURS, inf.CODI_RECURS) AS CODI_RECURS
        FROM ultimo_semestre_informado swr
        LEFT JOIN informed_semesters inf
            ON swr.DIM_ASSIGNATURA_KEY = inf.DIM_ASSIGNATURA_KEY
        AND swr.last_informed_semestre = inf.informed_DIM_SEMESTRE_KEY
    )
    SELECT
        propagacion_ultimo_semestre_informado.DIM_ASSIGNATURA_KEY,
        propagacion_ultimo_semestre_informado.DIM_SEMESTRE_KEY,
        'COCO - ' || propagacion_ultimo_semestre_informado.CODI_RECURS AS DIM_RECURSOS_APRENENTATGE_KEY,
        propagacion_ultimo_semestre_informado.CODI_RECURS,
        CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ),
        CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)

    FROM propagacion_ultimo_semestre_informado
    WHERE propagacion_ultimo_semestre_informado.CODI_RECURS IS NOT NULL;


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