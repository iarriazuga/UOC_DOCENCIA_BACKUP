
-- -- #################################################################################################
-- -- #################################################################################################
-- -- RECURSOS_APRENDIZATJE
-- -- #################################################################################################
-- -- #################################################################################################


    -- ID_DIM_D NUMBER(20, 0) IDENTITY(1, 1), -- Auto-increment without sequence
    -- ID_DIM_D INT AUTOINCREMENT PRIMARY KEY,
 

CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE AS -- DDP_DOCENCIA  vs  DDP_DADESRA 
With dim_coco_productes_moduls AS ( 
    
    SELECT
        0 as ID_CODI_RECURS      -- se genera con sequence 
        , 'COCO'|| ' - ' || CODI_RECURS AS DIM_RECURSOS_APRENENTATGE_KEY  -- no podemos poner origen_base_dades pq elementos NIU no distinge entre COCO_PROD y COCO_MOD        
        , CODI_RECURS
        , TITOL_RECURS
        , ORIGEN_RECURS
        , '' AS TIPUS_RECURS -- added: TFG, Exams, Articles (100+ elements)
        , origen_base_dades

        -- Added: empty in fields FROM DIMAX
        , '' AS LLICENCIA_LPC
        , '' AS LLICENCIA_LGC
        , '' AS LLICENCIA_ALTRES
        , '' AS LLICENCIA_BIBLIOTECA


        , BAIXA   -- BAIXA aprobado con xabi : no se visualiza ( similar a ocultar) para no romper integridad no se muestra  
        
        -- id_comentario: 6 v_recurs.Idioma_Recurs de dimax i autors_suport_idioma_i18n de COCO en Idioma_Recurs y por lo tanto desparece el suport_idioma de coco
        , descripcio_idioma_recurs  -- Options dimax: en / es / ca

        , DESCRIPCIO_SUPORT_RECURS AS FORMAT_RECURS  -- added: comentario francesc id_comentario: 5

        -- not filled in DIMAX 
        , null AS DATA_INICI_RECURS
        , null AS DATA_CADUCITAT_RECURS


        , '' AS CERCABLE_RECURS -- Options dimax: S / N
        , '' AS INDICADOR_PUBLIC_RECURS -- Options dimax: S / N
        , '' AS PUBLICAT_A_RECURS -- Options dimax: option of magazine of publication
        
        -- dades FROM publication: magazine, journal, newspaper, etc
        , '' AS ISBN_ISSN_RECURS
        , 0  AS PAGINA_INICI_RECURS
        , 0  AS PAGINA_FINAL_RECURS
        , '' AS BASE_DADES_RECURS
        , '' AS ELLIBRE_RECURS
        , '' AS URL_CAT_RECURS
        , '' AS URL_CAS_RECURS
        , '' AS URL_ANG_RECURS
        , 'ND' AS TIPUS_GESTIO_RECURS

        , '' AS DESPESA_VARIABLE_RECURS
        , null AS UPDATE_DATE
        , DATA_TANCAMENT_REAL AS CREATION_DATE -- id_comentario: 8 v_recurs.data_creacio de dimax i data_tancament_real de COCO en creation_date y por lo tanto desparece el data_tancament_real de coco
        , PRODUCTE_CREACIO_ID

        -- not exist in DIMAX
        , DESCRIPCIO_TRAMESA_RECURS --- error: CLASIFIED AS A TIMESTAMP 
        , NUM_CONTRACTE
        , OBSERVACIONS
        , MODUL_ORIGEN_ID
        , VERSIO_CREACIO_ID
        , OBRA_ID
        , CODI_MIGRACIO
        , URL_IDIOMA_RECURS as URL_RECURS_PROPI

 
    FROM DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS
                   
), 

-- CREATE TABLE DIMAX
dimax AS (

    SELECT
    
        0 as ID_CODI_RECURS      -- se genera con sequence 
        , 'DIMAX'|| ' - '|| CODI_RECURS AS DIM_RECURSOS_APRENENTATGE_KEY
        , CODI_RECURS
        , TITOL_RECURS
        , ORIGEN_RECURS
        , TIPUS_RECURS
        , 'DIMAX' AS origen_base_dades

        , LLICENCIA_LPC
        , LLICENCIA_LGC
        , LLICENCIA_ALTRES
        , LLICENCIA_BIBLIOTECA

        , WAIT_RECURS as BAIXA -- BAIXA aprobado con xabi : no se visualiza ( similar a ocultar) para no romper integridad no se muestra  

        , dimax.idioma_recurs AS DESCRIPCIO_IDIOMA_RECURS
        , FORMAT_RECURS

        , DATA_INICI_RECURS
        , DATA_CADUCITAT_RECURS

        , CERCABLE_RECURS
        , INDICADOR_PUBLIC_RECURS

        , PUBLICAT_A_RECURS
        , ISBN_ISSN_RECURS
        , PAGINA_INICI_RECURS
        , PAGINA_FINAL_RECURS
        , BASE_DADES_RECURS
        , ELLIBRE_RECURS


        , URL_CAT_RECURS
        , URL_CAS_RECURS
        , URL_ANG_RECURS

        // added; comentarios francesc 
        , iff(
            LLICENCIA_lpc = 'S','DRETS'
            ,iff( 
                LLICENCIA_lgc = 'S','DRETS'
                ,iff(
                    LLICENCIA_altres = 'S'
                    ,'DRETS'
                    ,iff(LLICENCIA_biblioteca = 'S','SUBS', '')
                    )
                )
        ) AS TIPUS_GESTIO_RECURS --ND 
        
        , DESPESA_VARIABLE_RECURS
        , CREATION_DATE  
        , UPDATE_DATE
        , NULL AS PRODUCTE_CREACIO_ID

        -- fields of coco : publicat al aula 
        , NULL AS DESCRIPCIO_TRAMESA_RECURS -- CHANGES: 
        , '' AS NUM_CONTRACTE
        , '' AS OBSERVACIONS
        , '' AS MODUL_ORIGEN_ID
        , 0 AS VERSIO_CREACIO_ID
        , '' AS OBRA_ID
        , '' AS CODI_MIGRACIO
        , '' AS URL_RECURS_PROPI
 

    FROM db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax  dimax

 
) 


 
SELECT * FROM dim_coco_productes_moduls

union all 
 
SELECT  * FROM dimax; 


--   select  distinct  origen_base_dades,  DESCRIPCIO_IDIOMA_RECURS 
--  from DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE  ;