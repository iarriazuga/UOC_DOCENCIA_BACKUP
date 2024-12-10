
-- -- #################################################################################################
-- -- #################################################################################################
-- -- FACT_DADES_ACADEMIQUES_EVENTS
-- -- #################################################################################################
-- -- #################################################################################################
 

CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS2 (
    ID_ASSIGNATURA NUMBER(38, 0),
    ID_SEMESTRE NUMBER(38, 0),
    ID_CODI_RECURS NUMBER(38, 0),
    ID_PERSONA NUMBER(38, 0) COMMENT 'Identificador del persona.',


    DIM_PERSONA_KEY NUMBER(10,0) COMMENT 'Clau DIM_PERSONA_KEY.',
    DIM_ASSIGNATURA_KEY VARCHAR2(6),
    DIM_SEMESTRE_KEY NUMBER(38, 0),
    DIM_RECURSOS_APRENENTATGE_KEY VARCHAR2(15),
    ORIGEN_DADES_ACADEMIQUES VARCHAR2(5),
    CODI_RECURS NUMBER(38, 0),
    EVENT_CODI_RECURS NUMBER(38, 0),
    EVENT_TIME VARCHAR2(16777216),
    EVENT_DATE VARCHAR2(16777216),
    ACCIO VARCHAR2(16777216),
    NOM_ACTOR VARCHAR2(16777216),
    ACTOR_TIPUS VARCHAR2(16777216),
    usuari_dAcces VARCHAR2(16777216),
    id_sistema_usuari VARCHAR2(16777216),
    titol_assignatura VARCHAR2(16777216),
    id_curs_canvas VARCHAR2(16777216),
    id_sistema_curs VARCHAR2(16777216),
    ROL VARCHAR2(16777216),
    estat_membre VARCHAR2(16777216),
    titol_recurs VARCHAR2(16777216),
    enllac VARCHAR2(16777216),
    OBJECT_MEDIATYPE VARCHAR2(16777216),
    tipus_recurs VARCHAR2(16777216),
    format_recurs VARCHAR2(16777216),
    Origen_events VARCHAR2(6), -- Corregido: Espacio agregado entre el nombre de la columna y el tipo
    enllac_url VARCHAR2(16777216)

 
        
 

) AS 

with aux_temporary_table as (
    select 

        dades_academiques.DIM_PERSONA_KEY   
        , dades_academiques.DIM_ASSIGNATURA_KEY
        , dades_academiques.DIM_SEMESTRE_KEY
        , dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY    

        , dades_academiques.ORIGEN_DADES_ACADEMIQUES
        , dades_academiques.CODI_RECURS

        --REVIEW
        , events.CODI_RECURS as EVENT_CODI_RECURS
        , events.EVENT_TIME
        , events.EVENT_DATE
        , events.ACCIO
        , events.NOM_ACTOR
        , events.ACTOR_TIPUS
        , events.usuari_dAcces
        , events.id_sistema_usuari
        , events.titol_assignatura
        , events.id_curs_canvas
        , events.id_sistema_curs
        , events.ROL
        , events.estat_membre
        , events.titol_recurs
        , events.enllac
        , events.OBJECT_MEDIATYPE
        , events.tipus_recurs
        , events.format_recurs
        , events.Origen_events
        , events.enllac_url

    FROM  DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES dades_academiques -- 7,888,532

    left join DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED events   -- 4 ultimos anos : 8,741,384 vs 123,019 --> datos by semestre, asignatura, producto grouped
        on dades_academiques.DIM_ASSIGNATURA_KEY = events.DIM_ASSIGNATURA_KEY -- 114,821,250
        AND dades_academiques.DIM_SEMESTRE_KEY = events.DIM_SEMESTRE_KEY
        -- AND dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY = events.DIM_RECURSOS_APRENENTATGE_KEY   --      14_859_255
        AND dades_academiques.CODI_RECURS = events.CODI_RECURS -- confirmacion Francesc & Acoran 2024/12/03 :   15_720_775

) 
select 

        -- FK IDs:
        asignatura.id_assignatura
        , semestre.id_semestre
        , recursos.id_codi_recurs --review 
        , dim_persona.id_persona
        
        -- other_fields
        , aux_temporary_table.DIM_PERSONA_KEY   
        , aux_temporary_table.DIM_ASSIGNATURA_KEY
        , aux_temporary_table.DIM_SEMESTRE_KEY
        , aux_temporary_table.DIM_RECURSOS_APRENENTATGE_KEY    

        , aux_temporary_table.ORIGEN_DADES_ACADEMIQUES
        , aux_temporary_table.CODI_RECURS
        , aux_temporary_table.CODI_RECURS as EVENT_CODI_RECURS
        , aux_temporary_table.EVENT_TIME
        , aux_temporary_table.EVENT_DATE
        , aux_temporary_table.ACCIO
        , aux_temporary_table.NOM_ACTOR
        , aux_temporary_table.ACTOR_TIPUS
        , aux_temporary_table.usuari_dAcces
        , aux_temporary_table.id_sistema_usuari
        , aux_temporary_table.titol_assignatura
        , aux_temporary_table.id_curs_canvas
        , aux_temporary_table.id_sistema_curs
        , aux_temporary_table.ROL
        , aux_temporary_table.estat_membre
        , aux_temporary_table.titol_recurs
        , aux_temporary_table.enllac
        , aux_temporary_table.OBJECT_MEDIATYPE
        , aux_temporary_table.tipus_recurs
        , aux_temporary_table.format_recurs
        , aux_temporary_table.Origen_events
        , aux_temporary_table.enllac_url


from aux_temporary_table

    --ID_CODES:
    left join DB_UOC_PROD.DD_OD.DIM_ASSIGNATURA as asignatura 
        on  asignatura.DIM_ASSIGNATURA_KEY = aux_temporary_table.DIM_ASSIGNATURA_KEY

    left join DB_UOC_PROD.DD_OD.DIM_SEMESTRE as semestre 
        on semestre.DIM_SEMESTRE_KEY = aux_temporary_table.DIM_SEMESTRE_KEY

    left join DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE as recursos 
        on recursos.DIM_RECURSOS_APRENENTATGE_KEY  = aux_temporary_table.DIM_RECURSOS_APRENENTATGE_KEY

    left join  DB_UOC_PROD.DD_OD.DIM_PERSONA dim_persona  -- 1,242,113
        on dim_persona.dim_persona_key = aux_temporary_table.DIM_PERSONA_KEY  -- 312,187 
    
 