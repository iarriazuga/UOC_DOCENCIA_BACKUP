-- -- #################################################################################################
-- -- #################################################################################################
-- -- STAGE_POST_DADES_ACADEMIQUES_EVENTS_SIMPLIFIED 
-- -- #################################################################################################
-- -- #################################################################################################

CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG2 (

    ID_ASSIGNATURA NUMBER(38, 0) COMMENT 'Identificador de la assignatura.',
    ID_SEMESTRE NUMBER(38, 0) COMMENT 'Identificador del semestre.',
    ID_CODI_RECURS NUMBER(38, 0) COMMENT 'Identificador del recurs.',

    ID_PERSONA NUMBER(38, 0) COMMENT 'Identificador del persona.',
    DIM_PERSONA_KEY NUMBER(10,0) COMMENT 'Clau DIM_PERSONA_KEY.',
    
    DIM_ASSIGNATURA_KEY VARCHAR(6) COMMENT 'Clau assignatura.',
    DIM_SEMESTRE_KEY NUMBER(38, 0) COMMENT 'Clau semestre.',
    DIM_RECURSOS_APRENENTATGE_KEY VARCHAR(15) COMMENT 'Clau recursos d\'aprenentatge.',
    TIMES_USED NUMBER(18, 0) COMMENT 'Número de vegades utilitzat.'
) AS 

with auxiliar as ( 
SELECT 

    dades_academiques.id_assignatura   
    , dades_academiques.id_semestre
    , dades_academiques.id_codi_recurs    
    , dades_academiques.id_persona 

    , dades_academiques.DIM_PERSONA_KEY
    , dades_academiques.DIM_ASSIGNATURA_KEY
    , dades_academiques.DIM_SEMESTRE_KEY
    , dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY
    
    , dades_academiques.ORIGEN_DADES_ACADEMIQUES 
    
    , count( dades_academiques.EVENT_CODI_RECURS )  as TIMES_USED
 

FROM  DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS dades_academiques
group by 1,2,3,4,5,6,7,8,9

) 

select
    id_assignatura
    , id_semestre
    , id_codi_recurs
    , id_persona

    , DIM_PERSONA_KEY
    , DIM_ASSIGNATURA_KEY
    , DIM_SEMESTRE_KEY
    
    , DIM_RECURSOS_APRENENTATGE_KEY
    , coalesce(TIMES_USED , 0) as TIMES_USED

from auxiliar
 

 