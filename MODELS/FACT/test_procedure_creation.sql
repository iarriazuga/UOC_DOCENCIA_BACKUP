--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Caracteres para sustituir saltos de linea y tabulacion:

#T# = \t
#NL# = \r\n


CALL db_uoc_prod.dd_od.CREA_DIM(
    'SELECT 
        ENTIDAD_GESTORA as ENTITAT_GESTORA 
        , ID_EMISOR
        , ID_TRIBUTO
        , DESCRIPCION
        , SUFIJO
        , GESTION_DUDOSO_PAGO
        , DIAS_CADUCIDAD
        , SUFIJO_RAF
        , IND_MANTENER_FPAGO
    FROM db_uoc_prod.stg_cofros.cofros_tributos', --query genera DIM

    'DB_UOC_PROD.DD_OD.DIM_COFROS_TRIBUTS', --nom taula DIM
    
    ['ENTITAT_GESTORA', 'ID_EMISOR', 'ID_TRIBUTO'], --camps identificador unic
    
    [], --camps identificador unic NULLABLES
    
    'DB_UOC_PROD.DD_OD.STAGE_COFROS_EFECTES_PRODUCTES_POST', --nom taula POST
    
    'DIM_COFROS', --prefix
    
    0 --debug (1 true, 0 false)
);

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Caracteres para sustituir saltos de linea y tabulacion:

#T# = \t
#NL# = \r\n
CALL db_uoc_prod.dd_od.CREA_DIM(
    '
SELECT 

    dades_academiques.id_assignatura   
    , dades_academiques.id_semestre
    , dades_academiques.id_codi_recurs    
    , dades_academiques.DIM_ASSIGNATURA_KEY
    , dades_academiques.DIM_SEMESTRE_KEY
    , dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY
    , dades_academiques.ORIGEN_DADES_ACADEMIQUES 
    , count( dades_academiques.EVENT_CODI_RECURS )  as TIMES_USED
 

FROM  DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS dades_academiques
group by 1,2,3,4,5,6,7

', --query genera DIM
    'DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG2', --nom taula DIM
    ['id_assignatura', 'id_semestre', 'id_codi_recurs', 'DIM_ASSIGNATURA_KEY', 'DIM_SEMESTRE_KEY', 'DIM_RECURSOS_APRENENTATGE_KEY'], --camps identificador unic
    [], --camps identificador unic NULLABLES
    'DB_UOC_PROD.DD_OD.AS_TEST', --nom taula POST
    'DIM_COFROS', --prefix
    0 --debug (1 true, 0 false)
);





CALL db_uoc_prod.dd_od.CREA_DIM(
    '
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
        -- , events.DIM_SEMESTRE_KEY
        -- , events.DIM_ASSIGNATURA_KEY

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
        , events.FORMAT
        , events.SOURCE
        , events.URL

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
        , * 

from aux_temporary_table

    --ID_CODES:
    left join DB_UOC_PROD.DD_OD.DIM_ASSIGNATURA as asignatura 
        on  asignatura.DIM_ASSIGNATURA_KEY = aux_temporary_table.DIM_ASSIGNATURA_KEY

    left join DB_UOC_PROD.DD_OD.DIM_SEMESTRE as semestre 
        on semestre.DIM_SEMESTRE_KEY = aux_temporary_table.DIM_SEMESTRE_KEY

    left join DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE as recursos 
        on recursos.DIM_RECURSOS_APRENENTATGE_KEY  = aux_temporary_table.DIM_RECURSOS_APRENENTATGE_KEY

    left join  DB_UOC_PROD.DD_OD.DIM_PERSONA dim_persona  -- 1,242,113
        on dim_persona.dim_persona_key = personas_assignaturas.idp  -- 312,187 

', --query genera DIM
    'DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS', --nom taula DIM
    ['id_assignatura', 'id_semestre', 'id_codi_recurs', 'DIM_ASSIGNATURA_KEY', 'DIM_SEMESTRE_KEY', 'DIM_RECURSOS_APRENENTATGE_KEY'], --camps identificador unic
    [], --camps identificador unic NULLABLES
    'DB_UOC_PROD.DD_OD.AS_TEST', --nom taula POST
    'DIM_COFROS', --prefix
    0 --debug (1 true, 0 false)
);
