

-- -- #################################################################################################
-- -- #################################################################################################
-- -- ANALISIS_CALIPER_EVENTS
-- -- #################################################################################################
-- -- #################################################################################################
CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.ANALISIS_RESOURCES_CALIPER_EVENTS AS

with aux as (

select 
-- DIM_ASSIGNATURA_KEY, 
-- DIM_SEMESTRE_KEY, 
-- DIM_RECURSOS_APRENENTATGE_KEY, 
CODI_RECURS,
upper(trim(source)) as source,
count(*) as num_events

from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED   -- 12,224,872 vs 172,784 grouped
group by 1,2-- ,3 -- ,4,5

/*
select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED limit 100 
select source_event, count(*) from aux group by 1 order by 2 desc

    SOURCE_EVENT	COUNT(*) 
    NIU	            12_224_872
    null	        41_042
    DIMAX	        27_288
    COCO	        19_027

*/
)

,  codi_recurs_valoration as (
    
    select distinct
    CODI_RECURS,
        -- Origen_events calculation
        case 
            when Origen_events = 'DIMAX' or Origen_events = 'dimax' then 'DIMAX'
            when Origen_events = 'COCO' or Origen_events = 'coco' then 'COCO'

            WHEN TRY_CAST(CODI_RECURS AS INT) IS NULL THEN 'INV'
            
            -- Both tables: ( no null resources)
            when 
                TRY_CAST(CODI_RECURS AS INT) in (select codi_recurs from DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS)  
                AND 
                TRY_CAST(CODI_RECURS AS INT) in (select codi_recurs from db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax)  
            then 'BOTH'  --- rewrite after 
            -- Dimax only: 
            when TRY_CAST(CODI_RECURS AS INT) in (select codi_recurs from db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax)  then 'DIMAX'
            -- Coco only:
            when TRY_CAST(CODI_RECURS AS INT) in (select codi_recurs from DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS)   then 'COCO'
        else 'ERROR' end as SOURCE2, 
    from aux  
)

-- select codi_recurs_origen , count(*) from codi_recurs_valoration group by 1 order by 2 desc


/*

select codi_recurs_origen , count(*) from codi_recurs_valoration group by 1 order by 2 desc

CODI_RECURS_ORIGEN	COUNT(*)
DIMAX	            22943
COCO	            18399
BOTH	            3515 -- listar y presentar a francesc 
ERROR	            6
    * not fount in base tables: 
        db_uoc_prod.stg_dadesra.autors_producte  -- coco_prod
        db_uoc_prod.stg_dadesra.autors_modul   -- coco_mod
        db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax  -- dimax
        db_uoc_prod.stg_dadesra.dimax_v_recurs -- id_recurs --> origen tables 
    
    -- AND codi_recurs_origen = 'ERROR' 
        '305213',
        '302376',
        '296716',
        '305233',
        '302378',
        '296708'

*/

select *
from codi_recurs_valoration 

where 1=1
-- AND codi_recurs_origen = 'ERROR'
-- AND codi_recurs_origen = 'BOTH'
-- group by 1,2 
-- order by 1 desc



