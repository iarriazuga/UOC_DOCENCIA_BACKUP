-- -- #################################################################################################
-- -- #################################################################################################
-- -- RECURSOS_APRENDIZATJE
-- -- #################################################################################################
-- -- #################################################################################################
CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS (
    CODI_RECURS VARCHAR(12),
    TITOL_RECURS VARCHAR(255),
    ORIGEN_RECURS VARCHAR(5),
    SOURCE_RECURS VARCHAR(9),
    VERSIO_CREACIO_ID NUMBER(12, 0),
    PRODUCTE_CREACIO_ID NUMBER(18, 5),
    PRODUCTE_ORIGEN_ID VARCHAR(255),
    URL_IDIOMA_RECURS VARCHAR(500),
    URL VARCHAR(500),
    DESCRIPCIO_TRAMESA_RECURS VARCHAR(255),
    DESCRIPCIO_SUPORT_RECURS VARCHAR(255),
    DESCRIPCIO_IDIOMA_RECURS VARCHAR(2295),
    DESCRIPCIO VARCHAR(255),
    IND_MATERIAL_PROPI VARCHAR(1),
    CODI_MIGRACIO VARCHAR(255),
    BAIXA VARCHAR(1),
    PARAULA_CLAU VARCHAR(100),
    CODI_RECURS_ORIGEN VARCHAR(50),
    NUM_CONTRACTE VARCHAR(50),
    DATA_TANCAMENT_REAL TIMESTAMP_NTZ(9),
    OBSERVACIONS VARCHAR(2000),
    MODUL_ORIGEN_ID VARCHAR(255),
    OBRA_ID VARCHAR(12)
);



CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS_LOADS() 
RETURNS VARCHAR(16777216) 
LANGUAGE SQL 
EXECUTE AS CALLER AS 
BEGIN
    -- Declaración de variables
    LET start_time TIMESTAMP_NTZ := CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ); 
    LET execution_time FLOAT;

    -- INSERT: Volcat de registres
    TRUNCATE TABLE DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS;


    INSERT INTO DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS (
        CODI_RECURS,
        TITOL_RECURS,
        ORIGEN_RECURS,
        SOURCE_RECURS,
        VERSIO_CREACIO_ID,
        PRODUCTE_CREACIO_ID,
        PRODUCTE_ORIGEN_ID,
        URL_IDIOMA_RECURS,
        URL,
        DESCRIPCIO_TRAMESA_RECURS,
        DESCRIPCIO_SUPORT_RECURS,
        DESCRIPCIO_IDIOMA_RECURS,
        DESCRIPCIO,
        IND_MATERIAL_PROPI,
        CODI_MIGRACIO,
        BAIXA,
        PARAULA_CLAU,
        CODI_RECURS_ORIGEN,
        NUM_CONTRACTE,
        DATA_TANCAMENT_REAL,
        OBSERVACIONS,
        MODUL_ORIGEN_ID,
        OBRA_ID
    )
    WITH productos_aux AS (
        SELECT                               
            autors_producte.id AS CODI_RECURS,                     
            autors_producte.titol AS TITOL_RECURS,                
            'PROPI' AS ORIGEN_RECURS,
            'COCO_PROD' AS SOURCE_RECURS,
            autors_producte.versio_creacio_id,                    
            autors_producte.id AS PRODUCTE_CREACIO_ID,           
            autors_producte.producte_origen_id,                 
            autors_producte.url AS URL_IDIOMA_RECURS,            
            autors_producte.url AS URL,                         
            autors_tipus_tramesa_i18n.descripcio AS DESCRIPCIO_TRAMESA_RECURS,
            autors_suport_producte_i18n.descripcio AS DESCRIPCIO_SUPORT_RECURS,
            INITCAP(autors_idioma_producte_i18n.descripcio) AS DESCRIPCIO_IDIOMA_RECURS,
            autors_tipus_tramesa_i18n.descripcio AS DESCRIPCIO,
            autors_producte.ind_material_propi,                  
            autors_producte.codi_migracio,                       
            autors_producte.baixa,                               
            autors_producte.paraula_clau,                        
            autors_producte.codi_recurs_origen,                  
            autors_producte.num_contracte,                       
            autors_producte.data_tancament_real,                 
            'NA' AS OBSERVACIONS,                                
            'NA' AS MODUL_ORIGEN_ID,                            
            'NA' AS OBRA_ID                                     
        FROM db_uoc_prod.stg_dadesra.autors_producte  
        LEFT JOIN db_uoc_prod.stg_dadesra.autors_suport_producte_i18n  
            ON autors_producte.fk_suport_producte_suport_id = autors_suport_producte_i18n.fk_suport_producte_suport_id
            AND autors_suport_producte_i18n.idioma = 'CAT'
        LEFT JOIN db_uoc_prod.stg_dadesra.autors_tipus_tramesa_i18n
            ON autors_producte.fk_tipus_tramesa_tipus_tra__id = autors_tipus_tramesa_i18n.fk_tipus_tramesa_tipus_tra__id
            AND autors_tipus_tramesa_i18n.idioma = 'CAT'
        LEFT JOIN db_uoc_prod.stg_dadesra.autors_idioma_producte_i18n
            ON autors_producte.fk_idioma_producte_idioma_id = autors_idioma_producte_i18n.fk_idioma_producte_idioma___id
            AND autors_idioma_producte_i18n.idioma = 'CAT'
    ),
    modulos_aux AS (
        SELECT 
            COALESCE(autors_modul.ID, autors_producte.CODI_RECURS) AS CODI_RECURS,
            COALESCE(autors_modul.DESCRIPCIO, autors_producte.TITOL_RECURS) AS TITOL_RECURS,
            'PROPI' AS ORIGEN_RECURS,
            CASE 
                WHEN autors_modul.ID IS NOT NULL THEN 'COCO_MOD' 
                ELSE 'COCO_PROD' 
            END AS SOURCE_RECURS,
            COALESCE(autors_modul.versio_creacio_id, autors_producte.versio_creacio_id) AS VERSIO_CREACIO_ID,
            autors_modul.PRODUCTE_CREACIO_ID,
            autors_producte.producte_origen_id,
            autors_producte.url AS URL_IDIOMA_RECURS,
            autors_producte.url AS URL,
            autors_producte.DESCRIPCIO_TRAMESA_RECURS,
            autors_producte.DESCRIPCIO_SUPORT_RECURS,
            INITCAP(autors_producte.DESCRIPCIO_IDIOMA_RECURS) AS DESCRIPCIO_IDIOMA_RECURS,
            autors_producte.DESCRIPCIO,
            autors_producte.ind_material_propi,
            COALESCE(autors_modul.CODI_MIGRACIO, autors_producte.codi_migracio) AS CODI_MIGRACIO,
            autors_producte.baixa,
            autors_producte.paraula_clau,
            autors_producte.codi_recurs_origen,
            autors_producte.num_contracte,
            autors_producte.data_tancament_real,
            autors_modul.OBSERVACIONS,
            autors_modul.MODUL_ORIGEN_ID,
            autors_modul.OBRA_ID
        FROM db_uoc_prod.stg_dadesra.autors_modul autors_modul  
        LEFT JOIN productos_aux autors_producte 
            ON autors_producte.CODI_RECURS = autors_modul.PRODUCTE_CREACIO_ID
    )
    SELECT * FROM modulos_aux
    UNION ALL
    SELECT * FROM productos_aux;
 


    -- LOGS
    EXECUTION_TIME := DATEDIFF(MILLISECOND, START_TIME, CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ));
    INSERT INTO DB_UOC_PROD.DD_OD.PROCEDURES_LOG (
        ID_LOG, PROCEDURE_NAME, EXECUTED_BY, EXECUTION_DATE, EXECUTION_TIME, REMARKS
    )
    VALUES (
        DB_UOC_PROD.DD_OD.SEQUENCIA_ID_LOG.NEXTVAL, 
        'DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS', 
        CURRENT_USER(), 
        :START_TIME, 
        :EXECUTION_TIME, 
        'DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS Success'
    );

    RETURN 'Update completed successfully';
END;

 

-- Procedure Execution
CALL DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO_LOADS();




