-- 2024/12/04
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- FACT_DADES_ACADEMIQUES_EVENTS: 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT 

    ID_ASSIGNATURA
    , ID_SEMESTRE
    , ID_CODI_RECURS
    , ID_PERSONA 
    , DIM_PERSONA_KEY
    , DIM_ASSIGNATURA_KEY
    , DIM_SEMESTRE_KEY
    , DIM_RECURSOS_APRENENTATGE_KEY
    -- 
    , SOURCE_DADES_ACADEMIQUES as ORIGEN_DADES_ACADEMIQUES -- dimax / coco 
    , CODI_RECURS -- valid 
    , EVENT_CODI_RECURS

-- mireia
    , EVENT_TIME --esdeveniment_dia
    , EVENT_DATE
    
    , ACTION as accio
    , ACTOR_NAME as nom_actor
    , ACTOR_TYPE as actor_tipus
    , USERLOGIN as usuari_dAcces --> francesc 
    , USER_SIS_ID as id_sistema_usuari
    , GROUP_NAME as titol_assignatura
    -- 
    , CANVASCOURSEID as id_curs_canvas
    , SISCOURSEID as id_sistema_curs
    
    , ROL 
    , MEMBERSHIP_STATUS as estat_membre
    , OBJECT_NAME as titol_recurs
    , OBJECT_ID as enllac -- ç
    , OBJECT_MEDIATYPE  -- revisar mirei 
    , OBJECT_TYPE as tipus_recurs
    , FORMAT as format_recurs
    , SOURCE as Origen_events  -- esdeveniments mireia 
    , URL as enllac_url -- ç

from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS ; 
select * from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS limit 100; 



--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- DIM_RECURSOS_APRENENTATGE: 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SELECT 

    ID_CODI_RECURS
    , DIM_RECURSOS_APRENENTATGE_KEY
    , CODI_RECURS
    , TITOL_RECURS
    , ORIGEN_RECURS -- propi / dimax 
    , TIPUS_RECURS 

    , SOURCE_RECURS as origen_base_dades -- coco_mod , coco_prod, dimax
    , LLICENCIA_LPC
    , LLICENCIA_LGC
    , LLICENCIA_ALTRES
    , LLICENCIA_BIBLIOTECA
    , BAIXA
    , DESCRIPCIO_IDIOMA_RECURS
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
    , TIPUS_GESTIO_RECURS
    , DESPESA_VARIABLE_RECURS
    -- revisar 
    , UPDATE_DATE 
    , CREATION_DATE

    
    , PRODUCTE_CREACIO_ID
    , DESCRIPCIO_TRAMESA_RECURS
    , NUM_CONTRACTE
    , OBSERVACIONS
    , MODUL_ORIGEN_ID
    , VERSIO_CREACIO_ID
    , OBRA_ID
    , CODI_MIGRACIO
    , URL_RECURS_PROPI

From DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE;

select * From DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE limit 100;
-- 
/***

validez de la asignatura --> logica de fechas --> sino victor en options 


acabar de validar que todos los datos que tienen coherencia 

--> poner un -1 para 6k que no cruzan : 



*/