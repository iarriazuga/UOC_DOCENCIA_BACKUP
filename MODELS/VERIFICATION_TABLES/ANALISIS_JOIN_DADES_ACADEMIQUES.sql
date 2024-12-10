-- CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS AS 

with temp_table_dim_key as (
    select 
        dades_academiques.DIM_ASSIGNATURA_KEY || dades_academiques.DIM_SEMESTRE_KEY || dades_academiques.CODI_RECURS as concat_key
        , dades_academiques.DIM_ASSIGNATURA_KEY
        , dades_academiques.DIM_SEMESTRE_KEY
        , dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY    
        -- , dades_academiques. PLAN_ESTUDIOS_BASE
        , dades_academiques.ORIGEN_DADES_ACADEMIQUES
        , dades_academiques.CODI_RECURS


        
        --REVIEW
        , events.CODI_RECURS as EVENT_CODI_RECURS
        -- , events.DIM_SEMESTRE_KEY
        -- , events.DIM_ASSIGNATURA_KEY
        , dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY  as events_key_rec
 
 
    FROM  DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES dades_academiques -- 7,888,532

    left join DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED events   -- 4 ultimos anos : 8,741,384 vs 123,019 --> datos by semestre, asignatura, producto grouped
        on dades_academiques.DIM_ASSIGNATURA_KEY = events.DIM_ASSIGNATURA_KEY -- 114,821,250
        AND dades_academiques.DIM_SEMESTRE_KEY = events.DIM_SEMESTRE_KEY
        AND dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY = events.DIM_RECURSOS_APRENENTATGE_KEY -- 43k  -- agrupar por 
        -- AND dades_academiques.CODI_RECURS = events.CODI_RECURS -- 43k  -- agrupar por 

    where 1=1 
    AND EVENT_CODI_RECURS is not null

) 

 

select * 

 
from temp_table_dim_key --- 12_351_002 vs not null  -- 9,813,254 -- mucho mas cercano 

where 1=1 
and EVENT_CODI_RECURS is not null
-- AND concat_key  not in ( select concat_key from temp_table_dim_key )





-- 
-- select count(*) from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED -- 12_351_002










select codi_recurs,  count(*) 
from DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE -- estan todos 
-- from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO -- no aparecen
-- from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX --- no aparecen 
where codi_recurs in ( 

'294864',
'225145',
'294255',
'261666',
'249559',
'144806',
'186555',
'247935',
'221399',
'214717',
'233814',
'249730',
'244609',
'188220',
'244611',
'250928',
'259387',
'247551',
'277255',
'218275',
'141193',
'171873',
'237360',
'218258',
'224895',
'275360',
'177246',
'249103',
'277171',
'258047',
'262444',
'103318',
'260024',
'141757',
'246480'

)

group by 1 









