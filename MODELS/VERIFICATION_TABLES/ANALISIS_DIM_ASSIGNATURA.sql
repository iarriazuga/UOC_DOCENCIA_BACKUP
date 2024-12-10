

-- -- #################################################################################################
-- -- #################################################################################################
-- -- ANALISIS_CALIPER_EVENTS
-- -- #################################################################################################
-- -- #################################################################################################
CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.ANALISIS_ASSIGNATURA_EVENTS AS

with aux as (

    select 
    DIM_ASSIGNATURA_KEY, 
    count(*) as num_events

    from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED   -- 12,224,872 vs 172,784 grouped
    group by 1 
 
)

,  codi_asignatura_valoration as (
    
    select *,
    case 
        when DIM_ASSIGNATURA_KEY in (select DIM_ASSIGNATURA_KEY from DB_UOC_PROD.DD_OD.DIM_ASSIGNATURA)  then 'ASIGNATURA'
    else 'ERROR' end as DIM_ASSIGNATURA_KEY_origen
    from aux  
)
 


select * 
from  codi_asignatura_valoration
-- where 1=1
-- AND DIM_ASSIGNATURA_KEY_origen = 'ERROR'